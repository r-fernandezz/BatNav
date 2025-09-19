ui <-  dashboardPage(

        dashboardHeader(
            title = tags$a(
                href = "https://github.com/r-fernandezz/BatNav",
                target = "_blank",
                style = "color: #fff;",
                tags$img(
                    src = "logo-BatNav_officiel_white.png",
                    style = "height: 40px; margin-right: 10px;"
                ),
                "BatNav"
            )
        ),

        dashboardSidebar(
            sidebarMenu(
                menuItem("Accueil", 
                         tabName = "home", 
                         icon = icon("home", lib = "glyphicon")
                ),

                menuItem(   "Paramétrage des données GPS", 
                            tabName = "readData", 
                            icon = icon("map-marker", lib = "glyphicon")
                ),

                menuItem(   "Exploration des données", 
                            tabName = "exploreData", 
                            icon = icon("zoom-in", lib = "glyphicon")
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
                    ),

                    menuSubItem("Pollution lumineuse",
                                tabName = "VizDataPollu",
                                icon = icon("eye-open", lib = "glyphicon")
                    ),

                    menuSubItem("Typologie de végétation",
                                tabName = "VizDataVegeONF",
                                icon = icon("eye-open", lib = "glyphicon")
                    ),

                    menuSubItem("Modèle num. de terrain (MNT)",
                                tabName = "VizDataMNT",
                                icon = icon("eye-open", lib = "glyphicon")
                    )
                ),

                menuItem(   "Reposoirs diurnes probables",
                            tabName = "roostPrediction", 
                            icon = icon("tent", lib = "glyphicon")
                ),

                menuItem("Hauteur de vol", icon = icon("stats", lib = "glyphicon")

                ),

                menuItem("Distribution spatio-temporelle", icon = icon("screenshot", lib = "glyphicon")

                ),

                div(
                    "Romain Fernandez - BatNav v1.0.0 (2025)",
                    br(),
                    a(  "Code on Github",
                        href = "https://github.com/r-fernandezz/BatNav",
                        target = "_blank",
                        style = "color: #9C9A9A;"
                    ),
                    tags$img(
                                src = "logo-GCOI_grey.png",
                                style = "display: block; margin-left: auto; margin-right: auto; max-width: 100px; margin-top: 3px;"
                            ),
                    style = "position: absolute; bottom: 5px; color: #9C9A9A; font-size: 10px; text-align: center; width: 220px;"
                )
            )
        ),

        dashboardBody(
            tags$head( #personalised CSS
                tags$style(HTML("
                    /* For centering all tables */
                    .shiny-table {
                        margin-left: auto !important;
                        margin-right: auto !important;
                    }

                    /* Header color */
                    .skin-blue .main-header .navbar {
                    background-color: #A72800;  !important;
                    }

                    .skin-blue .main-header .logo {
                    background-color: #A72800;  !important;
                    color: #fff;  !important;
                    }

                    /* Flyover color */
                    .logo:hover, 
                    .skin-blue .main-header .sidebar-toggle:hover {
                    background-color: #ABC649 !important; /* couleur au survol */
                    color: #fff !important;
                    }

                    /* Sidebar color */
                    .skin-blue .main-sidebar {
                    background-color: #000043;  !important;
                    }

                    /* Flyover sidebar color */
                    .skin-blue .main-sidebar .sidebar a:hover {
                        background-color: #ABC649 !important;
                        color: #fff !important;
                    }

                    /* Submenu sidebar background color */
                    .skin-blue .main-sidebar .sidebar .treeview-menu {
                        background-color: #1C382D !important; /* Mets ici la couleur que tu veux */
                    }

                    /* Sidebar text color */
                    .skin-blue .sidebar a {
                    color: #fff;  !important;
                    }

                    /* Body background color */
                    .content-wrapper, .right-side {
                    background-color: #f4f6f7;
                    }

                    /* Box color */
                    .box {
                    border-top: 3px solid #A72800;
                    }

                    /* Button color */
                    .btn {
                    background-color: #A72800;
                    color: #fff;
                    border: none;
                    }

                    .btn:hover {
                    background-color: #F1B370;
                    color: #fff;
                    }
                "))
            ),

            tabItems(
                tabItem(tabName = "home",
                    tags$img(
                        src = "logo-GCOI.png",
                        style = "display: block; margin-left: auto; margin-right: 5px; max-width: 100px; margin-top: 5px;"
                    ),
                    h1("Bienvenue dans BatNav !", align = "center", style = "font-weight: bold; front-size= 30px;"),
                    fluidRow(
                        tags$img(
                                src = "logo-BatNav_officiel.png",
                                style = "display: block; margin-left: auto; margin-right: auto; max-width: 550px; margin-top: 50px;"
                            )
                    ),
                    p("🚀 BatNav est une application R Shiny développée par le GCOI pour faciliter la mise à jour des résultats de l'analyse des données de localisation GPS des Roussettes noires de l'île de La Réunion.",
                        style = "text-align: justify; margin-left: 15px; margin-right: 15px;"
                    ),
                    div(
                        style = "text-align: justify; margin-left: 15px; margin-right: 15px;",
                            p("L'application permet..", style = "font-weight: bold;"),
                            tags$ul(
                                style = "list-style-type: none; padding-left: 0;",
                                tags$li("✅ Importer, filtrer et prévisualiser des données GPS."),
                                tags$li("✅ Croiser les données GPS avec plusieurs couches SIG."),
                                tags$li("✅ Analyser la hauteur de vol des individus."),
                                tags$li("✅ Analyser la distribution spatio-temporelle des individus."),
                                tags$li("✅ Visualiser les résultats et les exporter si besoin.")
                            )
                    ),
                    br(),
                    div(
                            style = "text-align: justify; margin-left: 15px; margin-right: 15px;",
                            p("Pour commencer...", style = "font-weight: bold;"),
                            tags$ul(
                                style = "list-style-type: none; padding-left: 0;",
                                tags$li("1️⃣ Rendez-vous dans l'onglet 'Paramétrage des données GPS' pour importer vos données et configurer les paramètres de votre analyse."),
                                tags$li("2️⃣ Lancer si besoin les analyses et visualiser vos résultats en vous déplaçant dans les différents onglets disponibles.")
                            )
                        )
                ),

                tabItem(tabName = "readData", 
                    h1("Importer les données GPS pour votre analyse"),

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
                            choices = c("Conserver les points avec une vitesse de 0 km/h" = "0km/h",
                                        "Conserver les points avec une vitesse > 0 km/h" = ">0km/h",
                                        "Conserver tous les points" = "all")
                        ),

                    h2("Filtrage des points par une emprise spatiale"),
                    radioButtons(   inputId = "filterWindow",
                                    label = NULL,
                                    choices = c("Filtre Sud-Ouest Ocean Indien : Supprimer les points hors de la fenêtre 10°S–30°S, 40°E–65°E" = "SudOIFilter",
                                                "Filtre La Réunion : Supprimer les points hors de la fenêtre 21.4°S–20.8°S, 55.2°E–55.9°E" = "ReunionFilter",
                                                "Pas de filtre spatial" = "NoFilter"
                                                )
                    ),

                    h2("Filtrage par individu"),
                    p("Ajouter un tableau CSV avec deux colonnes 'DeviceID' et 'nom_individu' (sans accents !) pour faire la correspondance entre l'identifiant du GPS et le nom de l'individu."),
                    fileInput(  inputId = "correspFile", 
                                label = NULL,
                                multiple = FALSE,
                                buttonLabel = "Choisir le fichier", 
                                placeholder = "Aucun fichier"
                    ),
                    selectizeInput( inputId = "filterInd",
                                    label = "Sectionner les individus",
                                    multiple = TRUE,
                                    choices = NULL,
                    ),

                    h2("Vérification des données importées"),
                    withSpinner(dataTableOutput(outputId = "previewBDD")),

                    h2("Visualisation des données importées"),
                    leaflet::leafletOutput("mapInteractive", height = 600),

                ),

                tabItem(tabName = "exploreData",
                        h1("Explorer les données importées"),
                        p(  style = "color: red;", 
                            icon("exclamation-triangle", lib = "font-awesome"),
                            "Si un filtre de vitesse ou spatial est appliqué dans l'onglet paramétrage, les résultats sur cette page seront affectés."
                            ),
                        br(),

                        h3("Résumé des données importées et filtrées"),
                        p(  style = "color: red;", 
                            icon("exclamation-triangle", lib = "font-awesome"),
                            "La colonne proportion théorique est calculée sur une base de 1 point toutes les 15 minutes entre 18h et 6h."
                            ),
                        br(),
                        div(
                            style = "text-align: center;",
                            downloadButton("download_tab_summary", "Télécharger le tableau")
                        ),
                        withSpinner(dataTableOutput("summaryTable")),
                        br(),

                        fluidRow(
                            box(
                                title = "Nombre de points par individu et par jour",
                                width = 6,
                                withSpinner(plotOutput("plot_nbPt")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_plot_nbPt", "Télécharger le graphique")
                                )
                            ),
                            box(
                                title = "Nombre de points par année et individu",
                                width = 6,
                                withSpinner(plotOutput("hist_nbPtYears")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_hist_nbPtYears", "Télécharger le graphique")
                                )
                            )
                        )
                        
                ),

                tabItem(tabName = "VizDataPNR",
                        h1("Emprise sur le Parc National de La Réunion"),
                        p(  
                            icon("book", lib = "font-awesome"),
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
                        h1("Classes d'occupation du sol fréquentées par les individus"),
                        p(  
                            icon("book", lib = "font-awesome"),
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
                        withSpinner(dataTableOutput(outputId = "tab_OCS")),
                        br(),
                        h3("Proportion de localisation par classe d'occupation du sol"),
                        div(
                            style = "text-align: center;",
                            downloadButton("download_diagCirc_OCS", "Télécharger le diagramme")
                        ),
                        br(),
                        withSpinner(plotOutput("diagCirc_OCS"))
                        
                ),

                tabItem(tabName = "VizDataPLU",
                        h1("Les zones du plan local d'urbanisme fréquéntées"),
                        p(  
                            icon("book", lib = "font-awesome"),
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
                            ),
                            br(),
                            box(
                                title = "Proportion de localisation par type de zone",
                                width = 6,
                                withSpinner(plotOutput("diagCirc_PLU")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_diagCirc_PLU", "Télécharger le diagramme")
                                )
                            )
                            
                        )
                ),

                tabItem(tabName = "VizDataRPG",
                        h1("Types de parcelles agricoles fréquentées"),
                        p(  
                            icon("book", lib = "font-awesome"),
                            "Analyses réalisées avec les données du Référentiel Parcellaire Graphique (RPG) 2024",
                            a("(source)", 
                                href = "https://geoservices.ign.fr/rpg#telechargementrpg2024", 
                                target = "_blank"
                            )
                        ),
                        p(  style = "color: red;", 
                            icon("exclamation-triangle", lib = "font-awesome"),
                            "Les données des RPG peuvent varier d'une année sur l'autre."
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
                ),

                tabItem(tabName = "VizDataPollu",
                        h1("Niveau de pollution lumineuse"),
                        p(  
                            icon("book", lib = "font-awesome"),
                            "Analyses réalisées avec les données de modélisation de la pollution lumineuse (coeur de nuit - 00h à 5h00 du matin) du Parc national de la Réunion de 2021",
                            a("(source)", 
                                href = "http://peigeo.re:8080/geonetwork/srv/fre/catalog.search#/metadata/7b3397d6-eeb0-4bcb-b0ac-62607f1e4bd5", 
                                target = "_blank"
                            ),
                            br(),
                            tags$a(
                                "Voir la documentation (PDF page 23)",
                                href = "pollution_lumineuse_methode.pdf",
                                target = "_blank"
                                )
                        ),
                        fluidRow(
                            box(
                                title = "Carte des localisations",
                                width = 6,
                                withSpinner(plotOutput("map_pollu")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_map_pollu", "Télécharger la carte")
                                ),
                            ),
                            box(
                                title = "Dénombrement des localisations",
                                width = 6,
                                withSpinner(plotOutput("hist_pollu")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_hist_pollu", "Télécharger l'histogramme")
                                )
                            )
                        )
                ),

                tabItem(tabName = "VizDataVegeONF",
                    h1("Types de végétation fréquentés"),
                    p(
                        icon("book", lib = "font-awesome"),
                        "Analyses réalisées avec le référentiel typologique de végétation de l'ONF de 2019.",
                        br(),
                        tags$a(
                                "Voir la documentation (PDF)",
                                href = "Metadonnées_typologie_vegetation_ONF.pdf",
                                target = "_blank"
                                )
                    ),
                    div(
                        style = "text-align: center;",
                        downloadButton("download_tab_vegeONF", "Télécharger le tableau")
                    ),
                    withSpinner(dataTableOutput(outputId = "tab_vegeONF")),
                    br(),
                    h3("Proportion de localisation par type de végétation"),
                    div(
                        style = "text-align: center;",
                        downloadButton("download_diagCirc_vegeONF", "Télécharger le diagramme")
                    ),
                    br(),
                    withSpinner(plotOutput("diagCirc_vegeONF")),
                    br(),
                    fluidRow(
                        box(
                            title = "Origine de la végétation fréquentée",
                            width = 6,
                            withSpinner(plotOutput("hist_vegeONForg")),
                            br(),
                            div(
                                style = "text-align: center;",
                                downloadButton("download_hist_vegeONForg", "Télécharger de l'histogramme")
                            )
                        )
                    )
                    ),

                tabItem(tabName = "VizDataMNT",
                        h1("Modèle numérique de terrain (MNT)"),
                        p(  
                            icon("book", lib = "font-awesome"),
                            "Ces analyses sont réalisées avec le levé LidarHD de 2025 de l'institut national de l'information géographique et forestière (IGN-F).",
                            a("(source)", 
                                href = "https://cartes.gouv.fr/catalogue/dataset/IGNF_MNT-LIDAR-HD", 
                                target = "_blank"
                            )),
                        p("Ces données ont été dégradées à une résolution de 3m (produit brut à 0.5m)."),
                        p(  
                            style = "color: red;", 
                            icon("exclamation-triangle", lib = "font-awesome"),
                            "Cette analyse télécharge les dalles MNT dans lesquelles des points sont trouvés à l'intérieur (et les 8 dalles voisines). 
                            Les dalles sont téléchargées une seule fois et stockées sur votre ordinateur. 
                            Cette analyse peut donc être longue si les dalles n'ont jamais été téléchargées auparavant."
                        ),
                        br(),
                        div(
                            style = "text-align: center;",
                            actionButton("runMNT_analysis", "Lancer l'analyse")
                        ),
                        br(),
                        br(),
                        fluidRow(
                            box(
                                title = "Distribution de l'altitude des localisations",
                                width = 6,
                                withSpinner(plotOutput("hist_altitude")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_hist_altitude", "Télécharger l'histogramme")
                                )
                            ),
                            box(
                                title = "Orientation des pentes sous les localisations",
                                width = 6,
                                withSpinner(plotOutput("hist_aspect")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_hist_aspect", "Télécharger l'histogramme")
                                )
                            ),
                            box(
                                title = "Inclinaison des pentes sous les localisations",
                                width = 6,
                                withSpinner(plotOutput("hist_slope")),
                                div(
                                    style = "text-align: center;",
                                    downloadButton("download_hist_slope", "Télécharger l'histogramme")
                                )
                            )
                        ),
                        br(),
                        div(
                            style = "text-align: center;",
                            downloadButton("download_df_lidar_MNT", "Télécharger le tableau avec les valeurs LidarHD")
                        )
                ),

                tabItem(tabName = "roostPrediction",
                        h1("Localisation des reposoirs diurnes probables"),
                        p(" Cette analyse calcule la distance entre le point de fin de nuit (point maximal entre 00h et 6h) et le point de début de nuit (minimal entre 18h et 00h) pour chaque individu et chaque jour. 
                            Si la distance entre ces deux points est inférieure à la distance maximale définie ci-dessous, le point de fin de nuit est considéré comme un reposoir diurne probable."),
                        p(  style = "color: red;", 
                            icon("exclamation-triangle", lib = "font-awesome"),
                            "Pour réaliser cette analyse aucun filtre de vitesse ne doit être appliqué dans l'onglet paramétrage."
                        ),
                        br(),
                        numericInput(  inputId = "distanceRoost",
                                        label = "Distance maximale (en mètres) entre le premier et le dernier point pour considérer le premier point comme un reposoir diurne",
                                        value = 20,
                                        min = 1,
                                        max = 100,
                                        step = 1
                        ),
                        br(),
                        div(
                            style = "text-align: left;",
                            actionButton("runRoostAnalysis", "Lancer l'analyse")
                        ),
                        h3("Visualisation des reposoirs diurnes probables"),
                        withSpinner(leaflet::leafletOutput("map_roost", height = 600)),
                        br(),
                        h3("Tableau des reposoirs diurnes probables"),
                        withSpinner(dataTableOutput("preview_tab_roost")),
                )
            )
        )
)