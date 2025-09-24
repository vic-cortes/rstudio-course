# Remove all variables
rm(list = ls())


if (require("pacman", quietly = TRUE)) {
    cat("Pacma packages already installed")
} else {
    install.packages("pacman", dependencies = TRUE)
}
