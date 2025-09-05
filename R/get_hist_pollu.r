#' get_hist_Pollu
#'
#' @description histogram of light pollution levels at GPS points
#'
#'
#' @param df Dataframe. Data frame containing GPS coordinates
#' @param pollu_rast Raster. Raster layer of light pollution
#'
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_hist_pollu <- function(df_gpsRCT, pollu_rast) {

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    df_extract <- terra::extract(pollu_rast, gps_sf)
    gps_sf$pollu_value <- df_extract[ ,2]

    gps_sf$class <- cut(gps_sf$pollu_value,
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


    ggplot(gps_sf, aes(x = class, fill = class)) +
        geom_bar(color = "black", alpha = 0.7, show.legend = FALSE) +
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
        ) +
        scale_x_discrete(
            drop = FALSE,
            labels = c(
                "Grandes_villes" = "Grandes\nvilles", 
                "Urbain" = "Urbain",
                "Suburbain_dense" = "Suburbain\ndense",
                "Suburbain" = "Suburbain",
                "Transition_suburbain-rural" = "Transition\nsuburbain-rural",
                "Rural" = "Rural",
                "Site_sombre" = "Site\nsombre",
                "Site_très_sombre" = "Site\ntrès sombre"
            )
        ) +
        labs(x = NULL, y = "Nombre de points") +
        theme_minimal() +
        theme(
            axis.title.x = element_blank(),
            legend.position = "bottom",
            legend.box = "vertical",
            legend.text = element_text(size = 10),
            legend.key.width = unit(0.5, "cm")
        )

}
