


survey <- read.csv("survey_first10.csv")
choicetask <- read.csv("choicetask_first10.csv")

colnames(survey)
table(unique(survey$subject))

library(dplyr)
survey <- survey %>% arrange(subject, session)
survey <- survey[, !(names(survey) %in% c("X.1", "X", "group", "build"))]
survey <- survey[, grep("Latency$", colnames(survey), value = TRUE, invert = TRUE)]


colnames(choicetask)
table(unique(choicetask$subject))
choicetask <- subset(choicetask, choicetask$subject < 26)
choicetask <- choicetask %>% arrange(subject, session)
choicetask <- choicetask[, grep("itemCount$", colnames(choicetask), value = TRUE, invert = TRUE)]
choicetask <- subset(choicetask, choicetask$blockcode != "finish" & choicetask$trialcode == "choice")
choicetask <- choicetask[, !(names(choicetask) %in% c("X", "group", "build", "blocknum", "blockcode", "trialcode", "pairIndex", "pair", "picture.alc.x", "picture.soft.x"))]

#choicetask <- choicetask %>%
#  group_by(subject, session) %>%
#  mutate(trialnum = row_number()) %>%
#  ungroup()


choicetask %>%
  group_by(subject, session, date, time) %>%
  summarize(count = n(), .groups = "drop") %>%
  group_by(subject, session) %>%
  summarize(unique_datetime_count = n(), .groups = "drop") %>%
  filter(unique_datetime_count > 1)

choicetask <- choicetask %>%
  group_by(subject, session, date, time) %>%
  mutate(trialnum = row_number()) %>%
  ungroup()

choicetask <- choicetask %>%
  group_by(subject, session, date, time) %>%
  mutate(datetime_id = cur_group_id()) %>%
  ungroup()

choicetask <- choicetask %>%
  group_by(subject) %>%
  mutate(session = dense_rank(datetime_id)) %>%
  dplyr::select(-datetime_id) %>%
  ungroup()

survey <- survey %>%
  group_by(subject, session, date, time) %>%
  mutate(datetime_id = cur_group_id()) %>%
  ungroup()

survey <- survey %>%
  group_by(subject) %>%
  mutate(session = dense_rank(datetime_id)) %>%
  dplyr::select(-datetime_id) %>%
  ungroup()


intersect(colnames(survey), colnames(choicetask))

survey <- survey[, !(names(survey) %in% c("date", "time"))]


data <- merge(survey, choicetask, by=c("subject", "session"))

#
# merging complete
#
q2_cols <- grep("q2StressfulEventDescriptionoption.*Response", names(survey), value = TRUE)
q2_summary <- data.frame(Option = character(), Count = integer(), stringsAsFactors = FALSE)

for (col in q2_cols) {
  col_table <- table(survey[[col]], useNA = "ifany")
    col_df <- data.frame(
    Option = names(col_table),
    Count = as.integer(col_table),
    stringsAsFactors = FALSE
  )
  
  # Remove empty responses (if needed)
  col_df <- col_df[col_df$Option != "" & !is.na(col_df$Option), ]
  
  # Append to the summary table
  q2_summary <- rbind(q2_summary, col_df)
}

# Sort by frequency (optional)
q2_summary <- q2_summary[order(-q2_summary$Count), ]

# Print the summary table
print(q2_summary)


q26_cols <- grep("q26BehAfterAlcoption.*Response", names(survey), value = TRUE)
q26_summary <- data.frame(Option = character(), Count = integer(), stringsAsFactors = FALSE)

for (col in q26_cols) {
  col_table <- table(survey[[col]], useNA = "ifany")
  col_df <- data.frame(
    Option = names(col_table),
    Count = as.integer(col_table),
    stringsAsFactors = FALSE
  )
  
  # Remove empty responses (if needed)
  col_df <- col_df[col_df$Option != "" & !is.na(col_df$Option), ]
  
  # Append to the summary table
  q26_summary <- rbind(q26_summary, col_df)
}

