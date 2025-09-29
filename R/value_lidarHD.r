#' value_lidarHD
#'
#' @description Export altitude, slope and aspect values from LidarHD raster for GPS points. 
#' Extraction performed by tile. Each main tile has 8 neighboring tiles, which are merged with the main tile to calculate altitude, slope, and aspect.
#'
#'
#' @param df_gpsRCT Dataframe with GPS points
#' @param lidarHD Text file with LidarHD slabs URLs
#'
#' @return Dataframe with altitude, slope and aspect values for each GPS point
#'
#' @export NULL
#' 
#' 

value_lidarHD <- function(df_gpsRCT, lidarHD){

    df_gpsRCT_WGS84 <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs(paste0("EPSG:4326")))

    # Change SCR of GPS points
    df_gpsRCT_2975 <- st_transform(df_gpsRCT_WGS84, "EPSG:2975")
    df_gpsRCT_2975 <- cbind(df_gpsRCT_2975, st_coordinates(df_gpsRCT_2975))

    req_list <- lapply(1:length(lidarHD), function(i){

        # Check bbox of the first slab
        coord <- sub(".*BBOX=(.*)&WIDTH=.*", "\\1", lidarHD[i])
        coord <- stringr::str_split(coord, ",")
        df_coord <- data.frame(
                        Xmin = as.numeric(coord[[1]][1]), 
                        Ymin = as.numeric(coord[[1]][2]), 
                        Xmax = as.numeric(coord[[1]][3]), 
                        Ymax = as.numeric(coord[[1]][4])
                    )

        # Create slab name
        slab_name <- sub(".*&FILENAME=", "\\1", lidarHD[i])

        # Check if there are points in the slab
        df_extract_2975 <- subset(  df_gpsRCT_2975,
                                    X < df_coord$Xmax & X > df_coord$Xmin & Y < df_coord$Ymax & Y > df_coord$Ymin)

        if(nrow(df_extract_2975) > 0){

            if(!file.exists(here::here("data", "LidarHD", slab_name))){

                print("###### Downloading central LidarHD slab... ######")

                # Download the central raster slab
                success <- FALSE
                n_try <- 0

                while(success == FALSE && n_try < 10){
                    try_error <- try(
                                download.file(
                                    lidarHD[i], 
                                    destfile = here::here("data", "LidarHD", slab_name),
                                    mode = "wb"
                                ),
                            silent = TRUE
                            )
                    
                    if(!inherits(try_error, "try-error")) success <- TRUE
                    if(success == FALSE) {
                        n_try <- n_try + 1
                        message(paste("Failed to download, attempt n°", n_try, "out of 10 for", slab_name))
                    }
                    if(n_try == 10) stop("Download of LidarHD slab failed after 10 attempts")
                }

            }

            # Create all neighboring of the slabs : real and unreal (ouside LidarHD grid)
            neigh_N <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_N <- paste0(paste(neigh_N[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_N[3])), "_", as.numeric(neigh_N[4])+1, "_", paste(neigh_N[5:length(neigh_N)], collapse = "_"))

            neigh_S <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_S <- paste0(paste(neigh_S[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_S[3])), "_", as.numeric(neigh_S[4])-1, "_", paste(neigh_S[5:length(neigh_S)], collapse = "_"))
            
            neigh_E <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_E <- paste0(paste(neigh_E[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_E[3])+1), "_", as.numeric(neigh_E[4]), "_", paste(neigh_E[5:length(neigh_E)], collapse = "_"))

            neigh_W <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_W <- paste0(paste(neigh_W[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_W[3])-1), "_", as.numeric(neigh_W[4]), "_", paste(neigh_W[5:length(neigh_W)], collapse = "_"))

            neigh_NE <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_NE <- paste0(paste(neigh_NE[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_NE[3])+1), "_", as.numeric(neigh_NE[4])+1, "_", paste(neigh_NE[5:length(neigh_NE)], collapse = "_"))

            neigh_NW <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_NW <- paste0(paste(neigh_NW[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_NW[3])-1), "_", as.numeric(neigh_NW[4])+1, "_", paste(neigh_NW[5:length(neigh_NW)], collapse = "_"))

            neigh_SE <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]    
            neigh_SE <- paste0(paste(neigh_SE[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_SE[3])+1), "_", as.numeric(neigh_SE[4])-1, "_", paste(neigh_SE[5:length(neigh_SE)], collapse = "_"))

            neigh_SW <- stringr::str_split(sub(".*&FILENAME=", "\\1", lidarHD[i]), "_")[[1]]
            neigh_SW <- paste0(paste(neigh_SW[1:2], collapse = "_"), "_", paste0("0", as.numeric(neigh_SW[3])-1), "_", as.numeric(neigh_SW[4])-1, "_", paste(neigh_SW[5:length(neigh_SW)], collapse = "_"))

            neigh_list <- c(neigh_N, neigh_S, neigh_E, neigh_W, neigh_NE, neigh_NW, neigh_SE, neigh_SW)

            # Remove neighbors unavailable on the website (out of the extent)
            place <- unlist(lapply(neigh_list, function(x){grep(x, sub(".*&FILENAME=", "\\1", lidarHD))}))
            neigh_list <- sub(".*&FILENAME=", "\\1", lidarHD[place])

            lapply(1:length(neigh_list), function(ii){

                if(!file.exists(here::here("data", "LidarHD", neigh_list[ii]))){

                    print(paste("###### Downloading neighboring slabs... ######"))

                    # Download the neighboring raster slabs
                    success <- FALSE
                    n_try <- 0

                    while(success == FALSE && n_try < 10){
                        
                        try_error <- try(
                                    download.file(
                                        lidarHD[grep(neigh_list[ii], sub(".*&FILENAME=", "\\1", lidarHD))],
                                        destfile = here::here("data", "LidarHD", neigh_list[ii]),
                                        mode = "wb"
                                    ),
                                silent = TRUE
                                )

                        if(!inherits(try_error, "try-error")) success <- TRUE
                        if(success == FALSE) {
                            n_try <- n_try + 1
                            message(paste("Failed to download, attempt n°", n_try, "out of 10 for", neigh_list[ii]))
                        }
                        if(n_try == 10) stop("Download of LidarHD slab failed after 10 attempts")
                    }
                }

            })

            print(paste("###### Extract values from the central slab (merging neighboring slab) :", slab_name, "######"))

            # Load raster slab
            rast_lidar <- terra::rast(here::here("data", "LidarHD", slab_name))

            # Test if the central slab is corrupted
            error_slab <- try(mean(terra::values(rast_lidar)), silent = TRUE)

            while(inherits(error_slab, "try-error")){

                n_try <- 0
                success <- FALSE
                print(paste("Error during the merge process, removing and re-downloading the central slab :", slab_name))
                file.remove(here::here("data", "LidarHD", slab_name))

                while(success == FALSE && n_try < 10){

                    try_error <- try(
                                download.file(
                                    lidarHD[grep(slab_name, sub(".*&FILENAME=", "\\1", lidarHD))],
                                    destfile = here::here("data", "LidarHD", slab_name),
                                    mode = "wb"
                                ),
                            silent = TRUE
                            )

                    if(!inherits(try_error, "try-error")) success <- TRUE
                    if(success == FALSE) {
                        n_try <- n_try + 1
                        message(paste("Failed to download the new central slab, attempt n°", n_try, "out of 10 for", slab_name))
                    }
                    if(n_try == 10) stop("Download of LidarHD slab failed after 10 attempts")
                }

                # Reload the slab
                rast_lidar <- terra::rast(here::here("data", "LidarHD", slab_name))
                error_slab <- try(mean(terra::values(rast_lidar)), silent = TRUE)

            }

            # Merge with neighboring slabs
            lapply(neigh_list, function(x){

                slab_2 <- terra::rast(here::here("data", "LidarHD", x))

                # Test if the file is corrupted
                error_neigh_slab <- try(mean(terra::values(slab_2)), silent = TRUE)

                while(inherits(error_neigh_slab, "try-error")){

                    n_try <- 0
                    success <- FALSE
                    print(paste("Error during the merge process, removing and re-downloading the neighboring slab :", x))
                    file.remove(here::here("data", "LidarHD", x))

                    while(success == FALSE && n_try < 10){

                        try_error <- try(
                                    download.file(
                                        lidarHD[grep(x, sub(".*&FILENAME=", "\\1", lidarHD))],
                                        destfile = here::here("data", "LidarHD", x),
                                        mode = "wb"
                                    ),
                                silent = TRUE
                                )

                        if(!inherits(try_error, "try-error")) success <- TRUE
                        if(success == FALSE) {
                            n_try <- n_try + 1
                            message(paste("Failed to download the new neighboring slab, attempt n°", n_try, "out of 10 for", x))
                        }
                        if(n_try == 10) stop("Download of LidarHD slab failed after 10 attempts")
                    }

                    # Reload the slab
                    slab_2 <- terra::rast(here::here("data", "LidarHD", x))
                    error_neigh_slab <- try(mean(terra::values(slab_2)), silent = TRUE)

                }

                rast_lidar <<- terra::merge(rast_lidar, slab_2)

            })

            # Degradation of spatial resolution 0.5m->3m
            rast_lidar <- terra::aggregate(rast_lidar, fact = 6, fun = mean)

            # Extract altitude values
            altMnt <- terra::extract(rast_lidar, df_extract_2975)
            df_extract_2975$altMnt <- altMnt[ , 2]

            # Extract slope value
            slope <- terra::terrain(rast_lidar, v = "slope", unit = "degrees")
            slope_val <- terra::extract(slope, df_extract_2975)
            df_extract_2975$slope <- slope_val[ ,2]

            # Extract orientation value
            aspect <- terra::terrain(rast_lidar, v = "aspect", unit = "degrees")
            aspect_val <- terra::extract(aspect, df_extract_2975)
            df_extract_2975$aspect <- aspect_val[ ,2]

            return(as.data.frame(df_extract_2975))

        }

    })

    df_final <- do.call(rbind, req_list)
    # assign("df_final", df_final, envir = .GlobalEnv) #for dev
    # assign("df_gpsRCT_2975", df_gpsRCT_2975, envir = .GlobalEnv) #for dev
    # print("Variables extracted") #for dev

    # Rename columns
    colnames(df_final)[which(colnames(df_final) %in% "altMnt")] <- "Altitude LidarHD"
    colnames(df_final)[which(colnames(df_final) %in% "slope")] <- "Pente LidarHD"
    colnames(df_final)[which(colnames(df_final) %in% "aspect")] <- "Orientation LidarHD"

    # Remove geometry column
    df_final <- df_final[ , colnames(df_final) != "geometry"]

    # Add point outside MNT emprise with NA values
    df_gpsRCT_2975 <- as.data.frame(df_gpsRCT_2975)
    df_gpsRCT_2975 <- df_gpsRCT_2975[ , colnames(df_gpsRCT_2975) != "geometry"]
    
    df_final$mergeNA <- paste0( df_final$DeviceID, "_", 
                                df_final$Year, "-", df_final$Month, "-", df_final$Day, " ", 
                                df_final$Hour, ":", df_final$Minute, ":", df_final$Second
                        )
    df_gpsRCT_2975$mergeNA <- paste0(   df_gpsRCT_2975$DeviceID, "_", 
                                        df_gpsRCT_2975$Year, "-", df_gpsRCT_2975$Month, "-", df_gpsRCT_2975$Day, " ", 
                                        df_gpsRCT_2975$Hour, ":", df_gpsRCT_2975$Minute, ":", df_gpsRCT_2975$Second
                                )
    line_outside <- dplyr::anti_join(df_gpsRCT_2975, df_final, by = "mergeNA")

    if(nrow(line_outside) > 0){
        line_outside$`Altitude LidarHD` <- NA
        line_outside$`Pente LidarHD` <- NA
        line_outside$`Orientation LidarHD` <- NA

        df_final <- rbind(df_final, line_outside)
    }else {
        print("None points outside of the LidarHD emprise")
    }

    # Remove columns of the merge
    df_final <- df_final[ , colnames(df_final) != "mergeNA"]

    return(df_final)

}
