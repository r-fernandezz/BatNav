#' get_plot_speed
#'
#' @description Create histogram with distribution of speed for GPS points.
#'
#' @param df_gpsRCT DataFrame. Containing GPS points and speed information.
#'
#' @return ggplot object representing the histogram of speed distribution.
#'
#' @export
#'
#' 

get_plot_speed <- function(df_gpsRCT) {

    df_gpsRCT$classSpe <- cut(df_gpsRCT$Speed,
                        breaks = seq(0, 100, by = 2), 
                        limits = c(0, 100),
                        labels = paste(seq(0, 99, by = 2), seq(1, 100, by = 2), sep = "\nà\n"),
                        right = FALSE)

    ggplot <- ggplot(df_gpsRCT, aes(x = classSpe)) +
              geom_histogram(stat = "count", fill = "#f700ff", color = "black") +
              labs(x = "Vitesse (km/h)", y = "Nombre de points") +
              theme_minimal()

    return(ggplot)

}