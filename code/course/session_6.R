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
  "readr",
  "sf"
)


# Datos de series de tiempo
DAILY_SIMPLE_FILE <- "db/afluenciastc_simple_08_2025.csv"

df <- read.csv(DAILY_SIMPLE_FILE, encoding = "latin1", stringsAsFactors = FALSE)

df |> mutate()
