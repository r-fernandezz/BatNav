#' get_tab_summary
#'
#' @description Create summary table of tracking data
#'
#'
#' @param df_gpsRCT Data frame containing GPS tracking data.
#' @param distanceAnalysis Logical. If TRUE, distance traveled and mean distance per day are calculated and added to the summary table.
#'
#' @return Dataframe summary table.
#'
#'
#' @export NULL


get_tab_summary <- function(df_gpsRCT, distanceAnalysis) {

        # Create a full date column
        df_gpsRCT$date <- as.POSIXct(paste(paste(df_gpsRCT$Year, df_gpsRCT$Month, df_gpsRCT$Day, sep = "-"), 
                                            paste(df_gpsRCT$Hour, df_gpsRCT$Minute, df_gpsRCT$Second, sep = ":"), 
                                    sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

        # Convertir les données GPS en objet spatial
        df_gpsRCT <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = 4326)
        df_gpsRCT <- st_transform(df_gpsRCT, "EPSG:2975")

        # Add name of individuals if correspondence table is provided
        if("nom_individu" %in% colnames(df_gpsRCT)) {
            name <<- sapply(unique(df_gpsRCT$DeviceID), function(x) {
                unique(df_gpsRCT[df_gpsRCT$DeviceID == x, ]$nom_individu)
            })
        } else if (!"nom_individu" %in% colnames(df_gpsRCT)) {
            name <<- rep(NA, length(unique(df_gpsRCT$DeviceID)))
        }

        # Create summary table
        df <- data.frame(
                name = name,

                DeviceID = unique(df_gpsRCT$DeviceID),

                nb_point = sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    nrow(df_gpsRCT[df_gpsRCT$DeviceID == x, ])
                }),

                date_min = as.Date(as.POSIXct(sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    min(df_gpsRCT[df_gpsRCT$DeviceID == x, ]$date)
                }), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")),

                date_max = as.Date(as.POSIXct(sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    max(df_gpsRCT[df_gpsRCT$DeviceID == x, ]$date)
                }), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")),

                nb_days = sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    date_min <- as.Date(min(as.POSIXct(df_gpsRCT[df_gpsRCT$DeviceID == x, ]$date, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")))
                    date_max <- as.Date(max(as.POSIXct(df_gpsRCT[df_gpsRCT$DeviceID == x, ]$date, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")))
                    
                    (as.numeric(date_max) - as.numeric(date_min))+1
                    
                }),

                speedMean = sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    speed <- df_gpsRCT[df_gpsRCT$DeviceID == x,]$Speed
                    round(mean(speed[speed != 0]), 2)
                }),

                speedMax = sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    round(max(df_gpsRCT[df_gpsRCT$DeviceID == x, ]$Speed), 2)
                })

        )

        if(distanceAnalysis == TRUE){
            # Distance
            distance <- sapply(unique(df_gpsRCT$DeviceID), function(x) {

                message(paste("Calculating distance for DeviceID n°:", x, "(", grep(x, unique(df_gpsRCT$DeviceID)), "/", length(unique(df_gpsRCT$DeviceID)), ")"))
                df_dist <- df_gpsRCT[df_gpsRCT$DeviceID == x,]

                # Identify nights
                df_dist$night <- ifelse(
                    format(df_dist$date, "%H:%M:%S") >= "14:00:00", #18h en UTC+4
                    as.character(as.Date(as.POSIXct(df_dist$date, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))), #current night
                    as.character(as.Date(as.POSIXct(df_dist$date, format = "%Y-%m-%d %H:%M:%S", tz = "UTC") -  as.difftime(1, units = "days"))) #previous night
                )

                # Distance for each night
                nightly_distances <- tapply(1:nrow(df_dist), df_dist$night, function(rows) {

                    if (length(rows) > 1) {

                        # Calculate distance for each night
                        dist <- unlist(sapply(1:(length(rows) - 1), function(i) {
                            st_distance(df_dist[rows[i], ], df_dist[rows[i + 1], ])
                        }))

                        sum(as.numeric(dist))/ 1000 #in kilometers

                    } else {
                        0 #if only one point, distance = 0
                    }

                })

                list(
                    total = round(sum(nightly_distances), 2),
                    mean = round(mean(unlist(nightly_distances), na.rm = TRUE), 2),
                    max = round(max(unlist(nightly_distances), na.rm = TRUE), 2)
                )

            })

            # Distance mean by day
            df$distance_total <- distance["total", ]
            df$distance_mean_day <- distance["mean", ]
            df$distance_max <- distance["max", ]
        }

        # Number point mean by day
        df$nb_point_mean_day <- round(as.numeric(df$nb_point) / as.numeric(df$nb_days), 2)

        # Number of theorical points
        df$nb_point_theorical <- round((df$nb_point / (as.numeric(df$nb_days) * 12 * 4))*100, 2) #12 hours (18h-6h) with 4 points by hour (1 by 15 min)

        # Rename columns
        if(distanceAnalysis == TRUE){
            colnames(df) <- c(
                    "Nom de l'individu",
                    "Numéro de GPS", 
                    "Nombre de points", 
                    "Date du premier point", 
                    "Date du dernier point", 
                    "Nombre de nuits de suivi",
                    "Vitesse moyenne de déplacement (km/h)",
                    "Vitesse maximale (km/h)",
                    "Distance totale parcourue (km)",
                    "Distance moyenne par nuit (km)",
                    "Distance moyenne maximale (km)",
                    "Nombre de points moyen par nuit",
                    "Proportion théorique de points acquise (%)"
                )
        } else{
            colnames(df) <- c(
                    "Nom de l'individu",
                    "Numéro de GPS", 
                    "Nombre de points", 
                    "Date du premier point", 
                    "Date du dernier point", 
                    "Nombre de nuits de suivi",
                    "Vitesse moyenne de déplacement (km/h)",
                    "Vitesse maximale (km/h)",
                    "Nombre de points moyen par nuit",
                    "Proportion théorique de points acquise (%)"
                )
        }

        return(df)
}