
[![logo](logo.svg)](https://uclacovidbehindbars.org/)

## 2020 Change in State Prison Mortality 

The [UCLA Law COVID Behind Bars Data Project](https://uclacovidbehindbars.org/), launched in March 2020, tracks the spread and impact of COVID in American carceral facilities and advocates for greater transparency and accountability around the pandemic response of the carceral system. 

Alongside our [core data](https://github.com/uclalawcovid19behindbars/data), our project gathers and processes data on deaths and demographics in state prisons. We intend to use this data to estimate the 2020 change in all-cause mortality amongst state prison populations. Currently, we currently have custodial decedent data available through 2020 for 35 U.S. state prison systems. 

## Legislative and oversight background

Passed into law in 2000, the Death in Custody Reporting Act (DCRA) mandates that the U.S. Attorney General collect data on the deaths of individuals under arrest, en route to incarceration, and incarcerated in a local or state correctional facilities (e.g. jails and prisons). Since 2003, the Bureau of Justice Statistics (BJS) has been responsible for collecting information on deaths from local and state correctional agencies and processing this data into standardized reports on annual changes in U.S. prison and jail mortality. While the law was reauthorized in 2014, BJS suspended collection of arrest-related data that year due to data quality concerns. 

In 2019, the Attorney General shifted responsibility for data collection and processing for DCRA to the Bureau of Justice Assistance (BJA). BJA typically provides 'leadership and consulatation' to local criminal justice agencies. They do not, historically, collect, process, or produce statistical reports on the decedent data as usually done by BJS. While BJA intends to collect decedent data on a quarterly basis and report data to BJS on an annual basis, it is not clear data quality will be sufficient to produce standardized year-to-year comparisons of mortality in local and state correctional agencies. Given uncertainty on future data availability, BJS is planning to release a report on reported COVID deaths in U.S. prisons and to release overal numbers of deaths in prisons through the National Prisoner Statistics Program. Any records collected by BJS and/or BJA regarding individual deaths are protected from FOIA/public records disclosure per 34 U.S.C. §10231(a). 

## About the data

If BJA does not produce public statistical reports on annual changes in U.S. correctional mortality like prior [publications](https://bjs.ojp.gov/data-collection/mortality-correctional-institutions-mci-formerly-deaths-custody-reporting-program) (or does not collect and transfer sufficient data to BJS to do so), the federal government will not produce a report on the 2020 change in standardized all-cause mortality in correctional facilities in the near future. Understanding the change in all-cause mortality in state prisons from 2019 to 2020 is essential to understanding the impact of COVID-19 in U.S. carceral facilities. Here, we centralize and analyze data collected by our project on deaths in state prisons (typically from 2018-2020) and demographics of state prison populations (typically from 2019-2020) to estimate these changes in mortality. Raw data in this repository is broken into `Deaths` and `Demographics`. 

### Potential Death Variables

| Variable               | Description                                                                                                        |
|------------------------|--------------------------------------------------------------------------------------------------------------------|
| `State`                | State prison system                                                                                                |
| `Year`                 | Year of death(s)                                                                                                   |
| `Month`                | Month of death(s)                                                                                                  |
| `Death.Date`           | Date of death(s)                                                                                                   |
| `Facility`             | Facility of death(s)                                                                                               |
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
| `Cause.General`        | General circumstances of death (N.B. not necessarily cause of death)                                               |
| `Cause.Specific`       | Specific circumstances of death (N.B. not necessarily cause of death)                                              |
| `Cause.Other`          | Other circumstances of death (N.B. not necessarily cause of death)                                                 |
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

This dataset is still evolving as we obtain and assess custodial decedent data from carceral/law enforcement agencies. Agencies do not produce custodial death and demographic data from public records requests in the same format or on the same level. While we are working to obtain the most detailed and publicly-necessary decedent and demographic data through public records requests, this repository contains our most recent available processed raw data. As such, there are known issues we are working to document and harmonize as we analyze the data. Examples of incosistencies include: (1) New Jersey reporting semi-redacted deaths for the New Jersey Department of Correction's 'Special Treatment Unit' only for 2020 and each accompanied by a note reading 'Do Not Report to Federal Government'; (2) Differences in the total number of/specific deaths reported by the North Carolina Department of Corrections in public records responses compared with their online prison database; and (3) missing variables and observations for certain variables across datasets, among other issues.

Future functions will be written to compare these datafiles with existing data on mortality in state prisons including all prior data reported by BJS while it operated the Mortality in Correctional Institutions (MCI) project. 

## Planned analysis

Estimate 2020 change in all-cause mortality using uneven data. [Research](https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.1002687) using similar methods. 

## Future projects

Develop functions for loading and comparison with other available carceral mortality statistics

Integrate data from other existing mortality projects on the UCLA team (FL and TX)

Develop 2020 archive/request guide to spur ongoing public collection of carceral decedent data 

Develop strategy to estimate changes in jail mortality using public records requests

Integrate Facility.IDs and functions in behindbarstools to analyze all-cause decedent data alongside reported COVID data



