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

# Download data from https://inegi.org.mx/programas/envipe/2025/#microdatos
ENVIPE_FILE <- "db/TSDem.csv"

df <- read.csv(ENVIPE_FILE)
names(df)

# Diario Oficial de la Federacion

TC_DOF <- "db/TC_DOF.csv"
df <- read.csv(TC_DOF, skip = 29)
colnames(df) <- c("Fecha", "TC_DOF")

# Convert column to date and extract year
df <- df |>
  mutate(
    Fecha = as.Date(Fecha, format = "%d/%m/%Y"),
    year = format(Fecha, "%Y")
  )

# Datos de panel

# Datos de series de tiempo
DAILY_SIMPLE_FILE <- "db/afluenciastc_simple_08_2025.csv"

df <- read.csv(DAILY_SIMPLE_FILE, encoding = "latin1", stringsAsFactors = FALSE)
df <- read.csv(
  DAILY_SIMPLE_FILE,
  fileEncoding = "UTF-8",
  stringsAsFactors = FALSE
)
df <- read_csv(DAILY_SIMPLE_FILE, locale = locale(encoding = "Latin1"))

# Other examples

EXAMPLE_FILE <- "db/IDEFC_NM_ago25.csv"

df <- read.csv(EXAMPLE_FILE, encoding = "latin1")
df |> head()
