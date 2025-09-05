#' get_map_PNR
#'
#' @description GPS points on the map of the Réunion National Park
#'
#'
#' @param df_gpsRCT Data frame containing GPS data.
#' @param PNR_shp Spatial object representing the boundaries of the Réunion National Park.
#'
#' @return A ggplot object displaying the GPS points on the map of the Réunion National Park.
#'
#' @export 

get_map_PNR <- function(df_gpsRCT, PNR_shp) {

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    
    PNR_shp$Type <- factor(
        PNR_shp$Type,
        levels = c(
            "Coeur du Parc national",
            "Aire d'Adhésion",
            "Aire ouverte à l'Adhésion"
        )
    )
    
    ggplot() +
    geom_sf(data = PNR_shp, aes(fill = Type), alpha = 0.5) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 1) +
    scale_fill_manual(
        values = c(
            "Coeur du Parc national" = "#32913a",
            "Aire d'Adhésion" = "#15ff00",
            "Aire ouverte à l'Adhésion" = "#ffe600"
        ),
        labels = c(
            "Coeur du Parc national" = "Cœur du parc",
            "Aire d'Adhésion" = "Aire d'adhésion",
            "Aire ouverte à l'Adhésion" = "Aire ouverte à l'adhésion"
        ),
    ) +
    scale_color_manual(values = c("Localisations GPS" =  "#ff0000")) +
    labs(fill = NULL, color = NULL) +
    theme_minimal() +
    theme(
        legend.position = "bottom"
    )

}