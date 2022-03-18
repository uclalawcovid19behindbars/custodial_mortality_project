#### UCLA Prison Mortality Utilities

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
    ## Load Last MCI
    suppressMessages(suppressWarnings(mci.19 <- 'Data/External/msfp0119stt14.csv' %>%
                                          read_csv() %>%
                                          subset(!is.na(X3)) %>%
                                          mutate(Jurisdiction = coalesce(`Bureau of Justice Statistics`, X2)) %>%
                                          select(-c(`Bureau of Justice Statistics`, X2))
    ))
    ## Clean Last MCI
    mci.cols <- mci.19[1,]
    suppressMessages(suppressWarnings(mci.19 <- mci.19 %>%
                                          set_colnames(mci.cols) %>%
                                          melt() %>%
                                          mutate(Jurisdiction = str_replace_all(Jurisdiction, '\\/.*', '')) %>%
                                          subset(!str_detect(Jurisdiction, 'Jurisdiction') & !str_detect(Jurisdiction, 'State')) %>%
                                          set_colnames(c('State', 'Year', 'Total.Deaths'))
    ))
    
    mci.19 <- mci.19 %>%
        as.data.frame()
    mci.19$Year <- as.numeric(as.character(mci.19$Year))
    mci.19
}

read_nps_20 <- function() {
    nps.cols <- c('Label', 'State', 'Pop.2019', 'Pop.2020', 'Change.2020', 'Pct.Change.2020',
                  'Drop', 'Unc.Releases.2019', 'Unc.Releases.2020', 'Con.Releases.2019', 'Con.Releases.2020',
                  'Deaths.2019', 'Deaths.2020')
    nps.clean <- c('Pop.2019', 'Pop.2020', 'Unc.Releases.2019', 'Unc.Releases.2020', 'Con.Releases.2019', 'Con.Releases.2020')
    
    suppressMessages(suppressWarnings(
        nps.20 <- 'Data/External/p20stt09.csv' %>%
        read_csv() %>%
        set_colnames(nps.cols) %>%
        subset(!is.na(State)) %>%
        select(-c(Drop, Label, Change.2020, Pct.Change.2020)) %>%
        mutate(Deaths.2019 = as.numeric(Deaths.2019),
               Deaths.2020 = as.numeric(Deaths.2020),
               State = str_replace_all(State, '\\/.*', '')) %>%
        mutate_at(nps.clean, ~as.numeric(str_replace_all(., ',', ''))) %>%
        subset(!is.na(Deaths.2019))
    ))
    
    nps.20
    
}

