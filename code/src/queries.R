library(DBI)

response <- dbSendQuery(conn, "SELECT * FROM data WHERE LEN(error) > 0")

# Traer, por ejemplo, 1000 filas
df <- dbFetch(response, n = 1000) |> as_tibble()


clean_error <- function(x) {
  # Standardize errors by removing extra spaces and trimming
  DELIMITER <- "Falla"

  x <- gsub("\\s+", " ", x) |> trimws() |> strsplit(DELIMITER) |> sapply(`[`, 1)

  return(x)
}

df |>
  mutate(
    error = clean_error(error)
  ) |>
  select(error) |>
  distinct() |>
  as.data.frame()
