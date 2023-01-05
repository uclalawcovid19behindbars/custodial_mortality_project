#### Carceral Mortality Project Utilities

#### Set Environment -----------------------------------
library(tidyverse)
library(httr)
library(magrittr)
library(reshape2)
library(lubridate)
library(data.table)
library(dplyr)
library(tidyr)
library(zoo)

#### Functions -----------------------------------------

## Read in BJS Historical Decedent Data ------------

read_mci_19 <- function() {
    
    suppressMessages(
        mci.19 <- 'Data/External/msfp0119stt14_cleaned.csv' %>%
        read_csv()
    )
    mci.19
}

read_nps_20 <- function() {
    suppressMessages(
    nps.20 <- 'Data/External/p20stt09_cleaned.csv' %>%
        read_csv()
    )
    
    nps.20
    
}

read_bjs <- function(all.agencies, agencies, source) {
    ## Load Last MCI
    mci.19 <- read_mci_19()
    
    ## Load Last NPS
    nps.20 <- read_nps_20()
    
    ## Prep MCI Data
    if(source == 'NPS+MCI'){
    mci.clean <- mci.19 %>%
                 subset(Year != 2019)
    }
    if(source == 'MCI'){
        mci.clean <- mci.19 
    }
    
    ## Prep NPS Data
    suppressMessages(suppressWarnings(
    nps.clean <- nps.20 %>%
                 select(State, Deaths.2019, Deaths.2020) %>%
                 melt(id.vars = 'State', measure.vars = c('Deaths.2019', 'Deaths.2020')) %>%
                 mutate(Year = as.numeric(str_replace_all(variable, '.*\\.', '')),
                        Total.Deaths = value) %>%
                 select(c(State, Year, Total.Deaths)) 
    ))  
    
    ## Combine Data
    if(source == 'NPS+MCI'){
    bjs.data <- mci.clean %>%
                rbind(nps.clean)
    }
    if(source == 'MCI'){
        bjs.data <- mci.clean 
    }
    

    ## Make State Dataframe
    states <- data.frame(State.Abb = state.abb,
                         State = state.name)
    
    ## 
    if(all.agencies == TRUE) {
        print('Pulling all annual agency data from BJS')
        bjs.out <- bjs.data
    }
    
    if(all.agencies == FALSE) {
        bjs.out <- bjs.data %>%
                   left_join(., states, by = c('State')) 
        bjs.out <- bjs.out[bjs.out$State.Abb %in% agencies,]
    }
    
    bjs.out
    
}

## Read in UCMP Historical Decedent Data -------------------------

# sub functions for read_CMP_data

# pull raw files

pull_raw_files <- function(path) {
    out <- 'Data/Raw/' %>%
        str_c(., path) %>%
        list.files() %>%
        as.data.frame() %>%
        set_colnames('Files')
    out
}

# all var sum to year obs
sum.to.year <- function(x) {
    read <- x %>%
        read.csv() 
    data.cols <- read %>%
        colnames() %>%
        as.vector()
    group.cols <- data.cols %>%
        as.data.frame() %>%
        plyr::rename(c('.' = 'cols')) %>%
        subset(cols != 'Month' & cols != 'Total.Deaths' & cols != 'Death.Date' &
               cols != 'ID.No' & cols != 'Full.Name' & cols != 'Last.Name' & 
               cols != 'First.Name' & cols != 'Death.Age' & cols != 'DoB.Year' &
               cols != 'DoB' & cols != 'Location') 
    group.cols <- group.cols$cols 
    if(!('Total.Deaths' %in% data.cols)) {
        out <- read %>%
            group_by(across(all_of(group.cols))) %>%
            summarise(Total.Deaths = n())
    }
    
    if('Total.Deaths' %in% data.cols) {
        out <- read %>%
            group_by(across(all_of(group.cols))) %>%
            summarise(Total.Deaths = sum(Total.Deaths, na.rm = TRUE))
            
    }
    out
}

# all var sum to month obs
sum.to.month <- function(x) {
    read <- x %>%
        read.csv() 
    data.cols <- read %>%
        colnames() %>%
        as.vector()
    group.cols <- data.cols %>%
        as.data.frame() %>%
        plyr::rename(c('.' = 'cols')) %>%
        subset(cols != 'Total.Deaths' & cols != 'Death.Date' &
                   cols != 'ID.No' & cols != 'Full.Name' & cols != 'Last.Name' & 
                   cols != 'First.Name' & cols != 'Death.Age' & cols != 'DoB.Year' &
                   cols != 'DoB' & cols != 'Location') 
    group.cols <- group.cols$cols 
    if(!('Total.Deaths' %in% data.cols)) {
        out <- read %>%
            group_by(across(all_of(group.cols))) %>%
            summarise(Total.Deaths = n())
    }
    
    if('Total.Deaths' %in% data.cols) {
        out <- read %>%
            group_by(across(all_of(group.cols))) %>%
            summarise(Total.Deaths = sum(Total.Deaths, na.rm = TRUE))
        
    }
    out
}

# Make default year aggregate function - for default all sum in read_CMP_deaths [read_to_year()]
only.year <- function(x) {
    read <- x %>%
        read.csv() 
    data.cols <- read %>%
        colnames() %>%
        as.vector()
    if(!('Total.Deaths' %in% data.cols)) {
        out <- read %>%
            group_by(State, Year) %>%
            summarise(Total.Deaths = n())
    }
    
    if('Total.Deaths' %in% data.cols) {
        out <- read %>%
            group_by(State, Year) %>%
            summarise(Total.Deaths = sum(Total.Deaths, na.rm = TRUE))
    }
    out
}

# Make default month aggregate function - for default all sum in read_CMP_deaths [read_to_year()]
only.year.month <- function(x) {
    read <- x %>%
        read.csv() 
    data.cols <- read %>%
        colnames() %>%
        as.vector()
    if(!('Total.Deaths' %in% data.cols)) {
        out <- read %>%
            group_by(State, Year) %>%
            summarise(Total.Deaths = n())
    }
    
    if('Total.Deaths' %in% data.cols) {
        out <- read %>%
            group_by(State, Year) %>%
            summarise(Total.Deaths = sum(Total.Deaths))
    }
    out
}

