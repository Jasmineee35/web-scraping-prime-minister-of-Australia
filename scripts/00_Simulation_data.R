# Plan 
## Create a simulation for the prime minister of Canada's data 

# Set up the workspace
library(babynames)
#library(gh)
#library(here)
library(httr)
library(janitor)
#library(jsonlite)
library(knitr)
library(kableExtra)
library(lubridate)
library(pdftools)
#library(purrr)
library(rvest)
#library(spotifyr)
#library(tesseract)
library(tidyverse)
library(ggplot2)
#library(xml2)


# For reproductivity 
set.seed(123)

simulated_dataset <-
  tibble(
    prime_minister = babynames |>
      filter(prop > 0.01) |>
      distinct(name) |>
      unlist() |>
      sample(size = 10, replace = FALSE),
    # Based on the Wikipedia data, we set the range of birth years as follows
    birth_year = sample(1810:1985, size = 10, replace = TRUE),
    # For this simulation, we assume that the range of years lived by each prime
    # minister is 50 to 100 years.
    years_lived = sample(50:100, size = 10, replace = TRUE),
    death_year = birth_year + years_lived
  ) |>
  select(prime_minister, birth_year, death_year, years_lived) |>
  arrange(birth_year)

simulated_dataset