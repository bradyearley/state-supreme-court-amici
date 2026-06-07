#' ---
#' title: Scraping State Case Database for Amicus Briefs
#' author: Brady Earley
#' date: December 5, 2025
#' purpose: This code scrapes all cases with amicus briefs from the State Case Database. 
#' In particular, it collects the name of the case, the state supreme court deciding
#' the case, year of the case, and the number of amicus briefs filed in the case
#' ---

# load libraries
library(tidyverse)
library(lubridate)
library(rvest)


# extracting relative urls from the cases on the first database page
test <- read_html(x = "https://statecourtreport.org/state-case-database?page=0")

state_links_rel_page_1 <- test |>
  html_elements(".grid--cases-cards .card__heading__link") |>
  html_attr("href")

# we should have 10 case links
length(state_links_rel_page_1)
state_links_rel_page_1[1:3]
is.character(state_links_rel_page_1)

# create full URL from base and relative urls
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

# create a function for scraping all the links from a page
links_all_pages <- function(page_url, domain_url) {
  # Scrapes case link data from a state case database page, pausing between requests
  # Args:
  #  page_url (string): url for one state case page
  #  domain_url (string): the base url that will be added to the front of each 
  #   relative link to make it work
  # Returns:
  #  vector: a vector with the full url link for the provided database webpage.
  #   The vector should have a length of 10 or less.
  
  # get HTML page
  Sys.sleep(runif(1, min = 1, max = 3))
  page_html <- read_html(page_url)
  
  # extract relative links for each page
  relative_links <- page_html |>
    html_elements(".grid--cases-cards .card__heading__link") |>
    html_attr("href")
  
  # convert to full URL
  full_links <- paste0(domain_url, relative_links)
  
  return(full_links)
}

# test the function to ensure it workability
test_link_1 <- links_all_pages(page_urls[1], base_url)
length(test_link_1)
test_link_1

test_link_2 <- links_all_pages(page_urls[2], base_url)
length(test_link_2)
test_link_2

test_link_109 <- links_all_pages(page_urls[109], base_url)
length(test_link_109)
test_link_109


# initialize vector to store all links
all_urls <- vector("character", length(page_urls) * 10)

# counter
url_index <- 1

# loop over all pages and store links (recommended to first loop over selected pages)
for (i in seq_along(page_urls)) {
  pages_links <- links_all_pages(page_urls[i], base_url)
  # nest another for loop to store in empty vector and continue to next page
  for (link in pages_links) {
    all_urls[url_index] <- link
    url_index <- url_index + 1
  }
}

# check resulting vector
head(all_urls)
length(all_urls)
all_urls[11]
all_urls[1087]

# subset to exclude the 3 empty elements at the end
my_urls <- all_urls[1:1087]
my_urls[11]
my_urls[1087]
my_urls[1088]

# function for scraping the case information from each link
scrape_case <- function(page_url) {
  # Scrapes information from each case page in state case database
  # Args:
  #  page_url (string): one state case page link
  # Returns:
  #  tibble: a tibble with the case name, date, state, and number of amicus briefs  
  
  # get html page
  Sys.sleep(runif(1, min = 1, max = 3))
  page_html <- read_html(x = page_url)
  
  # extract elements
  date <- html_elements(x = page_html, css = ".field__item time") %>%
    html_text2() %>% mdy()
  
  name <- html_elements(x = page_html, css = ".h1 span") %>%
    html_text2()
  
  state <- html_element(x = page_html, css = ".state-icon__icon-tooltip") %>%
    html_text2()
  
  amicus <- html_elements(x = page_html, css = ".tags__item--amicus-brief") %>%
    html_text2()
  
  # store in a data frame and return it
  url_data <- tibble(
    date = date,
    name = name,
    state = state,
    amicus = amicus
  )
  
  return(url_data)
}

# initialize vector to store results
results_list <- vector("list", length(my_urls))

for (i in seq_along(my_urls)) {
  results_list[[i]] <- scrape_case(my_urls[i])
}
amicus <- bind_rows(results_list)

# save to project folder as .RDS to access in .rmd
saveRDS(amicus, "amicus.rds")
