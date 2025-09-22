#' found_roost
#'
#' @description Found roost locations based on GPS data and buffer circle around the last point of the night.
#' If the first point of the night is within the buffer, the buffer is considered as roost locations.
#'
#'
#' @param df_gpsRCT Dataframe. GPS data points.
#' @param distance_size Numeric. Distance maximal (in meters) between the first and last points to consider the first point as roost location.
#'
#' @return Dataframe with roost locations.
#' Dataframe with column "roost" indicating if the point is a roost location ("Yes") or not ("No"). 
#' If none first point of the night is found between 12h and 00h, or 00h and 12h for the last point of the night, the point is not considered.
#' Dataframe with column "typePt" indicating if the point is the first point of the night ("first_night_point") or the last point of the night ("last_night_point").
#' 
#' @export NULL
#' 
#' 

found_roost <- function(df_gpsRCT, distance_size = 20){

    # Convertir les données GPS en objet spatial
    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = 4326)
    gps_sf_2975 <- st_transform(gps_sf, "EPSG:2975")

    # Add full date column
    gps_sf_2975$full_date <- as.POSIXct(   paste(
                                        paste(gps_sf_2975$Year, gps_sf_2975$Month, gps_sf_2975$Day, sep = "-"), 
                                        paste(gps_sf_2975$Hour, gps_sf_2975$Minute, gps_sf_2975$Second, sep = "-")
                                    ),
                                    format = "%Y-%m-%d %H-%M-%S",
                                    tz = "UTC"
                                )

    # For each individual, find the last point of all nights
    data_roost <- lapply(unique(gps_sf_2975$DeviceID), function(x){

        df_ind <- gps_sf_2975[gps_sf_2975$DeviceID == x, ]

        print(paste("Processing individu with DeviceID n°:", x, "(", grep(x, unique(gps_sf_2975$DeviceID)), "/", length(unique(gps_sf_2975$DeviceID)), ")"))

        df <- lapply(unique(as.Date(df_ind$full_date)), function(y){

            # Keep last point of the night (max between 00h -> 6h, UTC+4)
            df_day <- df_ind[as.Date(df_ind$full_date) == y, ]
            df_last_pt <- df_day[which(df_day$full_date <= as.POSIXct(paste(y, "02:00:00"), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), ]
            df_last_pt <- df_last_pt[df_last_pt$full_date == max(df_last_pt$full_date), ]

            # Keep first point of the night (min between 18h - 00h, UTC+4)
            df_first_pt <- df_day[which(df_day$full_date >= as.POSIXct(paste(y, "14:00:00"), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), ]
            df_first_pt <- df_first_pt[df_first_pt$full_date == min(df_first_pt$full_date), ]

            if (nrow(df_last_pt) > 0 && nrow(df_last_pt) < 2 &&
                nrow(df_first_pt) > 0 && nrow(df_first_pt) < 2) {

                df_first_pt$typePt <- "first_night_point"
                df_last_pt$typePt <- "last_night_point"

                # Check distance between first and last points
                dist <- st_distance(df_first_pt, df_last_pt)
                df_first_pt$roost_distance <- round(as.numeric(dist), 2)
                df_last_pt$roost_distance <- round(as.numeric(dist), 2)

                if(as.numeric(dist) < distance_size && 
                df_first_pt$Longitude != df_last_pt$Longitude && 
                df_first_pt$Latitude != df_last_pt$Latitude) {
                    df_first_pt$roost <- "Yes"
                    df_last_pt$roost <- "Yes"
                }else {
                    df_first_pt$roost <- "No"
                    df_last_pt$roost <- "No"
                }

                df_subfinal <- rbind(df_first_pt, df_last_pt)

            }else {
                df_subfinal <- NULL
            }

            return(df_subfinal)

        })

        df_final <- do.call(rbind, df)
        return(df_final)

    })

    data_roost_final <- do.call(rbind, data_roost)

    # Display the date in UTC+4
    data_roost_final$full_date <- lubridate::with_tz(data_roost_final$full_date, tzone = "Etc/GMT-4")

    # Remove point which are not roost
    data_roost_final <- data_roost_final[data_roost_final$roost == "Yes", ]

    #Remove point which are not last point of the night
    data_roost_final <- data_roost_final[data_roost_final$typePt == "last_night_point", ]

    # Reproject to WGS84
    data_roost_final <- st_transform(data_roost_final, "EPSG:4326")
    
    # Add coordinates columns
    data_roost_final$LongitudeDecimal <- sf::st_coordinates(data_roost_final)[,1]
    data_roost_final$LatitudeDecimal <- sf::st_coordinates(data_roost_final)[,2]

    return(data_roost_final)
}