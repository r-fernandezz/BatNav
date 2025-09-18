#' get_tab_summary
#'
#' @description Create summary table of tracking data
#'
#'
#' @param df_gpsRCT Data frame containing GPS tracking data.
#'
#' @return Dataframe summary table.
#'
#'
#' @export NULL


get_tab_summary <- function(df_gpsRCT) {

        # Number day of tracking by individuals
        df_gpsRCT$date <- as.Date(paste(df_gpsRCT$Year, df_gpsRCT$Month, df_gpsRCT$Day, sep = "-"))

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
                date_min = as.Date(sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    min(df_gpsRCT[df_gpsRCT$DeviceID == x, "date"])
                })),
                date_max = as.Date(sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    max(df_gpsRCT[df_gpsRCT$DeviceID == x, "date"])
                })),
                nb_days = sapply(unique(df_gpsRCT$DeviceID), function(x) {
                    date_min <- min(df_gpsRCT[df_gpsRCT$DeviceID == x, "date"])
                    date_max <- max(df_gpsRCT[df_gpsRCT$DeviceID == x, "date"])
                    if(as.numeric(date_max) - as.numeric(date_min) == 0) {
                        1
                    } else {
                        as.numeric(date_max) - as.numeric(date_min)
                    }
                })
        )

        # Number point mean by day
        df$nb_point_mean_day <- round(as.numeric(df$nb_point) / as.numeric(df$nb_days), 2)

        # Number of theorical points
        df$nb_point_theorical <- round((df$nb_point / (as.numeric(df$nb_days) * 12 * 4))*100, 2) #12 hours (18h-6h) with 4 points by hour (1 by 15 min)

        # Rename columns
        colnames(df) <- c(
                "Nom de l'individu",
                "Numéro de GPS", 
                "Nombre de points", 
                "Date du premier point", 
                "Date du dernier point", 
                "Nombre de jours de suivi",
                "Nombre de points moyen par jour",
                "Proportion théorique de points acquise (%)"
            )

        return(df)
}