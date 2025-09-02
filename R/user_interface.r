ui <-  dashboardPage(

        dashboardHeader(
            title = "BatNav"
        ),

        dashboardSidebar(
            sidebarMenu(
                menuItem(   "Importation des données", 
                            tabName = "readData", 
                            icon = icon("download-alt", lib = "glyphicon")
                ),

                menuItem(   "Visualisation des données",
                            tabName = "VizData",
                            icon = icon("eye-open", lib = "glyphicon"))
            )
        ),

        dashboardBody(
            tabItems(
                tabItem(tabName = "readData", 
                        h1("Importation des données", align = "center"),
                        h2("Rechercher les tableaux de localisation"), 
                        fileInput(  inputId = "BDDFile", 
                                    label = NULL,
                                    multiple = TRUE,
                                    buttonLabel = "Choisir les fichiers", 
                                    placeholder = "Aucun fichier"),
                        
                        uiOutput("titlePreviewBDD"),
                        dataTableOutput(outputId = "previewBDD")
                ),

                tabItem(tabName = "VizData",
                        h1("Visualisation des données", align = "center"),
                )
            )
        )
)