#------------------------------------------------------------------------------#
# Check Individual-Level Detail by State and Year
# Author: Mari Roberts
# Date: October 31, 2025
# Description:
#   Reads all state-level mortality files from Data/Raw/Deaths/Individual,
#   checks for presence of data in selected columns that indicate
#   individual-level detail.
#------------------------------------------------------------------------------#

library(tidyverse)
library(here)

# ---- Config ----
data_dir <- here("Data", "Raw", "Deaths", "Individual")

# Columns that indicate individual-level detail
cols_to_test <- c(
    "Death.Date", "Last.Name", "First.Name",
    "Middle.Name", "Full.Name"
)

# ---- Function to Summarize a File ----
summarize_file <- function(file_path) {
    file_name <- basename(file_path)
    state <- str_extract(file_name, "^[A-Z]{2,}")
    year  <- str_extract(file_name, "\\d{4}")
    
    df <- read_csv(file_path, show_col_types = FALSE)
    
    # Only check columns that exist in this dataset
    cols_present <- intersect(cols_to_test, names(df))
    
    # Determine for each whether it has any data
    col_summary <- tibble(
        Column = cols_present,
        Has_Data = map_lgl(cols_present, ~ any(!is.na(df[[.x]])))
    )
    
    tibble(
        File = file_name,
        State = state,
        Year = year,
        Columns_Checked = length(cols_present),
        Columns_With_Data = sum(col_summary$Has_Data),
        Columns_All_NA = length(cols_present) - sum(col_summary$Has_Data),
        Has_Individual_Level_Details = any(col_summary$Has_Data)
    )
}

# ---- Apply to All Files ----
files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
summary_all <- map_dfr(files, summarize_file)

View(summary_all)




#------------------------------------------------------------------------------#
# Step 1: Inventory Columns Across All Individual Death Files
#------------------------------------------------------------------------------#

# library(tidyverse)
# library(here)
# 
# data_dir <- here("Data", "Raw", "Deaths", "Individual")
# 
# files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
# 
# column_inventory <- map_dfr(files, function(file) {
#     df <- read_csv(file, show_col_types = FALSE, n_max = 100)  # just sample first 100 rows
#     tibble(
#         File = basename(file),
#         State = str_extract(basename(file), "^[A-Z]{2,}"),
#         Columns = names(df)
#     )
# })
# 
# # Flatten list of all unique columns
# unique_columns <- unique(column_inventory$Columns)
