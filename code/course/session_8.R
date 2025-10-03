#====================================================#
# Diplomado: Bases de datos y técnicas de gráficación#
# Tema: Gráfico lineal                               #
# Sesión: 08                                         #
# Fecha: 01/10/2025                                  #
# Instructor: Alexis Adonai Morales Albero           #
# SciData                                            #
#====================================================#

# Limpieza inicial de consola ----

rm(list = ls())

# Condicional de existencia de pacman ----

if (require("pacman", quietly = T)) {
  cat("El paquete de pacman se encuentra instalado")
} else {
  install.packages("pacman", dependencies = T)
}

# Llamado e instalación de paquetes ----

pacman::p_load(
  "tidyverse",
  "dplyr",
  "tseries",
  "readxl",
  "openxlsx",
  "haven",
  "foreign",
  "lubridate",
  "ggthemes",
  "cowplot",
  "png",
  "grid",
  "ggtext",
  "extrafont"
)


FILE_NAME <- "db/ElectricCarData_Clean.csv"

df <- read_csv(FILE_NAME)
