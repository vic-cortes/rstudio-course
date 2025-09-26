library(DBI)

response <- dbSendQuery(conn, "SELECT * FROM data")

# Traer, por ejemplo, 1000 filas
partial_data <- dbFetch(response, n = 1000)


# As tibble
partial_data <- as_tibble(partial_data)
