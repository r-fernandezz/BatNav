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
                            "#6BAED6", "#9ECAE1", "#C6DBEF"
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
