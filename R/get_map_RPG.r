
#' get_map_RPG
#'
#' @description Create map with GPS points and RPG parcels
#'
#'
#' @param df_gpsRCT Data frame with GPS data.
#' @param rpg_shp Spatial object with RPG parcels.
#'
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_map_RPG <- function(df_gpsRCT, rpg_shp) {

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))

    # Change encoding and list names of commune shapefile for better visualization
    com_shp$NOM <- iconv(com_shp$NOM, from = "latin1", to = "UTF-8")
    com_shp$NOM <- ifelse(
                    com_shp$NOM %in% c("Le Tampon", "Cilaos", "Bras-Panon", "Saint-Benoit", "Salazie", "Saint-Paul", "Saint-Denis", "Saint-Pierre", "Sainte-Rose", "Saint-Philippe"),
                    com_shp$NOM,
                    NA
                    )

    ggplot() +
    geom_sf(data = com_shp, fill = NA, color = "black", size = 0.2, show.legend = FALSE) +
    geom_sf(data = rpg_shp, aes(fill = "Parcelles RPG"), color = NA, alpha = 0.5, show.legend = c(fill = TRUE, color = FALSE)) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), fill = NA, size = 0.8, alpha = 0.8, show.legend = c(fill = FALSE, color = TRUE)) +
    geom_sf_text(data = com_shp, aes(label = NOM), size = 3, color = "black", fontface = "bold", na.rm = TRUE) +
    scale_color_manual(values = c(  "Localisations GPS" =  "#ff0000")) +
    scale_fill_manual(values = c("Parcelles RPG" =  "grey50")) +
    labs(fill = NULL, color = NULL) +
    theme_minimal() +
    theme(
        legend.position = "bottom",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(angle = 90, hjust = 0.5)
    )
}