# Make defaults individual aggregate function - for default all sum in read_CMP_deaths [read_to_year()]
only.year.individual <- function(x) {
    read <- x %>%
        read.csv() %>%
        group_by(State, Year) %>%
        summarise(Total.Deaths = n())
}

# Read to Year aggregate function (default operation)
read_to_year <- function(file.base) {
    file.list <- file.base %>%
                 mutate(Files = str_c('Data/Raw/Deaths/', Data.Type, '/', Files)) 
                 
    # Prepare Annual Data
    year.data <- file.list %>%
        subset(Data.Type == 'Annual')
    # end year aggregate function
    year.list <- lapply(year.data$Files, only.year)
    year.out <- rbindlist(year.list, fill = TRUE)
    # Prepare Monthly Data
    month.data <- file.list %>%
        subset(Data.Type == 'Monthly')

    month.list <- lapply(month.data$Files, only.year.month)
    month.out <- rbindlist(month.list, fill = TRUE)
    # Prepare Individual Data
    individual.data <- file.list %>%
        subset(Data.Type == 'Individual')
    individual.list <- lapply(individual.data$Files, only.year.individual)
    individual.out <- rbindlist(individual.list, fill = TRUE)
    
    all.deaths <- year.out %>%
        plyr::rbind.fill(month.out) %>%
        plyr::rbind.fill(individual.out)
    all.deaths
}


