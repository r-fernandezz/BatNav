#' get_diagCirc_OCS
#'
#' @description Create circular diagram of land use (OCS) types from GPS data.
#'
#'
#' @param df_gps Dataframe. Dataframe with GPS coordinates (longitude, latitude).
#' @param ocs_shp SpatialPolygonsDataFrame. Spatial polygons for OCS areas.
#'
#' @return ggplot object.
#'
#' @export NULL

get_diagCirc_OCS <- function(df_gps, ocs_shp) {

    df_ocs <- get_tab_OCS(df_gps, ocs_shp)

    ggplot(df_ocs, aes(x = "", y = `Nombre de points`, fill = `Occupation du sol`)) +
        geom_bar(stat = "identity", width = 1, color = "white") +
        coord_polar(theta = "y") +
        labs(x = NULL, y = NULL, fill = "Occupation du sol") +
        scale_fill_manual(values = c(
            "#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD",
            "#8C564B", "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF",
            "#393B79", "#5254A3", "#6B6ECF", "#9C9EDE", "#637939",
            "#8CA252", "#B5CF6B", "#CEDB9C", "#8C6D31", "#BD9E39",
            "#E7BA52", "#E7CB94", "#843C39", "#AD494A", "#D6616B"
            )) +
        theme_void() +
        theme(
            legend.position = "right",
            legend.title = element_blank(),
            legend.text = element_text(size = 8),
            legend.key.size = unit(0.5, "cm")
        ) +
        guides(fill = guide_legend(nrow = 15, ncol = 2, byrow = FALSE))

}