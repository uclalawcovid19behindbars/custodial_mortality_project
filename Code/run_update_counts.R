# -------------------------------------------------------------------
# run_update_counts.R
# Purpose: Build combined state + federal prison death and population data,
#          and calculate updated crude mortality rates for 2019–2024.
#
# Workflow:
#   1. Load utilities and reference state frame
#   2. Load CMP summary and state-level deaths
#   3. Load and aggregate BOP deaths (all + by state)
#   4. Combine state + BOP deaths
#   5. Load Vera population data + BOP population data
#   6. Combine populations
#   7. Merge deaths + populations → crude rates
#   8. Reshape to wide (dynamic by year)
#   9. Reconcile with original published counts (2019–2021)
#  10. Build state-year coverage (states vs BoP separately)
#  11. Save outputs
#
# Logging:
#   - QA log (summary, row counts): Data/Output/run_update_counts_QA.txt
#   - Debug log (warnings/messages): Data/Output/run_update_counts_debug.txt
# -------------------------------------------------------------------

library(reshape2)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
source("Code/general_utilities.R")

# -------------------------------------------------------------------
# Setup logging
log_dir <- "Data/Logs"
if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)

qa_log    <- file.path(log_dir, "run_update_counts_QA.txt")
debug_log <- file.path(log_dir, "run_update_counts_debug.txt")

qa_con    <- file(qa_log, open = "wt")
debug_con <- file(debug_log, open = "wt")

sink(qa_con, type = "output", split = TRUE)
sink(debug_con, type = "message")

# Ensure sinks are always closed, even if error occurs
on.exit({
    sink(type = "message")
    sink(type = "output")
    close(qa_con)
    close(debug_con)
}, add = TRUE)

cat("============================================================\n")
cat(" UCLA CMP Mortality Update Log\n")
cat(" Run started at:", Sys.time(), "\n")
cat("============================================================\n\n")

# -------------------------------------------------------------------
# Step 1. State frame
cat("Step 1: Building state frame...\n")
state.frame <- state.name |>
    as.data.frame() |>
    mutate(State.Abb = state.abb) |>
    plyr::rename(c("." = "State"))
cat("✓ State frame ready (rows:", nrow(state.frame), ")\n\n")

# -------------------------------------------------------------------
# Step 2. CMP summary + state deaths
cat("Step 2: Loading CMP data...\n")
summary.data <- summarize_CMP_data()
state.deaths.data <- read_CMP_deaths(all.agencies = TRUE) |>
    mutate(Agency = State, Deaths = Total.Deaths) |>
    dplyr::select(Agency, Year, Deaths)
cat("✓ State deaths loaded (rows:", nrow(state.deaths.data), ")\n\n")

# -------------------------------------------------------------------
# Step 3. BOP deaths
cat("Step 3: Loading and aggregating BOP deaths...\n")
bop.deaths.data <- read_csv("Data/Other/Deaths/Federal/BOP-Individual.csv")
bop.all.locations.deaths <- bop.deaths.data |>
    group_by(Year) |>
    summarise(Deaths = n(), .groups = "drop") |>
    mutate(Agency = "BoP - All Locations")

bop.state.locations.deaths <- bop.deaths.data |>
    group_by(State, Year) |>
    summarise(Deaths = n(), .groups = "drop") |>
    mutate(Agency = str_c("BoP - ", State)) |>
    dplyr::select(Agency, Year, Deaths)

bop.combined.deaths <- plyr::rbind.fill(bop.all.locations.deaths,
                                        bop.state.locations.deaths) |>
    tidyr::complete(Year = min(Year):max(Year), Agency, fill = list(Deaths = 0))
cat("✓ BOP deaths aggregated (rows:", nrow(bop.combined.deaths), ")\n\n")

# -------------------------------------------------------------------
# Step 4. Combine deaths
combined.death.data <- plyr::rbind.fill(state.deaths.data,
                                        bop.combined.deaths) |>
    filter(!is.na(Deaths), !is.na(Year))
cat("✓ Combined death data ready (rows:", nrow(combined.death.data), ")\n\n")

