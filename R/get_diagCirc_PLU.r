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

    df <- pt_within_poly(df_gps, plu_shp, arg_shp = "typezone")

    # Add point ouside PLU
    nb_pt_ext <- nrow(df_gps) - sum(df$nb_point)
    pr_pt_ext <- round(nb_pt_ext / nrow(df_gps) * 100, 2)
    df <- rbind(df, data.frame(type = "HP", nb_point = nb_pt_ext, proportion = pr_pt_ext))

    ggplot(df, aes(x = "", y = nb_point, fill = type)) +
        geom_bar(stat = "identity", width = 1, color = "white") +
        coord_polar(theta = "y") +
        scale_fill_manual(
            values = c("A" = "#e7ef4a", "AU" = "#359bef", "N" = "#3cd061", "U" = "#9a36d0", "HP" = "#d3d3d3"),
            labels = c("A" = "Agricole", "AU" = "Urbanisable", "N" = "Naturelle", "U" = "Urbanisée", "HP" = "Hors PLU")
        ) +
        theme_void() +
        theme(
            legend.position = "right",
            legend.title = element_blank()
        ) 
}
