#' value_lidarHD
#'
#' @description Export altitude, slope and aspect values from LidarHD raster for GPS points
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

        # Change SCR of GPS points
        df_gpsRCT_2975 <- st_transform(df_gpsRCT_WGS84, "EPSG:2975")
        df_gpsRCT_2975 <- cbind(df_gpsRCT_2975, st_coordinates(df_gpsRCT_2975))

        # Check if there are points in the slab
        df_extract_2975 <- subset(  df_gpsRCT_2975,
                                    X < df_coord$Xmax & X > df_coord$Xmin & Y < df_coord$Ymax & Y > df_coord$Ymin)

        if(nrow(df_extract_2975) > 0){

            if(!file.exists(here::here("data", "LidarHD", slab_name))){

                print("###### Downloading LidarHD slab... ######")

                # Download the raster slab
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
                        message(paste("Echec téléchargement, tentative n°", n_try, "sur 10 pour", slab_name))
                    }
                    if(n_try == 10) stop("Download of LidarHD slab failed after 10 attempts")
                    Sys.sleep(1)
                }
                

            }

            rast_lidar <- terra::rast(here::here("data", "LidarHD", slab_name))

            # Degradation of spatial resolution 0.5m->3m
            rast_lidar <- terra::aggregate(rast_lidar, fact = 6, fun = mean)

            # Extract altitude values
            altMnt <- terra::extract(rast_lidar, df_extract_2975)
            df_extract_2975$altMnt <- altMnt[ , 2]

            #For slope and aspect use WGS84 projection
            rast_lidarWGS84 <- terra::project(rast_lidar, "EPSG:4326")

            # Extract slope value
            slope <- terra::terrain(rast_lidarWGS84, v = "slope", unit = "degrees")
            df_extractWGS84 <- st_transform(df_extract_2975, "EPSG:4326")
            slope_val <- terra::extract(slope, df_extractWGS84)
            df_extractWGS84$slope <- slope_val[ ,2]

            # Extract orientation value
            aspect <- terra::terrain(rast_lidarWGS84, v = "aspect", unit = "degrees")
            aspect_val <- terra::extract(aspect, df_extractWGS84)
            df_extractWGS84$aspect <- aspect_val[ ,2]

            return(as.data.frame(df_extractWGS84))

        }

    })

    df_final <- do.call(rbind, req_list)

    return(df_final)

}
