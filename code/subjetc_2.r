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
  "lubridate"
)

# Download data from https://inegi.org.mx/programas/envipe/2025/#microdatos
ENVIPE_FILE <- "db/TSDem.csv"

df <- read.csv(ENVIPE_FILE)
names(df)

# Datos de series de tiempo
DAILY_SIMPLE_FILE <- "db/afluenciastc_simple_08_2025.csv"

# Diraro Ofcial de la Federacion
TC_DOF <- "db/TC_DOF.csv"
df <- read.csv(TC_DOF, skip = 29)
colnames(df) <- c("Fecha", "TC_DOF")
