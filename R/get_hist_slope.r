#' Name function
#'
#' @description 
#'
#'
#' @param Variable Type. Explication.
#' @param Variable Type. Explication.
#'
#' @return Name Variable
#'
#' @export 
#' 
#' 

get_hist_slope <- function(df_lidar_MNT) {

    df_lidar_MNT$class <- cut(df_lidar_MNT$slope,
                                breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                                labels = c("0-10", "10-20", "20-30", "30-40", "40-50", "50-60", "60-70", "70-80", "80-90"),
                                right = FALSE)

    ggplot(df_lidar_MNT, aes(x = class)) +
        geom_histogram(stat="count", fill = "lightyellow", color = "black", alpha = 0.7) +
        labs(x = "Inclinaison des pentes (degrés)", y = "Nombre de points") +
        theme_minimal()

}