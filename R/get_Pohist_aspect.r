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

    df_lidar_MNT$class <- cut(df_lidar_MNT$aspect,
                                breaks = c(0, 45, 90, 135, 180, 225, 270, 315, 360),
                                labels = c("N", "NE", "E", "SE", "S", "SO", "O", "NO"),
                                right = FALSE)

    ggplot(df_lidar_MNT, aes(x = class)) +
        geom_bar(fill = "lightgreen", color = "black", alpha = 0.7) +
        geom_text(stat = "count", aes(label = ..count.., y = ..count.. + 10), size = 4) +
        coord_polar() + 
        labs(x = "Orientation (degrés)", y = "Nombre de points") +
        theme_minimal() +
        theme(
            axis.text.y = element_blank()
        )

    # Calcul du nombre de points par classe
    count_tab <- as.data.frame(table(df_lidar_MNT$class, useNA = "ifany"))
    colnames(count_tab) <- c("class", "count")
    count_tab$class <- factor(count_tab$class, levels = levels(df_lidar_MNT$class))

    # Rayon pour placer les labels à l'extérieur
    y_label <- max(count_tab$count) + max(count_tab$count) * 0.1

    ggplot(df_lidar_MNT, aes(x = class)) +
        geom_bar(fill = "lightgreen", color = "black", alpha = 0.7) +
        geom_text(
            data = count_tab,
            aes(x = class, y = y_label, label = count),
            inherit.aes = FALSE,
            size = 2.5,
            fontface = "italic"
        ) +
        coord_polar() +
        labs(x = "Orientation (degrés)", y = "Nombre de points") +
        theme_minimal() +
        theme(
            axis.text.y = element_blank(),
            axis.text.x = element_text(face = "bold", size = 12)
        )

}