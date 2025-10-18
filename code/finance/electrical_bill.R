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
df |>
  select(fecha, k_wh) |>
  arrange(fecha) |>
  mutate(
    consumo_diario = k_wh - lag(k_wh),
    weekday = weekdays(fecha),
    month_day = lubridate::day(fecha),
    month = lubridate::month(fecha, label = TRUE, abbr = TRUE),
    year = lubridate::year(fecha),
    week_number = lubridate::isoweek(fecha)
  ) |>
  arrange(desc(fecha)) |>
  group_by(week_number, year) |>
  summarise(
    consumo_semanal = sum(consumo_diario, na.rm = TRUE)
  ) |>
  ungroup() |>
  arrange(week_number)