# -------------------------------------------------------------------
# Step 5. Vera population data
cat("Step 5: Loading Vera population data...\n")
vera_loaded <- TRUE
aggregate.population.data <- tryCatch({
    df <- interpolate_vera_dem_updated()
    
    df <- df |>
        filter(str_detect(as.character(Date), "06-30") |
                   str_detect(as.character(Date), "2024-03-31")) |>
        mutate(State = ifelse(str_detect(State, "BOP"),
                              "BoP - All Locations", State),
               Agency = State) |>
        ungroup() |> 
        dplyr::select(Agency, Year, Population) |>
        filter(!is.na(Agency), !is.na(Population))
    
    expected_years <- 2019:2024
    missing_years <- setdiff(expected_years, unique(df$Year))
    if (length(missing_years) > 0) {
        cat("⚠ Vera population missing for years:",
            paste(missing_years, collapse = ", "), "\n")
    }
    
    df
}, error = function(e) {
    cat("✗ ERROR in Step 5: Could not load Vera population data\n")
    cat("  Details:", conditionMessage(e), "\n")
    vera_loaded <<- FALSE
    return(tibble(Agency = character(),
                  Year = integer(),
                  Population = numeric()))
})

cat("✓ Vera population loaded (rows:", nrow(aggregate.population.data), ")\n\n")

# -------------------------------------------------------------------
# Step 6. BOP population (by state)
cat("Step 6: Loading BOP population data...\n")
state.bop.population <- read.csv("Data/Raw/Population/BOP_state_year_count.csv") |>
    left_join(state.frame, by = c("state" = "State.Abb")) |>
    magrittr::set_colnames(c("State.Abb", "Date", "Year", "Population", "State")) |>
    mutate(Agency = str_c("BoP - ", State)) |>
    dplyr::select(Agency, Year, Population) |>
    filter(!is.na(Population), !is.na(Agency))
cat("✓ BOP population loaded (rows:", nrow(state.bop.population), ")\n\n")

# -------------------------------------------------------------------
# Step 7. Combine populations
combined.population.data <- plyr::rbind.fill(aggregate.population.data,
                                             state.bop.population)
cat("✓ Combined population data ready (rows:", nrow(combined.population.data), ")\n\n")

# -------------------------------------------------------------------
# Step 8. Combine deaths + populations
cat("Step 8: Combining deaths and population data...\n")
combined.data <- combined.population.data |>
    left_join(combined.death.data, by = c("Agency", "Year")) |>
    mutate(Crude.Rate = ifelse(!is.na(Population) & Population > 0,
                               (Deaths / Population) * 10000, NA_real_))
cat("✓ Combined dataset built (rows:", nrow(combined.data), 
    ") — includes Deaths, Population, and Crude.Rate (long format)\n\n")

# -------------------------------------------------------------------
# Step 9. Reshape to wide, dynamic by year
cat("Step 9: Reshaping to wide format...\n")
combined.data <- combined.data |>
    pivot_longer(cols = c(Deaths, Population, Crude.Rate),
                 names_to = "Variable", values_to = "Value") |>
    mutate(Variable.Name = str_c(Variable, ".", Year)) |>
    select(Agency, Variable.Name, Value) |>
    pivot_wider(names_from = Variable.Name, values_from = Value)

cat("✓ Data reshaped to wide format — variables now appear as Deaths.YYYY, Population.YYYY, Crude.Rate.YYYY\n\n")

# -------------------------------------------------------------------
# Step 10. Reconcile with original counts
cat("Step 10: Reconciling with original published counts...\n")
original.counts <- read_csv(
    "https://raw.githubusercontent.com/uclalawcovid19behindbars/custodial_mortality_project/refs/heads/main/Data/Output/prison_agency_counts.csv"
) |>
    mutate(O.Deaths.2019 = Deaths.2019,
           O.Deaths.2020 = Deaths.2020,
           O.Deaths.2021 = Deaths.2021) |>
    dplyr::select(Agency, O.Deaths.2019, O.Deaths.2020, O.Deaths.2021)

new.joined.counts <- combined.data %>%
    left_join(original.counts, by = "Agency") %>%
    mutate(
        Deaths.2019 = coalesce(Deaths.2019, O.Deaths.2019),
        Deaths.2020 = coalesce(Deaths.2020, O.Deaths.2020),
        Deaths.2021 = coalesce(Deaths.2021, O.Deaths.2021)
    )

