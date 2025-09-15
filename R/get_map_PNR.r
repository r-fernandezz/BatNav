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
    
    # Change encoding and list names of commune shapefile for better visualization
    com_shp$NOM <- iconv(com_shp$NOM, from = "latin1", to = "UTF-8")
    com_shp$NOM <- ifelse(
                    com_shp$NOM %in% c("Le Tampon", "Cilaos", "Bras-Panon", "Saint-Benoit", "Salazie", "Saint-Paul", "Saint-Denis", "Saint-Pierre", "Sainte-Rose", "Saint-Philippe"),
                    com_shp$NOM,
                    NA
                    )

    ggplot() +
    geom_sf(data = com_shp, fill = NA, color = "black", size = 0.2) +
    geom_sf(data = PNR_shp, aes(fill = Type), color = NA, alpha = 0.5) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 0.8, alpha = 0.8) +
    geom_sf_text(data = com_shp, aes(label = NOM), size = 3, color = "black", fontface = "bold", na.rm = TRUE) +
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
        legend.position = "bottom",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(angle = 90, hjust = 0.5)
    )

}