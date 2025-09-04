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

                menuItem(   "Parc National de La Réunion",
                            tabName = "VizDataPNR",
                            icon = icon("eye-open", lib = "glyphicon")
                ),

                menuItem(   "Occupation du sol",
                            tabName = "VizDataOCS",
                            icon = icon("eye-open", lib = "glyphicon"))
            )
        ),

        dashboardBody(
            tabItems(
                tabItem(tabName = "readData", 
                    h1("Quelles sont vos données pour cette analyse ?", align = "center"),

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
                    withSpinner(dataTableOutput(outputId = "previewBDD"))

                ),

                tabItem(tabName = "VizDataPNR",
                        h1("Emprise sur le Parc National de La Réunion", align = "center"),
                        fluidRow(
                            box(
                                title = "Carte des localisations",
                                width = 6,
                                withSpinner(plotOutput("map_PNR")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_PNR", "Télécharger la carte")
                                )
                            ),
                            box(
                                title = "Résumé des localisations",
                                width = 6,
                                withSpinner(tableOutput("tab_PNR"))
                            )
                        )
                        
                ),

                tabItem(tabName = "VizDataOCS",
                        h1("Zones fréquentées par les individus"),
                        div(
                            style = "text-align: center;",
                            downloadButton("download_OCS", "Télécharger le tableau")
                        ),
                        withSpinner(dataTableOutput(outputId = "tab_OCS"))
                )
            )
        )
)