read_bjs <- function(all.agencies, agencies) {
    ## Load Last MCI
    mci.19 <- read_mci_19()
    
    ## Load Last NPS
    nps.20 <- read_nps_20()
    
    ## Prep MCI Data
    mci.clean <- mci.19 %>%
                 subset(Year != 2019)
    
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
    bjs.data <- mci.clean %>%
                rbind(nps.clean)

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

## Read in UCLA Historical Decedent Data -------------------------

# sub functions for read_ucla_data

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

# Make default year aggregate function - for default all sum in read_ucla_deaths [read_to_year()]
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

# Make default month aggregate function - for default all sum in read_ucla_deaths [read_to_year()]
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

# Make defaults individual aggregate function - for default all sum in read_ucla_deaths [read_to_year()]
only.year.individual <- function(x) {
    read <- x %>%
        read.csv() %>%
        group_by(State, Year) %>%
        summarise(Total.Deaths = n())
}

# Read to Year aggregate function (default operation)
read_to_year <- function(file.base) {
    file.list <- file.base %>%
                 subset(Files != 'UT-Monthly') %>% # remove more detailed UT data for yearly based aggregate
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


read_ucla_deaths <- function(all.agencies, agencies) {
    
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
    print('Summarized by years of data available for all agencies from UCLA')
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
           print('Aggregated annually')
        })
        # For yearly only
        suppressMessages(
        if(('Annual' %in% file.list$Data.Type) &
           !('Monthly' %in% file.list$Data.Type) &
           !('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, sum.to.year)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print('Aggregated annually')
        })
        # For monthly only
        suppressMessages(
        if(!('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           !('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, sum.to.month)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print('Aggregated monthly')
        })
        # For individual only
        suppressMessages(
        if(!('Annual' %in% file.list$Data.Type) &
           !('Monthly' %in% file.list$Data.Type) &
           ('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, read.csv)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print('All individual level, no aggregation')
        })
        # For yearly and monthly
        suppressMessages(
        if(('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           !('Individual' %in% file.list$Data.Type)){
            output.list <- lapply(file.list$Files, sum.to.year)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print('Aggregated annually')
        })
        # For monthly and individual
        suppressMessages(
        if(!('Annual' %in% file.list$Data.Type) &
           ('Monthly' %in% file.list$Data.Type) &
           ('Individual' %in% file.list$Data.Type)) {
            output.list <- lapply(file.list$Files, sum.to.month)
            output.deaths <- rbindlist(output.list, fill = TRUE)
            print('Aggregated monthly')
        })
    }
    output.deaths
}
    
## Compare Annual BJS Numbers with Aggregated UCLA numbers -----------------

compare_ucla_bjs <- function() {
    bjs.data <- read_bjs(all.agencies = TRUE) 
    bjs.data <- bjs.data %>%
                plyr::rename(c('Total.Deaths' = 'BJS.Deaths'))
    ucla.data <- read_ucla_deaths(all.agencies = TRUE) 
    ucla.data <- ucla.data %>%
                 plyr::rename(c('Total.Deaths' = 'UCLA.Deaths'))
    joined.data <- ucla.data %>%
                   left_join(., bjs.data, by = c('State', 'Year')) %>%
                   mutate(Absolute.Difference = abs(UCLA.Deaths-BJS.Deaths)) %>%
                   subset(Year < 2021) %>%
                   arrange(desc(Absolute.Difference))
    joined.data
    
}

## Read in UCLA Historical Demograpahic Data -------------------

read_ucla_dem <- function(all.agencies, agencies) {
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
        print('Pulling UCLA demographic data for all agencies')
        dem.out <- dem.pull
    }
    
    if(all.agencies == FALSE){
        input <- agencies
        dem.out <- dem.pull[dem.pull$State.Abb %in% input,]
        print('Pulling UCLA demographic data for specific agencies')
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

## Harmonize a Deaths and Demographics dataset from UCLA ----------------------------
# Current datasets of interest to Harmonize for standardized analysis: 
# AZ, GA, IL, MA (needs sex), MI, MS (needs DoB), MT, NC, NV, NY (needs demographics), OK, PA (missing DoB), WV

harmonize_ucla_deaths <- function(agencies) {
    # function testing
    # input <- c('AZ', 'GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV')
    input <- agencies
    ucla.deaths <- read_ucla_deaths(all.agencies = FALSE, agencies = input)
    ucla.dem <- read_ucla_dem(all.agencies = FALSE, agencies = input)
    
    if(!('Sex' %in% colnames(ucla.deaths))) {
        ucla.deaths <- ucla.deaths %>%
                       mutate(Sex = NA)
    }
    
    ucla.deaths.i <- ucla.deaths %>%
                    mutate(Sex = ifelse(str_detect(Sex, 'F'), 'Female', Sex),
                           Sex = ifelse((Sex != 'Female' & !is.na(Sex)), 'Male', Sex)) # Harmonize sex
    if(!('DoB.Year' %in% colnames(ucla.deaths.i)) & !('Death.Age' %in% colnames(ucla.deaths.i))) {
        ucla.deaths.i <- ucla.deaths.i %>%
                         mutate(DoB.Year = NA)
    } 
    
    if(!('DoB' %in% colnames(ucla.deaths.i)) & 'Death.Age' %in% colnames(ucla.deaths.i)) {
        ucla.deaths.i <- ucla.deaths.i %>%
            mutate(DoB.Year = year(Death.Date) - Death.Age,
                   DoB = NA) 
    } 
    
    if(!('DoB.Year' %in% colnames(ucla.deaths.i)) & ('DoB' %in% colnames(ucla.deaths.i))) {
        ucla.deaths.i <- ucla.deaths.i %>%
            mutate(DoB.Year = NA)
    } 
    
    if(!('DoB' %in% colnames(ucla.deaths.i)) & 'DoB.Year' %in% colnames(ucla.deaths.i)) {
        ucla.deaths.i <- ucla.deaths.i %>%
            mutate(DoB = NA) 
    } 
    
    if(!('Death.Age' %in% colnames(ucla.deaths.i))) {
        ucla.deaths.i <- ucla.deaths.i %>%
                         mutate(Death.Age = NA) 
    } 
    
    ucla.deaths.h <- ucla.deaths.i %>%
                    mutate(DoB.Year = str_c(str_c(DoB.Year, '-01', '-01')),
                           DoB.Combined = coalesce(DoB, DoB.Year)) %>%
                    mutate(Death.Age = ifelse((is.na(Death.Age) & !is.na(DoB.Combined)), (as.Date(Death.Date, format = '%Y-%m-%d') - as.Date(DoB.Combined, format = '%Y-%m-%d'))/365, Death.Age))
    
    ucla.dem.h <- ucla.dem %>%
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
    
    dem.group.frame <- ucla.dem.h %>%
        select(State, Start.Age, End.Age, Standard.Groups) %>%
        unique()
    
    ucla.death.groups <- ucla.deaths.h %>%
                         left_join(., dem.group.frame, by = c('State')) %>%
                         mutate(Standard.Age.Group = ifelse((Death.Age <= End.Age & Death.Age >= Start.Age), Standard.Groups, 'Remove')) %>%
                         subset(Standard.Age.Group != 'Remove') %>%
                         select(-c(Start.Age, End.Age, Standard.Groups))
    
   ucla.death.groups
    
}

harmonize_ucla_dem <- function(agencies) {
    # function testing
    # input <- c('AZ', 'GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV', 'NY')
    input <- agencies
    ucla.dem <- read_ucla_dem(all.agencies = FALSE, agencies = input)
    
    ucla.dem.h <- ucla.dem %>%
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
    
    ucla.dem.h
}

summarize_ucla_data <- function() {
    ## Set up state match dataframe
    states <- data.frame(State.Abb = state.abb,
                         State.Name = state.name)
    summary.file <- lapply(states$State.Abb, summarize_ucla_state) %>%
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

summarize_ucla_state <- function(state) {
    
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
                                'Location', 'Total.Deaths')
        
        sapply(variables.to.check, check_variable, columns = state.variables)
        
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
    }
    State.Abb <- state
    death.summary <- data.frame(State.Abb, State, Year, Month, Death.Date,
                                Facility, Full.Name, Last.Name, First.Name,
                                ID.No, Sex, Race, Ethnicity, DoB, DoB.Year,
                                Death.Age, Circumstance.General, Circumstance.Specific, Circumstance.Other,
                                Location, Total.Deaths)
    
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
    ucla.summary <- summarize_ucla_data()
    
    range_write(
        data = ucla.summary, 
        ss = mortality_sheet_loc, 
        sheet = "Summary", 
        reformat = FALSE)
}

interpolate_ucla_dem <- function(demographics) {
    
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

pull_ucla_age_rate <- function(state) {
    dem <- harmonize_ucla_dem(agencies = c(state))
    deaths <- harmonize_ucla_deaths(agencies = c(state))
    
    suppressMessages(
    dem.load <- dem %>%
        interpolate_ucla_dem() %>%
        group_by(Year, Month, Standard.Groups) %>%
        filter(row_number()==1) %>%
        group_by(Date, Standard.Groups) %>%
        summarise(Number = sum(Number)) %>%
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
        mutate(Deaths = ifelse(is.na(Deaths), 0, Deaths)) #%>%
    #subset(select = -c(State, Year, Month))
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

pull_ucla_fac_data <- function(death.data) {
    ucla.fac <- 'https://raw.githubusercontent.com/uclalawcovid19behindbars/facility_data/master/data/fac_data.csv' %>%
        read_csv() %>%
        select(-c(State))
    
    death.cols <- death.data %>%
        colnames()
    
    if('UCLA.ID' %in% death.cols) {
        out <- death.data %>%
            left_join(., ucla.fac, by = c('UCLA.ID' = 'Facility.ID'))
        
    } else {
        print('WARNING: UCLA Facility.IDs have not been integrated into this dataset. Please inspect entered data. Returning original data.')
        out <- death.data
    }
    
    return(out)
    
    
}

pull_harmonize_interpolate <- function(state) {
    #state <- states.w.dem$State.Abb[24]
    out <- state %>%
        harmonize_ucla_dem() %>%
        interpolate_ucla_dem()
    return(out)
}

calculate_monthly_rate <- function(pop.source) {
    summary <- summarize_ucla_data()
    states.w.dem <- summary %>%
        subset(!str_detect('No', Demographics) &
                   !str_detect('No', Year) &
                   !str_detect('IA', State.Abb) &
                   !str_detect('WA', State.Abb) &
                   !str_detect('WV', State.Abb) &
                   !str_detect('AR', State.Abb) &
                   !str_detect('VA', State.Abb)) # Iowa has weird dem data 
    
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
                summarise(Population = mean(Population))
        )
        
    }
    
    if(pop.source == 'Vera') {
        clean.population <- interpolate_vera_dem() %>%
            group_by(State, Year, Month, Date) %>%
            summarise(Population = sum(Population, na.rm = TRUE)) %>%
            group_by(State, Year, Month) %>%
            summarise(Population = mean(Population)) %>%
            filter(State %in% states.w.dem$State.Name)
        
        
    }
    
    suppressMessages(
        read.deaths <- states.w.dem$State.Abb %>%
            lapply(., read_ucla_deaths, all.agencies = FALSE) %>%
            rbindlist(fill = TRUE) 
    )
    suppressMessages(
        clean.deaths <- read.deaths %>%
            group_by(State, Year, Month) %>%
            summarise(Deaths = n())
    )
    
    combined <- clean.population %>%
        left_join(., clean.deaths, by = c('State', 'Year', 'Month')) %>%
        mutate(Rate = Deaths/Population*10000,
               Deaths = ifelse((Year<=2020)&is.na(Deaths), 0, Deaths))  %>%
        arrange(desc(Rate))
    
    return(combined)
    
}

calculate_annual_rate <- function(pop.source) {
    summary <- summarize_ucla_data()
    states.w.dem <- summary %>%
        subset(!str_detect('No', Demographics) &
                   !str_detect('No', Year) &
                   !str_detect('IA', State.Abb) &
                   !str_detect('WA', State.Abb) &
                   !str_detect('WV', State.Abb) &
                   !str_detect('AR', State.Abb) &
                   !str_detect('VA', State.Abb)) # Iowa has weird dem data 
    
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
                group_by(State, Year) %>%
                summarise(Population = mean(Population))
        )
        
    }
    
    if(pop.source == 'Vera') {
        clean.population <- interpolate_vera_dem() %>%
            group_by(State, Year, Month, Date) %>%
            summarise(Population = sum(Population, na.rm = TRUE)) %>%
            group_by(State, Year) %>%
            summarise(Population = mean(Population)) %>%
            filter(State %in% states.w.dem$State.Name)
        
        
    }
    
    suppressMessages(
        read.deaths <- states.w.dem$State.Abb %>%
            lapply(., read_ucla_deaths, all.agencies = FALSE) %>%
            rbindlist(fill = TRUE) 
    )
    suppressMessages(
        clean.deaths <- read.deaths %>%
            group_by(State, Year) %>%
            summarise(Deaths = n())
    )
    
    combined <- clean.population %>%
        left_join(., clean.deaths, by = c('State', 'Year')) %>%
        mutate(Rate = Deaths/Population*10000,
               Deaths = ifelse((Year<=2020)&is.na(Deaths), 0, Deaths))  %>%
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

