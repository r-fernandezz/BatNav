library("shiny")
library("shinydashboard")

options(shiny.maxRequestSize = 100*1024^2)

source(here::here("R", "user_interface.r"))
source(here::here("R", "server.r"))

shiny::shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
#runApp(".")