read_CMP_deaths <- function(all.agencies = FALSE, agencies) {
    
    ## Pull all possible files in repo and set up state dataframe
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
    
    # User wants all potential decedent data
    if(all.agencies == TRUE) {
    suppressMessages(output.deaths <- all.files %>%
                     read_to_year())
    print('Summarized by years of data available for all agencies')
    }
    
    # User wants decedent data from specific states
    # If user wants states of different data levels (i.e. Annual, Monthly, Individual)
    if(all.agencies == FALSE) {
        # function testing
        # agencies <- c('UT', 'MN', 'AR', 'GA', 'NV', 'NC')
        # set selected states from user
        input <- agencies
        # create file frame of selected states
        file.list <- all.files %>%
            select(Files, Data.Type) %>%
            mutate(Files = str_c('Data/Raw/Deaths/', Data.Type, '/', Files),
                   State = str_replace_all(Files, '-.*', ''),
                   State = str_replace_all(State, 'Data\\/Raw\\/Deaths\\/', ''),
                   State = str_replace_all(State, '.*\\/', '')) %>%
            subset(!str_detect(Files, 'UT-Yearly')) # remove less detailed UT data for alternative aggregates
        file.list <- file.list[file.list$State %in% input,]
        ## Check for levels in data to aggregate to same level
        # For all three levels
        suppressMessages(
        if(('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           ('Individual' %in% file.list$Data.Type)) {
           output.list <- lapply(file.list$Files, sum.to.year)
           output.deaths <- rbindlist(output.list, fill = TRUE)
           print(str_c('Aggregated annually: ', paste0(agencies, collapse = ', ')))
        })
        # For yearly only
        suppressMessages(
        if(('Annual' %in% file.list$Data.Type) &
           !('Monthly' %in% file.list$Data.Type) &
           !('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, sum.to.year)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print(str_c('Aggregated annually: ', paste0(agencies, collapse = ', ')))
        })
        # For monthly only
        suppressMessages(
        if(!('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           !('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, sum.to.month)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print(str_c('Aggregated monthly: ', paste0(agencies, collapse = ', ')))
        })
        # For individual only
        suppressMessages(
        if(!('Annual' %in% file.list$Data.Type) &
           !('Monthly' %in% file.list$Data.Type) &
           ('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, read.csv)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print(str_c('All individual level, no aggregation: ', paste0(agencies, collapse = ', ')))
        })
        # For yearly and monthly
        suppressMessages(
        if(('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           !('Individual' %in% file.list$Data.Type)){
            output.list <- lapply(file.list$Files, sum.to.year)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print(str_c('Aggregated annually: : ', paste0(agencies, collapse = ', ')))
        })
        # For monthly and individual
        suppressMessages(
        if(!('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           ('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, sum.to.month)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print(str_c('Aggregated monthly: : ', paste0(agencies, collapse = ', ')))
        })
    }
    output.deaths
}
    
## Compare Annual BJS Numbers with Aggregated CMP numbers -----------------

compare_CMP_bjs <- function(source) {
    bjs.data <- read_bjs(all.agencies = TRUE, source = source) 
    bjs.data <- bjs.data %>%
                plyr::rename(c('Total.Deaths' = 'BJS.Deaths'))
    CMP.data <- read_CMP_deaths(all.agencies = TRUE) 
    CMP.data <- CMP.data %>%
                 plyr::rename(c('Total.Deaths' = 'CMP.Deaths'))
    joined.data <- CMP.data %>%
                   left_join(., bjs.data, by = c('State', 'Year')) %>%
                   mutate(Absolute.Difference = abs(CMP.Deaths-BJS.Deaths)) %>%
                   subset(Year < 2021) %>%
                   arrange(desc(Absolute.Difference))
    joined.data
    
}

## Read in CMP Historical Demograpahic Data -------------------

read_CMP_dem <- function(all.agencies, agencies) {
    ## Pull all possible files in repo and set up state dataframe
    states <- data.frame(State.Abb = state.abb,
                         State = state.name)
    combined.files <- 'Demographics/Combined' %>%
        pull_raw_files()
    distinct.files <- 'Demographics/Distinct' %>%
        pull_raw_files()
    
    all.files <- combined.files %>%
                 plyr::rbind.fill(distinct.files) %>%
        mutate(State.Abb = str_replace_all(Files, '-.*', ''),
               Data.Type = str_replace_all(Files, '.*-', ''),
               Data.Type = str_replace_all(Data.Type, '\\.csv', ''),
               Data.Category = ifelse(str_detect(Data.Type, 'Age.Sex'), 'Combined', 'Distinct')) %>%
        left_join(., states, by = c('State.Abb')) %>%
        mutate(Files = str_c('Data/Raw/Demographics/', Data.Category, '/', Files)) 
    
    dem.pull <- all.files %>%
                pull_dem() %>%
                select(-c(State.Abb)) %>%
                left_join(states, by = c('State')) %>%
                select(State, State.Abb, Date, Sex.Group, Age.Group, Number, Origin.Type)
    
    if(all.agencies == TRUE){
        print('Pulling CMP demographic data for all agencies')
        dem.out <- dem.pull
    }
    
    if(all.agencies == FALSE){
        input <- agencies
        dem.out <- dem.pull[dem.pull$State.Abb %in% input,]
        print(str_c('Pulling CMP demographic data for specific agencies: ', paste0(agencies, collapse = ', ')))
    }
    
    dem.out
    
}

# Pull all demographic files

pull_dem <- function(file.base) {
    states.clean <- data.frame(State = state.name, State.Abb = state.abb) 
    combined <- file.base %>%
                subset(Data.Category == 'Combined')
    combined.list <- lapply(combined$Files, read.csv)
    combined.out <- rbindlist(combined.list, fill = TRUE)
    combined.out <- combined.out %>%
                    mutate(Origin.Type = 'Combined') %>%
                    select(-c(State.Abb)) %>%
                    left_join(., states.clean, by = c('State'))
    
    distinct <- file.base %>%
                select(-c(State.Abb)) %>%
                left_join(., states.clean, by = c('State')) %>%
                subset(Data.Category == 'Distinct' & State.Abb != 'WV' & State.Abb != 'WA') 
    # Currently excluding WV and WA for lack of explanatory value with non-demographic decedent data and differing dates for 
    # demographic data sources
    distinct.list <- lapply(distinct$Files, read.csv)
    distinct.out <- rbindlist(distinct.list, fill = TRUE)
    distinct.out <- distinct.out %>%
                    #select(-c(State.Abb)) %>%
                    left_join(., states.clean, by = c('State'))
    
    sex.totals <- distinct.out %>%
              subset(is.na(Age.Group) | is.na(Sex.Group)) %>%
              mutate(Marker = ifelse(is.na(Age.Group), 'Sex', 'Age')) %>%
              subset(Marker == 'Sex') %>%
              group_by(Date, State) %>%
              summarise(Total = sum(Number))
    new.percent <- distinct.out %>%
        subset(is.na(Age.Group) | is.na(Sex.Group)) %>%
        mutate(Marker = ifelse(is.na(Age.Group), 'Sex', 'Age')) %>%
        subset(Marker == 'Sex') %>%
        left_join(sex.totals, by = c('State', 'Date')) %>%
        ungroup() %>%
        mutate(New.Percent = Number/Total) %>%
        select(State, Date, Sex.Group, New.Percent)
    distinct.clean <- distinct.out %>%
        subset(is.na(Age.Group) | is.na(Sex.Group)) %>%
        mutate(Marker = ifelse(is.na(Age.Group), 'Sex', 'Age')) %>%
        subset(Marker == 'Age') %>%
        select(-c(Sex.Group)) %>%
        left_join(., new.percent, by = c('State', 'Date')) %>%
        mutate(Number = as.integer(Number*New.Percent),
               Origin.Type = 'Distinct') %>%
        select(State, Date, Age.Group, Sex.Group, Number, Percent, Origin.Type, Source)
    
    demographics.combined <- combined.out %>%
                             plyr::rbind.fill(distinct.clean)
    demographics.combined
    
    
}

## Harmonize a Deaths and Demographics dataset from CMP ----------------------------
# Current datasets of interest to Harmonize for standardized analysis: 
# AZ, GA, IL, MA (needs sex), MI, MS (needs DoB), MT, NC, NV, NY (needs demographics), OK, PA (missing DoB), WV

harmonize_CMP_deaths <- function(agencies) {
    # function testing
    # input <- c('AZ', 'GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV')
    input <- agencies
    CMP.deaths <- read_CMP_deaths(all.agencies = FALSE, agencies = input)
    CMP.dem <- read_CMP_dem(all.agencies = FALSE, agencies = input)
    
    if(!('Sex' %in% colnames(CMP.deaths))) {
        CMP.deaths <- CMP.deaths %>%
                       mutate(Sex = NA)
    }
    
    CMP.deaths.i <- CMP.deaths %>%
                    mutate(Sex = ifelse(str_detect(Sex, 'F'), 'Female', Sex),
                           Sex = ifelse((Sex != 'Female' & !is.na(Sex)), 'Male', Sex)) # Harmonize sex
    if(!('DoB.Year' %in% colnames(CMP.deaths.i)) & !('Death.Age' %in% colnames(CMP.deaths.i))) {
        CMP.deaths.i <- CMP.deaths.i %>%
                         mutate(DoB.Year = NA)
    } 
    
    if(!('DoB' %in% colnames(CMP.deaths.i)) & 'Death.Age' %in% colnames(CMP.deaths.i)) {
        CMP.deaths.i <- CMP.deaths.i %>%
            mutate(DoB.Year = year(Death.Date) - Death.Age,
                   DoB = NA) 
    } 
    
    if(!('DoB.Year' %in% colnames(CMP.deaths.i)) & ('DoB' %in% colnames(CMP.deaths.i))) {
        CMP.deaths.i <- CMP.deaths.i %>%
            mutate(DoB.Year = NA)
    } 
    
    if(!('DoB' %in% colnames(CMP.deaths.i)) & 'DoB.Year' %in% colnames(CMP.deaths.i)) {
        CMP.deaths.i <- CMP.deaths.i %>%
            mutate(DoB = NA) 
    } 
    
    if(!('Death.Age' %in% colnames(CMP.deaths.i))) {
        CMP.deaths.i <- CMP.deaths.i %>%
                         mutate(Death.Age = NA) 
    } 
    
    CMP.deaths.h <- CMP.deaths.i %>%
                    mutate(DoB.Year = str_c(str_c(DoB.Year, '-01', '-01')),
                           DoB.Combined = coalesce(DoB, DoB.Year)) %>%
                    mutate(Death.Age = ifelse((is.na(Death.Age) & !is.na(DoB.Combined)), (as.Date(Death.Date, format = '%Y-%m-%d') - as.Date(DoB.Combined, format = '%Y-%m-%d'))/365, Death.Age))
    
    CMP.dem.h <- CMP.dem %>%
                  plyr::rename(c('Sex.Group' = 'Sex')) %>%
                  mutate(Sex = ifelse(str_detect(Sex, 'F'), 'Female', Sex),
                         Sex = ifelse((Sex != 'Female' & Sex != 'B'), 'Male', Sex),
                         Sex = ifelse(Sex == 'B', NA, Sex)) %>% # Harmonize sex
                  plyr::rename(c('Age.Group' = 'Age')) %>%
                  mutate(Start.Age = case_when(str_detect(Age, 'nder') ~ '0',
                                               str_detect(Age, '-') ~ str_replace_all(Age, '-.*', ''),
                                               str_detect(Age, 'bove') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                               str_detect(Age, 'ver') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                               str_detect(Age, '\\+') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                               (str_length(Age) == 2) ~ Age
                                               ),
                         Start.Age = as.numeric(Start.Age),
                         End.Age = case_when(str_detect(Age, 'bove') ~ '120',
                                             str_detect(Age, 'ver') ~ '120',
                                             str_detect(Age, '\\+') ~'120',
                                             str_detect(Age, 'Under') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                             str_detect(Age, 'under') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                             str_detect(Age, '-') ~ str_replace_all(Age, '.*-', ''),
                                             (str_length(Age) == 2) ~ Age
                                             ),
                         End.Age = as.numeric(End.Age),
                         Standard.Groups = str_c(as.character(Start.Age), '-', as.character(End.Age)))
    
    dem.group.frame <- CMP.dem.h %>%
        select(State, Start.Age, End.Age, Standard.Groups) %>%
        unique()
    
    CMP.death.groups <- CMP.deaths.h %>%
                         left_join(., dem.group.frame, by = c('State')) %>%
                         mutate(Standard.Age.Group = ifelse((Death.Age <= End.Age & Death.Age >= Start.Age), Standard.Groups, 'Remove')) %>%
                         subset(Standard.Age.Group != 'Remove') %>%
                         select(-c(Start.Age, End.Age, Standard.Groups))
    
   CMP.death.groups
    
}

harmonize_CMP_dem <- function(agencies) {
    # function testing
    # input <- c('AZ', 'GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV', 'NY')
    input <- agencies
    CMP.dem <- read_CMP_dem(all.agencies = FALSE, agencies = input)
    
    CMP.dem.h <- CMP.dem %>%
        plyr::rename(c('Sex.Group' = 'Sex')) %>%
        mutate(Sex = ifelse(str_detect(Sex, 'F'), 'Female', Sex),
               Sex = ifelse((Sex != 'Female' & Sex != 'B'), 'Male', Sex),
               Sex = ifelse(Sex == 'B', NA, Sex)) %>% # Harmonize sex
        plyr::rename(c('Age.Group' = 'Age')) %>%
        mutate(Start.Age = case_when(str_detect(Age, 'nder') ~ '0',
                                     str_detect(Age, '-') ~ str_replace_all(Age, '-.*', ''),
                                     str_detect(Age, 'bove') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                     str_detect(Age, 'ver') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                     str_detect(Age, '\\+') ~ str_replace_all(Age, '[^0-9.-]', ''),
                                     (str_length(Age) == 2) ~ Age
        ),
        Start.Age = as.numeric(Start.Age),
        End.Age = case_when(str_detect(Age, 'bove') ~ '120',
                            str_detect(Age, 'ver') ~ '120',
                            str_detect(Age, '\\+') ~'120',
                            str_detect(Age, 'Under') ~ str_replace_all(Age, '[^0-9.-]', ''),
                            str_detect(Age, 'under') ~ str_replace_all(Age, '[^0-9.-]', ''),
                            str_detect(Age, '-') ~ str_replace_all(Age, '.*-', ''),
                            (str_length(Age) == 2) ~ Age
        ),
        End.Age = as.numeric(End.Age),
        Standard.Groups = str_c(as.character(Start.Age), '-', as.character(End.Age)))
    
    CMP.dem.h
}

summarize_CMP_data <- function() {
    ## Set up state match dataframe
    states <- data.frame(State.Abb = state.abb,
                         State.Name = state.name)
    summary.file <- lapply(states$State.Abb, summarize_CMP_state) %>%
        rbindlist()
    
    out.file <- summary.file %>%
                left_join(., states, by = 'State.Abb') %>%
                select(State.Name, everything())
    
    return(out.file)
}

check_variable <- function(variable, columns) {
    # Variable Check
    if(variable %in% columns) {
        mark <- 'Yes'
        assign(variable, mark, envir = .GlobalEnv)
    } else {
        mark <- 'No'
        assign(variable, mark, envir = .GlobalEnv)
    }
}

summarize_CMP_state <- function(state) {
    
    ## Set up state match dataframe
    states <- data.frame(State.Abb = state.abb,
                         State.Name = state.name)
    ## Pull death data files
    # Description: Pull all possible decedent files in repo 
    annual.files <- 'Deaths/Annual' %>%
        pull_raw_files()
    monthly.files <- 'Deaths/Monthly' %>%
        pull_raw_files()
    individual.files <- 'Deaths/Individual' %>%
        pull_raw_files()
    all.death.files <- annual.files %>%
        plyr::rbind.fill(monthly.files) %>%
        plyr::rbind.fill(individual.files) %>%
        mutate(State.Abb = str_replace_all(Files, '-.*', ''),
               Data.Type = str_replace_all(Files, '.*-', ''),
               Data.Type = str_replace_all(Data.Type, '\\..*', ''),
               Data.Type = ifelse(str_detect(Data.Type, 'Yearly'), 'Annual', Data.Type)) %>%
        left_join(., states, by = c('State.Abb')) 
    
    ## Pull demographic data files
    # Description: Pull all possible demographic files in repo 
    combined.files <- 'Demographics/Combined' %>%
        pull_raw_files()
    distinct.files <- 'Demographics/Distinct' %>%
        pull_raw_files()
    
    all.dem.files <- combined.files %>%
        plyr::rbind.fill(distinct.files) %>%
        mutate(State.Abb = str_replace_all(Files, '-.*', ''),
               Data.Type = str_replace_all(Files, '.*-', ''),
               Data.Type = str_replace_all(Data.Type, '\\.csv', ''),
               Data.Category = ifelse(str_detect(Data.Type, 'Age.Sex'), 'Combined', 'Distinct')) %>%
        left_join(., states, by = c('State.Abb')) %>%
        mutate(Files = str_c('Data/Raw/Demographics/', Data.Category, '/', Files)) 
    
    ## Pull relevant state file locations
    death.file.frame <- all.death.files %>%
        subset(State.Abb == state)
    dem.file.frame <- all.dem.files %>%
        subset(State.Abb == state)
    
    ## Test state file locations
    death.file.test <- death.file.frame %>%
        row.names() %>%
        length()
    dem.file.test <- dem.file.frame %>%
        row.names() %>%
        length()
    
    if(death.file.test > 0) {
        ## Summarize Decedent Info in Files
        state.data.type <- death.file.frame %>%
            .[1,'Data.Type']
        state.death.file <- death.file.frame %>%
            .[1, 'Files'] %>%
            str_c('Data/Raw/Deaths/', state.data.type, '/', .)
        state.deaths <- state.death.file %>%
            read.csv()
        
        state.variables <- state.deaths %>%
            colnames()
        
        variables.to.check <- c('State', 'Year', 'Month', 'Death.Date', 
                                'Facility', 'Full.Name', 'Last.Name', 'First.Name',
                                'ID.No', 'Sex', 'Race', 'Ethnicity', 'DoB', 'DoB.Year',
                                'Death.Age', 'Circumstance.General', 'Circumstance.Specific', 'Circumstance.Other',
                                'Location', 'Total.Deaths', 'UCLA.ID')
        
        sapply(variables.to.check, check_variable, columns = state.variables)
        
        if(Death.Date == 'Yes'){
            
            if(is.character(state.deaths$Death.Date)){
                state.deaths <- state.deaths %>%
                    mutate(Death.Date = as.Date(Death.Date, format = '%Y-%m-%d'))
                
            }
            Deaths.Start <- state.deaths$Death.Date %>%
                min(na.rm = TRUE) %>%
                as.character()
            Deaths.End <- state.deaths$Death.Date %>%
                max(na.rm = TRUE) %>%
                as.character()
            Deaths.Interval <- 'Individual'
        } else {
            if(Month == 'Yes') {
                Deaths.Start <- state.deaths %>%
                    mutate(Death.Date = as.Date(str_c(Year, '-',Month, '-01'), format = '%Y-%B-%d')) %>%
                    as.data.frame()
                Deaths.Start <- Deaths.Start$Death.Date %>%
                    min() %>%
                    as.character()
                Deaths.End <- state.deaths %>%
                    mutate(Death.Date = as.Date(str_c(Year, '-',Month, '-28'), format = '%Y-%B-%d'))
                Deaths.End <- Deaths.End$Death.Date %>%
                    max() %>%
                    as.character()
                Deaths.Interval <- 'Monthly'
            } else {
                Deaths.Start <- state.deaths$Year %>%
                    min() %>%
                    as.character() %>%
                    str_c(., '-01-01')
                Deaths.End <- state.deaths$Year %>%
                    max() %>%
                    as.character() %>%
                    str_c(., '-12-31')
                Deaths.Interval <- 'Annual'
            }
        }
        
    } else { # end if for any file present
        State <- 'No'
        Year <- 'No'
        Month <- 'No'
        Death.Date <- 'No'
        Facility <- 'No'
        Full.Name <- 'No'
        Last.Name <- 'No'
        First.Name <- 'No'
        ID.No <- 'No'
        Sex <- 'No'
        Race <- 'No'
        Ethnicity <- 'No'
        DoB <- 'No'
        DoB.Year <- 'No'
        Death.Age <- 'No'
        Circumstance.General <- 'No'
        Circumstance.Specific <- 'No'
        Circumstance.Other <- 'No'
        Location <- 'No'
        Total.Deaths <- 'No'
        UCLA.ID <- 'No'
        Deaths.Start <- 'No Data'
        Deaths.End <- 'No Data'
        Deaths.Interval <- 'No Data'
    }
    State.Abb <- state
    death.summary <- data.frame(State.Abb, State, Year, Month, Death.Date,
                                Facility, Full.Name, Last.Name, First.Name,
                                ID.No, Sex, Race, Ethnicity, DoB, DoB.Year,
                                Death.Age, Circumstance.General, Circumstance.Specific, Circumstance.Other,
                                Location, Total.Deaths, UCLA.ID, Deaths.Start, Deaths.End, Deaths.Interval)
    
    if(dem.file.test == 0) {
        ## Summarize Decedent Info in Absent
        Demographics <- 'No'
        Demographics.Start <- 'No Data'
        Demographics.End <- 'No Data'
    }
    
    if(dem.file.test == 1) {
        ## Summarize Decedent Info in Files
        state.data.category <- dem.file.frame %>%
            .[1,'Data.Category']
        state.dem.file <- dem.file.frame %>%
            .[1, 'Files']
        state.dem <- state.dem.file %>%
            read.csv() %>%
            mutate(Date = as.Date(Date, format = '%Y-%m-%d'))
        Demographics <- 'Yes'
        Demographics.Start <- state.dem$Date %>%
            min() %>%
            as.character()
        Demographics.End <- state.dem$Date %>%
            max() %>%
            as.character()
        
    }
    
    if(dem.file.test > 1) {
        ## Summarize Decedent Info in Files
        state.data.category <- dem.file.frame %>%
            .[1,'Data.Category']
        state.age.file <- dem.file.frame %>%
            subset(Data.Type == 'Age') %>%
            .[1, 'Files']
        state.sex.file <- dem.file.frame %>%
            subset(Data.Type == 'Sex') %>%
            .[1, 'Files']
        state.age <- state.age.file %>%
            read.csv()
        state.sex <- state.sex.file %>%
            read.csv()
        state.dem <- state.age %>%
            plyr::rbind.fill(., state.sex)
        Demographics <- 'Yes'
        Demographics.Start <- state.dem$Date %>%
            min() %>%
            as.character()
        Demographics.End <- state.dem$Date %>%
            max() %>%
            as.character()
    }
    
    dem.summary <- data.frame(State.Abb, Demographics, Demographics.Start, Demographics.End)
    
    out.summary <- death.summary %>%
        left_join(., dem.summary, by = c('State.Abb'))
    
    return(out.summary)
} # end function

update_mortality_summary_sheet <- function(mortality_sheet_loc) {
    CMP.summary <- summarize_CMP_data()
    
    range_write(
        data = CMP.summary, 
        ss = mortality_sheet_loc, 
        sheet = "Summary", 
        reformat = FALSE)
}

interpolate_CMP_dem <- function(demographics) {
    
    demographics <- demographics %>%
        mutate(Date = as.Date(Date, format = '%Y-%m-%d'))
    
    start.date <- min(demographics$Date)
    end.date <- max(demographics$Date)
    
    state <- demographics[1,'State']
    
    out <- demographics %>%
        #mutate(Date = as.Date(Date, format = '%Y-%m-%d')) %>%
        arrange(Date) %>%
        complete(Sex, Standard.Groups, Date = seq.Date(start.date, end.date, by = 'day')) %>%
        arrange(Date) %>%
        group_by(Sex, Standard.Groups) %>%
        mutate(Number = na.approx(Number, na.rm = FALSE),
               Number = as.integer(Number),
               State = state,
               Month = month.name[month(Date)],
               Year = year(Date)) %>%
        select(State, Year, Month, Date, Sex, Standard.Groups, Number)
    
    return(out)
}

pull_CMP_age_rate <- function(state) {
    dem <- harmonize_CMP_dem(agencies = c(state))
    deaths <- harmonize_CMP_deaths(agencies = c(state))
    
    suppressMessages(
    dem.load <- dem %>%
        interpolate_CMP_dem() %>%
        group_by(Year, Month, Date, Standard.Groups) %>%
        summarise(Number = sum(Number, na.rm = TRUE)) %>%
        arrange(Year, Month, Date, Standard.Groups) %>%
        group_by(Year, Month, Standard.Groups) %>%
        filter(row_number()==1) %>%
        rename(Population = Number)
    )
    
    suppressMessages(
    death.load <- deaths %>%
        group_by(Year, Month, Standard.Age.Group) %>%
        summarise(Deaths = n()) %>%
        mutate(Date = ymd(str_c(Year, "-", Month, "-1"))) %>%
        rename(Standard.Groups = Standard.Age.Group) %>%
        subset(select = -c(Year, Month))
    )
    
    
    join <- dem.load %>%
        left_join(death.load, by = c('Date', 'Standard.Groups')) %>%
        mutate(Deaths = ifelse(is.na(Deaths), 0, Deaths)) %>%
        subset(select = -c(Year, Month))
    suppressMessages(
    out <- join %>%
        group_by(Date, Standard.Groups) %>%
        summarise_all(sum) %>%
        mutate(Rate = Deaths/Population*100000,
               State.Abb = state) %>%
        arrange(desc(Rate)) %>%
        select(State.Abb, everything())
    )
    
    return(out)
    
    
}

pull_CMP_fac_data <- function(death.data) {
    death.cols <- death.data %>%
        colnames()
    
    suppressWarnings(
        cmp.facility.data <- 'Crosswalks/CMP_fac_data.csv' %>%
            read_csv() 
    )
    suppressWarnings(
        hifld.facility.data <- 'Data/External/hifld_prison_boundaries_2022.csv' %>%
            read_csv() 
    )
    suppressWarnings(
        covid.fac.data <- 'https://raw.githubusercontent.com/uclalawcovid19behindbars/facility_data/master/data/fac_data.csv' %>%
            read_csv() %>%
            select(Facility.ID,Jurisdiction, Population.Feb20,Capacity,Source.Population.Feb20,Source.Capacity,Longitude,Latitude)
    )
    
    if('UCLA.ID' %in% death.cols) {
        out <- death.data %>%
            left_join(., cmp.facility.data, by = c('UCLA.ID' = 'CMP.ID')) %>% 
            left_join(., covid.fac.data, by = c('UCLA.ID' = 'Facility.ID')) %>%
            left_join(.,hifld.facility.data, by = c('HIFLD.ID' = 'FACILITYID'))
        
    } else {
        print('WARNING: CMP Facility.IDs have not been integrated into this dataset. Please inspect entered data. Returning original data.')
        out <- death.data
    }
    
    return(out)
    
    
}

pull_harmonize_interpolate <- function(state) {
    #state <- states.w.dem$State.Abb[24]
    out <- state %>%
        harmonize_CMP_dem() %>%
        interpolate_CMP_dem()
    return(out)
}

calculate_monthly_rate <- function(pop.source) {
    summary <- summarize_CMP_data()
    states.w.dem <- summary %>%
        subset(!str_detect('No', Demographics) &
                   !str_detect('No', Year) &
                   !str_detect('IA', State.Abb) &
                   !str_detect('WA', State.Abb) &
                   !str_detect('WV', State.Abb) &
                   !str_detect('VA', State.Abb) &
                   !str_detect('SC', State.Abb))  # These state demographics currently cannot be loaded for rate calculations 
    
    if(pop.source == 'UCLA') {
        suppressMessages(
            harmonized.population <- states.w.dem$State.Abb %>%
                lapply(., pull_harmonize_interpolate) %>%
                rbindlist() 
        )
        suppressMessages(
            clean.population <- harmonized.population %>%
                group_by(State, Year, Month, Date) %>%
                summarise(Population = sum(Number, na.rm = TRUE)) %>%
                group_by(State, Year, Month) %>%
                summarise(Avg.Population = round(mean(Population)))
        )
        
    }
    
    if(pop.source == 'Vera') {
        clean.population <- interpolate_vera_dem() %>%
            group_by(State, Year, Month, Date) %>%
            summarise(Population = sum(Population, na.rm = TRUE)) %>%
            group_by(State, Year, Month) %>%
            summarise(Avg.Population = round(mean(Population))) #%>%
            #filter(State %in% states.w.dem$State.Name)
        
        
    }
    states.to.read <- summarize_CMP_data()
    states.to.read <- states.to.read %>%
        subset(Month == 'Yes')
    states.to.read <- states.to.read$State.Abb
    suppressMessages(
        read.deaths <- read_CMP_deaths(all.agencies = FALSE, agencies = c(states.to.read))
    )
    suppressMessages(
        clean.deaths <- read.deaths %>%
            group_by(State, Year, Month) %>%
            summarise(Total.Deaths = sum(Total.Deaths))
    )
    
    combined <- clean.population %>%
        left_join(., clean.deaths, by = c('State', 'Year', 'Month')) %>%
        mutate(Rate = Total.Deaths/Avg.Population*10000)  %>%
        arrange(desc(Rate))
    
    return(combined)
    
}

calculate_annual_rate <- function(pop.source) {
    summary <- summarize_CMP_data()
    
    # Process Demographic Data
    if(pop.source == 'UCLA') {
        states.w.dem <- summary %>%
            subset(!str_detect('No', Demographics) &
                       !str_detect('No', Year) &
                       !str_detect('IA', State.Abb) &
                       !str_detect('WA', State.Abb) &
                       !str_detect('WV', State.Abb) &
                       !str_detect('AR', State.Abb) &
                       !str_detect('VA', State.Abb) &
                       !str_detect('SC', State.Abb)) 
        
        suppressMessages(
            harmonized.population <- states.w.dem$State.Abb %>%
                lapply(., pull_harmonize_interpolate) %>%
                rbindlist() 
        )
        suppressMessages(
            clean.population <- harmonized.population %>%
                group_by(State, Year, Month, Date) %>%
                summarise(Population = sum(Number, na.rm = TRUE)) %>%
                group_by(State, Year) %>%
                summarise(Avg.Population = round(mean(Population)))
        )
        
    }
    
    if(pop.source == 'Vera') {
        
        clean.population <- interpolate_vera_dem() %>%
            group_by(State, Year, Month, Date) %>%
            summarise(Population = sum(Population, na.rm = TRUE)) %>%
            group_by(State, Year) %>%
            summarise(Avg.Population = round(mean(Population))) 
        
    }
    # Process Death Data
    
    suppressMessages(
        read.deaths <- read_CMP_deaths(all.agencies = TRUE)
    )
    
    
    combined <- clean.population %>%
        left_join(., read.deaths, by = c('State', 'Year')) %>%
        mutate(Rate = Total.Deaths/Avg.Population*10000)  %>%
        subset(!is.na(Total.Deaths)) %>%
        arrange(desc(Rate))
    
    return(combined)
    
}

interpolate_vera_dem <- function() {
    vera.cols <- c('State.Abb', 'State', 'December.2018', 'December.2019',
                   'March.2020', 'May.2020', 'July.2020', 'October.2020',
                   'January.2021', 'April.2021')
    suppressWarnings(
        vera.pop <- 'Data/External/vera_pjp_s2021_appendix.csv' %>%
            read_csv() %>%
            set_colnames(vera.cols) %>%
            subset(!is.na(December.2018) &
                       State.Abb != 'State') %>%
            melt(id.vars = c('State.Abb', 'State')) %>%
            mutate(variable = as.character(variable),
                   Date = case_when(
                       str_detect('December.2018', variable) ~ '2018-12-31',
                       str_detect('December.2019', variable) ~ '2019-12-31',
                       str_detect('March.2020', variable) ~ '2020-03-31',
                       str_detect('May.2020', variable) ~ '2020-05-01',
                       str_detect('July.2020', variable) ~ '2020-06-01',
                       str_detect('October.2020', variable) ~ '2020-10-01',
                       str_detect('January.2021', variable) ~ '2021-01-01',
                       str_detect('April.2021', variable) ~ '2021-04-01'
                   ),
                   Date = as.Date(Date, format = '%Y-%m-%d'),
                   Population = value
            ) %>%
            select(State.Abb, State, Date, Population) %>%
            arrange(State, Date) %>%
            complete(State, Date = seq(as.Date('2018-12-31', format = '%Y-%m-%d'), 
                                       as.Date('2021-04-01', format = '%Y-%m-%d'),
                                       by = 'day')) %>%
            group_by(State) %>%
            mutate(Population = na.approx(Population, na.rm = FALSE),
                   Population = as.integer(Population),
                   Month = month.name[month(Date)],
                   Year = year(Date)) %>%
            select(-c(State.Abb))
    )
    
    return(vera.pop)
    
    
}

calculate_annual_facility_rate <- function() {
    summary <- summarize_CMP_data()
    
    states.w.id <- summary %>% subset(UCLA.ID == 'Yes')
    
    # Process Death Data
    
    suppressMessages(
        read.deaths <- states.w.id$State.Abb %>%
            lapply(., read_CMP_deaths, all.agencies = FALSE) %>%
            rbindlist(fill = TRUE) 
    )
    
    suppressMessages( 
        clean.deaths <- read.deaths %>%
            group_by(State, UCLA.ID, Year) %>%
            summarise(Deaths = n())
    )
    
    suppressWarnings(
        cmp.facility.data <- 'Crosswalks/CMP_fac_data.csv' %>%
            read_csv() 
    )
    suppressWarnings(
        hifld.facility.data <- 'Data/External/hifld_prison_boundaries_2022.csv' %>%
            read_csv() 
    )
    suppressWarnings(
        covid.fac.data <- 'https://raw.githubusercontent.com/uclalawcovid19behindbars/facility_data/master/data/fac_data.csv' %>%
            read_csv() %>%
            select(Facility.ID,Jurisdiction, Population.Feb20,Capacity,Source.Population.Feb20,Source.Capacity,Longitude,Latitude)
    )
    
    out.deaths <- clean.deaths %>%
        left_join(., cmp.facility.data, by = c('UCLA.ID' = 'CMP.ID')) %>% 
        left_join(., covid.fac.data, by = c('UCLA.ID' = 'Facility.ID')) %>%
        left_join(.,hifld.facility.data, by = c('HIFLD.ID' = 'FACILITYID')) %>%
        subset(!is.na(HIFLD.NAME)) %>%
        mutate(POPULATION = ifelse(POPULATION <0, NA, POPULATION),
               CAPACITY = ifelse(CAPACITY <0, NA, CAPACITY),
               HIFLD.Capacity.Ratio = POPULATION/CAPACITY,
               #Name = ifelse(is.na(Name), 'ALL NON MATCHING FACILITIES TO UCLA', Name),
               HIFLD.Mortality.Rate.Pop = Deaths/POPULATION*10000,
               HIFLD.Mortality.Rate.Cap = Deaths/CAPACITY*10000,
               Feb20.Mortality.Rate.Pop = Deaths/Population.Feb20*10000,
               UCLA.ID = as.character(UCLA.ID)) %>%
        select(State, Year, UCLA.ID, NAME, Deaths, 
               POPULATION, CAPACITY, Population.Feb20, Capacity, 
               HIFLD.Capacity.Ratio, HIFLD.Mortality.Rate.Pop, HIFLD.Mortality.Rate.Cap, 
               Feb20.Mortality.Rate.Pop,
               SECURELVL, TYPE) %>%
        rename('HIFLD.Population' = 'POPULATION',
               'HIFLD.Capacity' = 'CAPACITY') %>%
        arrange(desc(Feb20.Mortality.Rate.Pop))
    
    
    return(out.deaths)
    
}

calculate_monthly_facility_rate <- function() {
    summary <- summarize_CMP_data()
    
    states.w.id <- summary %>% subset(UCLA.ID == 'Yes')
    
    # Process Death Data
    
    suppressMessages(
        read.deaths <- states.w.id$State.Abb %>%
            lapply(., read_CMP_deaths, all.agencies = FALSE) %>%
            rbindlist(fill = TRUE) 
    )
    
    suppressMessages( 
        clean.deaths <- read.deaths %>%
            group_by(State, UCLA.ID, Year, Month) %>%
            summarise(Deaths = n())
    )
    suppressWarnings(
        cmp.facility.data <- 'Crosswalks/CMP_fac_data.csv' %>%
            read_csv() 
    )
    suppressWarnings(
        hifld.facility.data <- 'Data/External/hifld_prison_boundaries_2022.csv' %>%
            read_csv() 
    )
    suppressWarnings(
        covid.fac.data <- 'https://raw.githubusercontent.com/uclalawcovid19behindbars/facility_data/master/data/fac_data.csv' %>%
            read_csv() %>%
            select(Facility.ID,Jurisdiction, Population.Feb20,Capacity,Source.Population.Feb20,Source.Capacity,Longitude,Latitude)
    )
    
    out.deaths <- clean.deaths %>%
        left_join(., cmp.facility.data, by = c('UCLA.ID' = 'CMP.ID')) %>% 
        left_join(., covid.fac.data, by = c('UCLA.ID' = 'Facility.ID')) %>%
        left_join(.,hifld.facility.data, by = c('HIFLD.ID' = 'FACILITYID')) %>%
        subset(!is.na(HIFLD.NAME)) %>%
        mutate(POPULATION = ifelse(POPULATION <0, NA, POPULATION),
               CAPACITY = ifelse(CAPACITY <0, NA, CAPACITY),
               HIFLD.Capacity.Ratio = POPULATION/CAPACITY,
               #Name = ifelse(is.na(Name), 'ALL NON MATCHING FACILITIES TO UCLA', Name),
               HIFLD.Mortality.Rate.Pop = Deaths/POPULATION*10000,
               HIFLD.Mortality.Rate.Cap = Deaths/CAPACITY*10000,
               Feb20.Mortality.Rate.Pop = Deaths/Population.Feb20*10000,
               UCLA.ID = as.character(UCLA.ID)) %>%
        select(State, Year, Month, UCLA.ID, NAME, Deaths, 
               POPULATION, CAPACITY, Population.Feb20, Capacity, 
               HIFLD.Capacity.Ratio, HIFLD.Mortality.Rate.Pop, HIFLD.Mortality.Rate.Cap, 
               Feb20.Mortality.Rate.Pop,
               SECURELVL, TYPE) %>%
        rename('HIFLD.Population' = 'POPULATION',
               'HIFLD.Capacity' = 'CAPACITY') %>%
        arrange(desc(Feb20.Mortality.Rate.Pop))
    
    
    return(out.deaths)
    
}

