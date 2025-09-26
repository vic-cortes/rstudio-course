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

df <- read.csv(INCIDENCIA_DELICTIVA_FILE, sep = ",", encoding = "latin1")
