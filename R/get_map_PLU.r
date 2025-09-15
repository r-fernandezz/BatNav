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
    
    # Change encoding and list names of commune shapefile for better visualization
    com_shp$NOM <- iconv(com_shp$NOM, from = "latin1", to = "UTF-8")
    com_shp$NOM <- ifelse(
                    com_shp$NOM %in% c("Le Tampon", "Cilaos", "Bras-Panon", "Saint-Benoit", "Salazie", "Saint-Paul", "Saint-Denis", "Saint-Pierre", "Sainte-Rose", "Saint-Philippe"),
                    com_shp$NOM,
                    NA
                    )

    ggplot() +
    geom_sf(data = com_shp, fill = NA, color = "black", size = 0.2) +
    geom_sf(data = plu_shp, aes(fill = typezone), color = NA, alpha = 0.5) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 0.8, alpha = 0.8) +
    geom_sf_text(data = com_shp, aes(label = NOM), size = 3, color = "black", fontface = "bold", na.rm = TRUE) +
    scale_fill_manual(
        values = c("A" = "#e7ef4a", "AU" = "#359bef", "N" = "#3cd061", "U" = "#9a36d0"),
        labels = c("A" = "Agricole", "AU" = "Urbanisable", "N" = "Naturelle", "U" = "Urbanisée")
    ) +
    scale_color_manual(values = c("Localisations GPS" =  "#ff0000")) +
    labs(fill = NULL, color = NULL) +
    theme_minimal() +
    theme(
        legend.position = "bottom",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(angle = 90, hjust = 0.5)
    )

}