# ---- Setup --------------------------------------------------------------------
suppressPackageStartupMessages({
    library(tidyverse)
    library(lubridate)
    library(here)
    library(glue)
})

options(
    dplyr.summarise.inform = FALSE,
    readr.show_col_types = FALSE
)

# ---- Load Utilities -----------------------------------------------------------
source(here("Code", "general_utilities.R"))

# ---- Config -------------------------------------------------------------------
CONFIG <- list(
    original_counts_url =
        "https://raw.githubusercontent.com/uclalawcovid19behindbars/custodial_mortality_project/main/Data/Output/prison_agency_counts.csv",
    bop_exclude_years = c(2022),
    out_file = here("Data", "Output", "UCLA_BBDP_Updated_Output_Prison_Mortality.csv")
)

# ---- Combined State Frame -----------------------------------------------------
state.frame <- tibble(State = state.name, State.Abb = state.abb)

# ---- Load CMP Data ------------------------------------------------------------
summary.data <- summarize_CMP_data()

state.deaths.data <- read_CMP_deaths(all.agencies = TRUE) |>
    transmute(Agency = State, Year, Deaths = Total.Deaths)

# ---- BoP Deaths ---------------------------------------------------------------
bop.deaths.data <- read_csv("Data/Other/Deaths/Federal/BOP-Individual.csv")

bop.all.locations <- bop.deaths.data |>
    count(Year, name = "Deaths") |>
    filter(!Year %in% CONFIG$bop_exclude_years) |>
    mutate(Agency = "BoP - All Locations")

bop.state.locations <- bop.deaths.data |>
    count(State, Year, name = "Deaths") |>
    filter(!Year %in% CONFIG$bop_exclude_years) |>
    mutate(Agency = str_c("BoP - ", State)) |>
    select(Agency, Year, Deaths)

bop.combined <- bind_rows(bop.all.locations, bop.state.locations) |>
    complete(Agency, Year = full_seq(Year, 1), fill = list(Deaths = 0))

# ---- Combine All Death Data ---------------------------------------------------
combined.death.data <- bind_rows(state.deaths.data, bop.combined) |>
    drop_na(Deaths, Year)

# ---- Population Data (Vera + BoP) --------------------------------------------
aggregate.population.data <- interpolate_vera_dem_updated() |>
    filter(str_detect(as.character(Date), "06-30|03-31")) |>
    mutate(Agency = if_else(str_detect(State, "BOP"), "BoP - All Locations", State)) |>
    select(Agency, Year, Population) |>
    drop_na()

state.bop.population <- read_csv("Data/Raw/Population/BOP_state_year_count.csv") |>
    left_join(state.frame, by = c("state" = "State.Abb")) |>
    transmute(
        Agency = str_c("BoP - ", State),
        Year = year_scraped,
        Population = state_total
    ) |>
    drop_na()

combined.population.data <- bind_rows(aggregate.population.data, state.bop.population)

# ---- Combine Death + Population -----------------------------------------------
combined.data <- combined.population.data |>
    left_join(combined.death.data, by = c("Agency", "Year")) |>
    mutate(
        Crude.Rate = (Deaths / Population) * 10000,
        Crude.Rate = ifelse(is.nan(Crude.Rate), NA, Crude.Rate),
        Deaths = ifelse(is.nan(Deaths), NA, Deaths),
        Population = ifelse(is.nan(Population), NA, Population)
    )

# ---- Pivot long-to-wide dynamically to include all future years ---------------
combined.wide <- combined.data |>
    pivot_longer(
        cols = c(Deaths, Population, Crude.Rate),
        names_to = "Variable",
        values_to = "Value"
    ) |>
    mutate(VarName = paste0(Variable, ".", Year)) |>
    select(Agency, VarName, Value) |>
    pivot_wider(
        names_from = VarName,
        values_from = Value,
        values_fn = ~ mean(as.numeric(.x), na.rm = TRUE)  # resolve duplicates safely
    ) |>
    ungroup()

# ---- Integrate Original Counts ------------------------------------------------
original.counts <- read_csv(CONFIG$original_counts_url, show_col_types = FALSE)

# Drop unnamed / duplicate index columns before renaming
original.counts <- original.counts |>
    select(-matches("^\\.{3}\\d+|^X\\d+"))   # removes ...1, X1, etc.

# Clean and normalize names
original.counts <- original.counts |>
    janitor::clean_names() |>                     # e.g. agency, deaths_2019
    rename_with(~ str_replace_all(., "_", ".")) |> # convert to deaths.2019 format
    rename_with(~ paste0("O.", .), starts_with("deaths.")) |>
    rename_with(~ str_to_title(.), "agency") |>   # agency → Agency
    select(Agency, starts_with("O.Deaths"))

# ---- Final Combined Join ------------------------------------------------------
# Standardize names in original.counts for case-insensitive merge
names(original.counts) <- str_replace_all(names(original.counts), "^O\\.deaths", "O.Deaths")

new.joined.counts <- combined.wide |>
    left_join(original.counts, by = "Agency")

# Detect which original death columns actually exist (2019–2021)
orig_years <- names(original.counts) |>
    str_extract("\\d{4}") |>
    na.omit() |>
    unique()

