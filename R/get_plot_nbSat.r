#' get_plot_nbSat
#'
#' @description Create histogram with distribution of number of satellites used for GPS points.
#'
#' @param df_gpsRCT DataFrame. Containing GPS points and satellite information.
#'
#' @return ggplot object representing the histogram of Dop distribution.
#'
#' @export 
#' 
#' 

get_plot_nbSat <- function(df_gpsRCT) {

    df_gpsRCT$classSat <- cut(df_gpsRCT$Satellites,
                            breaks = seq(0, 50, by = 1), 
                            limits = c(0, 50),
                            labels = paste(seq(0, 49, by = 1), seq(1, 50, by = 1), sep = "\nà\n"),
                            right = FALSE)
    
    ggplot <-   ggplot(df_gpsRCT, aes(x = classSat)) + 
                geom_histogram(stat = "count", fill = "#ffee00", color = "black") +
                labs(x = "Nombre de satellites", y = "Nombre de points") +
                theme_minimal()

    return(ggplot)

}