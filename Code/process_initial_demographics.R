## Prep Custodial Demographics

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


list_to_csv <- function(list, destination) {
    run.length <- list %>%
        length()
    names.to.assign <- list %>%
        names()
    for (k in 2:run.length) {
        out.data <- list[k] %>%
            as.data.frame() 
        clean.names <- out.data %>%
            colnames() %>%
            as.data.frame() %>%
            plyr::rename(c('.' = 'cols')) %>%
            mutate(cols = ifelse(!str_detect(cols, 'Group'), str_replace_all(cols, '.*Age\\.', ''), cols)) %>%
            mutate(cols = ifelse(!str_detect(cols, 'Group'), str_replace_all(cols, '.*Sex\\.', ''), cols)) %>%
            mutate(cols = ifelse(str_detect(cols, 'Group'), str_sub(cols, str_length(cols)-8, str_length(cols)), cols)) 
        clean.names <- clean.names$cols
        colnames(out.data) <- clean.names
        
        out.data <- out.data %>%
            mutate(Number = trunc(as.numeric(Number))) #%>%
            mutate(Date = as.Date(Date, ))

        if(str_detect(names.to.assign[k], 'Age') & str_detect(names.to.assign[k], 'Sex')) write_csv(out.data, str_c(destination, 'Combined/', names.to.assign[k], '.csv'))
        if(str_detect(names.to.assign[k], 'Age') & !str_detect(names.to.assign[k], 'Sex')) write_csv(out.data, str_c(destination, 'Distinct/', names.to.assign[k], '.csv'))
        if(!str_detect(names.to.assign[k], 'Age') & str_detect(names.to.assign[k], 'Sex')) write_csv(out.data, str_c(destination, 'Distinct/', names.to.assign[k], '.csv'))
    }
}


# Load Demographic Data
dem.file <- '/Users/michaeleverett/Documents/UCLA/R_PT/deaths_backups/ucla.dem.data.out.xlsx'

dem.list <- dem.file %>%
    read_excel_allsheets()

# Write New Death Data to Repo
dem.list %>%
    list_to_csv(., 'Data/Raw/Demographics/')








