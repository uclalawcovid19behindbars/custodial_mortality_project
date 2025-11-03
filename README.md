## UCLA Law CBBDP Custodial Mortality Project Data

The [UCLA Law Behind Bars Data Project](https://uclacovidbehindbars.org/), launched in March 2020, tracks the spread and impact of COVID in U.S. carceral facilities and advocates for greater transparency and accountability for the pandemic response behind bars.

## Purpose of Data Collection

To better monitor the public health conditions behind bars, the project began gathering data on all-cause deaths in U.S. prisons in June 2020. Because prison agencies report different records on deaths in custody, the project has attempted to standardize records into similar variables so the public can compare what information agencies make available and study the data they do release. The project intends this repository to function as a tool for the public and researchers to better understand the drivers of deaths in custody and assist policymakers in developing strategies to reduce their occurence. In particular, the project hopes this database helps support the full implementation of the Death in Custody Reporting Act [(link to bill)](https://www.congress.gov/bill/113th-congress/house-bill/1447/text) by supplementing 'Mortality in Correctional Institutions' reports, which were produced by the U.S. Department of Justice up until 2019, and assisting efforts to study (1) how this data may be used to reduce the number of deaths in custody, and (2) how carceral facility management practices may contribute to deaths in custody.

### Accessing Current Data (2022–2024 Update)

As of November 3, 2025, this repository incorporates custodial mortality data through 2024.

**National aggregate data by state (2019–2024):** [prison_agency_counts.csv](https://github.com/uclalawcovid19behindbars/custodial_mortality_project/blob/main/Data/Output/prison_agency_counts.csv)

**Individual-level death records (when available):** [Raw Deaths folder](https://github.com/uclalawcovid19behindbars/custodial_mortality_project/tree/main/Data/Raw/Deaths)

These datasets expand upon prior 2019–2021 data, adding standardized counts and individual records for 2022, 2023, and 2024. Data from the Bureau of Prisons and all 50 state prison systems have been integrated where available.

## Data Collection Procedures

Data on deaths in prisons and prison demographics comes from a variety of sources. Where prison death data is listed publicly on an agency website or where another organization has already collected and processed records on deaths in custody for a particular agency, the project has gathered, standardized, and reproduced those records here.

Examples of U.S. prison agencies that publicly list records on deaths in custody include the Arizona Department of Corrections [(link to source)](https://corrections.az.gov/inmate-death-notifications) and the Florida Department of Corrections [(link to source)](http://www.dc.state.fl.us/pub/mortality/index.html). The project has reproduced records from the Texas Justice Initiative for deaths in Texas state prisons, Incarceration Transparency at Loyola University New Orleans, College of Law for deaths in Louisiana state prisons, and the NPR Investigations team for deaths in Bureau of Prisons facilities.

Where information on deaths in prisons was not publicly available through an agency or another organization, or was not provided at the individual or facility-level, the project used public records requests to gather records on deaths in custody and standardized these records into a uniform database. For each request, the project asked for records from 2015 to 2020 and for the following pieces of information for each death:

-   Name of individual;
-   Age, race, and sex of individual;
-   Date of death;
-   Facility to which individual was assigned;
-   Location of death (e.g., cell number or hospital name);
-   Type of death (e.g., suicide, homicide, accident, drugs/alcohol, illness, other);
-   Additional details about death including circumstances, cause of death, and/or details of illness (if illness is listed as type of death).

As of December 2022, the project has gathered records on all-cause deaths in all state prison systems and the Bureau of Prisons (BoP). The project has gathered complete data up to the end of 2020 for 49 states and the BoP. Agencies provided different intervals of data on deaths in their facilities. Most state agencies, 42 in total, and the BoP, provided ‘individual-level’ data, meaning records that provide a specific date for each death. In many cases, other variables are tied to that death, like the name, race, or housing facility of the individual. Six states provided data on prison deaths that were aggregated on a monthly basis. Two agencies provided data that were aggregated on an annual basis.

Agencies also provided different variables for reported prison deaths. Twenty-seven states provided a name for individual deaths in their prisons. Forty-three states provided the facilities in which deaths occurred. Twenty-nine states provided the sex of decedents, and twenty-three states provided the race of decedents. Thirty-seven states provided descriptions of circumstances of deaths. The project has created a [summary sheet](https://docs.google.com/spreadsheets/d/10STQkTWb3uW_CXVLmVZ5GQ6ppsRmMBZ2y1yd5_eclSI/edit#gid=0) demonstrating which variables are available by prison agency. As the project collects more data, it will update this sheet accordingly.

## Time and Timing of Data Collection

Data collection for this project began in June 2020 and is ongoing. For most states, the project has obtained records covering at least 2015-2020. For one state, New Mexico, the project has partial data for 2020 and it is working with the agency to obtain complete records. Some prison agencies have also provided complete records for 2021. Please see the project's summary sheet [link to sheet](https://docs.google.com/spreadsheets/d/10STQkTWb3uW_CXVLmVZ5GQ6ppsRmMBZ2y1yd5_eclSI/edit#gid=0)

## Data Validation and Quality Assurance

To validate data collected in this database, the project compared annual aggregates in state agency records here with annual aggregates for deaths reported for agencies in BJS MCI Reports. If an agency had a difference of 5 or more deaths, the project reached out to the agency asking why the records it gathered had different total annual counts from federal reports.

Agencies of interest and status of validation:

| Prison Agency | Largest difference with MCI Reports | Outreach Status |
|------------------|--------------------|-----------------------------------|
| California | 32 less than BJS (2005) | See discrepancy outreach summary sheet in repository |
| Colorado | 6 less than BJS (2015) | See discrepancy outreach summary sheet in repository |
| Florida | 28 more than BJS (2016) | See discrepancy outreach summary sheet in repository |
| Georgia | 12 more than BJS (2015/2018) | See discrepancy outreach summary sheet in repository |
| Hawaii | 7 more than BJS (2017) | See discrepancy outreach summary sheet in repository |
| Louisiana | 18 less than BJS (2015) | See discrepancy outreach summary sheet in repository |
| Maryland | 14 more than BJS (2018) | See discrepancy outreach summary sheet in repository |
| Missouri | 9 less than BJS (2017) | See discrepancy outreach summary sheet in repository |
| Nevada | 17 more than BJS (2018) | See discrepancy outreach summary sheet in repository |
| Oklahoma | 7 more than BJS (2013) | See discrepancy outreach summary sheet in repository |
| Oregon | 5 more than BJS (2015) | See discrepancy outreach summary sheet in repository |
| Pennsylvania | 5 more than BJS (2015) | See discrepancy outreach summary sheet in repository |
| Texas | 6 more than BJS (2010) | See discrepancy outreach summary sheet in repository |
| West Virginia | 14 more than BJS (2019) | See discrepancy outreach summary sheet in repository |

Based off responses from agencies, some records were edited to better reflect deaths in custody that occur within prison facilities. Any observations removed from a state's records are contained in the `Edited` folder. Please see data manipulation section for details on which states were edited.

## Types of Manipulation Conducted on Raw Data During Standardization and Analysis

Agency records on deaths in custody were processed from pdfs, xlsx, csv, and jpgs. Records were made machine-readable using R and Adobe. Unprocessed records are maintained in the `Documents` folder.

As the project conducted data validation efforts it made decisions as to how to present data that may include differences with prior BJS reports due to the type of data provided to the project, issues with agency reporting to BJS, and agencies managing facilities other than prisons (e.g. jails in a unified system).

Reasons for differences and manipulation steps:

| Prison Agency | Reasons for Differences | Mainuplation Made |
|---------------|------------------------------------------|---------------|
| California | Undetermined | None |
| Colorado | CDOC reported more types of deaths to BJS than deaths in CO prisons (i.e. fugitives, supervision programs) | None |
| Florida | Problem with listed date of death for roster data source | Different data source used |
| Georgia | Undetermined | None |
| Hawaii | Issue in agency reporting to BJS - Agency is correcting this issue | None |
| Louisiana | Potentially differences in LDPS reporting post-conviction deaths in jails - see Incarceration Transparency | None |
| Maryland | MDPS also provided deaths in 'Home Detention Units' and pre-trial facilities | Observations removed |
| Missouri | Undetermined | None |
| Nevada | Undetermined | None |
| Oklahoma | Undetermined | None |
| Oregon | Issue in agency reporting to BJS | None |
| Pennsylvania | Undetermined | None |
| Texas | Potentially differences in which facility deaths are reported to BJS - see Texas Justice Initiative | None |
| West Virginia | WVDCR oversees prisons and jails - when jails are removed, annual totals are more similar | Jail observations removed |

Other manipulation steps taken to limit primary repository data to prison / post-conviction facilities:

| Prison Agency | Reasons for Manipulation | Mainuplation Made |
|---------------|------------------------------------------|---------------|
| California | Deaths in California Jails are available from the CA DoJ | Observations removed |
| New Hampshire | Deaths in Secure Psychiatric Facilities Included | Observations removed |
| New Jersey | Deaths in Special Treatment Units Included | Observations removed |

Note on deaths due to executions: Reported deaths due to execution are not removed from prepared data files and are included in summary statistics for agencies located in the `Output` folder. For more information on deaths due to execution in the U.S., please see the Death Penalty Information Center [(link to database)](https://deathpenaltyinfo.org/executions/execution-database), which is also reproduced in the `Other` sub-folder in the `Data` folder.

## Structure and Organization of Data Files

This repository is broken into four primary folders: `Code`, `Crosswalks`, `Data`, `Documents`, and `Graphics`.

### Code

This folder contains an R script titled 'general_utilities.' This script contains utility functions to help users load death and demographic data, harmonize death data to available demographic data, and compare aggregate totals from records collected here to reports on deaths in prisons formerly reported by the Bureau of Justice Statistics in 'Mortality in Correctional Institutions' (MCI) and 'National Prisoner Statistics' (NPS) reports.

### Crosswalks

This folder contains a crosswalk of IDs for carceral facilities with reported deaths that link each facility to population, capacity and other contextual information contained in public records and DHS and DOJ datasets.

### Data

This folder contains four sub-folders: `External`, `Other`, `Output`, and `Raw`.

The `External` sub-folder contains archived datasets from the Bureau of Justice Statistics and the Vera Institute of Justice.

| Dataset | Source | Description |
|------------------|-----------------------|-------------------------------|
| `msfp0119stt14.csv` | BJS, MCI Reports (2000-2019) | Totals of deaths of state and federal prisoners (unprocessed) |
| `msfp0119stt14_cleaned.csv` | BJS, MCI Reports (2000-2019) | Same as above, processed for easy loading and comparison |
| `p20stt09.csv` | BJS, NPS Reports (2019-2020) | Releases of state and federal sentenced prisoners (unprocessed) |
| `p20stt09_cleaned.csv` | BJS, NPS Reports (2019-2020) | Same as above, processed for easy loading and comparison |
| `vera_pjp_s2021_appendix.csv` | Vera, People in Prisons and Jails Spr 2021 | Counts of state and federal prisoners |
| `hifld_prison_boundaries_2022.csv` | DHS, HIFLD Prison Boundaries Data | DHS ensus of carceral facilities conducted |

The `Other` sub-folder contains data on deaths in custody which are not from state prisons (e.g. recorded deaths in county and local facilities), data on executions for comparison with reported mortality data, and data on deaths in federal prisons and detention centers (e.g. deaths in BoP and ICE facilities). Since this dataset is currently focused on recording custodial deaths and demographics in state prisons, these files are located in a separate folder from the repository's primary data.

The `Output` sub-folder contains current aggregate summary tables for mortality in state prisons which the project has produced using the data in the `Raw` sub-folder.

The `Output` sub-folder also contains state-wide aggregates that came from scraped data from the BoP website. The total sum of the state-wide population counts differs from the count listed under `BoP - All Locations` because they were taken from different sources. Below is a table of the difference.

|                       | Population.2019 | Population.2020 | Population.2021 |
|-----------------------|-----------------|-----------------|-----------------|
| Vera Institute        | 177906          | 161640          | 153683          |
| BoP Website           | 169696          | 144363          | 139006          |
| Aggregated Difference | 8210            | 17277           | 14677           |

The `Raw` sub-folder contains data files on `Deaths` in state prisons that the project has collected and standardized. There are four types of `Raw` death data: `Annual`, `Monthly`, `Individual`, and `Additional`. The `Annual` sub-folder contains data files from state prison systems for which the project has gathered data reported as annual aggregates. The `Monthly` sub-folder contains data files from state prison systems for which the project has gathered data reported as monthly aggregates. The `Individual` sub-folder contains data files from state prison systems for which the project has gathered data with an individual date of death for each reported death. The `Additional` sub-folder contains data files from state prisons for which the project has separated observations on deaths in custody due to discrepancy inquiries or the inclusion of non-prison / pre-trial facilities. Each `Raw` file is titled by the state abbrevation for the state prison system it covers and the name of the time interval of reporting.

The `Raw` sub-folder also contains data files on `Demographics` in state prisons that the project has collected and standardized. There are two types of of `Raw` demographics data: `Combined` and `Distinct`. The `Combined` sub-folder contains data files from state prisons that report information on the total population by age group and sex. The `Distinct` sub-folder contains data files from state prisons that report information on the total population by age group and the total population by sex separately. Population totals for state prison agencies that provide `Distinct` demographic data are calculated in functions described below (i.e. read_CMP_dem) by applying the population sex ratio for the prison system uniformly across each reported age group. Population totals from these functions for states that provide `Distinct` demographic data therefore do not represent numbers reported directly by prison agencies.

The `Raw` sub-folder also contains data files on `Population` in federal prison that the project web-scraped using the Wayback Machine and BoP prisons population data website. The dataset was used to create the aggregate output file for state counts.

### Documents

This folder contains documentation for how the project obtained data for each state prison system. Sub-folders for each state contain a R Markdown file describing how it obtained the data, what variables are present in the data, and how to load and compare annual aggregates from the data with past MCI reports from BJS.

`Example` folders contain raw unprocessed versions of the documents / data sources used to create the datasets in the `Raw` folder.

## Accessing the Data and Data Dictionary

``` r
# Load all Custodial Mortality Project utility functions
source('Code/general_utilities.R')

# Load all CMP decedent data
CMP.data <- read_CMP_deaths(all.agencies = TRUE)

# Load specific CMP death data (function aggregates to least detailed level for time interval)
CMP.data <- read_CMP_deaths(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'WA'))

# Load all BJS decedent data
bjs.data <- read_bjs(all.agencies = TRUE, source = 'MCI')

# Load specific BJS decedent data
bjs.data <- read_bjs(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV', 'WA'), source = 'MCI')

# Compare CMP and BJS decedent data
compare_CMP_bjs(source = 'MCI') # source parameter designates what BJS report to compare to: MCI, NPS, or MCI+NPS

# Summarize CMP Database
summarize_CMP_data()

# Load all CMP demographic data
# (N.B. If an agency's demographic data is collected in a `Distinct` format, population totals by age and sex group are calculated by applying the sex ratio for the total population to each age group reported by an agency. The calculated number may not reflect the actual population total for the prison population for that age and sex group. If an agency's demographic data is collected in a `Combined` format, population totals by age and sex group are reported directly from agency reports or aggregations of these reports)
CMP.dem <- read_CMP_dem(all.agencies = TRUE)

# Load specific CMP demographic data
# (N.B. If an agency's demographic data is collected in a `Distinct` format, population totals by age and sex group are calculated by applying the sex ratio for the total population to each age group reported by an agency. The calculated number may not reflect the actual population total for the prison population for that age and sex group. If an agency's demographic data is collected in a `Combined` format, population totals by age and sex group are reported directly from agency reports or aggregations of these reports)
CMP.dem <- read_CMP_dem(all.agencies = FALSE, agencies = c('CA', 'NC', 'NV'))

# Harmonize CMP demographic data (for analysis)
# (N.B. If an agency's demographic data is collected in a `Distinct` format, population totals by age and sex group are calculated by applying the sex ratio for the total population to each age group reported by an agency. The calculated number may not reflect the actual population total for the prison population for that age and sex group. If an agency's demographic data is collected in a `Combined` format, population totals by age and sex group are reported directly from agency reports or aggregations of these reports)
CMP.dem.h <- harmonize_CMP_dem(agencies = c('GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV'))

# Harmonize CMP decedent data to demographic data (for analysis)
CMP.deaths.h <- harmonize_CMP_deaths(agencies = c('GA', 'IL', 'MA', 'MI', 'MT', 'NC', 'NV'))

# Interpolate harmonized CMP demographic data
# (N.B. If an agency's demographic data is collected in a `Distinct` format, population totals by age and sex group are calculated by applying the sex ratio for the total population to each age group reported by an agency. The calculated number may not reflect the actual population total for the prison population for that age and sex group. If an agency's demographic data is collected in a `Combined` format, population totals by age and sex group are reported directly from agency reports or aggregations of these reports)
'IL' %>%
    harmonize_CMP_dem() %>%
    interpolate_CMP_dem()
    
# Calculate and plot age-specific mortality rate
age.rate <- 'IL' %>%
    pull_CMP_age_rate() %>%
    subset(!is.nan(Rate) & 
               !is.na(Rate) &
               !is.na(Standard.Groups)) %>%
    filter(Date > as.Date('2014-12-31', format = '%Y-%m-%d') &
               Date < as.Date('2021-01-01', format = '%Y-%m-%d'))

ggplot() +
    geom_smooth(data = age.rate, aes(x = Date, y = Rate, color = Standard.Groups))
 
# Pull all CBBDP facility data for decedent data (N.B. please see our `facility_data` repository for more details and context to the data used in these functions)
'NJ' %>%
    read_CMP_deaths(all.agencies = FALSE,
                     agencies = .) %>%
    pull_CMP_fac_data()
    
# Pull all CBBDP facility data for harmonized decedent data (N.B. please see our `facility_data` repository for more details and context to the data used in these functions)
'CA' %>%
    harmonize_CMP_deaths() %>%
    pull_CMP_fac_data()
    
# Calculate monthly crude mortality rate from available data
# Options: set pop.source to 'Vera' or 'UCLA' (N.B. some interpolation of total population numbers for agencies is conducted in these functions and total population numbers do not necessarily reflect a number actually reported by an agency. Please see the interpolation functions in the `general_utilities.R` file for more context on how this data is produced).
# Output Note: The Avg.Population field is calculated by taking the monthly average of daily population numbers interpolated from available dates of population data from the source selection (i.e. Vera or UCLA). These numbers may be different from population denominators contained in the output summary files which use Vera prison population data interpolated from available data or reported directly by agencies from Jun 2018, June 2019, June 2020, and April 2021. Monthly rate observations for agencies that are NA represent months for which there were no deaths or months for which the project has yet to collect data. All crude rates are calculated as deaths per 10,000 individuals.
calculate_monthly_rate('Vera')

monthly.rate <- calculate_monthly_rate(pop.source = 'Vera') %>%
    mutate(Date = as.Date(str_c(Year, '-', Month, '-01'), format = '%Y-%B-%d'))

ggplot() +
    geom_bar(data = monthly.rate, aes(x = Date, y = Rate), stat = 'identity') +
    facet_wrap(~ State) 

# Calculate annual crude mortality rate from available data
# Options: set pop.source to 'Vera' or 'UCLA' (N.B. some interpolation of total population numbers for agencies is conducted in these functions and total population numbers do not necessarily reflect a number actually reported by an agency. Please see the interpolation functions in the `general_utilities.R` file for more context on how this data is produced).
# Output Note: The Avg.Population field is calculated by taking the annual average of daily population numbers interpolated from available dates of population data from the source selection (i.e. Vera or UCLA). These numbers may be different from population denominators contained in the output summary files which use Vera prison population data interpolated from available data or reported directly by agencies from June 2018, June 2019, June 2020, and April 2021. All crude rates are calculated as deaths per 10,000 individuals.
calculate_annual_rate('Vera')

annual.rate <- calculate_annual_rate(pop.source = 'Vera') 

ggplot() +
    geom_bar(data = annual.rate, aes(x = Year, y = Rate), stat = 'identity') +
    facet_wrap(~ State) 
    
# Calculate monthly crude mortality rate for crosswalked facilities (N.B. only facilities with a 'CMP.ID' variable will be included in this output and there is more facility information contained in raw files than summarized here. Please see our `facility_data` repository for more details and context to the data used in these functions)
facilities.monthly <- calculate_monthly_facility_rate()

# Calculate annual crude mortality rate for crosswalked facilities (N.B. only facilities with a 'CMP.ID' variable will be included in this output and there is more facility information contained in raw files than summarized here. Please see our `facility_data` repository for more details and context to the data used in these functions)
facilities.annual <- calculate_annual_facility_rate()
```

### Potential Death Variables

| Variable | Description |
|------------------|------------------------------------------------------|
| `State` | State prison system |
| `Year` | Year of death(s) |
| `Month` | Month of death(s) |
| `Death.Date` | Date of death(s) |
| `Facility` | Facility of death(s) |
| `CMP.ID` | Facility ID in project data [COVID Data](https://github.com/uclalawcovid19behindbars/data) |
| `Full.Name` | Full name of decedent |
| `Last.Name` | Last name of decedent |
| `First.Name` | First name of decedent |
| `ID.No` | Agency-assigned ID number of decedent |
| `Sex` | Sex of decedent |
| `Race` | Race of decedent |
| `Ethnicity` | Agency-listed ethnicity |
| `DoB` | Date of birth of decedent |
| `DoB.Year` | Year of birth of decedent |
| `Death.Age` | Age at death of decedent |
| `Circumstance.General` | General circumstances of death (N.B. not necessarily cause of death) |
| `Circumstance.Specific` | Specific circumstances of death (N.B. not necessarily cause of death) |
| `Circumstance.Other` | Other circumstances of death (N.B. not necessarily cause of death) |
| `Location` | Specific/other listed location of death |
| `Total.Deaths` | For aggregated categories, the total number of deaths |

### Context Notes on Potential Death Variables

The project only reproduces records provided to it and other projects. The project does not correct or investigate records for accuracy aside from data validation efforts to ensure total counts of deaths match or are similar to reporting for that agency produced by the Bureau of Justice Statistics. As such, there may be errors or issues with information contained within these variables. In particular, circumstances of death were reported differently across prison agencies and do not always reflect actual causes of death. Many death records are labeled as 'Natural' and 'Undetermined,' which provide little detail on the circumstances of death. For more context on issues with custodial death investigations please see the following resources.

> Nick Shapiro, Terrence Keel. *Natural Causes? 58 Autopsies Prove Otherwise*. UCLA Carceral Ecologies Lab, <https://ucla.app.box.com/s/sv54jmxhmq19kqifpakh4jfu3vnmhbqt/file/974263270262>

> Roger Mitchell Jr., Jay Aronson. *Death in Custody: How America Ignores the Truth and What We Can Do About It*. Johns Hopkins University Press, <https://www.press.jhu.edu/books/title/12925/death-custody>

## Citations

### Academic Publications and Research Reports

> Sharon Dolovich, Aaron Littman, Michael Everett, Lauren Woyczynski, Victoria Rossi, Baji Tumendemberel, Kalind Parish, Grace DiLaura, Chase Hommeyer, Hope Johnson, Neal Marquez, Erika Tyagi, and Megan Arellano.\
> *UCLA Law Covid-19 Behind Bars Data Project: Prison Mortality Dataset* [date you downloaded the data]. UCLA Law, 2023.\
> <https://uclacovidbehindbars.org/>

### Media Outlets, Policy Briefs, and Online Resources

> UCLA Law Covid-19 Behind Bars Data Project.\
> <https://uclacovidbehindbars.org/>

If you use any data in this repository from **Alabama, Florida, Hawaii, Louisiana, Minnesota, Ohio, New York, Texas, Virginia, Washington,** or the **Bureau of Prisons**, please also cite the appropriate original source of that data.

------------------------------------------------------------------------

#### Alabama

> Alabama Department of Corrections. (2022–2024). *Code of Alabama §14-1-24—Quarterly Reports (Fiscal Years 2022–2024).*\
> Research and Planning Division, Joint Legislative Prison Oversight Committee.\
> <https://doc.alabama.gov/statreports.aspx>

#### Florida

> Florida Department of Corrections. (2020). *Inmate Mortality Statistics.*\
> <https://www.fdc.myflorida.com/statistics-and-publications/inmate-mortality#mortality_graph>

#### Hawaii

> Hawaii Correctional System Oversight Commission. (2025). *Hawaii correctional system mortality data (2022–2024).*  
235 S. Beretania Street, 16th Floor, Honolulu, HI 96813.  

#### Louisiana

> Andrea Armstrong, Judson Mitchell, Erica Navalance, Shanita Farris.\
> *Incarceration Transparency: Louisiana Deaths Behind Bars.*\
> Loyola University New Orleans, College of Law.\
> <https://www.incarcerationtransparency.org/>

#### Minnesota

> Minnesota Department of Corrections. *Health & Safety in Correctional Facilities: 2022 Legislative Report.*\
> <https://mn.gov/doc/assets/2022%20Health%20and%20Safety%20in%20Correctional%20Facilities_tcm1089-565603.pdf>
>
> Minnesota Department of Corrections. *Health & Safety in Correctional Facilities: 2023 Legislative Report.*\
> <https://mn.gov/doc/assets/2023%20Health%20and%20Safety%20in%20Correctional%20Facilities_tcm1089-609949.pdf>
>
> Minnesota Department of Corrections. *Health & Safety in Correctional Facilities: 2024 Legislative Report.*\
> <https://www.lrl.mn.gov/docs/2025/mandated/250306.pdf>

#### Ohio
> Harland, A. (2022). *Ohio Deaths in Custody – 2022.*  
> Office of Criminal Justice Services.  
> https://ocjs.ohio.gov

#### New York
> Correctional Association of New York. *Deaths in Custody Dashboard.*  
> https://www.correctionalassociation.org/data/dashboard-deaths-in-custody

#### Texas

> Texas Justice Initiative. *Texas Deaths in Custody.*\
> <https://texasjusticeinitiative.org/data>

#### Virginia
> Virginia Department of Criminal Justice Services. (2025, July). *Virginia Civilian Deaths in Custody in 2024.*  
> Richmond, VA: Commonwealth of Virginia, Department of Criminal Justice Services.  
> https://www.dcjs.virginia.gov :contentReference[oaicite:0]{index=0}

#### Washington

> Washington State Department of Corrections. (2025, October).\
> *Death Statistics for DOC Incarcerated Individuals.*\
> <https://doc.wa.gov/corrections/services/health-services>

#### Bureau of Prisons (BoP)

> Meg Anderson, Huo Jingnan, Neal Marquez, Erika Tyagi, Alison Guernsey, Robert Benincasa, Nick McMillan.\
> *NPR Investigations: BOP Excess Deaths.*\
> <https://github.com/NPR-investigations/BOP_all_cause_mortality>

------------------------------------------------------------------------

If you use any of the **prison population data** in this repository from the **Vera Institute of Justice**, please also cite their reporting.

> Jacob Kang-Brown, Chase Montagnet, Jasmine Heiss.\
> *Vera Institute of Justice: People in Jail and Prison in Spring 2021.*\
> <https://www.vera.org/publications/people-in-jail-and-prison-in-spring-2021#>:\~:text=By%20spring%202021%2C%20jail%20populations,reduce%20incarceration%20through%20spring%202021

If you use any of the **execution data** in this repository from the **Death Penalty Information Center**, please also cite their reporting.

> Death Penalty Information Center.\
> <https://deathpenaltyinfo.org/executions/execution-database>

Additionally, the **ACLU of Delaware** assisted with the collection of death records for Delaware state prisons.\
<https://www.aclu-de.org/>

## Data Notes

-   **New Jersey (NJ):** People who died in the Special Treatment Unit (STU) were excluded.\
    These individuals are considered civilly committed rather than incarcerated under DOC custody.

-   **Wisconsin (WI):** One individual listed as having died in "Other State" in 2024 was excluded,\
    as no context was provided to identify which state this referred to.

## License

Our data is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/). That means that you must give appropriate credit, provide a link to the license, and indicate if changes were made. You may not use our work for commercial purposes, which means anything primarily intended for or directed toward commercial advantage or monetary compensation.

## Contributors

For questions or feedback about the data, please reach out to [bbdp.data\@law.ucla.edu](mailto:bbdp.data@law.ucla.edu){.email}.
