


get_map_RPG <- function(df_gpsRCT, rpg_shp) {

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    ggplot() +
    geom_sf(data = rpg_shp, aes(fill = CODE_CULTU), color = NA, alpha = 0.5, show.legend = FALSE) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 1) +
    scale_color_manual(values = c("Localisations GPS" =  "#ff0000")) +
    labs(fill = NULL, color = NULL) +
    theme_minimal() +
    theme(
        legend.position = "bottom"
    )
}