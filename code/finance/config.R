pacman::p_load("dotenv")

load_dot_env(file = ".env")

Config <- list(
  GOOGLE_SHEET_ID = Sys.getenv(
    "GOOGLE_SHEET_ID",
    unset = "your_google_sheet_id"
  ),
  GOOGLE_SHEET_CFE = Sys.getenv(
    "GOOGLE_SHEET_CFE",
    unset = "your_google_sheet_cfe"
  )
)
