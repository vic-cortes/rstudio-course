pacman::p_load("dotenv")

load_dot_env(file = ".env")


db_config <- list(
    password = Sys.getenv("DB_PASSWORD", unset = ""),
    server = Sys.getenv("DB_SERVER", unset = "localhost"),
    database = Sys.getenv("DB_DATABASE", unset = "testdb"),
    user = Sys.getenv("DB_USER", unset = "sa"),
    port = Sys.getenv("DB_PORT", unset = 1433)
)
