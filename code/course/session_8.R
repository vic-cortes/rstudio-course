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

colors <- list(
  BLUE = "#1C69A8",
  RED = "#E7180B",
  GREEN = "#7CB342",
  BLACK = "black",
  WHITE = "white"
)

html_info <- list(
  TITLE = "<b style = 'color:#1C69A8'> Vehículos eléctricos según su </b><b style = 'color:#E7180B'> velocidad máxima</b><b style = 'color:#1C69A8'> y </b><b style = 'color:#E7180B'> autonomía de batería</b>",
  SUBTITLE = "<i style = 'color:#E7180B'> registros del 2024</i>",
  CAPTION = "<span style = 'color:#E7180B'> Fuente. Kaggle. EVs - One Electric Vehicle Dataser-Smaller. (2024)</span>",
  X_LABEL = "<span style = 'color:#E7180B'> Velocidad máxima registrada</span>",
  Y_LABEL = "<span style = 'color:#E7180B'> Autonomía de la batería</span>"
)

df <- read_csv(FILE_NAME)

punto_max <- df |> filter(Range_Km == max(Range_Km))
punto_min <- df |> filter(Range_Km == min(Range_Km))
punto_max <- df |> filter(Range_Km > 550)
all_points <- df |> filter(Range_Km > 550 | Range_Km == min(Range_Km))

create_graph <- function(selected_data) {
  # Creates a scatter plot with a linear model fit and annotations for
  # the maximum range car
  DEFAULT_FONT <- "Goudy Old Style"

  df |>
    ggplot(aes(x = TopSpeed_KmH, y = Range_Km)) +
    geom_smooth(
      method = "lm",
      # formula = y ~ splines::bs(x, 3),
      se = FALSE,
      color = colors$RED
    ) +
    geom_text(
      data = selected_data,
      aes(label = paste(Brand, "-", Model)),
      vjust = -1,
      hjust = -0.1,
      color = colors$BLACK,
      fontface = "bold"
    ) +
    annotate(
      "segment",
      x = selected_data$TopSpeed_KmH + 10,
      y = selected_data$Range_Km + 10,
      xend = selected_data$TopSpeed_KmH + 2,
      yend = selected_data$Range_Km + 2,
      arrow = arrow(length = unit(0.2, "cm")),
      color = colors$BLACK,
      size = 1.3
    ) +
    geom_point(shape = 17, size = 3, color = colors$BLUE) +
    scale_x_continuous(breaks = seq(100, 420, 20), limits = c(100, 420)) +
    scale_y_continuous(breaks = seq(50, 1000, 50), limits = c(50, 1050)) +
    labs(
      title = html_info$TITLE,
      subtitle = html_info$SUBTITLE,
      caption = html_info$CAPTION,
      x = html_info$X_LABEL,
      y = html_info$Y_LABEL
    ) +
    theme(
      plot.title = element_markdown(size = 16, family = DEFAULT_FONT),
      plot.subtitle = element_markdown(size = 14, family = DEFAULT_FONT),
      plot.caption = element_markdown(
        hjust = 0,
        size = 12,
        family = DEFAULT_FONT
      ),
      axis.title.x = element_markdown(size = 13, family = DEFAULT_FONT),
      axis.title.y = element_markdown(size = 13, family = DEFAULT_FONT),
      axis.text = element_text(
        color = colors$BLUE,
        face = "bold",
        size = 13,
        family = DEFAULT_FONT
      ),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(
        color = alpha(colors$GREEN, 0.3),
        linetype = "dashed"
      ),
      panel.background = element_rect(fill = "white"),
      axis.ticks = element_line(color = colors$GREEN)
    )
}

create_graph(punto_max)
create_graph(punto_min)
create_graph(all_points)
