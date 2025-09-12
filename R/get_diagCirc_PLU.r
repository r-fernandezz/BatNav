#' get_diagCirc_PLU
#'
#' @description Create circular diagram of land use (PLU) types from GPS data.
#'
#'
#' @param df Dataframe. Dataframe with GPS coordinates (longitude, latitude).
#' @param plu_shp SpatialPolygonsDataFrame. Spatial polygons for PLU areas.
#' 
#' @return ggplot object.
#'
#' @export NULL
#' 
#' 

get_diagCirc_PLU <- function(df_gps, plu_shp) {

    df_gps <- pt_within_poly(df_gps, plu_shp, arg_shp = "typezone")

    ggplot(df_gps, aes(x = "", y = nb_point, fill = type)) +
        geom_bar(stat = "identity", width = 1, color = "white") +
        coord_polar(theta = "y") +
        labs(x = NULL, y = NULL, fill = "Occupation du sol") +
        scale_fill_manual(
            values = c("A" = "#e7ef4a", "AU" = "#359bef", "N" = "#3cd061", "U" = "#9a36d0"),
            labels = c("A" = "Agricole", "AU" = "Urbanisable", "N" = "Naturelle", "U" = "Urbanisée")
        ) +
        theme_void() +
        theme(
            legend.position = "bottom",
            legend.title = element_blank()
        ) 
}
