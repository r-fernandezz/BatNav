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

        gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
        ggplot() +
        geom_sf(data = PNR_shp, aes(fill = Type), alpha = 0.5) +
        geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 1) +
        scale_fill_manual(values = c(
                            "Coeur du Parc national" = "#32913a",
                            "Aire d'Adhésion" = "#15ff00",
                            "Aire ouverte à l'Adhésion" = "#ffe600"
                        )) +
        scale_color_manual(values = c("Localisations GPS" =  "#ff0000")) +
        labs(fill = NULL, color = NULL) +
        theme_minimal() +
        theme(
            legend.position = "bottom"
        )

    })

    # Table with PNR areas
    output$tab_PNR <- renderTable({

        req(df_gps())
        df_gpsRCT <- df_gps()

        gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
        gps_sf <- st_transform(gps_sf, st_crs(PNR_shp))
        pt <- st_within(gps_sf, PNR_shp, sparse = FALSE)
        colnames(pt) <- gsub(" ", "_", PNR_shp$Type)
        
        df <- data.frame(
                inside  = colSums(pt == TRUE),
                proportion = (colSums(pt == TRUE)/nrow(df_gpsRCT))*100,
                row.names = gsub("_", " ", colnames(pt))
        )

        df <- df[-3, ] #remove one category
        df["Hors du parc", ] <-  c( as.numeric(nrow(df_gpsRCT) - sum(df$inside)), 
                                    as.numeric(((nrow(df_gpsRCT) - sum(df$inside))/nrow(df_gpsRCT))*100)) # add line outside PNR
        colnames(df) <- c("Nombre de points l'intérieur", "Pourcentage")

        return(df)

    }, rownames = TRUE, align = "c")

    # Table with OCS areas
    output$tab_OCS <- renderDataTable({

        req(df_gps())
        df_gpsRCT <- df_gps()

        gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
        gps_sf <- st_transform(gps_sf, st_crs(ocs_shp))
        pt <- st_within(gps_sf, ocs_shp, sparse = TRUE) #st_within creates an indice for each polygon
        pt_n3 <- sapply(pt, function(x) if(length(x) > 0) ocs_shp$Niveau3[x[1]] else NA) #pt return indice
        tab_n3 <- table(pt_n3)
        df <- data.frame(
                    Type_oso = names(tab_n3),
                    Nb_point = as.numeric(tab_n3),
                    proportion = round((as.numeric(tab_n3)/nrow(df_gpsRCT))*100, digit = 2)
                    )
        
        colnames(df) <- c("Types de végétation", "Nombre de points", "Proportion")

        return(df)

    })
}