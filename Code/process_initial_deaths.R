## Prep Custodial Deaths Repo

# Set Environment

library(tidyverse)
library(readxl)

# Set Functions
read_excel_allsheets <- function(filename, tibble = FALSE) {
    # I prefer straight data.frames
    # but if you like tidyverse tibbles (the default with read_excel)
    # then just pass tibble = TRUE
    sheets <- readxl::excel_sheets(filename)
    x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
    if(!tibble) x <- lapply(x, as.data.frame)
    names(x) <- sheets
    x
}

list_to_dataframes <- function(list) {
    run.length <- list %>%
                  length()
    names.to.assign <- list %>%
                       names()
    for (k in 1:run.length) {
        out.data <- list[k] %>%
            as.data.frame()
        clean.names <- out.data %>%
            colnames() %>%
            str_replace_all('.*Monthly\\.', '') %>%
            str_replace_all('.*Yearly\\.', '') %>%
            str_replace_all('.*Individual\\.', '')
        colnames(out.data) <- clean.names
        assign(names.to.assign[k], out.data, envir = .GlobalEnv)
    }
}

list_to_csv <- function(list, destination) {
    run.length <- list %>%
        length()
    names.to.assign <- list %>%
        names()
    for (k in 1:run.length) {
        out.data <- list[k] %>%
            as.data.frame() 
        clean.names <- out.data %>%
                       colnames() %>%
                       str_replace_all('.*Monthly\\.', '') %>%
                       str_replace_all('.*Yearly\\.', '') %>%
                       str_replace_all('.*Individual\\.', '')
        colnames(out.data) <- clean.names
        if(c('DoB') %in% clean.names) {
            if(is.character(out.data$DoB)) {
                out.data <- out.data %>%
                            mutate(DoB = as.Date(as.numeric(DoB), origin = "1899-12-30"))
            }
            out.data <- out.data %>%
                        mutate(DoB = format(DoB, format = '%Y-%m-%d'))
        }
        if(c('Death.Date') %in% clean.names) {
            if(is.character(out.data$Death.Date)) {
                out.data <- out.data %>%
                    mutate(Death.Date = as.Date(as.numeric(Death.Date), origin = "1899-12-30"))
            }
            out.data <- out.data %>%
                mutate(Death.Date = format(Death.Date, format = '%Y-%m-%d'))
        }
        if(str_detect(names.to.assign[k], 'Monthly')) write_csv(out.data, str_c(destination, 'Monthly/', names.to.assign[k], '.csv'))
        if(str_detect(names.to.assign[k], 'Yearly')) write_csv(out.data, str_c(destination, 'Annual/', names.to.assign[k], '.csv'))
        if(str_detect(names.to.assign[k], 'Individual')) write_csv(out.data, str_c(destination, 'Individual/', names.to.assign[k], '.csv'))
    }
}

# Load Death Data
death.file <- '/Volumes/Kanaloa/Projects/2020_Deaths/Data/=Core.Sheets/ucla.death.data.xlsx'

death.list <- death.file %>%
              read_excel_allsheets()

death.list %>%
    list_to_dataframes()

# Write New Death Data to Repo
death.list %>%
    list_to_csv(., 'Data/Raw/Deaths/')
#/Users/michaeleverett/Documents/UCLA/R_PT/state_prison_deaths_2020/Data/Raw/Deaths/Annual











