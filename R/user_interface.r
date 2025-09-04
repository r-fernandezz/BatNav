ui <-  dashboardPage(

        dashboardHeader(
            title = "BatNav"
        ),

        dashboardSidebar(
            sidebarMenu(
                menuItem(   "Paramétrage des données GPS", 
                            tabName = "readData", 
                            icon = icon("map-marker", lib = "glyphicon")
                ),
                menuItem("Croisement couches SIG", icon = icon("book", lib = "glyphicon"),
                
                    menuSubItem("Parc National de La Réunion",
                                tabName = "VizDataPNR",
                                icon = icon("eye-open", lib = "glyphicon")
                    ),

                    menuSubItem("Occupation du sol",
                                tabName = "VizDataOCS",
                                icon = icon("eye-open", lib = "glyphicon")),

                    menuSubItem("Plan Local d'Urbanisme (PLU)",
                                tabName = "VizDataPLU",
                                icon = icon("eye-open", lib = "glyphicon")
                    ),

                    menuSubItem("Réf. Parcellaire Graphique (RPG)",
                                tabName = "VizDataRPG",
                                icon = icon("eye-open", lib = "glyphicon")
                    )
                ),

                menuItem("Hauteur de vol", icon = icon("stats", lib = "glyphicon")

                ),

                menuItem("Distribution spatio-temporelle", icon = icon("screenshot", lib = "glyphicon")

                ),

                div(
                    "Romain Fernandez v1.0.0 - 2025",
                    br(),
                    a(  "Code on Github",
                        href = "https://github.com/r-fernandezz/BatNav",
                        target = "_blank"
                    ),
                    style = "position: absolute; bottom: 5px; color: #888; font-size: 10px; text-align: center; width: 220px;"
                )
            )
        ),

        dashboardBody(
            tags$head( #personalised CSS for centering all tables
                tags$style(HTML("
                .shiny-table {
                    margin-left: auto !important;
                    margin-right: auto !important;
                }
                "))
            ),
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
                        h1("Emprise sur le Parc National de La Réunion"),
                        p(
                            "Analyses réalisées avec les données générées par le Parc national de La Réunion 2021",
                            a("(source)", 
                                href = "http://peigeo.re:8080/geonetwork/srv/fre/catalog.search#/metadata/PNRun", 
                                target = "_blank"
                            )
                        ),
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
                                title = "Dénombrement des localisations",
                                width = 6,
                                withSpinner(tableOutput("tab_PNR"))
                            )
                        )
                        
                ),

                tabItem(tabName = "VizDataOCS",
                        h1("Zones fréquentées par les individus"),
                        p(
                            "Analyses réalisées avec les données générées par Dupuy, Stéphane; Gaetano, Raffaele, 2019, 'La Réunion - Carte d'occupation du sol 2018 (Spot6/7) - 1.5m'",
                            a("(source)", 
                                href = "https://geode.cirad.fr/geonetwork/srv/fre/catalog.search#/metadata/4181a26f-1a3d-42f4-a72c-da7eaff285ee", 
                                target = "_blank"
                            )
                        ),
                        div(
                            style = "text-align: center;",
                            downloadButton("download_tab_OCS", "Télécharger le tableau")
                        ),
                        withSpinner(dataTableOutput(outputId = "tab_OCS"))
                ),

                tabItem(tabName = "VizDataPLU",
                        h1("Zones d'urbanisation et d'activités économiques"),
                        p(
                            "Analyses réalisées avec la base permanente des PLU de La Réunion 2021",
                            a("(source)", 
                                href = "http://peigeo.re:8080/geonetwork/srv/fre/catalog.search#/metadata/d35ec660-e26f-4bcb-add0-83c90997018f", 
                                target = "_blank"
                            )
                        ),
                        fluidRow(
                            box(
                                title = "Carte des localisations",
                                width = 6,
                                withSpinner(plotOutput("map_PLU")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_map_PLU", "Télécharger la carte")
                                ),
                            ),
                            box(
                                title = "Dénombrement des localisations",
                                width = 6,
                                withSpinner(tableOutput("tab_PLU"))
                            )
                        )
                ),

                tabItem(tabName = "VizDataRPG",
                        h1("Types de parcelles agricoles fréquentées"),
                        p(
                            "Analyses réalisées avec les données du Référentiel Parcellaire Graphique (RPG) 2024",
                            a("(source)", 
                                href = "https://geoservices.ign.fr/rpg#telechargementrpg2024", 
                                target = "_blank"
                            )
                        ),
                        fluidRow(
                            box(
                                title = "Carte des localisations",
                                width = 6,
                                withSpinner(plotOutput("map_RPG")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_map_RPG", "Télécharger la carte")
                                ),
                            ),
                            box(
                                title = "Dénombrement des localisations",
                                width = 6,
                                withSpinner(dataTableOutput("tab_RPG"))
                            )
                        )
                )
            )
        )
)