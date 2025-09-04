#' get_map_PLU
#'
#' @description data GPS vs. PLU areas
#'
#'
#' @param df_gpsRCT Data frame with GPS data.
#' @param PLU_shp Spatial object with PLU areas.
#'
#' @return Name Variable
#'
#' @export 

get_map_PLU <- function(df_gpsRCT, plu_shp) {

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    ggplot() +
    geom_sf(data = plu_shp, aes(fill = typezone), alpha = 0.5) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 1) +
    scale_fill_manual(
        values = c("A" = "#e7ef4a", "AU" = "#359bef", "N" = "#3cd061", "U" = "#9a36d0"),
        labels = c("A" = "Agricole", "AU" = "Urbanisable", "N" = "Naturelle", "U" = "Urbanisée")
    ) +
    scale_color_manual(values = c("Localisations GPS" =  "#ff0000")) +
    labs(fill = NULL, color = NULL) +
    theme_minimal() +
    theme(
        legend.position = "bottom"
    )
}