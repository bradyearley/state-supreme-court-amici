#' ---
#' title: Scraping All Cases from State Case Database
#' author: Brady Earley
#' date: December 6, 2025
#' purpose: This code scrapes cases from pages of the State Case Database. 
#' In particular, it collects the name of the case, the state supreme court deciding
#' the case, and the year of the case.
#' ---

# load libraries
library(tidyverse)
library(lubridate)
library(rvest)
library(stringr)


# figuring out what goes inside the function
test <- read_html(x = "https://statecourtreport.org/state-case-database?page=2")

state_links_rel_page_1 <- test |>
  html_elements(".grid--cases-cards .card__heading__link") |>
  html_attr("href")

# the best html element we can get picks up duplicates for each state name
# this regular expression removes the duplicated state name
state_name_rel_page_1 <- test |>
  html_elements(".grid--cases-cards .state-icons__list--medium") |>
  html_text2() |>
  str_extract("^New\\s+(\\w+)|^North\\s+(\\w+)|
              ^South\\s+(\\w+)|^Rhode\\s+(\\w+)|
              ^West\\s+(\\w+)|([^\\s]+)")


# tests to ensure above scraping worked
length(state_name_rel_page_1)
state_name_rel_page_1
is.character(state_name_rel_page_1)

# generating full URL from base and relative
base_url <- "https://statecourtreport.org"
state_links_full_page <- paste(base_url, state_links_rel_page_1, sep = "")
length(state_links_full_page)

# now we have all the links from the first page, so we just need to scale it up!
num_pages <- 108
listing_page_urls <- vector("character", num_pages)
listing_base_url <- "https://statecourtreport.org/state-case-database" 
page_0 <- "https://statecourtreport.org/state-case-database?page=0"

for (i in 0:num_pages) {
  listing_page_urls[i] <- paste0(listing_base_url, "?page=", i)
}

page_urls <- c(page_0, listing_page_urls)
page_urls[1]
length(page_urls)

# function for scraping case page information
case_name_each_pages <- function(page_url) {
  # Scrapes data from state case database case pages
  # Args:
  #  page_url (string): the unique url for each page in state case database
  # Returns:
  #  tibble: a tibble with the case name, date, and state
  
  # get HTML page
  Sys.sleep(runif(1, min = 1, max = 3))
  page_html <- read_html(page_url)
  
  # extract state for each case name on each page
  state <- page_html |>
    html_elements(".grid--cases-cards .state-icons__list--medium") |>
    html_text2() |>
    str_extract("^New\\s+(\\w+)|^North\\s+(\\w+)|^South\\s+(\\w+)|^Rhode\\s+(\\w+)|^West\\s+(\\w+)|([^\\s]+)")
  
  date <- page_html |>
    html_elements(".grid--cases-cards time") |>
    html_text2() |> mdy()
  
  name <- page_html |>
    html_elements(".grid--cases-cards .card__heading__link span") |>
    html_text2()
  
  # convert to data frame
  url_data <- tibble(
    date = date,
    name = name,
    state = state
  )
  
  return(url_data)
}

test0 <- case_name_each_pages("https://statecourtreport.org/state-case-database?page=6")

# initialize vector to store resulting dataframe
case_list <- vector("list", length(page_urls))

for (i in seq_along(page_urls)) {
  case_list[[i]] <- case_name_each_pages(page_urls[i])
}

case <- bind_rows(case_list)

# save to project folder as .RDS
saveRDS(case, "case.rds")