for (yr in 2019:2024) {
    death_col <- paste0("Deaths.", yr)
    pop_col   <- paste0("Population.", yr)
    rate_col  <- paste0("Crude.Rate.", yr)
    
    if (death_col %in% names(new.joined.counts) &&
        pop_col %in% names(new.joined.counts)) {
        new.joined.counts[[rate_col]] <- 
            (new.joined.counts[[death_col]] / new.joined.counts[[pop_col]]) * 10000
    }
}

cat("✓ Reconciled counts with original data (rows:", nrow(new.joined.counts), ")\n\n")

# -------------------------------------------------------------------
# Step 10b. Standardized Mortality Rates (SMR) placeholder

# Requirements for SMR:
#   - Age-specific death counts (by Agency x Year x AgeGroup)
#   - Age-specific population denominators (by Agency x Year x AgeGroup)
#   - A reference "standard population" distribution (AgeGroup, StdPop)

# Example structure (Michael can replace once data are ready):
# deaths_age <- data.frame(Agency, Year, AgeGroup, Deaths)
# pop_age    <- data.frame(Agency, Year, AgeGroup, Population)
# std_pop    <- data.frame(AgeGroup, StdPop)

# SMR calculation steps:
# 1. Merge deaths_age + pop_age → calculate age-specific rates
# 2. Multiply each rate by StdPop → expected deaths
# 3. Sum expected deaths / total StdPop → standardized rate

calculate_smr <- function(deaths_age, pop_age, std_pop) {
    merged <- deaths_age %>%
        left_join(pop_age, by = c("Agency","Year","AgeGroup")) %>%
        left_join(std_pop, by = "AgeGroup") %>%
        mutate(Rate = ifelse(Population > 0, Deaths / Population, NA_real_),
               ExpDeaths = Rate * StdPop)
    
    smr <- merged %>%
        group_by(Agency, Year) %>%
        summarise(
            SMR = sum(ExpDeaths, na.rm = TRUE) / sum(StdPop, na.rm = TRUE),
            .groups = "drop"
        )
    return(smr)
}

# --- Placeholder in main workflow ---
# For now, create NA SMR columns for each year
for (yr in 2019:2024) {
    smr_col <- paste0("SMR.", yr)
    new.joined.counts[[smr_col]] <- NA_real_
}

# Later, once age-specific data available:
# smr_results <- calculate_smr(deaths_age, pop_age, std_pop)
# new.joined.counts <- new.joined.counts %>%
#     left_join(smr_results, by = c("Agency","Year")) %>%
#     mutate(SMR = round(SMR * 10000, 2))  # scale per 10,000 if needed

cat("✓ Standardized Mortality Rate (SMR) placeholders added for 2019–2024 (currently NA)\n\n")

# Order columns
order_columns <- function(df) {
    cols <- names(df)
    years <- sort(unique(as.integer(stringr::str_extract(cols, "\\d{4}"))), na.last = NA)
    
    death_cols <- paste0("Deaths.", years[!is.na(years)])
    pop_cols   <- paste0("Population.", years[!is.na(years)])
    rate_cols  <- paste0("Crude.Rate.", years[!is.na(years)])
    smr_cols   <- paste0("SMR.", years[!is.na(years)])
    
    ordered <- c("Agency", death_cols, pop_cols, rate_cols, smr_cols)
    ordered <- ordered[ordered %in% cols]
    
    df %>% dplyr::select(all_of(ordered))
}
new.joined.counts <- order_columns(new.joined.counts)

# -------------------------------------------------------------------
# Step 11. Coverage summary (states vs BoP)
cat("Step 11: Building state-year coverage tables...\n")

coverage <- combined.population.data |>
    full_join(combined.death.data, by = c("Agency","Year")) |>
    group_by(Agency, Year) |>
    summarise(
        Pop.Available    = any(!is.na(Population)),
        Deaths.Available = any(!is.na(Deaths)),
        .groups = "drop"
    ) |>
    mutate(Available = Pop.Available & Deaths.Available)

coverage_wide <- coverage |>
    mutate(Mark = ifelse(Available, "✓", "–")) |>
    filter(Year >= 2019 & Year <= 2024) |>
    select(Agency, Year, Mark) |>
    tidyr::pivot_wider(names_from = Year, values_from = Mark) |>
    mutate(across(-Agency, ~replace_na(.x, "–")))

state_coverage <- coverage_wide |> filter(!str_detect(Agency, "^BoP"))
bop_coverage   <- coverage_wide |> filter(str_detect(Agency, "^BoP"))

