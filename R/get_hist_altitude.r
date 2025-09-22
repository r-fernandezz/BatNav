
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

    df_lidar_MNT$class <- cut(df_lidar_MNT$'Altitude LidarHD',
                                breaks = seq(0, 3100, by = 200),
                                labels = paste(seq(0, 2900, by = 200), seq(200, 3100, by = 200), sep = "\nà\n"),
                                right = FALSE)

    ggplot(df_lidar_MNT, aes(x = class)) + 
        geom_bar(aes(y = ((..count..) / sum(..count..))*100), fill = "#9b34ca", color = "black", alpha = 0.7) +
        geom_text(
            stat = "count",
            aes(label = ..count.., y = ((..count..) / sum(..count..))*100),
            vjust = -0.5,
            size = 3
        ) +
        labs(x = "Altitude (m)", y = "Pourcentage de points") +
        theme_minimal()

}