# Sort by frequency (optional)
q26_summary <- q26_summary[order(-q26_summary$Count), ]

# Print the summary table
print(q26_summary)


q27_cols <- grep("q27StatementsAfterAlcoption.*Response", names(survey), value = TRUE)
q27_summary <- data.frame(Option = character(), Count = integer(), stringsAsFactors = FALSE)

for (col in q27_cols) {
  col_table <- table(survey[[col]], useNA = "ifany")
  col_df <- data.frame(
    Option = names(col_table),
    Count = as.integer(col_table),
    stringsAsFactors = FALSE
  )
  
  # Remove empty responses (if needed)
  col_df <- col_df[col_df$Option != "" & !is.na(col_df$Option), ]
  
  # Append to the summary table
  q27_summary <- rbind(q27_summary, col_df)
}

# Sort by frequency (optional)
q27_summary <- q27_summary[order(-q27_summary$Count), ]

# Print the summary table
print(q27_summary)


q31_cols <- grep("q31Peopleoption.*Response", names(survey), value = TRUE)
q31_summary <- data.frame(Option = character(), Count = integer(), stringsAsFactors = FALSE)

for (col in q31_cols) {
  col_table <- table(survey[[col]], useNA = "ifany")
  col_df <- data.frame(
    Option = names(col_table),
    Count = as.integer(col_table),
    stringsAsFactors = FALSE
  )
  
  # Remove empty responses (if needed)
  col_df <- col_df[col_df$Option != "" & !is.na(col_df$Option), ]
  
  # Append to the summary table
  q31_summary <- rbind(q31_summary, col_df)
}

# Sort by frequency (optional)
q31_summary <- q31_summary[order(-q31_summary$Count), ]

# Print the summary table
print(q31_summary)

table(data$response)
data$response <- ifelse(data$response == "0", NA, data$response)

head(choicetask, 1)


# First, calculate the difference between ratings
data <- data %>%
  mutate(rating_diff = ratingAlc - ratingSoft)

# Now calculate the percentage of "alc" and "soft" responses for each difference value
response_by_diff <- data %>%
  group_by(rating_diff) %>%
  summarize(
    total_trials = n(),
    alc_count = sum(response == "alc", na.rm = TRUE),
    soft_count = sum(response == "soft", na.rm = TRUE),
    alc_percent = round(100 * alc_count / total_trials, 1),
    soft_percent = round(100 * soft_count / total_trials, 1)
  ) %>%
  arrange(rating_diff)

# Print the results
print(response_by_diff)



library(lubridate)
library(ggplot2)
library(tidyr)

# Convert the date string to a proper date and extract weekday
data <- data %>%
  mutate(
    # Convert string date to proper date format (assuming MM/DD/YYYY format)
    date_proper = mdy(date),
    # Extract weekday as both number (1-7) and name
    weekday_num = wday(date_proper),
    weekday = weekdays(date_proper)
  )

# Function to calculate response percentages by rating difference
calc_response_by_diff <- function(data) {
  data %>%
    mutate(rating_diff = ratingAlc - ratingSoft) %>%
    group_by(rating_diff) %>%
    summarize(
      total_trials = n(),
      alc_count = sum(response == "alc", na.rm = TRUE),
      soft_count = sum(response == "soft", na.rm = TRUE),
      alc_percent = round(100 * alc_count / total_trials, 1),
      soft_percent = round(100 * soft_count / total_trials, 1)
    ) %>%
    arrange(rating_diff)
}

# Calculate for all data
all_responses <- calc_response_by_diff(data)

# Calculate for Tuesdays only
monday_responses <- data %>%
  filter(weekday == "Monday") %>%
  calc_response_by_diff()

# Calculate for Fridays only
saturday_responses <- data %>%
  filter(weekday == "Saturday") %>%
  calc_response_by_diff()

# Print results
print(all_responses)
print(monday_responses)
print(saturday_responses)

