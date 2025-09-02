library("shiny")
library("shinydashboard")

options(shiny.maxRequestSize = 100*1024^2)

# Charge all functions except ui and server to build Shiny application
ls <- list.files(here::here("R"), full.names = TRUE)
ls_sub <- grepv("server.r|user_interface.r", ls, invert = TRUE)
lapply(ls_sub, source)

source(here::here("R", "user_interface.r"))
source(here::here("R", "server.r"))

shiny::shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
