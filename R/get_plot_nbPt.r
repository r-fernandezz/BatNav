#' get_plot_nbPt
#'
#' @description Plot number of GPS point by day and per individual
#'
#'
#' @param df_gpsRCT Data frame containing GPS data.
#' @param Variable Type. Explication.
#' @param fixYear Logical. If TRUE, the year is fixed to 2014 to visualize data over one year.
#' @param deviceID Character. DeviceID number of one individual to plot only one individual. If NULL, all individuals are plotted.
#'
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_plot_nbPt <- function(df_gpsRCT, fixYear = TRUE, deviceID = NULL) {

    # Create a full date column
    df_gpsRCT$full_date <- as.Date(paste(df_gpsRCT$Year, df_gpsRCT$Month, df_gpsRCT$Day, sep = "-"), format = "%Y-%m-%d")

    # Filter on one individual if deviceID number is provided
    if(!is.null(deviceID)){
        df_gpsRCT <- df_gpsRCT[df_gpsRCT$DeviceID == deviceID, ]
    }

    # Fix year to create a plot over one year
    if(fixYear == TRUE){
        monthDay <- format(as.Date(df_gpsRCT$full_date, format = "%Y-%m-%d"),"%m-%d")
        df_gpsRCT$FixYear2014 <- as.Date(paste(2014, monthDay, sep = "-"))
    }else {
       df_gpsRCT$FixYear2014 <- df_gpsRCT$full_date
    }

    # Conversion with numeric for plot
    df_gpsRCT$FixYear2014 <- as.numeric(as.Date(df_gpsRCT$FixYear2014, format = "%Y-%m-%d"))

    # Count number of points per individual and per day
    if(!"nom_individu" %in% colnames(df_gpsRCT)){
        df_count <- aggregate(
                        x = list(nb_points = df_gpsRCT$DeviceID), 
                        by = list(DeviceID = df_gpsRCT$DeviceID, FixYear2014 = df_gpsRCT$FixYear2014), 
                        FUN = length
                    )
    }

    if("nom_individu" %in% colnames(df_gpsRCT)){
        df_count <- aggregate(
                            x = list(nb_points = df_gpsRCT$nom_individu), 
                            by = list(nom_individu = df_gpsRCT$nom_individu, FixYear2014 = df_gpsRCT$FixYear2014), 
                            FUN = length
                        )
    }

    # Plot
    if(!"nom_individu" %in% colnames(df_gpsRCT)){

        if(is.null(deviceID)){

            plot <- ggplot( df_count, aes(x = FixYear2014, y = as.character(DeviceID), fill = nb_points)) +
                            geom_tile(aes(width = 1), height = 0.8)

            if(fixYear == TRUE){
                plot <- plot + scale_x_continuous(
                                    labels = function(x) format(as.Date(x, origin = "1970-01-01"), "%d-%b"),
                                    breaks = as.numeric(seq.Date(as.Date("2014-01-01"), as.Date("2014-12-31"), by = "2 months")),
                                    limits = c(as.numeric(as.Date("2014-01-01")), as.numeric(as.Date("2014-12-31")))
                                )
            }else {
                plot <- plot + scale_x_continuous(
                                    labels = function(x) format(as.Date(x, origin = "1970-01-01"), "%d-%b-%Y")
                                )
            }

            plot <- plot +  scale_fill_viridis_c(name = "Nombre de points") +
                            labs(x = "Date", y = "Numéro du GPS") +
                            theme(
                                title.text.y = element_text(face = "bold", size = 14),
                                title.text.x = element_text(face = "bold", size = 14)
                            )
        }else {

            plot <- ggplot(df_count, aes(x = FixYear2014, y = nb_points, fill = as.character(DeviceID))) +
                    geom_point(color = "black", size = 0.5) +
                    geom_line(color = "lightgreen", linewidth = 1) +
                    scale_fill_manual(values = "lightgreen") +
                    scale_x_continuous( breaks = as.numeric(seq.Date(as.Date(min(df_count$FixYear2014), origin = "1970-01-01"), 
                                                                    as.Date(max(df_count$FixYear2014), origin = "1970-01-01"), 
                                                                    by = "2 months")
                                                        ),
                                        labels = function(x) format(as.Date(x, origin = "1970-01-01"), "%d-%m\n%Y")) +
                    labs(x = "Date", y = "Nombre de points") +
                    ggtitle(paste0("Balise n°", as.character(df_count$DeviceID))) +
                    theme(
                        title.text.y = element_text(face = "bold", size = 14),
                        title.text.x = element_text(face = "bold", size = 14),
                        legend.position = "none" 
                    )

        }
    }

    if("nom_individu" %in% colnames(df_gpsRCT)){
        
        if(is.null(deviceID)){

            plot <- ggplot( df_count, aes(x = FixYear2014, y = nom_individu, fill = nb_points)) +
                            geom_tile(aes(width = 1), height = 0.8)
                
            if(fixYear == TRUE){
                plot <- plot + scale_x_continuous(
                                    labels = function(x) format(as.Date(x, origin = "1970-01-01"), "%d-%b"),
                                    breaks = as.numeric(seq.Date(as.Date("2014-01-01"), as.Date("2014-12-31"), by = "2 months")),
                                    limits = c(as.numeric(as.Date("2014-01-01")), as.numeric(as.Date("2014-12-31")))
                                ) 
            }else {
                plot <- plot + scale_x_continuous(
                                    labels = function(x) format(as.Date(x, origin = "1970-01-01"), "%d-%b-%Y")
                                )
            }

            plot <- plot +  scale_fill_viridis_c(name = "Nombre de points") +
                            labs(x = "Date", y = "Nom de l'individu") +
                            theme(
                                title.text.y = element_text(face = "bold", size = 14),
                                title.text.x = element_text(face = "bold", size = 14)
                            )
        }else {

            plot <- ggplot(df_count, aes(x = FixYear2014, y = nb_points, fill = as.character(nom_individu))) +
                    geom_point(color = "black", size = 0.5) +
                    geom_line(color = "lightgreen", linewidth = 1) +
                    scale_fill_manual(values = "lightgreen") +
                    scale_x_continuous( breaks = as.numeric(seq.Date(as.Date(min(df_count$FixYear2014), origin = "1970-01-01"), 
                                                                    as.Date(max(df_count$FixYear2014), origin = "1970-01-01"), 
                                                                    by = "2 months")
                                                        ),
                                        labels = function(x) format(as.Date(x, origin = "1970-01-01"), "%d-%m\n%Y")) +
                    labs(x = "Date", y = "Nombre de points") +
                    ggtitle(paste("Individu", as.character(df_count$nom_individu))) +
                    theme(
                        title.text.y = element_text(face = "bold", size = 14),
                        title.text.x = element_text(face = "bold", size = 14),
                        legend.position = "none" 
                    )

        }
    }

    return(plot)
}


