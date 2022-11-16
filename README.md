

## UCLA Law CBBDP Custodial Mortality Data

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

## Time and Timing of Data Collection

Data collection for this project began in June 2020 and is ongoing. For most states, our project has obtained records covering at least 2015-2020. For some states (OH and VT) we have partial data for 2020 due to the timing of when we requested data and when data as provided.

## Data Validation and Quality Assurance

To validate data collected in this database, we compared annual aggregates in state agency records here with annual aggregates for deaths reported for agencies in BJS MCI Reports. If an agency had a difference of 5 or more deaths, our project reached out to the agency asking why the records we gathered had different total annual counts from federal reports.

Agencies of interest and status of validation:

| Prison Agency       | Largest difference with MCI Reports        | Outreach Status                                                              |
|---------------------|--------------------------------------------|------------------------------------------------------------------------------|
| California          | 32 less than BJS (2005)                    | No response to letter sent to CDCR in Apr - new letter sent Oct 2022         |
| Colorado            | 6 less than BJS (2015)                     | Letter sent to CDOC in Apr - received response in Apr 2022                   |
| Florida             | 28 more than BJS (2016)                    | New letter for FLDOC needed for new data                                     |
| Georgia             | 12 more than BJS (2015/2018)               | No response to letter sent to GDC in Apr - new letter sent Oct 2022          |
| Hawaii              | 7 more than BJS (2017)                     | Letter sent to HDPS in Apr - response received - no changes needed           |
| Louisiana           | 18 less than BJS (2015)                    | See Incarceration Transparency                                               |
| Maryland            | 14 more than BJS (2018)                    | Letter sent in Apr - response received and correction made to data           |
| Missouri            | 9 less than BJS (2017)                     | No response to letter sent to MODOC in Apr - new letter sent Oct 2022        |
| Nevada              | 17 more than BJS (2018)                    | No response to letter sent to NDOC in Apr - new letter sent Oct 2022         |
| Oklahoma            | 7 more than BJS (2013)                     | Letter sent in Apr - clarification needed for response - letter sent Oct 22  |
| Oregon              | 5 more than BJS (2015)                     | Letter sent in Apr - response received in - no changes needed                |
| Pennsylvania        | 5 more than BJS (2015)                     | Letter sent in Oct - agency is investigating our inquiry                     |
| Texas               | 6 more than BJS (2010)                     | See Texas Justice Initiative                                                 |
| West Virginia       | 14 more than BJS (2019)                    | Letter sent in Apr - response received - no changes needed    

Based off responses from agencies, some records were edited to better reflect deaths in custody that occur within carceral facilities (i.e. prisons or jails). Any observations removed from a state's records are contained in the `Edited` folder. Please see data manipulation section for details on which states were edited.

## Types of Manipulation Conducted on Raw Data During Standardization and Analysis

Agency records on deaths in custody were processed from PDFs, xlsx, csv, and jpgs. Records were made machine readable using R and Adobe. Unprocessed records are maintained in the `Documents` folder.

As we conducted data validation efforts our project made decisions as to how to present data that may include differences with prior BJS reports due to the type of data provided to UCLA, issues with agency reporting to BJS, and agencies managing facilities other than prisons (i.e. jails in a unified system). 

Reasons for differences and manipulation steps:

| Prison Agency | Reasons for Differences                                                                                   | Mainuplation Made        |
|---------------|-----------------------------------------------------------------------------------------------------------|--------------------------|
| California    | Undetermined                                                                                              | None                     |
| Colorado      | CDOC reported more types of deaths to BJS than deaths in CO prisons (i.e. fugitives, supervision programs)| None                     |
| Florida       | Undetermined                                                                                              | None                     |
| Georgia       | Undetermined                                                                                              | None                     |
| Hawaii        | Error in agency reporting to BJS - Agency is correcting this issue                                        | None                     |
| Louisiana     | Potentially differences in LDPS reporting post-conviction deaths in jails - see Incarceration Transparency| None                     |
| Maryland      | MDPS also provided deaths in 'Home Detention Units' and pre-trial facilities                              | Observations removed     |
| Missouri      | Undetermined                                                                                              | None                     |
| Nevada        | Undetermined                                                                                              | None                     |
| Oklahoma      | Undetermined                                                                                              | None                     |
| Oregon        | Error in agency reporting to BJS                                                                          | None                     |
| Pennsylvania  | Undetermined                                                                                              | None                     |
| Texas         | Potentially differences in which facility deaths are reported to BJS - see Texas Justice Initiative       | None                     |
| West Virginia | WVDCR oversees prisons and jails - when jails are removed, annual totals match                            | None


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



## Accessing the Data and Data Dictionary

