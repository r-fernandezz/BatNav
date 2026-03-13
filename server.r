server <- function(input, output, session) { 

    # Import location database
    df_gps <- reactive({

        req(input$BDDFile)
        req(input$dateRange)
        req(input$speedZero)
        req(input$filterWindow)
        req(input$filterMoveMod)
        
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
                                    filterWindow  = input$filterWindow,
                                    resampleSwitch = input$resampleSwitch)

        # If correspondence table is provided merge column "nom_individu"
        if(!is.null(input$correspFile)){
            req(corresp_tab())
            df_filter <- merge(df_filter, corresp_tab(), by = "DeviceID", all.x = TRUE)
            assign("df_merge", df_filter, envir = .GlobalEnv) #for dev
        }

        if(length(input$filterInd) > 0){
            req(input$filterInd)
            df_filter <- df_filter[!df_filter$nom_individu %in% input$filterInd, ]
        }

        # Filter by months for movement model (distribution part)
        df_filter <- df_filter[df_filter$Month %in% input$filterMoveMod, ]

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

    # Download location database
    output$downloadBDD <- downloadHandler(
        filename = function() {
            paste("Database_gps_points_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(df_gps(), file, row.names = FALSE)
        }
    )

    # Add summary table
    summaryTable <- reactive({
        req(df_gps())
        get_tab_summary(df_gpsRCT = df_gps(), distanceAnalysis = input$distanceAnalysis)
    })

    # Preview summary table
    output$summaryTable <- renderDataTable({

        req(summaryTable())
        summaryTable()

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
            write.csv(summaryTable(), file, row.names = FALSE)
        }
    )

    # Plot number of points by day and per individual
    output$plot_nbPt <- renderPlot({

        req(df_gps())
        get_plot_nbPt(df_gps())

    })

    # Plot number point by day with individual graphics
    output$plots_nbPtInd <- renderUI({
        req(df_gps())

        plot_list <- lapply(unique(df_gps()$DeviceID), function(x){
            plotname <- paste0("plot_", x) 
            output[[plotname]] <- renderPlot({
                                    get_plot_nbPt(df_gpsRCT = df_gps(), fixYear = FALSE, deviceID = x)
                                })
            plotOutput(plotname, height = 300, width = "100%")
        })

        do.call(tagList, plot_list)

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
        tab <- get_tab_RPG(df_gps())
        return(tab)

    })

    # Download table RPG
    output$download_tab_RPG <- downloadHandler(
        filename = function() {
            paste("table_RPG_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_tab_RPG(df_gps()), file, row.names = FALSE)
        }
    )

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
        tab <- get_tab_roost(df_roost())
        return(tab)

    }, options = list(
            scrollX = TRUE, pageLength = 8,
            columnDefs = list(list(className = 'dt-center', targets = "_all"))
    ))

    # Download table with roost points
    output$download_tab_roost <- downloadHandler(
        filename = function() {
            paste("table_Roost_points_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_tab_roost(df_roost()), file, row.names = FALSE)
        }
    )

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

    # Database filtered for flight height analysis
    df_flyFilter <- reactive({
        req(df_gps())

        df_flyFilter <- subset(df_gps(),   Hdop <= input$param_hdop & 
                                            Vdop <= input$param_vdop & 
                                            Satellites >= input$param_nbsat & 
                                            Speed >= input$param_speed)

        return(df_flyFilter)

    })

    # Plot altitude Hdop
    output$plot_altiHdop <- renderPlot({
        req(df_flyFilter())
        get_plot_altiDop(df_flyFilter(), dop = "Hdop")
    })

    # Plot altitude Vdop
    output$plot_altiVdop <- renderPlot({
        req(df_flyFilter())
        get_plot_altiDop(df_flyFilter(), dop = "Vdop")
    })

    # Plot number of satellites
    output$plot_nbSat <- renderPlot({
        req(df_flyFilter())
        get_plot_nbSat(df_flyFilter())
    })

    # Plot speed
    output$plot_speed <- renderPlot({
        req(df_flyFilter())
        get_plot_speed(df_flyFilter())
    })

    # Preview database for altitude analysis
    output$preview_tab_flyFilter <- renderDataTable({
        req(df_flyFilter())
        df_flyFilter()
    }, options = list(
            scrollX = TRUE, pageLength = 10,
            columnDefs = list(list(className = 'dt-center', targets = "_all"))
    ))

    # Download database for altitude analysis
    output$download_tab_flyFilter <- downloadHandler(
        filename = function() {
            paste("table_fly_height_filtered_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(df_flyFilter(), file, row.names = FALSE)
        }
    )

    # Flight height analysis
    df_fly <- eventReactive(input$runFlyAltiAnalysis, {
        req(df_flyFilter())
        df_fly <- altiProcess(df_flyFilter())
        assign("df_fly", df_fly, envir = .GlobalEnv) #for dev
        return(df_fly)
    })

    # Plot distribution of flight height
    output$hist_flyHeight <- renderPlot({
        req(df_fly())
        get_hist_flyHeight(df_fly(), inter = input$inter_hist_flyHeight)
    })

    # Download distribution of flight height
    output$download_hist_flyHeight <- downloadHandler(
        filename = function() {
            paste(  "hist_fly_height_", 
                    "inter=", input$inter_hist_flyHeight, "_", 
                    "hdop=", input$param_hdop, "_", 
                    "vdop=", input$param_vdop, "_", 
                    "nbsat=", input$param_nbsat, "_", 
                    "speed=", input$param_speed, "_", 
                    Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            png(file, width = 2000, height = 600, res = 150)
            print(get_hist_flyHeight(df_fly(), inter = input$inter_hist_flyHeight))
            dev.off()
        }
    )

    # Get data evaluation for variogram, periodogram and dt.plot
    viz_kEval <- reactive({
        req(df_gps())
        message("Getting data for variogram, periodogram and dt.plot")
        viz_kEval <- get_data_eval(bdd = df_gps(), corresp_tab = corresp_tab())
        return(viz_kEval)
    })

    # Plot SVF, dt.plot and periodogram for each individual
    output$plot_viz_modKer <- renderUI({
        req(viz_kEval())

        message("Plotting variogram, periodogram and dt.plot for each individual")
        lapply(viz_kEval(), function(x){
            
            output[[paste0("plot_svf_", x$DeviceID)]] <- renderPlot({
                ctmm::plot(x$svf, CTMM = NULL, level = input$kernel_lvl1/100, level.UD = 0.95, main = paste0("Individu ", x$DeviceID))
            })

            output[[paste0("plot_periodogram_", x$DeviceID)]] <- renderPlot({
                ctmm::plot(x$prdg, diagnostic = TRUE, main = paste0("Individu ", x$DeviceID))
            })

            output[[paste0("plot_dtPlot_", x$DeviceID)]] <- renderPlot({
                dt.plot(x$bdd.ctmm, main = paste0("Individu ", x$DeviceID))
            })

        })

        plot_list <- lapply(viz_kEval(), function(x) {
            fluidRow(
                column(4, plotOutput(outputId = paste0("plot_svf_", x$DeviceID))),
                column(4, plotOutput(outputId = paste0("plot_periodogram_", x$DeviceID))),
                column(4, plotOutput(outputId = paste0("plot_dtPlot_", x$DeviceID)))
            )
        })

        do.call(tagList, plot_list)
    })

    # Download SVF, dt.plot and periodogram plots
    output$download_viz_modKer <- downloadHandler(
        filename = function() {
            paste("evaluation_data_UDlvl=", input$kernel_lvl1, "_", Sys.Date(), ".pdf", sep = "")
        },
        content = function(file) {
            req(df_gps())
            req(viz_kEval())

            pdf(file, width = 14, height = 8)
            lapply(viz_kEval(), function(x) {
                par(mfrow = c(3, 1))
                ctmm::plot(x$svf, CTMM = NULL, level = input$kernel_lvl1/100, level.UD = 0.95, main = paste0("Individu ", x$DeviceID))
                ctmm::plot(x$prdg, diagnostic = TRUE, main = paste0("Individu ", x$DeviceID))
                dt.plot(x$bdd.ctmm, main = paste0("Individu ", x$DeviceID))
            })
            dev.off()
        }
    )

    # Create individual mouvement models (or import RDS file)
    moveMod <- eventReactive(input$runKDE, {

        if (input$moveMod_source == "create") {

            req(df_gps())
            req(input$moveMod_name)

            message("'moveMod' variable creation")
            dir.create(here::here("output", "kernel_analysis"), recursive = TRUE, showWarnings = FALSE)
            moveMod <- get_moveMod(df_gps(), hdop_error = input$hdop_error, corresp_tab = corresp_tab())
            saveRDS(moveMod, file = here::here("output", "kernel_analysis", input$moveMod_name))

            return(moveMod)

        } else if(input$moveMod_source == "import") {

            req(input$moveMod_file)

            message("Importation of 'moveMod' file from user")
            moveMod <- readRDS(input$moveMod_file$datapath)

            return(moveMod)

        }

    })

    # Navigate to result tab when click on run KDE button (to activate reactive moveMod())
    observeEvent(input$runKDE, {
        updateTabItems(session, "tabs", "resultMoveMod")
    })

    # Plot variogram and kernel density estimation
    output$plot_kMod <- renderUI({

        req(moveMod())

        lapply(moveMod(), function(x){
            
            output[[paste0("plot_SVF_", x$DeviceID)]] <- renderPlot({
                ctmm::plot(x$svf, CTMM = x$models, level = input$kernel_lvl2/100, level.UD = 0.95, main = paste0("Individu ", x$DeviceID))
            })

            output[[paste0("plot_kernel_", x$DeviceID)]] <- renderPlot({
                #ctmm::plot(x$bdd.ctmm, UD = x$UDs, level = 0.5, level.UD = 0.95, main = paste0("Individu n°", x$DeviceID))
                get_kernel_plot(bdd = x$bdd.ctmm, UD = x$UDs, deviceID = x$DeviceID, level.UD = input$kernel_lvl2/100, level.IC = 0.95, osm.lvl = input$zoomOSM1)
            })

        })

        plot_list <- lapply(moveMod(), function(x) {
            fluidRow(
                column(6, plotOutput(outputId = paste0("plot_SVF_", x$DeviceID))),
                column(6, plotOutput(outputId = paste0("plot_kernel_", x$DeviceID)))
            )
        })

        do.call(tagList, plot_list)

    })

    # Download plots of kernel density estimation
    output$download_kMod <- downloadHandler(
        filename = function() {
            paste("kernel_individual_maps_UDlvl=", input$kernel_lvl2, "_", Sys.Date(), ".pdf", sep = "")
        },
        content = function(file) {
            req(moveMod())
            pdf(file, width = 10, height = 8)
            lapply(moveMod(), function(x) {
                plot <- get_kernel_plot(
                            bdd = x$bdd.ctmm, 
                            UD = x$UDs, 
                            deviceID = x$DeviceID, 
                            level.UD = input$kernel_lvl2/100, 
                            level.IC = 0.95,
                            osm.lvl = input$zoomOSM1)
                print(plot)
            })
            dev.off()
        }
    )

    # Download variogram plots
    output$download_svf <- downloadHandler(
        filename = function() {
            paste("variogram_individual_plots_UDlvl=", input$kernel_lvl2, "_", Sys.Date(), ".pdf", sep = "")
        },
        content = function(file) {
            req(moveMod())
            pdf(file, width = 10, height = 8)
            lapply(moveMod(), function(x) {
                ctmm::plot(
                        x$svf, 
                        CTMM = x$models, 
                        level = input$kernel_lvl2/100, 
                        level.UD = 0.95, 
                        main = paste0("Individu n°", x$DeviceID)
                )
            })
            dev.off()
        }
    )

    # Download shapefile kernel density estimation
    output$download_UD <- downloadHandler(
            filename = function() {
                paste0("Kernel", input$kernel_lvl2, "_individual_",  Sys.Date(), ".zip")
            },
            content = function(file){
                req(moveMod())
                message("#### Export individual kernels into zip file")
                dir.create(here::here("temp")) # create temporary folder to create zip

                lapply(moveMod(), function(x){

                    file_name <- paste0("Individual_", x$DeviceID, "_", "kernel", input$kernel_lvl2, "_",  Sys.Date(), ".shp")
                    file_path <- here::here("temp", file_name)

                    # Select UD and IC level
                    ctmm::writeVector(
                        x$UDs, 
                        filename = file_path,
                        overwrite = TRUE
                    )
                })

                zip::zip(zipfile = file, files = list.files(here::here("temp"), pattern = ".*\\.(shp|shx|dbf|prj)$", full.names = TRUE), mode = "cherry-pick")
                unlink(here::here("temp"), recursive = TRUE, force = TRUE) #remove temporary folder
                message(paste0("Individual kernels exported!"))
            }
    )

    # Plot surface of kernel density estimation
    output$surf_kInd <- renderPlot({

        req(moveMod())
        get_surfKer_plot(k_analysis = moveMod(), level.UD = input$kernel_lvl2/100)

    })

    # Plot localisation of kernel density estimation
    output$loc_kInd <- renderPlot({

        req(moveMod())

        get_locKer_plot(k_analysis = moveMod(), level.UD = input$kernel_lvl2/100, osm.lvl = input$zoomOSM2)

    })

    # Download surface
    output$download_surf_kInd <- downloadHandler(
        filename = function() {
            paste("surface_kernels_individuals_UDlvl=", input$kernel_lvl2, "_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            png(file, width = 900, height = 900)
            get_surfKer_plot(k_analysis = moveMod(), level.UD = input$kernel_lvl2/100)
            dev.off()
        }
    )

    # Download localisation kernel individuals
    output$download_loc_kInd <- downloadHandler(
        filename = function() {
            paste("localisation_kernels_individuals_UDlvl=", input$kernel_lvl2, "_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(
                file, 
                plot = get_locKer_plot(k_analysis = moveMod(), level.UD = input$kernel_lvl2/100, osm.lvl = input$zoomOSM2), 
                device = "png", 
                width = 10,
                height = 8)
        }
    )
    
    # Create mean kernel density estimation with individual kernels
    k_mean <- eventReactive(input$runKDEmean, {
        
        # RDS file name
        if(input$moveMod_source == "create") {
            path_name <- here::here("output", "kernel_analysis", input$moveMod_name) 
        } else if(input$moveMod_source == "import") {
            path_name <- input$moveMod_file$datapath
        }

        # Create mean model
        if(file.exists(path_name) == TRUE){

            moveMod <- readRDS(path_name)
            k_mean <- get_kernel_mean(k_analysis = moveMod)

            return(k_mean)

        }else {
            message("Cannot find RDS file into 'output/kernel_analysis'. Add the file or create model with your data.")
        }

        assign("k_mean", k_mean, envir = .GlobalEnv) #for dev

    })

    # Plot mean kernel density estimation
    output$plot_kMean <- renderPlot({

        req(k_mean())
        message("Plot mean kernel density estimation")
        get_kernel_plot(
            bdd = NULL, 
            UD = k_mean(), 
            deviceID = NULL, 
            level.UD = input$kernel_lvl2/100, 
            level.IC = 0.95, 
            osm.lvl = input$zoomOSM3
        )

    })

    # Download mean kernel density estimation
    output$download_kMean_map <- downloadHandler(
        filename = function() {
            paste("kernel_mean_map_UDlvl=", input$kernel_lvl2, "_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            req(k_mean())
            ggsave(
                file, 
                plot = get_kernel_plot(
                            bdd = NULL, 
                            UD = k_mean(), 
                            deviceID = NULL, 
                            level.UD = input$kernel_lvl2/100, 
                            level.IC = 0.95, 
                            osm.lvl = input$zoomOSM3
                ), 
                device = "png", 
                width = 10,
                height = 8)
        }
    )

    # Download mean kernel density estimation shapefile
    output$download_UDMean <- downloadHandler(
        filename = function() {
            paste0("Kernel", input$kernel_lvl2, "_mean_",  Sys.Date(), ".zip")
        },
        content = function(file){
            req(k_mean())
            message("#### Export individual kernels mean into zip file")
            dir.create(here::here("temp")) # create temporary folder to create zip

            file_name <- paste0("Kernel", input$kernel_lvl2, "_mean_",  Sys.Date(), ".shp")
            file_path <- here::here("temp", file_name)

            # Select UD and IC level
            ctmm::writeVector(
                k_mean(), 
                filename = file_path,
                overwrite = TRUE
            )

            zip::zip(zipfile = file, files = list.files(here::here("temp"), pattern = ".*\\.(shp|shx|dbf|prj)$", full.names = TRUE), mode = "cherry-pick")
            unlink(here::here("temp"), recursive = TRUE, force = TRUE) #remove temporary folder
            message(paste0("Mean kernel exported!"))
        }
    )

    # Create movement animation frames
    frames <- eventReactive(input$generate_frames, {
        req(df_gps())
        req(input$title_anim)
        req(input$subtitle_anim)

        message("Creating movement animation frames")
        frames <- trip_animation(
                        BDD_track = df_gps(), 
                        corresp_tab = input$correspFile, 
                        title_anim = input$title_anim, 
                        map_res = input$res_background_anim,
                        interpol_anim = input$interpol_anim,
                        subtitle_anim = input$subtitle_anim,
                        n_cores = input$nb_cores_anim
                    )
        return(frames)
    })

    output$animation_preview <- renderPlot({
        req(frames())
        message("Displaying first frame of the animation")
        print(frames()[[1]])
    })

    # Download animation with static map
    output$download_anim <- downloadHandler(
        filename = function() {
            paste("trip_animation_", gsub(" ", "_", input$title_anim), "_", Sys.Date(), ".gif", sep = "")
        },
        content = function(file) {
            req(frames())

            message("Creating temporary file for animation")
            temp_folder <- here::here("tempfolder")
            temp_file <- file.path(temp_folder, "animation.gif") # Ensure the temporary file has the correct extension

            message("Creating animation...")
            moveVis::animate_frames(
                frames(), 
                out_file = temp_file, 
                fps = input$fps_anim, 
                display = FALSE
            )

            message("Saving animation in your folder")
            file.copy(temp_file, file, overwrite = TRUE) # Copy the temporary file to the final destination
            unlink(here::here("tempfolder"), recursive = TRUE) # Clean up the temporary folder
            message("Animation created and downloaded successfully!")
        }
    )

}