# Coalesce for each available original year
for (yr in orig_years) {
    deaths_col <- glue("Deaths.{yr}")
    orig_col <- glue("O.Deaths.{yr}")
    if (orig_col %in% names(new.joined.counts)) {
        new.joined.counts[[deaths_col]] <- coalesce(
            new.joined.counts[[deaths_col]],
            new.joined.counts[[orig_col]]
        )
    }
}

# Recalculate missing crude rates dynamically
for (yr in unique(combined.data$Year)) {
    rate_col <- glue("Crude.Rate.{yr}")
    deaths_col <- glue("Deaths.{yr}")
    pop_col <- glue("Population.{yr}")
    if (rate_col %in% names(new.joined.counts) &&
        deaths_col %in% names(new.joined.counts) &&
        pop_col %in% names(new.joined.counts)) {
        new.joined.counts[[rate_col]] <- ifelse(
            is.na(new.joined.counts[[rate_col]]) &
                !is.na(new.joined.counts[[deaths_col]]) &
                !is.na(new.joined.counts[[pop_col]]),
            (new.joined.counts[[deaths_col]] /
                 new.joined.counts[[pop_col]]) * 10000,
            new.joined.counts[[rate_col]]
        )
    }
}

# Drop temporary columns
new.joined.counts <- new.joined.counts |>
    select(-starts_with("O.Deaths"), -starts_with("O.deaths"), everything())

# ---- Fix Duplicate Rows from pivot_wider --------------------------------------
new.joined.counts <- new.joined.counts |>
    group_by(Agency) |>
    summarise(across(everything(),
                     ~ ifelse(length(unique(.x)) == 1, unique(.x), first(.x)),
                     .names = "{.col}")) |>
    ungroup()

# ---- Add Placeholder SMR Columns ---------------------------------------------
# These columns are temporary placeholders for Standardized Mortality Ratios (SMRs)
# Michael: once your SMR calculations are finalized, import your SMR dataset here
# and merge it into `new.joined.counts` by Agency and Year.
#
# Example (expected structure of your SMR file):
#   Agency | Year | SMR
#   --------------------
#   Alabama | 2019 | 1.12
#   Alabama | 2020 | 1.35
#   ...
#
# You can merge it like this:
# smr.data <- read_csv("Data/Other/SMR/smr_estimates.csv")
# new.joined.counts <- new.joined.counts %>%
#     pivot_longer(
#         cols = matches("Deaths|Population|Crude\\.Rate|SMR"),
#         names_to = c("Variable", "Year"),
#         names_pattern = "(.*)\\.(\\d{4})"
#     ) %>%
#     pivot_wider(
#         names_from = Variable,
#         values_from = value
#     ) %>%
#     left_join(smr.data, by = c("Agency", "Year")) %>%
#     pivot_longer(
#         cols = c(Deaths, Population, Crude.Rate, SMR),
#         names_to = "Variable",
#         values_to = "Value"
#     ) %>%
#     mutate(VarName = paste0(Variable, ".", Year)) %>%
#     select(Agency, VarName, Value) %>%
#     pivot_wider(names_from = VarName, values_from = Value)

# For now, we create placeholder columns so the structure is ready for merge.

# Determine available years (≥2019)
year_cols <- sort(unique(as.numeric(str_extract(names(new.joined.counts), "\\d{4}"))))
year_cols <- year_cols[!is.na(year_cols) & year_cols >= 2019]

# Create SMR placeholder columns
for (yr in year_cols) {
    smr_col <- glue("SMR.{yr}")
    if (!smr_col %in% names(new.joined.counts)) {
        new.joined.counts[[smr_col]] <- NA_real_
    }
}

# Reorder so SMR columns appear after Crude.Rate.*
ordered_cols <- c(
    "Agency",
    paste0("Deaths.", year_cols),
    paste0("Population.", year_cols),
    paste0("Crude.Rate.", year_cols),
    paste0("SMR.", year_cols)
)
new.joined.counts <- new.joined.counts %>%
    select(all_of(ordered_cols))

# ---- Final Cleanup: Replace NaN with NA across all columns --------------------
new.joined.counts <- new.joined.counts %>%
    mutate(across(everything(), ~ ifelse(is.nan(.x), NA, .x)))

# ---- Write Output (Version-Controlled) ----------------------------------------

# Create timestamped version for reproducibility
timestamp <- format(Sys.Date(), "%Y%m%d")

# Define both output paths
versioned_out <- here("Data", "Output",
                      glue("UCLA_BBDP_Updated_Output_Prison_Mortality_{timestamp}.csv"))
latest_out <- CONFIG$out_file

# Write both versions
write_csv(new.joined.counts, versioned_out)
write_csv(new.joined.counts, latest_out)

# Print confirmation messages
message(glue("Latest output saved to: {latest_out}"))
message(glue(" Versioned copy saved to: {versioned_out}"))

# Optionally, return a small summary for logging
summary_info <- tibble(
    n_agencies = n_distinct(new.joined.counts$Agency),
    n_years = length(unique(gsub(".*\\.(\\d{4})$", "\\1", names(new.joined.counts)))),
    file_date = Sys.Date()
)
print(summary_info)

