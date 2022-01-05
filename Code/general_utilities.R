#### UCLA Prison Mortality Utilities

#### Set Environment -----------------------------------
library(tidyverse)
library(httr)
library(magrittr)
library(reshape2)
library(lubridate)
library(data.table)

#### Functions -----------------------------------------

## Read in BJS Historical Decedent Data ------------

read_bjs <- function(all.agencies, agencies) {
    suppressMessages(suppressWarnings(mci.19 <- 'Data/External/msfp0119stt14.csv' %>%
               read_csv() %>%
               subset(!is.na(X3)) %>%
               mutate(Jurisdiction = coalesce(`Bureau of Justice Statistics`, X2)) %>%
               select(-c(`Bureau of Justice Statistics`, X2))
    ))
    mci.cols <- mci.19[1,]
    suppressMessages(suppressWarnings(mci.19 <- mci.19 %>%
              set_colnames(mci.cols) %>%
              melt() %>%
              mutate(Jurisdiction = str_replace_all(Jurisdiction, '\\/.*', '')) %>%
              subset(!str_detect(Jurisdiction, 'Jurisdiction') & !str_detect(Jurisdiction, 'State')) %>%
              set_colnames(c('Jurisdiction', 'Year', 'Total.Deaths'))
    ))
    
    if(all.agencies == TRUE) {
        print('Pulling all annual agency data from BJS')
    }
    
    if(all.agencies == FALSE) {
        mci.19 <- mci.19 %>%
            subset(Jurisdiction %in% agencies)
        print('Pulling specific agency data from BJS for:')
    }
    
    mci.19 <- mci.19 %>%
              plyr::rename(c('Jurisdiction' = 'State')) %>%
              as.data.frame()
    mci.19$Year <- as.numeric(as.character(mci.19$Year))
    mci.19
    
}

# Read in UCLA Historical Decedent Data -------------------------

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
        agencies <- c('UT', 'MN', 'AR', 'GA', 'NV', 'NC')
        # set selected states from user
        input <- agencies
        # create file frame of selected states
        file.list <- all.files %>%
            select(Files, Data.Type) %>%
            mutate(Files = str_c('Data/Raw/Deaths/', Data.Type, '/', Files),
                   State = str_replace_all(Files, '-.*', ''),
                   State = str_replace_all(State, 'Data\\/Raw\\/Deaths\\/', ''),
                   State = str_replace_all(State, '.*\\/', '')) %>%
            subset(State %in% input) %>%
            subset(!str_detect(Files, 'UT-Yearly')) # remove less detailed UT data for alternative aggregates
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












