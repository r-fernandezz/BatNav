ui <-  dashboardPage(

        dashboardHeader(
            title = "BatNav"
        ),

        dashboardSidebar(
            menuItem("Charger les données", tabName = "readData", icon = icon("poll")
            )
        ),

        dashboardBody(
            tabItem(tabName = "readData", 
                    h1("Charger les données"), 
                    fileInput(  inputId = "dataFile", 
                                label = NULL,
                                multiple = TRUE,
                                buttonLabel = "Choisir un dossier", 
                                placeholder = "Aucun dossier")
            )
        )
)