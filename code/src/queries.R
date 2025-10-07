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


DbDataFetcher <- R6Class(
  "DbDataFetcher",
  public = list(
    initialize = function() {},

    get_data_by_date = function(
      table,
      date_field,
      start_date,
      end_date
    ) {
      # Returns a tibble with data between start_date and end_date

      query <- glue::glue(
        "SELECT * FROM {table} WHERE {date_field} >= '{start_date}' AND {date_field} <= '{end_date}'"
      )

      response <- dbSendQuery(conn, query)
      df <- dbFetch(response) |> dplyr::as_tibble()
      dbClearResult(response)
      return(df)
    },

    get_checksum_data_by_date = function(start_date, end_date) {
      TABLE <- "checksum"
      DATE_FIELD <- "fechasvr"

      return(self$get_data_by_date(
        TABLE,
        DATE_FIELD,
        start_date,
        end_date
      ))
    },

    get_error_data_by_date = function(start_date, end_date) {
      TABLE <- "data"
      DATE_FIELD <- "fecha"

      return(self$get_data_by_date(
        TABLE,
        DATE_FIELD,
        start_date,
        end_date
      ))
    }
  )
)


# Traer, por ejemplo, 1000 filas
df <- dbFetch(response, n = 1000) |> as_tibble()

df |> view()


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

df |>
  mutate(
    error = clean_error(error)
  ) |>
  select(error) |>
  distinct() |>
  as.data.frame()
