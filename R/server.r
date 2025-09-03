server <- function(input, output) { 

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

    # Preview bdd
    output$previewBDD <- renderDataTable({
        df_gps()

        df_gps <- df_gps() #for dev
        assign("df_gps", df_gps, envir = .GlobalEnv) #for dev

    }, options = list(scrollX = TRUE, pageLength = 8))

    # Analysis with PNR emprise
    output$map_PNR <- renderPlot({

        req(df_gps())
        df_gpsRCT <- df_gps()
        
        gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
        ggplot() +
        geom_sf(data = PNR_shp_coeur, fill = "#32913a", alpha = 0.5) +
        geom_sf(data = PNR_shp_adh, fill = "#15ff00", alpha = 0.5) +
        geom_sf(data = PNR_shp_ouvAdh, fill = "#ffe600", alpha = 0.5) +
        geom_sf(data = gps_sf, color = "#ff0000", size = 1) +
        theme_minimal()

    })

}