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

loadfonts(device = "all")
font_import()


FILE_NAME <- "db/ElectricCarData_Clean.csv"

color <- list(BLUE = "#1C69A8", RED = "#E7180B", BLACK = "black")

df <- read_csv(FILE_NAME)

punto_max <- df |> filter(Range_Km == max(Range_Km))
punto_max <- df |> filter(Range_Km > 550)

df |>
  ggplot(aes(x = TopSpeed_KmH, y = Range_Km)) +
  geom_smooth(
    method = "lm",
    # formula = y ~ splines::bs(x, 3),
    se = FALSE,
    color = color$RED
  ) +
  geom_text(
    data = punto_max,
    aes(label = paste(Brand, "-", Model)),
    vjust = -1,
    hjust = -0.1,
    color = color$BLACK
  ) +
  annotate(
    "segment",
    x = punto_max$TopSpeed_KmH + 10,
    y = punto_max$Range_Km + 10,
    xend = punto_max$TopSpeed_KmH + 1,
    yend = punto_max$Range_Km + 1,
    arrow = arrow(length = unit(0.2, "cm")),
    color = color$BLACK,
    size = 1.3
  ) +
  geom_point(shape = 17, size = 3, color = color$BLUE) +
  scale_x_continuous(breaks = seq(100, 420, 20), limits = c(100, 420)) +
  scale_y_continuous(breaks = seq(50, 1000, 50), limits = c(50, 1000))