``` r
# Load all Custodial Mortality Project utility functions
source('Code/general_utilities.R')

# Load all CMP decedent data
CMP.data <- read_CMP_deaths(all.agencies = TRUE)

# Load specific CMP death data (function aggregates to least detailed level for time interval)
CMP.data <- read_CMP_deaths(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'AR'))

# Load all BJS decedent data
bjs.data <- read_bjs(all.agencies = TRUE)

# Load specific BJS decedent data
bjs.data <- read_bjs(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'AR'))

# Compare CMP and BJS decedent data
compare_CMP_bjs(source = 'MCI') # source parameter designates what BJS report to compare to: MCI, NPS, or MCI+NPS

# Summarize UCLA Mortality Database
summarize_CMP_data()

# Load all CMP demographic data
CMP.dem <- read_CMP_dem(all.agencies = TRUE)

# Load specific CMO demographic data
CMP.dem <- read_CMP_dem(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'AR'))

# Harmonize CMP demographic data (for analysis)
CMP.dem.h <- harmonize_CMP_dem(agencies = c('GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV'))

# Harmonize CMP decedent data to demographic data (for analysis)
ucla.CMP.h <- harmonize_CMP_deaths(agencies = c('GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV'))

# Interpolate harmonized CMP demographic data
'CA' %>%
    harmonize_CMP_dem() %>%
    interpolate_CMP_dem()
    
# Calculate and plot age group mortality rate
age.rate <- 'CA' %>%
    pull_CMP_age_rate() %>%
    subset(!is.nan(Rate) & 
               !is.na(Rate) &
               !is.na(Standard.Groups)) %>%
    filter(Date > as.Date('2014-12-31', format = '%Y-%m-%d') &
               Date < as.Date('2021-01-01', format = '%Y-%m-%d'))

ggplot() +
    geom_smooth(data = age.rate, aes(x = Date, y = Rate, color = Standard.Groups))
 
# Pull all UCLA facility data for decedent data
'NJ' %>%
    read_CMP_deaths(all.agencies = FALSE,
                     agencies = .) %>%
    pull_ucla_fac_data()
    
# Pull all UCLA facility data for harmonized decedent data
'CA' %>%
    harmonize_CMP_deaths() %>%
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

### Context Notes on Potential Death Variables

Our project only reproduces records provided to us and other projects. We do not correct or investigate records for accuracy aside from our data validation efforts to ensure total counts of deaths match reporting for that agency produced by the Bureau of Justice Statistics. As such, there may be errors or issues with information contained within these variables. In particular, circumstances of death were reported differently across prison agencies and often do not reflect actual causes of death. Many death records are labeled as 'Natural' and 'Undetermined,' which provide little detail on the circumstances of death. For more context on issues with custodial death investigations please see the following resources.

> Nick Shapiro, Terrence Keel. Natural Causes? 58 Autopsies Prove Otherwise. UCLA Carceral Ecologies Lab, https://ucla.app.box.com/s/sv54jmxhmq19kqifpakh4jfu3vnmhbqt/file/974263270262


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

## Citations

Citations for academic publications and research reports:

> Sharon Dolovich, Aaron Littman, Kalind Parish, Grace DiLaura, Chase Hommeyer,  Michael Everett, Hope Johnson, Neal Marquez, Erika Tyagi, Megan Arellano, and Lauren Woyczynski. UCLA Law Covid-19 Behind Bars Data Project: Prison Mortality Dataset [date you downloaded the data]. UCLA Law, 2022, https://uclacovidbehindbars.org/.

Citations for media outlets, policy briefs, and online resources:

> UCLA Law Covid-19 Behind Bars Data Project, https://uclacovidbehindbars.org/.

If you use any data in this repository from Louisiana, Texas, or the Bureau of Prisons please also cite the appropriate original source of that data. 

For Louisiana

> Andrea Armstrong, Judson Mitchell, Erica Navalance, Shanita Farris. Incarceration Transparency: Louisiana Deaths Behind Bars. Loyola University New Orleans, College of Law, https://www.incarcerationtransparency.org/.

For Texas

> Texas Justice Initiative: Texas Deaths in Custody, https://texasjusticeinitiative.org/data.

For BoP

> Meg Anderson, Huo Jingnan, Neal Marquez, Erika Tyagi, Alison Guernsey, Robert Benincasa, Nick McMillan, NPR Investigations: BOP_excess_Deaths, https://github.com/NPR-investigations/BOP_all_cause_mortality

If you use any of the prison population data in this repository from Vera please also cite their reporting.

> Jacob Kang-Brown, Chase Montagnet, Jasmine Heiss. Vera Institute of Justice: People in Jail and Prison in Spring 2021, https://www.vera.org/publications/people-in-jail-and-prison-in-spring-2021#:~:text=By%20spring%202021%2C%20jail%20populations,reduce%20incarceration%20through%20spring%202021.

## License 

Our data is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/). That means that you must give appropriate credit, provide a link to the license, and indicate if changes were made. You may not use our work for commercial purposes, which means anything primarily intended for or directed toward commercial advantage or monetary compensation. 

## Contributors 

For questions or feedback about the data, please reach out to COVIDBehindBars@law.ucla.edu. 

In cases when agencies do not publicly report comprehensive data for all facilities in a state, we supplement our data with statewide aggregate totals collected through public records requests, data collected by [The Marshall Project and the AP](https://www.themarshallproject.org/2020/05/01/a-state-by-state-look-at-coronavirus-in-prisons), and other sources. Our data for several jails in California is collected by the [COVID In-Custody Project](https://covidincustody.org/). Our data for facilities in Massachusetts is reported by [the ACLU of Massachusetts](https://data.aclum.org/sjc-12926-tracker/). Our data for deaths in Texas jails and prisons is collected by [the Texas Justice Initiative](https://texasjusticeinitiative.org/publications/covid-deaths-in-texas). If you would like to contribute data on COVID in a facility that we don't currently include, please see [our template](https://docs.google.com/spreadsheets/d/1cqjCvbXuUh5aIQeJ4NRKdUwVAb4adaWTK-nBPFAj0og/edit#gid=363817589). 




