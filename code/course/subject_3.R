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
coahuila_state <- "Coahuila de Zaragoza"

HOMICIDE_TYPES <- c(homicidio_doloso)

df %>% filter(`Subtipo de delito` == homicidio_doloso) %>% view()


# Or filter with multiple conditions
df %>%
  filter(
    `Subtipo de delito` %in%
      HOMICIDE_TYPES &
      Entidad == coahuila_state &
      (Año >= 2022 & Año <= 2024)
  ) %>%
  view()

included_names <- names(df)[8:19]

zfill <- function(number) {
  # Add leading zero if number is less than 10
  final_number <- ifelse(nchar(number) == 1, paste0("0", number), number)
  return(final_number)
}

interest_columns <- c(
  "Año",
  "Clave_Ent",
  "Entidad",
  "Subtipo de delito",
  "Anual"
)

df %>%
  mutate(
    Anual = rowSums(across(included_names)),
    Clave_Ent = zfill(Clave_Ent)
  ) %>%
  select(all_of(interest_columns)) %>%
  filter(Año == 2024 & `Subtipo de delito` %in% HOMICIDE_TYPES) %>%
  group_by(Año, Clave_Ent, Entidad) %>%
  summarize(Homicidios_dolosos = sum(Anual, na.rm = TRUE)) %>%
  ungroup() %>%
  bind_rows(summarize(
    .,
    Año = 2024,
    Clave_Ent = "00",
    Entidad = "Nacional",
    Homicidios_dolosos = sum(Homicidios_dolosos)
  ))
view()


# With dplyr
df %>%
  mutate(
    Clave_Ent = zfill(Clave_Ent),
    Anual = sum(across(included_names), na.rm = TRUE)
  ) %>%
  view()

# %>%
# select(all_of(interest_columns)) %>%
# filter(Año == 2024 & `Subtipo de delito` %in% HOMICIDE_TYPES) %>%
# view()
