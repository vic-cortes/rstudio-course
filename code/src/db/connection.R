pacman::p_load("DBI", "odbc")

source("../config.r")

DRIVER <- "ODBC Driver 17 for SQL Server"

con <- dbConnect(
    odbc::odbc(),
    Driver = DRIVER,
    Server = db_config$server,
    Database = db_config$database,
    UID = db_config$user,
    PWD = db_config$password,
    Port = db_config$port
)
