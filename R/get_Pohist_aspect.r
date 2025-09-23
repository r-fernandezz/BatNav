#' get_hist_aspect
#'
#' @description Create a polar histogram of aspect distribution from a dataframe containing GPS points and aspect data.
#'
#'
#' @param df_lidar_MNT A dataframe containing GPS points and aspect data.
#'
#' @return ggplot object representing the polar histogram of aspect distribution.
#'
#' @export NULL
#' 
#' 

get_Pohist_aspect <- function(df_lidar_MNT) {

    df_lidar_MNT$class <- cut(df_lidar_MNT$'Orientation LidarHD',
                                breaks = c(0, 45, 90, 135, 180, 225, 270, 315, 360),
                                labels = c("N", "NE", "E", "SE", "S", "SO", "O", "NO"),
                                right = FALSE)

    ggplot(df_lidar_MNT, aes(x = class)) +
        geom_bar(fill = "lightgreen", color = "black", alpha = 0.7) +
        coord_polar(start = -pi/8) + 
        geom_text(  stat = "count", 
                    aes(label = round(((..count..) / sum(..count..))*100, 1), y = ..count.. + 1000),
            size = 3,
            fontface = "italic"
        ) +
        labs(x = "Orientation (degrés)", y = "Pourcentage de points") +
        theme_minimal() +
        theme(
            axis.text.y = element_blank(),
            axis.text.x = element_text(face = "bold", size = 12)
        )

}