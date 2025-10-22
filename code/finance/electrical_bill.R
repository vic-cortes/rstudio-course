setwd("./code/finance/")

library(googlesheets4)
library(janitor)
library(dplyr)

source("config.R")

SHEET_NAME <- "Gasto CFE"

df <- read_sheet(Config$GOOGLE_SHEET_CFE, sheet = SHEET_NAME) |>
  janitor::clean_names()


# Actual analytics

df |> select(fecha, k_wh)

# Jalar el vector de kwh y usa diff para calcular el consumo diario
# con dplyr
selected_df <- df |>
  select(fecha, k_wh) |>
  arrange(fecha) |>
  mutate(
    daily_consumption = k_wh - lag(k_wh),
    weekday = weekdays(fecha),
    month_day = lubridate::day(fecha),
    month = lubridate::month(fecha, label = TRUE, abbr = TRUE),
    year = lubridate::year(fecha),
    week_number = lubridate::isoweek(fecha)
  ) |>
  # Remove all rows with NA in daily_consumption
  filter(!is.na(daily_consumption)) |>
  arrange(desc(fecha)) |>
  group_by(week_number, year) |>
  summarise(
    total_week = sum(daily_consumption, na.rm = TRUE),
    min_week = min(daily_consumption, na.rm = TRUE),
    avg_week = mean(daily_consumption, na.rm = TRUE),
    median_week = median(daily_consumption, na.rm = TRUE),
    max_week = max(daily_consumption, na.rm = TRUE)
  ) |>
  ungroup() |>
  # Sort by week number descending and year descending
  arrange(desc(year), desc(week_number))

selected_df |>
  # Combine year and week_number into a new column week_year
  tidyr::unite(
    week_year,
    c("year", "week_number"),
    sep = "-W",
    remove = FALSE
  ) |>
  mutate(week_year = factor(week_year, levels = unique(week_year))) |>
  ggplot(aes(
    x = total_week,
    y = week_year,
    fill = factor(year),
    label = abs(total_week)
  )) +
  scale_y_discrete(limits = rev) +
  geom_col() +
  geom_text() +
  theme_minimal()
