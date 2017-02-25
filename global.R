# ----------------------- requirements ---------------------------------
library(shiny)
library(shinyjs)
library(stockPortfolio)
library(lubridate)
library(dplyr)
library(scales)
library(ggplot2); library(gridExtra)


# Global variables shared between ui.R and server.R -----------------------------

# calculate start and end dates for quote retrievals
tday = today()
tenyears = tday - dyears(10)

# initial set of stocks to be displayed
initStocks = "AAPL, SPY, GOOG, GILD, T"