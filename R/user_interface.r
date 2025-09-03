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

                menuItem(   "Parc National Réunion",
                            tabName = "VizDataPNR",
                            icon = icon("eye-open", lib = "glyphicon"))
            )
        ),

        dashboardBody(
            tabItems(
                tabItem(tabName = "readData", 
                    h1("Quelles sont les données que vous voulez considérer dans votre analyse ?", align = "center"),

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

                    h2("Filtrage des points par la vitesse"),
                    radioButtons(   
                            inputId = "speedZero",
                            label = NULL,
                            choices = c("Conserver uniquement les points avec une vitesse de 0 km/h" = TRUE,
                                        "Conserver tous les points" = FALSE)
                        ),

                    h2("Filtrage des points par une emprise spatiale"),
                    radioButtons(   inputId = "filterWindow",
                                    label = NULL,
                                    choices = c("Supprimer les points hors de la fenêtre 10°S–30°S, 40°E–65°E" = TRUE,
                                                "Conserver les points hors de la fenêtre 10°S–30°S, 40°E–65°E" = FALSE
                                                )
                    ),

                    h2("Vérification des données importées"),
                    dataTableOutput(outputId = "previewBDD")

                ),

                tabItem(tabName = "VizDataPNR",
                        h1("Emprise sur le Parc National de La Réunion", align = "center"),
                        plotOutput("map_PNR")
                )
            )
        )
)