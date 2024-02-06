# Gather
## Acquiring the list of data of prime ministers of Australia from Wikipedia as it is a popular source, the information would likely to be correct 

# download the page using read_html
raw_data <-
  read_html(
    "https://en.wikipedia.org/wiki/List_of_prime_ministers_of_Australia"
  )
write_html(raw_data, "pms.html")

raw_data <- read_html("pms.html")

parse_data_selector_gadget <-
  raw_data |>
  html_element(".wikitable") |>
  html_table()
# Illustrate the first six rows of the gathered data
head(parse_data_selector_gadget)

parsed_data <-
parse_data_selector_gadget |> 
clean_names() |> 
rename(raw_text = name_birth_death_constituency) |> 
select(raw_text) |> 
filter(raw_text != "Name(Birth–Death)Constituency") |> 
distinct() 

# Extract the name, birth and death years
initial_clean <- parsed_data |>
  mutate(
    name = str_extract(raw_text, "^[^(]+"), # Extract the name before the first parenthesis
    lifespan = str_extract(raw_text, "\\(.*\\)"), # Extract the lifespan within the parenthesis
    born = if_else(str_detect(lifespan, "–"), NA_character_, str_extract(lifespan, "\\d{4}")), # If there's a dash, set born to NA
    date = if_else(str_detect(lifespan, "–"), str_extract(lifespan, "\\d{4}–\\d{4}"), NA_character_) # If there's no dash, set date to NA
  ) |>
  select(name, date, born)

# View the first 6 rows of results
head(initial_clean)

# clean up the columns
cleaned_data <-
  initial_clean |>
  separate(date, into = c("birth", "died"), 
           sep = "–") |>   # PMs who have died have their birth and death years 
  # separated by a hyphen, but we need to be careful with the hyphen as it seems 
  # to be a slightly odd type of hyphen and we need to copy/paste it.
  mutate(
    born = str_remove_all(born, "born[[:space:]]"),
    birth = if_else(!is.na(born), born, birth)
  ) |> # Alive PMs have slightly different format
  select(-born) |>
  rename(born = birth) |> 
  mutate(across(c(born, died), as.integer)) |> 
  mutate(Age_at_Death = died - born) |> 
  distinct() # Some of the PMs had two goes at it.

# Save the cleaned data into a csv file
write_csv(
  x = cleaned_data,
  file = "edited_data.csv"
)

