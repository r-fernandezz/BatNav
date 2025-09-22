server <- function(input, output) { 

    # Import location database
    df_gps <- reactive({

        req(input$BDDFile)
        req(input$dateRange)
        req(input$speedZero)
        req(input$filterWindow)
        
        df_ls <- lapply(input$BDDFile$datapath, read.csv, header = TRUE)
        df_ls <- lapply(df_ls, subset, select = c(  "name", "DeviceID", "Year", 
                                                    "Month", "Day", "Hour", "Minute", "Second", 
                                                    "CPUtemperature.C.", "Pressure.mbar.", "Temperaturesensor.C.", 
                                                    "AccelerationX", "AccelerationY", "AccelerationZ",
                                                    "GyroX", "GyroY", "GyroZ",
                                                    "MagnetoX", "MagnetoY", "MagnetoZ",
                                                    "Latitude", "Longitude", "Satellites", 
                                                    "Speed", "Altitude", "Batteryvoltage", 
                                                    "Hdop", "Vdop", "Searchingtime",
                                                    "Latitudedecimal", "Longitudedecimal", "Solarvoltage",
                                                    "Csvlinetype", "Timestamp", "file",
                                                    "Night", "fNight", "ts",
                                                    "failed", "DataSource", "NewDataSource",
                                                    "NewDevice", "Index"))
        df_merge <- do.call(rbind, df_ls)
        #assign("df_merge", df_merge, envir = .GlobalEnv) #for dev
        #assign("dateRange", input$dateRange, envir = .GlobalEnv) #for dev
        #assign("speedZero", input$speedZero, envir = .GlobalEnv) #for dev
        df_filter <- filterGPSdata( df = df_merge, 
                                    DataMin = input$dateRange[1], 
                                    DataMax = input$dateRange[2],
                                    speedZero = input$speedZero,
                                    filterWindow  = input$filterWindow)

        # If correspondence table is provided merge column "nom_individu"
        if(!is.null(input$correspFile)){
            req(corresp_tab())
            df_filter <- merge(df_filter, corresp_tab(), by = "DeviceID", all.x = TRUE)
            assign("df_merge", df_filter, envir = .GlobalEnv) #for dev
        }

        if(length(input$filterInd) > 0){
            req(input$filterInd)
            df_filter <- df_filter[df_filter$nom_individu %in% input$filterInd, ]
        }

        return(df_filter)

    })

    # Correspondance table
    corresp_tab <- reactive({

        req(input$correspFile)
        df_corresp <- read.csv(input$correspFile$datapath, header = TRUE)
        assign("df_corresp", df_corresp, envir = .GlobalEnv) #for dev

        return(df_corresp)

    })

    # Update choice of individuals in selectizeInput
    observeEvent(corresp_tab(), {
        req(corresp_tab())
        updateSelectizeInput(
            inputId = "filterInd",
            choices = as.list(setNames(corresp_tab()$nom_individu, corresp_tab()$nom_individu)),
            server = TRUE
        )
    })

    # Preview location map
    output$mapInteractive <- renderLeaflet({

        req(df_gps())

        map <- leaflet(data = df_gps()) %>%
            addTiles() %>%
            fitBounds(lng1 = ~min(Longitudedecimal), lat1 = ~min(Latitudedecimal), lng2 = ~max(Longitudedecimal), lat2 = ~max(Latitudedecimal), options = list())
            
        if("nom_individu" %in% colnames(df_gps())){
            map <- map %>% addCircleMarkers(
                            lng = ~Longitudedecimal,
                            lat = ~Latitudedecimal,
                            popup = ~paste(
                                "<b>Nom de l'individu :</b>", nom_individu, "<br>",
                                "<b>Date :</b>", paste(Day, Month, Year, sep = "/"), "<br>",
                                "<b>Heure :</b>", paste(Hour, Minute, Second, sep = ":"), "<br>",
                                "<b>Vitesse :</b>", Speed, "km/h<br>"
                            ),
                            radius = 1,
                            color = "red",
                            fillOpacity = 0.8
                        )
        }

        if(!"nom_individu" %in% colnames(df_gps())){
            map <- map %>% addCircleMarkers(
                            lng = ~Longitudedecimal,
                            lat = ~Latitudedecimal,
                            popup = ~paste(
                                "<b>Numéro de GPS (DeviceID) :</b>", DeviceID, "<br>",
                                "<b>Date :</b>", paste(Day, Month, Year, sep = "/"), "<br>",
                                "<b>Heure :</b>", paste(Hour, Minute, Second, sep = ":"), "<br>",
                                "<b>Vitesse :</b>", Speed, "km/h<br>"
                            ),
                            radius = 1,
                            color = "red",
                            fillOpacity = 0.8
                        )
        }
        
        return(map)

    })

    # Preview location database
    output$previewBDD <- renderDataTable({
        df_gps()

        df_gps <- df_gps() #for dev
        assign("df_gps", df_gps, envir = .GlobalEnv) #for dev

    },  options = list(
            scrollX = TRUE, pageLength = 8,
            columnDefs = list(list(className = 'dt-center', targets = "_all"))
    ))

    # Add summary table
    output$summaryTable <- renderDataTable({

        req(df_gps())

        get_tab_summary(df_gpsRCT = df_gps())

    },  options = list(
            scrollX = TRUE, pageLength = 20,
            columnDefs = list(list(className = 'dt-center', targets = "_all"))
    ))

    #Download summary table
    output$download_tab_summary <- downloadHandler(
        filename = function() {
            paste("summary_table_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_tab_summary(df_gps()), file, row.names = FALSE)
        }
    )

    # Plot number of points by day and per individual
    output$plot_nbPt <- renderPlot({

        req(df_gps())
        get_plot_nbPt(df_gps())

    })

    # Download plot number of points by day and per individual
    output$download_plot_nbPt <- downloadHandler(
        filename = function() {
            paste("plot_nbPt_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_plot_nbPt(df_gps()), device = "png", width = 10, height = 8)
        }
    )

    # Plot histogram of number of points by year and per individual
    output$hist_nbPtYears <- renderPlot({

        req(df_gps())
        get_hist_nbPtYears(df_gps())

    })

    # Download histogram of number of points by year and per individual
    output$download_hist_nbPtYears <- downloadHandler(
        filename = function() {
            paste("hist_nbPtYears_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_hist_nbPtYears(df_gps()), device = "png", width = 10, height = 8)
        }
    )

    # Analysis with PNR emprise
    output$map_PNR <- renderPlot({

        req(df_gps())
        df_gpsRCT <- df_gps()

        get_map_PNR(df_gpsRCT, PNR_shp)

    })

    # Export map PNR emprise
    output$download_PNR <- downloadHandler(
        filename = function() {
            paste("map_PNR_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_map_PNR(df_gps(), PNR_shp), device = "png", width = 10, height = 8)
        }
    )

    # Table with PNR areas
    output$tab_PNR <- renderTable({

        req(df_gps())
        get_tab_PNR(df_gps(), PNR_shp)

    }, align = "c")

    # Table with OCS areas
    output$tab_OCS <- renderDataTable({

        req(df_gps())
        get_tab_OCS(df_gps(), ocs_shp)

    }, options = list(
        columnDefs = list(list(className = 'dt-center', targets = "_all"))
        ))

    # Export table OSC
    output$download_tab_OCS <- downloadHandler(
        filename = function() {
            paste("table_OCS_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_tab_OCS(df_gps(), ocs_shp), file, row.names = FALSE)
        }
    )

    # Diagramme circulaire OCS
    output$diagCirc_OCS <- renderPlot({
        req(df_gps())
        get_diagCirc_OCS(df_gps(), ocs_shp)
    })

    # Download diagramme circulaire OCS
    output$download_diagCirc_OCS <- downloadHandler(
        filename = function() {
            paste("diagCirc_OCS_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_diagCirc_OCS(df_gps(), ocs_shp), device = "png", width = 10, height = 8, limitsize = FALSE)
        }
    )

    # Map with PLU areas
    output$map_PLU <- renderPlot({

        req(df_gps())
        get_map_PLU(df_gps(), plu_shp)

    })

    # Download map PLU
    output$download_map_PLU <- downloadHandler(
        filename = function() {
            paste("map_PLU_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_map_PLU(df_gps(), plu_shp), device = "png", width = 10, height = 8)
        }
    )

    # Table with PLU areas
    output$tab_PLU <- renderTable({

        req(df_gps())
        df <- pt_within_poly(df_gps(), plu_shp, arg_shp = "typezone")
        if(any(df$type == "A")) df[df$type == "A", ]$type <- "Agricole"
        if(any(df$type == "AU")) df[df$type == "AU", ]$type <- "Urbanisable"
        if(any(df$type == "N")) df[df$type == "N", ]$type <- "Naturelle"
        if(any(df$type == "U")) df[df$type == "U", ]$type <- "Urbanisée"

        nb_pt_ext <- nrow(df_gps()) - sum(df$nb_point)
        pr_pt_ext <- round(nb_pt_ext / nrow(df_gps()) * 100, 2)
        df <- rbind(df, data.frame(type = "Hors PLU", nb_point = nb_pt_ext, proportion = pr_pt_ext))
        colnames(df) <- c("Zonage des PLU", "Nombre de points", "Proportion")
        return(df)

    }, align = "c")

    # Diagramme circulaire PLU
    output$diagCirc_PLU <- renderPlot({
        req(df_gps())
        get_diagCirc_PLU(df_gps(), plu_shp)
    })

    #Download diagramme circulaire PLU
    output$download_diagCirc_PLU <- downloadHandler(
        filename = function() {
            paste("diagCirc_PLU_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_diagCirc_PLU(df_gps(), plu_shp), device = "png", width = 10, height = 8)
        }
    )

    # Map with RPG areas
    output$map_RPG <- renderPlot({

        req(df_gps())
        get_map_RPG(df_gps(), rpg_shp)

    })

    # Download map RPG
    output$download_map_RPG <- downloadHandler(
        filename = function() {
            paste("map_RPG_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_map_RPG(df_gps(), rpg_shp), device = "png", width = 10, height = 8)
        }
    )

    # Table with RPG areas
    output$tab_RPG <- renderDataTable({

        req(df_gps())

        df <- pt_within_poly(df_gps(), rpg_shp, arg_shp = "CODE_CULTU")
        df_merged <- merge(df, rpgRef_tab, by.x = "type", by.y = "CODE", all.x = TRUE)
        df_order <- df_merged[, c("LIBELLE_CULTURE","nb_point", "proportion")]
        
        nb_pt_ext <- nrow(df_gps()) - sum(df_order$nb_point)
        df_order <- rbind(df_order, data.frame(LIBELLE_CULTURE = "Hors RPG", nb_point = nb_pt_ext, proportion = round(nb_pt_ext / nrow(df_gps()) * 100, 2)))
        colnames(df_order) <- c("Types de parcelles", "Nombre de points", "Proportion")
        
        return(df_order)

    })

    # Map with light pollution
    output$map_pollu <- renderPlot({

        req(df_gps())
        get_map_Pollu(df_gps(), pollu_rast)

    })

    # Download map light pollution
    output$download_map_pollu <- downloadHandler(
        filename = function() {
            paste("map_Pollution_lumineuse_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_map_Pollu(df_gps(), pollu_rast), device = "png", width = 10, height = 8)
        }
    )

    #Histogram of pollution levels
    output$hist_pollu <- renderPlot({

        req(df_gps())
        get_hist_pollu(df_gps(), pollu_rast)

    })

    #Download histogram light pollution
    output$download_hist_pollu <- downloadHandler(
        filename = function() {
            paste("hist_Pollution_lumineuse_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_hist_pollu(df_gps(), pollu_rast), device = "png", width = 10, height = 8)
        }
    )

    # Table with vegetation types ONF
    output$tab_vegeONF <- renderDataTable({

        req(df_gps())
        get_tab_vegeONF(df_gps())

    }, options = list(
        columnDefs = list(list(className = 'dt-center', targets = "_all"))
        ))

    # Download table vegetation ONF
    output$download_tab_vegeONF <- downloadHandler(
        filename = function() {
            paste("table_Vegetation_ONF_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_tab_vegeONF(df_gps()), file, row.names = FALSE)
        }
    )

    # Histogram of vegetation origin ONF
    output$hist_vegeONForg <- renderPlot({
        req(df_gps())
        get_hist_vegeONForg(df_gps())
    })

    # Download histogram of vegetation origin ONF
    output$download_hist_vegeONForg <- downloadHandler(
        filename = function() {
            paste("hist_Origin_Vegetation_ONF_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_hist_vegeONForg(df_gps()), device = "png", width = 10, height = 8)
        }
    )

    # Diagramme circulaire vegetation ONF
    output$diagCirc_vegeONF <- renderPlot({
        req(df_gps())
        get_diagCirc_vegeONF(df_gps())
    })

    #Download diagramme circulaire vegetation ONF
    output$download_diagCirc_vegeONF <- downloadHandler(
        filename = function() {
            paste("diagCirc_Vegetation_ONF_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_diagCirc_vegeONF(df_gps()), device = "png", width = 10, height = 8, limitsize = FALSE)
        }
    )

    # Create dataframe with LidarHD values
    df_lidar_MNT <- eventReactive(input$runMNT_analysis, {
        req(df_gps())
        df_mnt <- value_lidarHD(df_gps(), lidarMNT) #with column altitude, slope, aspect
        assign("df_lidar_MNT", df_mnt, envir = .GlobalEnv) #for dev
        return(df_mnt)
    })

    # Download dataframe with LidarHD values
    output$download_df_lidar_MNT <- downloadHandler(
        filename = function() {
            paste("table_LidarHD_MNT_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(df_lidar_MNT(), file, row.names = FALSE)
        }
    )

    # Create histogram of altitude values
    output$hist_altitude <- renderPlot({
        req(df_lidar_MNT())
        get_hist_altitude(df_lidar_MNT())
    })

    # Download histogram of altitude values
    output$download_hist_altitude <- downloadHandler(
        filename = function() {
            paste("hist_Altitude_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_hist_altitude(df_lidar_MNT()), device = "png", width = 10, height = 8)
        }
    )

    # Create histogram of aspect values
    output$hist_aspect <- renderPlot({
        req(df_lidar_MNT())
        get_Pohist_aspect(df_lidar_MNT())
    })

    # Download histogram of aspect values
    output$download_hist_aspect <- downloadHandler(
        filename = function() {
            paste("hist_Orientation_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_Pohist_aspect(df_lidar_MNT()), device = "png", width = 10, height = 8)
        }
    )

    # Create histogram of slope values
    output$hist_slope <- renderPlot({
        req(df_lidar_MNT())
        get_hist_slope(df_lidar_MNT())
    })

    # Download histogram of slope values
    output$download_hist_slope <- downloadHandler(  
        filename = function() {
            paste("hist_Inclinaison_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = get_hist_slope(df_lidar_MNT()), device = "png", width = 10, height = 8)
        }
    )

    # Roost analysis
    df_roost <- eventReactive(input$runRoostAnalysis, {
        req(df_gps())
        df_roost <- found_roost(df_gpsRCT = df_gps(), distance_size = input$distanceRoost)
        assign("df_roost", df_roost, envir = .GlobalEnv) #for dev

        return(df_roost)
    })

    # Table roost preview 
    output$preview_tab_roost <- renderDataTable({
        req(df_roost())
        df_roostRCT <- df_roost()

        # Shape dataframe for preview
        col <- c("DeviceID", "nom_individu", "full_date", "LatitudeDecimal", "LongitudeDecimal", "roost_distance")
        df_roostRCT <- as.data.frame(df_roostRCT)
        df_roostRCT <- df_roostRCT[, colnames(df_roostRCT) %in% col]
        df_roostRCT$full_date <- as.character(df_roostRCT$full_date)

        if("nom_individu" %in% colnames(df_roostRCT)){
            colnames(df_roostRCT) <- c( "Numéro de la balise", 
                                        "Nom de l'individu", 
                                        "Date d'arrivée sur le reposoir",
                                        "Distance entre le premier et le dernier point de la nuit (m)",
                                        "Latitude", 
                                        "Longitude" 
                                    )
        } else if (!"nom_individu" %in% colnames(df_roostRCT)) {
            colnames(df_roostRCT) <- c( "Numéro de la balise",
                                        "Date d'arrivée sur le reposoir",
                                        "Distance entre le premier et le dernier point de la nuit (m)",
                                        "Latitude", 
                                        "Longitude" 
                                    )
        }

        return(df_roostRCT)

    }, options = list(
            scrollX = TRUE, pageLength = 8,
            columnDefs = list(list(className = 'dt-center', targets = "_all"))
    ))

    # Create map with roost points
    output$map_roost <- renderLeaflet({

        req(df_roost())
        df_roost <- df_roost()

        # Add color by individual
        color_ind <- setNames(c(
                                "#FF0000", "#FF9900", "#FFCC00", "#00FF00", "#6699FF", "#CC33FF", "#99991E",
                                "#999999", "#FF00CC", "#CC0000", "#FFCCCC", "#FFFF00", "#CCFF00", "#358000",
                                "#0000CC", "#99CCFF", "#00FFFF", "#CCFFFF", "#9900CC", "#CC99FF", "#996600",
                                "#666600", "#666666", "#CCCCCC", "#79CC3D", "#CCCC99"
                            ),
                            unique(df_roost$DeviceID))

        color_ind <- data.frame(DeviceID = names(color_ind), color_ind = as.character(color_ind))
        color_ind <- na.omit(color_ind)
        
        df_roost <- merge(df_roost, color_ind, by = "DeviceID", all.x = TRUE)

        map_roost <-    leaflet(data = df_roost) %>%
                        addTiles() %>%
                        fitBounds(lng1 = ~min(LongitudeDecimal), lat1 = ~min(LatitudeDecimal), lng2 = ~max(LongitudeDecimal), lat2 = ~max(LatitudeDecimal), options = list())


        if("nom_individu" %in% colnames(df_gps())){
            map <- map_roost %>% addCircleMarkers(
                                            lng = ~as.numeric(LongitudeDecimal),
                                            lat = ~as.numeric(LatitudeDecimal),
                                            popup = ~paste(
                                                "<b>Nom de l'individu :</b>", nom_individu, "<br>",
                                                "<b>Date de l'arrivé sur le reposoir :</b>", full_date, "<br>",
                                                "<b>Distance entre le premier et dernier point (m) :</b>", roost_distance, "<br>",
                                                "<b>Longitude :</b>", LongitudeDecimal, "<br>",
                                                "<b>Latitude :</b>", LatitudeDecimal, "<br>"
                                            ),
                                            radius = 5,
                                            color = ~color_ind,
                                            fillOpacity = 0.8
                                        )
        }

        if(!"nom_individu" %in% colnames(df_gps())){
            map <- map_roost %>% addCircleMarkers(
                                            lng = ~as.numeric(LongitudeDecimal),
                                            lat = ~as.numeric(LatitudeDecimal),
                                            popup = ~paste(
                                                "<b>Numéro de la balise :</b>", DeviceID, "<br>",
                                                "<b>Date de l'arrivé sur le reposoir :</b>", full_date, "<br>",
                                                "<b>Distance entre le premier et dernier point (m) :</b>", roost_distance, "<br>",
                                                "<b>Longitude :</b>", LongitudeDecimal, "<br>",
                                                "<b>Latitude :</b>", LatitudeDecimal, "<br>"
                                            ),
                                            radius = 5,
                                            color = ~color_ind,
                                            fillOpacity = 0.8
                                        )
        }

        return(map)

    })


}