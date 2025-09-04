#' get_OCS_table
#'
#' @description GPS data vs. OSC shapefile
#'
#'
#' @param df_gpsRCT Data frame containing GPS data.
#' @param ocs_shp Shapefile of the OSC areas.
#'
#' @return Data frame summarizing the points within each OSC area.
#'
#' @export NULL
#' 
#' 

get_OCS_table <- function(df_gpsRCT, ocs_shp) {

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    gps_sf <- st_transform(gps_sf, st_crs(ocs_shp))
    pt <- st_within(gps_sf, ocs_shp, sparse = TRUE) #st_within creates an indice for each polygon
    pt_n3 <- sapply(pt, function(x) if(length(x) > 0) ocs_shp$Niveau3[x[1]] else NA) #pt return indice
    tab_n3 <- table(pt_n3)
    df <- data.frame(
                Type_oso = names(tab_n3),
                Nb_point = as.numeric(tab_n3),
                proportion = round((as.numeric(tab_n3)/nrow(df_gpsRCT))*100, digit = 2)
                )
    
    colnames(df) <- c("Types de végétation", "Nombre de points", "Proportion")

    return(df)

}