cat("✓ Coverage tables built.\n\n")

# ----------------------------
# QA-friendly Coverage Output
# ----------------------------

cat("============================================================\n")
cat(" Deaths-only Coverage by Year (2019–2024) — States Only (excludes BoP)\n")
cat("============================================================\n")
deaths_only <- combined.death.data |>
    filter(Year >= 2019 & Year <= 2024, !str_detect(Agency, "^BoP")) |>
    mutate(Mark = ifelse(!is.na(Deaths), "✓", "–")) |>
    select(Agency, Year, Mark) |>
    pivot_wider(names_from = Year, values_from = Mark) |> 
    mutate(across(-Agency, ~replace_na(.x, "–")))
print.data.frame(deaths_only, row.names = FALSE)

cat("\n============================================================\n")
cat(" Vera Population Coverage by Year (2019–2024) — States Only (excludes BoP)\n")
cat("============================================================\n")
vera_only <- aggregate.population.data %>%
    filter(Year >= 2019 & Year <= 2024, !str_detect(Agency, "^BoP")) %>%
    mutate(Mark = "✓") %>%
    select(Agency, Year, Mark) %>%
    pivot_wider(names_from = Year, values_from = Mark, values_fill = list(Mark = "–"))
print.data.frame(vera_only, row.names = FALSE)

cat("\n============================================================\n")
cat(" States with Deaths but Missing Vera Population (cannot calc rate; excludes BoP)\n")
cat("============================================================\n")
missing_vera <- coverage |>
    filter(Deaths.Available, !Pop.Available, Year >= 2019 & Year <= 2024, !str_detect(Agency, "^BoP")) |>
    arrange(Year, Agency)
if (nrow(missing_vera) == 0) {
    cat("✓ None — all states with deaths also have Vera population where available.\n")
} else {
    print.data.frame(missing_vera, row.names = FALSE)
}

cat("\n============================================================\n")
cat(" Coverage by Year (2019–2024) — BoP (federal only)\n")
cat("============================================================\n")
print.data.frame(bop_coverage, row.names = FALSE)

cat("\n============================================================\n")
cat(" Summary counts by year — States Only (excludes BoP)\n")
cat("============================================================\n")
year_summary <- coverage |>
    filter(!str_detect(Agency, "^BoP"), Year >= 2019 & Year <= 2024) |>
    group_by(Year) |>
    summarise(
        States_With_Deaths = sum(Deaths.Available),
        States_With_Pop    = sum(Pop.Available),
        States_With_Both   = sum(Available),
        Missing_Either     = 50 - States_With_Both,
        .groups = "drop"
    )
print.data.frame(year_summary, row.names = FALSE)

cat("\n============================================================\n")
cat(" Crude Rates and SMR Placeholders (2019–2024) — States Only (excludes BoP)\n")
cat("============================================================\n")
rate_summary <- new.joined.counts %>%
    filter(!str_detect(Agency, "^BoP")) %>%
    select(Agency, starts_with("Crude.Rate."), starts_with("SMR."))
print.data.frame(head(rate_summary, 10), row.names = FALSE)

crude_counts <- rate_summary %>%
    summarise(across(starts_with("Crude.Rate."),
                     ~sum(!is.na(.x), na.rm = TRUE)))
smr_counts <- rate_summary %>%
    summarise(across(starts_with("SMR."),
                     ~sum(!is.na(.x), na.rm = TRUE)))

cat("\nCrude rate availability (states only):\n")
print.data.frame(crude_counts, row.names = FALSE)

cat("\nSMR availability (states only, placeholders NA):\n")
print.data.frame(smr_counts, row.names = FALSE)

# -------------------------------------------------------------------
# Step 12. Save final output
output_file <- "Data/Output/ucla_bbdp_prison_mortality_2019_2024.csv"
write_csv(new.joined.counts, output_file)
cat("\n✓ Final output written to:", output_file, "\n\n")

# -------------------------------------------------------------------
# Wrap up
cat("============================================================\n")
cat(" Run completed at:", Sys.time(), "\n")
cat(" Rows in final dataset:", nrow(new.joined.counts), "\n")
cat(" QA log saved to:", qa_log, "\n")
cat(" Debug log saved to:", debug_log, "\n")
cat("============================================================\n")

sink(type = "message")
sink(type = "output")
close(qa_con)
close(debug_con)
