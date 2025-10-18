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
df <- df |>
  arrange(fecha) |>
  mutate(
    consumo_diario = k_wh - lag(k_wh),
    costo_diario = costo_total - lag(costo_total)
  )
