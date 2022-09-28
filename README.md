

## UCLA Law CBBDP Carceral Mortality Data

The [UCLA Law COVID Behind Bars Data Project](https://uclacovidbehindbars.org/), launched in March 2020, tracks the spread and impact of COVID in U.S. carceral facilities and advocates for greater transparency and accountability for the pandemic response behind bars. 

## Purpose of Data Collection

To better monitor the health conditions behind bars, our project began gathering data on all-cause deaths in U.S. prisons in June 2020. Because prison agencies report different records on deaths in custody, we have attempted to standardize records into similar variables so the public can compare what information agencies make available and analyze the data they do release. We hope this repository will be a useful tool for the public and researchers to better understand the phenomenon of deaths in custody and assist policymakers in developing strategies reduce the rising number of deaths in custody.

## Data Collection Procedures

Data on custodial deaths and prison demographics comes from a variety of sources. Where custodial death data is listed publicly on an agency website or where another organization has already collected and processed records on deaths in custody for a particular agency, we have gathered, standardized, and reproduced those records here. 

Examples of U.S. prison agencies that publicly list records on deaths in custody include the Arizona Department of Corrections [link to source](https://corrections.az.gov/inmate-death-notifications) and the Florida Department of Corrections [link to source](http://www.dc.state.fl.us/pub/mortality/index.html). We have reproduced records from the Texas Justice Initiative for deaths in Texas state prisons, Incarceration Transparency at Loyola Law School for deaths in Louisiana state prisons, and the NPR Investigations team for deaths in Bureau of Prisons facilities.

Where information was not publicly available through an agency or another organization, our project used public records requests to gather records on deaths in custody and standardize these records into a uniform database. For each request, we asked for records from 2015 to 2020 and for the following pieces of information for each death:

* Name of individual; 
* Age, race, and sex of individual;
* Date of death;
* Facility to which individual was assigned;
* Location of death (e.g., cell number or hospital name);
* Type of death (e.g., suicide, homicide, accident, drugs/alcohol, illness, other);
* Additional details about death including circumstances, cause of death, and/or details of illness (if illness is listed as type of death).

Two years on, our project has gathered records on all-cause deaths in 49 state prison systems and the Bureau of Prisons (BoP). We have gathered complete data up to the end of 2020 for 47 states and the BoP. Agencies provided different intervals of data on deaths in their facilities. Most state agencies, 40 in total, and the BoP, provided ‘individual-level’ data, meaning records that provide a specific date for each death. In many cases, other variables are tied to that death, like the name, race, or housing facility of the individual. Seven states provided data on prison deaths that were aggregated on a monthly basis. Two agencies provided data that were aggregated on an annual basis. 

Agencies also provided different variables for reported prison deaths. Thirty-nine states provided a name for individual deaths in their prisons. Forty-two states provided the facilities in which deaths occurred. Twenty-six states provided the sexes of decedents, and twenty-three states provided the races of decedents. Thirty-six states provided descriptions of circumstances of deaths. We have created a [summary sheet](https://docs.google.com/spreadsheets/d/10STQkTWb3uW_CXVLmVZ5GQ6ppsRmMBZ2y1yd5_eclSI/edit#gid=0) demonstrating which variables are available by prison agency. As we collect more data, we will update this sheet accordingly.

## Structure and Organization of Data Files

This repository is broken into four primary folders: `Code`, `Data`, `Documents`, and `Graphics`.

### Code 

This folder contains an R script titled 'general_utilities.' This script contains utility functions to help users load death and demographic data, harmonize death data to available demographic data, and compare aggregate totals from records collected here to reports on deaths in custody formerly reported by the Bureau of Justice Statistics in 'Mortality in Correctional Institutions' and 'National Prisoner Statistics' reports.

### Data

This folder contains four sub-folders: `External`, `Other`, `Output`, and `Raw`. 

The `External` sub-folder contains archived datasets from the Bureau of Justice Statistics and the Vera Institute of Justice. 

| Dataset                        | Source                                         | Description                                                     |
|--------------------------------|------------------------------------------------|-----------------------------------------------------------------|
| `msfp0119stt14.csv`            | BJS, MCI Reports (2000-2019)                   | Totals of deaths of state and federal prisoners (unprocessed)   |
| `msfp0119stt14_cleaned.csv`    | BJS, MCI Reports (2000-2019)                   | Same as above, processed for easy loading and comparison        |
| `p20stt09.csv`                 | BJS, NPS Reports (2019-2020)                   | Releases of state and federal sentenced prisoners (unprocessed) |
| `p20stt09_cleaned.csv`         | BJS, NPS Reports (2019-2020)                   | Same as above, processed for easy loading and comparison        |
| `vera_pjp_s2021_appendix.csv`  | Vera, People in Prisons and Jails Spring 2021  | Counts of state and federal prisoners                           

The `Other` sub-folder contains data on deaths in custody which are not from state prisons (i.e. recorded deaths in county and local facilities), data on executions for comparison with reported mortality data, and data on deaths in federal prisons and detention centers (i.e. deaths in BoP and ICE facilities). Since our dataset is currently focused on recording custodial deaths and demographics in state prisons, these files are located in a separate folder from our primary data.

The `Output` sub-folder contains current aggregate summary tables for mortality in state prisons which we have produced using the data in the `Raw` sub-folder.

The `Raw` sub-folder contains data files on `Deaths` in state prisons that our project has collected and standardized. There are three types of `Raw` death data: `Annual`, `Monthly`, and `Individual`. The `Annual` sub-folder contains data files from state prison systems for which we gathered data reported as annual aggregates. The `Monthly` sub-folder contains data files from state prison systems for which we gathered data reported as monthly aggregates. The `Individual` sub-folder contains data files from state prison systems for which we gathered data with an individual data of death for each reported death. Each `Raw` file is titled by the state abbrevation for the state prison system it covers and the name of the time interval of reporting. 

The `Raw` sub-folder also contains data files on `Demographics` in state prisons that our project has collected and standardized. There are two types of of `Raw` demographics data: `Combined` and `Distinct`. The `Combined` sub-folder contains data files from state prisons that report information on the total population by age group and sex. The `Distinct` sub-folder contains data files from state prisons that report information on the total population by age group and the total population by sex separately.   

### Documents

This folder contains documentation for how we obtained data for each state prison system. Sub-folders for each state contain a RMarkdown file describing how we obtained the data, what variables are present in the data, and how to load and compare annual aggregates from the data with past MCI reports from BJS. 

`Example` folders contain raw unprocessed versions of the documents / data sources used to create the datasets in the `Raw` folder.

### Graphics

This folder contains visualizations summarizing the coverage of records contained in this database.

## Time and Timing of Data Collection

Data collection for this project began in June 2020 and is ongoing. For most states, our project has obtained records covering at least 2015-2020. 

## Data Validation and Quality Assurance

## Types of Manipulation Conducted on Raw Data During Standardization and Analysis

## Data Confidentiality, Access, and Use Conditions


Alongside our [core data](https://github.com/uclalawcovid19behindbars/data), our project gathers and processes data on deaths and demographics in U.S. prisons


. We intend to use this data to estimate the 2020 change in all-cause mortality amongst state prison populations. Currently, we have custodial decedent data available through 2020 for 36 U.S. state prison systems. 

## Legislative and oversight background

Passed into law in 2000, the Death in Custody Reporting Act (DCRA) mandates that the U.S. Attorney General collect data on the deaths of individuals under arrest, en route to incarceration, and incarcerated in a local or state correctional facilities (e.g. jails and prisons). Since 2003, the Bureau of Justice Statistics (BJS) has been responsible for collecting information on deaths from local and state correctional agencies and processing this data into standardized reports on annual changes in U.S. prison and jail mortality. While the law was reauthorized in 2014, BJS suspended collection of arrest-related data that year due to data quality concerns. 

In 2019, the Attorney General shifted responsibility for data collection and processing for DCRA to the Bureau of Justice Assistance (BJA). BJA typically provides 'leadership and consultation' to local criminal justice agencies. They do not, historically, collect, process, or produce statistical reports on decedent and demographic data as usually done by BJS. While BJA intends to collect decedent data on a quarterly basis and report data to BJS on an annual basis, it is not clear data quality will be sufficient to produce standardized year-to-year comparisons of mortality in local and state correctional agencies. Given uncertainty on future data availability, BJS is planning to release a report on reported COVID deaths in U.S. prisons and it has released overall numbers of all-cause deaths in prisons through the National Prisoner Statistics Program. Any records collected by BJS and/or BJA regarding individual deaths are protected from FOIA/public records disclosure per 34 U.S.C. §10231(a). 

## About the data

If BJA does not produce public statistical reports on annual changes in U.S. correctional mortality like prior [publications](https://bjs.ojp.gov/data-collection/mortality-correctional-institutions-mci-formerly-deaths-custody-reporting-program) (or does not collect and transfer sufficient data to BJS to do so), the federal government will not produce a report on the 2020 change in standardized all-cause mortality in correctional facilities in the near future. Understanding the change in all-cause mortality in state prisons from 2019 to 2020 is essential to understanding the impact of COVID-19 in U.S. carceral facilities. Here, we centralize and analyze data on deaths in state prisons (typically from 2018-2020) and demographics of state prison populations (typically from 2019-2020) to estimate these changes in mortality. Raw data in this repository is broken into `Deaths` and `Demographics`. 

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
    
# Calculate and plot age group mortality rate
age.rate <- 'CA' %>%
    pull_ucla_age_rate() %>%
    subset(!is.nan(Rate) & 
               !is.na(Rate) &
               !is.na(Standard.Groups)) %>%
    filter(Date > as.Date('2014-12-31', format = '%Y-%m-%d') &
               Date < as.Date('2021-01-01', format = '%Y-%m-%d'))

ggplot() +
    geom_smooth(data = age.rate, aes(x = Date, y = Rate, color = Standard.Groups))
 
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
    
# Calculate monthly mortality rate for crosswalked facilities
facilities.monthly <- calculate_monthly_facility_rate()

# Calculate annual mortality rate for crosswalked facilities
facilities.annual <- calculate_annual_facility_rate()

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

## Dataset Coverage

Figure 1 | State prison agencies with reported custodial decedent information in dataset

![state present](https://github.com/uclalawcovid19behindbars/carceral_mortality/blob/main/Graphics/state_present.png)

Figure 2 | State prison agencies with 2020 custodial decedent information in dataset

![state 2020](https://github.com/uclalawcovid19behindbars/carceral_mortality/blob/main/Graphics/state_2020.png)

Figure 3 | State prison agencies by interval of reported custodial decedent information

![state interval](https://github.com/uclalawcovid19behindbars/carceral_mortality/blob/main/Graphics/state_death_interval.png)

Figure 4 | State prison agencies with facility information reported in custodial decedent data

![state facility](https://github.com/uclalawcovid19behindbars/carceral_mortality/blob/main/Graphics/state_facility.png)

Figure 5 | State prison agencies with decedent data crosswalked to UCLA COVID data

![state ucla](https://github.com/uclalawcovid19behindbars/carceral_mortality/blob/main/Graphics/state_ucla.png)

## Credits and Data Sources

Our project has linked several datasets compiled by other organizations in this repository. Before using any data from our dataset, please read the `source_guide` for that data source in the `Documents` to understand it's context and attributions.

Current linked datasets:

Vera Institute of Justice |
People in Jail and Prison in Spring 2021 |
Link to [source](https://www.vera.org/publications/people-in-jail-and-prison-in-spring-2021).

Texas Justice Intitiative | 
Deaths in Custody | 
Link to [source](https://texasjusticeinitiative.org/datasets/custodial-deaths).

Death Penalty Information Center |
Execution Database |
Link to [source](https://deathpenaltyinfo.org/executions/execution-database).

NPR Investigations |
BoP Excess Deaths Analysis |
Link to [source](https://github.com/NPR-investigations/BOP_all_cause_mortality).

## Notes on data inconsistencies and issues

This dataset is still evolving as we obtain and assess custodial decedent data from carceral/law enforcement agencies. Agencies do not produce custodial death and demographic data in the same format or on the same level. While we are working to obtain the most detailed and publicly-necessary decedent and demographic data through public records requests, this repository contains our most recent available processed raw data. As such, there are known issues we are working to document and harmonize as we analyze the data. 

Future functions will be written to compare these datafiles with existing data on mortality in state prisons including all prior data reported by BJS while it operated the Mortality in Correctional Institutions (MCI) project. 

## Planned analysis

Estimate 2020 change in all-cause mortality using uneven data. [Research](https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.1002687) using similar methods. 

## Ongoing projects

Integrate data from other existing mortality projects with external collaborators (BoP data w/ NPR);

Integrate Reuters [jail decedent data](https://www.reuters.com/investigates/special-report/usa-jails-graphic/);

Integrate functions in behindbarstools to analyze all-cause decedent data alongside reported COVID data.





