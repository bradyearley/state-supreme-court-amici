## Purpose
* This project analyzes the relationship between state constitutions and amicus briefs filed in state supreme court cases.
* The data comes from two sources. Amicus briefs were scraped from the [State Case Database](https://statecourtreport.org/state-case-database)
and the state constitutions were downloaded from the [Council on State Governments Webiste](https://bookofthestates.org/tables/2022-1-3/)
followed by some minimal format cleaning in excel.
* The number of cases is 1087 and the number of amicus briefs filed in those cases is 1509.
* All state constitutions are current as of January 1, 2022.


## List of Files
Please be sure to consult the following scripts and files to understand how data was scraped and cleaned for analysis:
* `state_const_texts.R`: An R script for loading state constitutions data from the [Council on State Governments Webiste](https://bookofthestates.org/tables/2022-1-3/) excel file
* `scraping_amicus.R`: An R script for scraping all amicus briefs for each state supreme court case on the [State Case Database](https://statecourtreport.org/state-case-database) to prepare the `amicus.rds` file
* `scraping_case.R`: An R script for scraping all cases in the [State Case Database](https://statecourtreport.org/state-case-database) to prepare the `case.rds` file
* `state_const_texts.xlsx`: Excel file of state constitutions and their length
* `amicus.rds`: Dataframe of scraped state supreme court cases with amicus briefs
* `case.rds`: Dataframe of scraped state supreme court cases

## Required Packages
* `tidyverse`
* `rvest`
* `lubridate`
* `stringr`
* `readxl`
* `knitr`

## Additional Information
Please be aware that you the State Case Database website is updated frequently. 
This can create disparities between the `amicus.rds` file and `case.rds` file if 
the two are scraped at meaningfully different times.

This project received help from:
* UChicago MACSS program
* Stack Overflow for references on how to use particular R functions
* The University of Chicago's Phoenix AI (GPT 4.1) to debug code and Rmarkdown errors
* The website [regex101](https://regex101.com/) to test different regular expressions
