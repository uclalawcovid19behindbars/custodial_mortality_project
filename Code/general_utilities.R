## UCLA Prison Mortality Utilities

## Set Environment
library(tidyverse)
library(httr)
library(magrittr)
library(reshape2)
library(lubridate)

## Functions

read_bjs <- function(all.agencies, agencies) {
    mci.19 <- 'Data/External/msfp0119stt14.csv' %>%
               read_csv() %>%
               subset(!is.na(X3)) %>%
               mutate(Jurisdiction = coalesce(`Bureau of Justice Statistics`, X2)) %>%
               select(-c(`Bureau of Justice Statistics`, X2))
    mci.cols <- mci.19[1,]
    mci.19 <- mci.19 %>%
              set_colnames(mci.cols) %>%
              melt() %>%
              mutate(Jurisdiction = str_replace_all(Jurisdiction, '\\/.*', '')) %>%
              subset(!str_detect(Jurisdiction, 'Jurisdiction') & !str_detect(Jurisdiction, 'State')) %>%
              set_colnames(c('Jurisdiction', 'Year', 'Total.Deaths'))
    
    if(all.agencies == FALSE) {
        mci.19
    }
    
    if(all.agencies == TRUE) {
        mci.19 <- mci.19 %>%
            subset(Jurisdiction %in% agencies)
        mci.19
    }
    
}

read_ucla_deaths <- function(all.agencies, agencies) {
    states <- data.frame(State.Abb = state.abb,
                         State.Name = state.name)
    annual.files <- 'Deaths/Annual' %>%
                    pull_raw_files()
    monthly.files <- 'Deaths/Monthly' %>%
                     pull_raw_files()
    individual.files <- 'Deaths/Individual' %>%
                        pull_raw_files()
    all.files <- annual.files %>%
                 plyr::rbind.fill(monthly.files) %>%
                 plyr::rbind.fill(individual.files) %>%
                 mutate(State.Abb = str_replace_all(Files, '-.*', ''),
                        Data.Type = str_replace_all(Files, '.*-', ''),
                        Data.Type = str_replace_all(Data.Type, '\\..*', ''),
                        Data.Type = ifelse(str_detect(Data.Type, 'Yearly'), 'Annual', Data.Type)) %>%
                 left_join(., states, by = c('State.Abb')) 
    
    if(all.agencies = TRUE) {
        file.list <- all.files %>%
                     select(Files, Data.Type) %>%
                     mutate(Files = str_c('Data/Raw/Deaths/', Data.Type, '/', Files)) %>%
                     select(Files) 
        file.list <- file.list$Files
        death.list <- lapply(file.list, read.csv)
    }
    
    if(all.agencies = FALSE) {
        if(str_detect(''))
    }
}

pull_raw_files <- function(path) {
    out <- 'Data/Raw/' %>%
            str_c(., path) %>%
            list.files() %>%
            as.data.frame() %>%
            set_colnames('Files')
    out
}

check_death_lists <- function(death.list)

compare_ucla_bjs <- function(all.agencies) {}

# /Users/michaeleverett/Documents/UCLA/R_PT/state_prison_deaths_2020/Data/Raw/Deaths/Annual














