library(DBI)
library(dplyr)

response <- dbSendQuery(conn, "SELECT * FROM data WHERE LEN(error) > 0")
# Create a query by date
response <- dbSendQuery(
  conn,
  "SELECT * FROM data WHERE Fecha >= '2025-08-01' AND Fecha <= '2025-08-31'"
)

get_checksum_data_by_date <- function(start_date, end_date) {
  # Returns a tibble with data between start_date and end_date
  query <- sprintf(
    "SELECT * FROM checksum WHERE fechasvr >= '%s' AND fechasvr <= '%s'",
    start_date,
    end_date
  )
  response <- dbSendQuery(conn, query)
  df <- dbFetch(response) |> as_tibble()
  dbClearResult(response)
  return(df)
}


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
