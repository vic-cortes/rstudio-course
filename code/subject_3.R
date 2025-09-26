# Remove all variables
rm(list = ls())


if (require("pacman", quietly = TRUE)) {
  cat("Pacma packages already installed")
} else {
  install.packages("pacman", dependencies = TRUE)
}

pacman::p_load(
  "tidyverse",
  "tseries",
  "readxl",
  "haven",
  "foreign",
  "lubridate",
  "readr"
)

INCIDENCIA_DELICTIVA_FILE <- "db/IDEFC_NM_ago25.csv"

df <- read.csv(
  INCIDENCIA_DELICTIVA_FILE,
  check.names = FALSE,
  encoding = "latin1"
)

# Filters
homicidio_doloso <- "Homicidio doloso"
homicidio_culposo <- "Homicidio culposo"

df %>% filter(`Subtipo de delito` == homicidio_doloso) %>% view()

# Or filter with multiple conditions
df %>%
  filter(
    `Subtipo de delito` %in% c(homicidio_doloso, homicidio_culposo)
  ) %>%
  view()
