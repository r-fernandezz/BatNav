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

        return(df_filter)

    })

    # Preview location database
    output$previewBDD <- renderDataTable({
        df_gps()

        df_gps <- df_gps() #for dev
        assign("df_gps", df_gps, envir = .GlobalEnv) #for dev

    }, options = list(
        scrollX = TRUE, pageLength = 8,
        columnDefs = list(list(className = 'dt-center', targets = "_all"))
        ))

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
        get_PNR_table(df_gps(), PNR_shp)

    }, align = "c")

    # Table with OCS areas
    output$tab_OCS <- renderDataTable({

        req(df_gps())
        df <- pt_within_poly(df_gps(), ocs_shp, arg_shp = "Niveau3")

        nb_pt_ext <- nrow(df_gps()) - sum(df$nb_point)
        pr_pt_ext <- round(nb_pt_ext / nrow(df_gps()) * 100, 2)
        df <- rbind(df, data.frame(type = "Hors catégories", nb_point = nb_pt_ext, proportion = pr_pt_ext))

        colnames(df) <- c("Occupation du sol", "Nombre de points", "Proportion")
        return(df)

    }, options = list(
        columnDefs = list(list(className = 'dt-center', targets = "_all"))
        ))

    # Export table OSC
    output$download_tab_OCS <- downloadHandler(
        filename = function() {
            paste("table_OCS_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_OCS_table(df_gps(), ocs_shp), file, row.names = FALSE)
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
}