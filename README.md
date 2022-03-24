

## UCLA Law CBBDP Carceral Mortality Data

The [UCLA Law COVID Behind Bars Data Project](https://uclacovidbehindbars.org/), launched in March 2020, tracks the spread and impact of COVID in American carceral facilities and advocates for greater transparency and accountability around the pandemic response of the carceral system. 

Alongside our [core data](https://github.com/uclalawcovid19behindbars/data), our project gathers and processes data on deaths and demographics in state prisons. We intend to use this data to estimate the 2020 change in all-cause mortality amongst state prison populations. Currently, we have custodial decedent data available through 2020 for 36 U.S. state prison systems. 

## Legislative and oversight background

Passed into law in 2000, the Death in Custody Reporting Act (DCRA) mandates that the U.S. Attorney General collect data on the deaths of individuals under arrest, en route to incarceration, and incarcerated in a local or state correctional facilities (e.g. jails and prisons). Since 2003, the Bureau of Justice Statistics (BJS) has been responsible for collecting information on deaths from local and state correctional agencies and processing this data into standardized reports on annual changes in U.S. prison and jail mortality. While the law was reauthorized in 2014, BJS suspended collection of arrest-related data that year due to data quality concerns. 

In 2019, the Attorney General shifted responsibility for data collection and processing for DCRA to the Bureau of Justice Assistance (BJA). BJA typically provides 'leadership and consultation' to local criminal justice agencies. They do not, historically, collect, process, or produce statistical reports on decedent and demographic data as usually done by BJS. While BJA intends to collect decedent data on a quarterly basis and report data to BJS on an annual basis, it is not clear data quality will be sufficient to produce standardized year-to-year comparisons of mortality in local and state correctional agencies. Given uncertainty on future data availability, BJS is planning to release a report on reported COVID deaths in U.S. prisons and it has released overall numbers of all-cause deaths in prisons through the National Prisoner Statistics Program. Any records collected by BJS and/or BJA regarding individual deaths are protected from FOIA/public records disclosure per 34 U.S.C. §10231(a). 

## About the data

If BJA does not produce public statistical reports on annual changes in U.S. correctional mortality like prior [publications](https://bjs.ojp.gov/data-collection/mortality-correctional-institutions-mci-formerly-deaths-custody-reporting-program) (or does not collect and transfer sufficient data to BJS to do so), the federal government will not produce a report on the 2020 change in standardized all-cause mortality in correctional facilities in the near future. Understanding the change in all-cause mortality in state prisons from 2019 to 2020 is essential to understanding the impact of COVID-19 in U.S. carceral facilities. Here, we centralize and analyze data collected by our project on deaths in state prisons (typically from 2018-2020) and demographics of state prison populations (typically from 2019-2020) to estimate these changes in mortality. Raw data in this repository is broken into `Deaths` and `Demographics`. 

### Data Summary

A summary of the mortality database can be found [here](https://docs.google.com/spreadsheets/d/10STQkTWb3uW_CXVLmVZ5GQ6ppsRmMBZ2y1yd5_eclSI/edit#gid=0).

### Accessing Data

Functions to load and analyze the data can be found in the `general_utilities.R` file in the Code folder.

``` r
# Load all UCLA mortality functions
source('Code/general_utilities.R')

# Load all UCLA decedent data
ucla.data <- read_ucla_deaths(all.agencies = TRUE)

# Load specific UCLA decedent data (function aggregates to least detailed level for time interval)
ucla.data <- read_ucla_deaths(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'AR'))

# Load all BJS decedent data
bjs.data <- read_bjs(all.agencies = TRUE)

# Load specific BJS decedent data
bjs.data <- read_bjs(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'AR'))

# Compare UCLA and BJS decedent data
compare_ucla_bjs()

# Summarize UCLA Mortality Database
summarize_ucla_data()

# Load all UCLA demographic data
ucla.dem <- read_ucla_dem(all.agencies = TRUE)

# Load specific UCLA demographic data
ucla.dem <- read_ucla_dem(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'AR'))

# Harmonize UCLA demographic data (for analysis)
ucla.dem.h <- harmonize_ucla_dem(agencies = c('GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV'))

# Harmonize UCLA decedent data to demographic data (for analysis)
ucla.data.h <- harmonize_ucla_deaths(agencies = c('GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV'))

# Interpolate harmonized UCLA demographic data
'CA' %>%
    harmonize_ucla_dem() %>%
    interpolate_ucla_dem()
    
# Calculate age group mortality rate
'CA' %>%
    pull_ucla_age_rate()
 
# Pull all UCLA facility data for decedent data
'NJ' %>%
    read_ucla_deaths(all.agencies = FALSE,
                     agencies = .) %>%
    pull_ucla_fac_data()
    
# Pull all UCLA facility data for harmonized decedent data
'CA' %>%
    harmonize_ucla_deaths() %>%
    pull_ucla_fac_data()
    
# Calculate monthly mortality rate from available data
# Options: set pop.source to 'Vera' or 'UCLA'
calculate_monthly_rate('UCLA')

monthly.rate <- calculate_monthly_rate(pop.source = 'Vera') %>%
    mutate(Date = as.Date(str_c(Year, '-', Month, '-01'), format = '%Y-%B-%d'))

ggplot() +
    geom_bar(data = monthly.rate, aes(x = Date, y = Rate), stat = 'identity') +
    facet_wrap(~ State) 

# Calculate annual mortality rate from available data
calculate_annual_rate('UCLA')

annual.rate <- calculate_annual_rate(pop.source = 'Vera') 

ggplot() +
    geom_bar(data = annual.rate, aes(x = Year, y = Rate), stat = 'identity') +
    facet_wrap(~ State) 

```

### Potential Death Variables

| Variable               | Description                                                                                                        |
|------------------------|--------------------------------------------------------------------------------------------------------------------|
| `State`                | State prison system                                                                                                |
| `Year`                 | Year of death(s)                                                                                                   |
| `Month`                | Month of death(s)                                                                                                  |
| `Death.Date`           | Date of death(s)                                                                                                   |
| `Facility`             | Facility of death(s)                                                                                               |
| `UCLA.ID`              | Facility ID in UCLA Law CBBDP [COVID Data](https://github.com/uclalawcovid19behindbars/data)                       |
| `Full.Name`            | Full name of decedent                                                                                              |
| `Last.Name`            | Last name of decedent                                                                                              |
| `First.Name`           | First name of decedent                                                                                             |
| `ID.No`                | Agency-assigned ID number of decedent                                                                              |
| `Sex`                  | Sex of decedent                                                                                                    |
| `Race`                 | Race of decedent                                                                                                   |
| `Ethnicity`            | Agency-listed ethnicity                                                                                            |
| `DoB`                  | Date of birth of decedent                                                                                          |
| `DoB.Year`             | Year of birth of decedent                                                                                          |
| `Death.Age`            | Age at death of decedent                                                                                           |
| `Circumstance.General` | General circumstances of death (N.B. not necessarily cause of death)                                               |
| `Circumstance.Specific`| Specific circumstances of death (N.B. not necessarily cause of death)                                              |
| `Circumstance.Other`   | Other circumstances of death (N.B. not necessarily cause of death)                                                 |
| `Location`             | Specific/other listed location of death                                                                            |
| `Total.Deaths`         | For aggregated categories, the total number of deaths                                                              

### Potential Demographic Variables

| Variable               | Description                                                                                                        |
|------------------------|--------------------------------------------------------------------------------------------------------------------|
| `State`                | State prison system                                                                                                |
| `Date`                 | Source date of demographic data                                                                                    |
| `Sex.Group`            | Sex of group                                                                                                       |
| `Age.Group`            | Age of group                                                                                                       |
| `Number`               | Number in group                                                                                                    |
| `Percent`              | Percent of group in overall population (this is used for some states to calculate `Number`)                        |
| `Source`               | Source of demographic information                                                                                  

## Notes on data inconsistencies and issues

This dataset is still evolving as we obtain and assess custodial decedent data from carceral/law enforcement agencies. Agencies do not produce custodial death and demographic data in the same format or on the same level. While we are working to obtain the most detailed and publicly-necessary decedent and demographic data through public records requests, this repository contains our most recent available processed raw data. As such, there are known issues we are working to document and harmonize as we analyze the data. Examples of incosistencies include: (1) New Jersey reporting semi-redacted deaths for the New Jersey Department of Correction's 'Special Treatment Unit' only for 2020 and each accompanied by a note reading 'Do Not Report to Federal Government'; (2) Differences in the total number of/specific deaths reported by the North Carolina Department of Corrections in public records responses compared with their online prison database; and (3) missing variables and observations for certain variables across datasets, among other issues.

Future functions will be written to compare these datafiles with existing data on mortality in state prisons including all prior data reported by BJS while it operated the Mortality in Correctional Institutions (MCI) project. 

## Planned analysis

Estimate 2020 change in all-cause mortality using uneven data. [Research](https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.1002687) using similar methods. 

## Ongoing projects

Integrate data from other existing mortality projects with external collaborators (BoP data w/ NPR);

Integrate Reuters [jail decedent data](https://www.reuters.com/investigates/special-report/usa-jails-graphic/);

Integrate functions in behindbarstools to analyze all-cause decedent data alongside reported COVID data.




