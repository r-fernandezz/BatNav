
#' get_hist_altitude
#'
#' @description Create a histogram of altitude distribution from a dataframe containing GPS points and altitude data.
#'
#'
#' @param df_lidar_MNT A dataframe containing GPS points and altitude data.
#'
#' @return ggplot object representing the histogram of altitude distribution.
#'
#' @export NULL
#' 
#' 

get_hist_altitude <- function(df_lidar_MNT) {

    df_lidar_MNT$class <- cut(df_lidar_MNT$altMnt,
                                breaks = seq(0, 3100, by = 200),
                                labels = paste(seq(0, 2900, by = 200), seq(200, 3100, by = 200), sep = "\nà\n"),
                                right = FALSE)

    ggplot(df_lidar_MNT, aes(x = class)) + 
        geom_histogram(stat = "count", fill = "lightblue", color = "black", alpha = 0.7) +
        labs(x = "Altitude (m)", y = "Nombre de points") +
        theme_minimal()

}