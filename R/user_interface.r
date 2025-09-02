ui <-  dashboardPage(

        dashboardHeader(
            title = "BatNav"
        ),

        dashboardSidebar(
            sidebarMenu(
                menuItem(   "Importation des données GPS", 
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
                        h1("Importation des données GPS", align = "center"),

                        h2("Période de déploiement des GPS"),
                        dateRangeInput(inputId = "dateRange",
                                        label = NULL,
                                        format = "dd-mm-yyyy",
                                        language = "fr",
                                        separator = "à"
                        ),

                        h2("Tableaux des localisation GPS"), 
                        fileInput(  inputId = "BDDFile", 
                                    label = NULL,
                                    multiple = TRUE,
                                    buttonLabel = "Choisir les fichiers", 
                                    placeholder = "Aucun fichier"
                        ),

                        h2("Vérification des données importées"),
                        dataTableOutput(outputId = "previewBDD")

                ),

                tabItem(tabName = "VizData",
                        h1("Visualisation des données", align = "center"),
                )
            )
        )
)