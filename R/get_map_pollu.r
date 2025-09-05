#' get_map_Pollu
#'
#' @description map with light pollution and GPS points
#'
#'
#' @param df Dataframe. Data frame containing GPS data.
#' @param pollu_rast Raster. Raster layer of light pollution
#'
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_map_Pollu <- function(df_gpsRCT, pollu_rast) {
    
    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    
    pollu_df <- as.data.frame(pollu_rast, xy = TRUE)
    colnames(pollu_df) <- c("x", "y", "value")

    # Class found into technical report (into data folder)
    pollu_df$class <- cut(pollu_df$value,
                            breaks = c(0, 19.5, 20.30, 20.75, 21.00, 21.25, 21.50, 21.70, 22.00),
                            labels = c( "Grandes_villes", 
                                        "Urbain",
                                        "Suburbain_dense",
                                        "Suburbain",
                                        "Transition_suburbain-rural",
                                        "Rural",
                                        "Site_sombre",
                                        "Site_très_sombre"),
                            right = FALSE)
    
    ggplot() +
    geom_raster(data = pollu_df, aes(x = x, y = y, fill = class), alpha = 0.5) +
    geom_sf(data = gps_sf, aes(color = "Localisations GPS"), size = 1, alpha = 0.5) +
    scale_fill_manual(
        values = c( 
            "Grandes_villes" = "red", 
            "Urbain" = "orange",
            "Suburbain_dense" = "#F5C227",
            "Suburbain" = "yellow",
            "Transition_suburbain-rural" = "green",
            "Rural" = "cyan",
            "Site_sombre" = "blue",
            "Site_très_sombre" = "grey"),
        labels = c(
            "Grandes_villes" = "Grandes villes", 
            "Urbain" = "Urbain",
            "Suburbain_dense" = "Suburbain dense",
            "Suburbain" = "Suburbain",
            "Transition_suburbain-rural" = "Transition suburbain-rural",
            "Rural" = "Rural",
            "Site_sombre" = "Site sombre",
            "Site_très_sombre" = "Site très sombre"
    ),
        name = "Classe NSB\n(mag/arcsec²)") +
    scale_color_manual(values = c("Localisations GPS" =  "black")) +
    labs(fill = NULL, color = NULL) +
    theme_minimal() +
    theme(
        axis.title = element_blank(),
        legend.position = "bottom",
        legend.box = "vertical",
        legend.text = element_text(size = 10),
        legend.key.width = unit(0.5, "cm")
    )

}