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

                        h2("Type de points conservés dans l'analyse"),
                        radioButtons(   inputId = "speedZero",
                                        label = NULL,
                                        choices = c("Conserver tous les points" = FALSE,
                                                    "Conserver uniquement les points avec une vitesse de 0 km/h" = TRUE),
                                        inline = TRUE
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