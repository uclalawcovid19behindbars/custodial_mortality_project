# ---- Libraries ----
library(tidyverse)
library(glue)
library(fs)

# ---- Configuration ----
# Your repo base (change if needed)
repo_url <- "https://raw.githubusercontent.com/uclalawcovid19behindbars/custodial_mortality_project/main"

# Local branch directory
local_dir <- "Data/Raw/Deaths/Individual"

# Output directory
log_dir <- "logs/compare_with_github_main"
dir_create(log_dir)

# ---- Helper: Safe read ----
safe_read <- function(path_or_url) {
    tryCatch(read_csv(path_or_url, show_col_types = FALSE), error = function(e) tibble())
}

# ---- List local files ----
files_local <- dir_ls(local_dir, glob = "*.csv")

results_counts <- list()
results_columns <- list()

# ---- Compare ----
for (local_path in files_local) {
    file_name <- basename(local_path)
    remote_url <- glue("{repo_url}/Data/Raw/Deaths/Individual/{file_name}")
    
    message(glue("Comparing {file_name}..."))
    
    df_branch <- safe_read(local_path)
    df_main <- safe_read(remote_url)
    
    # ---- Row counts by year ----
    if ("Year" %in% names(df_main)) {
        counts_main <- df_main |> count(Year, name = "Rows_Main")
    } else {
        counts_main <- tibble(Year = NA, Rows_Main = nrow(df_main))
    }
    
    if ("Year" %in% names(df_branch)) {
        counts_branch <- df_branch |> count(Year, name = "Rows_Branch")
    } else {
        counts_branch <- tibble(Year = NA, Rows_Branch = nrow(df_branch))
    }
    
    counts <- full_join(counts_main, counts_branch, by = "Year") |>
        mutate(State_File = file_name) |>
        relocate(State_File)
    
    results_counts[[file_name]] <- counts
    
    # ---- Column comparison ----
    cols <- tibble(
        State_File = file_name,
        Source = c("main (GitHub)", "branch (local)"),
        Columns = c(
            paste(names(df_main), collapse = ", "),
            paste(names(df_branch), collapse = ", ")
        )
    )
    results_columns[[file_name]] <- cols
}

# ---- Combine results ----
summary_counts <- bind_rows(results_counts)
summary_columns <- bind_rows(results_columns)

summary_counts <- summary_counts |> mutate(same = ifelse(Rows_Main == Rows_Branch, TRUE, FALSE))

# ---- Save outputs ----
write_csv(summary_counts, file.path(log_dir, "row_counts_by_year.csv"))
write_csv(summary_columns, file.path(log_dir, "column_names.csv"))

message(glue("✅ Comparison complete. Logs saved to {log_dir}/"))
