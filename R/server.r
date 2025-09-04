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

    }, options = list(scrollX = TRUE, pageLength = 8))

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
        df_gpsRCT <- df_gps()

        get_PNR_table(df_gpsRCT, PNR_shp)

    }, rownames = TRUE, align = "c")

    # Table with OCS areas
    output$tab_OCS <- renderDataTable({

        req(df_gps())
        df_gpsRCT <- df_gps()

        get_OCS_table(df_gpsRCT, ocs_shp)

    })

    # Export table OSC
    output$download_OCS <- downloadHandler(
        filename = function() {
            paste("table_OCS_", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(get_OCS_table(df_gps(), ocs_shp), file, row.names = FALSE)
        }
    )
}