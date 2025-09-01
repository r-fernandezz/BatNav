library("shiny")
library("shinydashboard")

source(here::here("R", "user_interface.r"))
source(here::here("R", "server.r"))

shiny::shinyApp(ui = ui, server = server)
