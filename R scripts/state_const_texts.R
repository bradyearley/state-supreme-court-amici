# load the state constitutions file
library(readxl)
const_texts <- read_excel("const_texts.xlsx")
glimpse(const_texts)

# find the state with the longest constitution (its length), the shortest constitution (its length)
# and the mean, median, and standard deviation for the dataset
max_state <- const_texts |>
  filter(words == max(words)) |>
  pluck(1)

min_state <- const_texts |>
  filter(words == min(words)) |>
  pluck(1)

mean_words <- mean(const_texts$words)
median_words <- median(const_texts$words)
sd_words <- sd(const_texts$words)

