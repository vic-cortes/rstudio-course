library(R6)

library(DBI)
library(dplyr)


response <- dbSendQuery(conn, "SELECT * FROM data WHERE LEN(error) > 0")
# Create a query by date
response <- dbSendQuery(
  conn,
  "SELECT * FROM checksum WHERE fechasvr >= '2023-08-01 00:00:00' AND fechasvr <= '2023-08-31 23:59:59'"
)
response <- dbSendQuery(
  conn,
  "SELECT * FROM data WHERE fecha >= '2023-08-01 00:00:00' AND fecha <= '2023-08-31 23:59:59'"
)
response <- dbSendQuery(
  conn,
  "SELECT * FROM datos WHERE fechasvr >= '2023-08-01 00:00:00' AND fechasvr <= '2023-08-31 23:59:59'"
)

get_checksum_data_by_date <- function(start_date, end_date) {
  # Returns a tibble with data between start_date and end_date
  query <- sprintf(
    "SELECT * FROM checksum WHERE fechasvr >= '%s' AND fechasvr <= '%s'",
    start_date,
    end_date
  )
  response <- dbSendQuery(conn, query)
  df <- dbFetch(response) |> dplyr::as_tibble()
  dbClearResult(response)
  return(df)
}

get_data_by_date <- function(start_date, end_date) {
  # Returns a tibble with data between start_date and end_date
  query <- sprintf(
    "SELECT * FROM data WHERE fecha >= '%s' AND fecha <= '%s'",
    start_date,
    end_date
  )
  response <- dbSendQuery(conn, query)
  df <- dbFetch(response) |> dplyr::as_tibble()
  dbClearResult(response)
  return(df)
}

get_datos_by_date <- function(start_date, end_date) {
  # Returns a tibble with data between start_date and end_date
  query <- sprintf(
    "SELECT * FROM datos WHERE fechasvr >= '%s' AND fechasvr <= '%s'",
    start_date,
    end_date
  )
  response <- dbSendQuery(conn, query)
  df <- dbFetch(response) |> dplyr::as_tibble()
  dbClearResult(response)
  return(df)
}


DbDataFetcher <- R6Class(
  "DbDataFetcher",
  public = list(
    initialize = function() {},

    get_checksum_data_by_date = function(start_date, end_date) {
      TABLE <- "checksum"
      DATE_FIELD <- "fechasvr"

      return(private$get_data_by_date(
        TABLE,
        DATE_FIELD,
        start_date,
        end_date
      ))
    },

    get_error_data_by_date = function(start_date, end_date) {
      TABLE <- "data"
      DATE_FIELD <- "fecha"

      return(private$get_data_by_date(
        TABLE,
        DATE_FIELD,
        start_date,
        end_date
      ))
    }
  ),

  private = list(
    get_data_by_date = function(
      table,
      date_field,
      start_date,
      end_date
    ) {
      # Returns a tibble with data between start_date and end_date

      SUPPORTED_TABLES <- c("checksum", "data", "datos")

      if (!(table %in% SUPPORTED_TABLES)) {
        stop("Unsupported table")
      }

      query <- glue::glue(
        "SELECT * FROM {table} WHERE {date_field} >= '{start_date}' AND {date_field} <= '{end_date}'"
      )

      response <- dbSendQuery(conn, query)
      df <- dbFetch(response) |> dplyr::as_tibble()
      dbClearResult(response)
      return(df)
    }
  )
)

db_object <- DbDataFetcher$new()

db_object$get_checksum_data_by_date("2023-08-01", "2023-08-31")


# Traer, por ejemplo, 1000 filas
df <- dbFetch(response, n = 1000) |> as_tibble()

df |> view()

df2 <- df |>
  # Primero separar el string en lista de vectores de caracteres (split por coma)
  mutate(
    datos_list = stringr::str_split(datos, ",")
  ) |>
  # Seleccionar solamente datos_list que tengan 52 elementos
  filter(purrr::map_int(datos_list, length) == 52) |>
  # Opcional: si el string tiene comas al principio/final, filtrar los vacíos
  mutate(
    datos_list = purrr::map(datos_list, ~ purrr::discard(.x, ~ .x == "")) # elimina elementos vacíos
  ) |>
  # Convertir cada lista de caracteres a un tibble de una sola fila (columnas = cada posición)
  mutate(
    datos_wide = purrr::map(
      datos_list,
      ~ tibble::as_tibble_row(.x, .name_repair = "universal_quiet")
    )
  ) |>
  # Expandir esa columna de data frames en columnas sueltas
  tidyr::unnest_wider(datos_wide, names_sep = "_") |>
  # (Opcional) convertir esas columnas nuevas a numéricas
  mutate(across(contains("..."), ~ as.numeric(.x))) |>
  select(-datos_list, -datos)


clean_error <- function(x) {
  # Standardize errors by removing extra spaces and trimming
  DELIMITER <- "Falla"

  x <-
    gsub("\\s+", " ", x) |>
    trimws() |>
    strsplit(DELIMITER) |>
    sapply(`[`, 1) |>
    trimws()

  return(x)
}

df_errors <- get_data_by_date("2023-08-01", "2023-08-31")

df_errors <- df_errors |>
  mutate(
    serial = trimws(serial),
    error = clean_error(error),
    modelo = trimws(modelo)
  ) |>
  select(serial, modelo, error)

# |>
# select(error) |>
# distinct() |>
# as.data.frame()

# Join with df2 by serial
df_final <- df2 |>
  inner_join(
    df_errors,
    by = c("serial", "modelo"),
    relationship = "many-to-many"
  ) |>
  rename_with(
    .fn = ~ str_replace(.x, "datos_wide_...", "v"),
    .cols = contains("datos_wide_...")
  )


# Export to CSV
readr::write_csv(df_final, "august_2023_data.csv")
