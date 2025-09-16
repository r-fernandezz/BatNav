#' get_diagCirc_vegeONF
#'
#' @description Create a circular diagram of the vegetation typology from the ONF shapefile.
#'
#' @param df_gps Data frame containing GPS points.
#' @param shp Spatial object representing the vegetation typology shapefile.
#' @param arg_shp Character string representing the name of the vegetation typology column in the shapefile.
#'
#' @return ggplot object representing the circular diagram.
#'
#' @export NULL
#' 
#' 

get_diagCirc_vegeONF <- function(df_gps) {

    df <- get_tab_vegeONF(df_gps)

    df <- df[order(df$Proportion, decreasing = TRUE), ]
    df$'Typologie de végétation' <- factor(df$'Typologie de végétation',
                                            levels = df$'Typologie de végétation'[order(df$Proportion, decreasing = TRUE)]
        )

    ggplot(df, aes(x = "", y = `Nombre de points`, fill = `Typologie de végétation`)) +
        geom_bar(stat = "identity", width = 1, color = "white") +
        coord_polar(theta = "y") +
        labs(x = NULL, y = NULL, fill = "Typologie de végétation") +
        scale_fill_manual(values = c(
                                "#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD",
                                "#8C564B", "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF",
                                "#393B79", "#5254A3", "#6B6ECF", "#9C9EDE", "#637939",
                                "#8CA252", "#B5CF6B", "#CEDB9C", "#8C6D31", "#BD9E39",
                                "#E7BA52", "#E7CB94", "#843C39", "#AD494A", "#D6616B",
                                "#7B4173", "#A55194", "#CE6DBD", "#DE9ED6", "#3182BD",
                                "#6BAED6", "#9ECAE1", "#C6DBEF", "#00FFFF", "#000000",
                                "#FF1493", "#FFD700", "#40E0D0", "#32CD32", "#FF4500",
                                "#00CED1", "#ADFF2F", "#FF69B4", "#B22222", "#DAA520",
                                "#20B2AA", "#9932CC", "#00BFFF", "#F08080", "#8B0000",
                                "#3CB371", "#BA55D3", "#708090", "#DC143C", "#FF8C00",
                                "#2E8B57", "#00FA9A", "#8B008B", "#CD5C5C", "#FFDAB9",
                                "#191970", "#556B2F", "#FF00FF", "#6495ED", "#00FF7F",
                                "#FF6347", "#8FBC8F", "#6A5ACD", "#FFDEAD", "#FFB6C1",
                                "#4682B4", "#BDB76B", "#7FFF00", "#FF00FF", "#708090",
                                "#DA70D6", "#FFFA50", "#2F4F4F", "#F0E68C", "#C71585",
                                "#66CDAA", "#FFA07A", "#A0522D", "#00FF00"
                                )) +
        theme_void() +
        theme(
            legend.position = "right",
            legend.title = element_blank(),
            legend.text = element_text(size = 8),
            legend.key.size = unit(0.5, "cm")
        ) +
        guides(fill = guide_legend(nrow = 17, ncol = 2, byrow = FALSE))
}
