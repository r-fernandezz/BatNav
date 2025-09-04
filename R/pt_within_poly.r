#' pt_within_poly
#'
#' @description Count number of point by polygon
#'
#'
#' @param df Dataframe. Data frame containing GPS data.
#' @param shp Shapefile with polygons.
#' @param arg_shp Character. Name of the column in the shapefile containing the polygon names.
#'
#' @return Data frame summarizing the points within each OSC area.
#'
#' @export NULL
#' 
#' 

pt_within_poly <- function(df, shp, arg_shp) {

    gps_sf <- st_as_sf(df, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    gps_sf <- st_transform(gps_sf, st_crs(shp))
    pt <- st_within(gps_sf, shp, sparse = TRUE) #st_within creates an indice for each polygon
    pt_n3 <- sapply(pt, function(x) if(length(x) > 0) shp[[arg_shp]][x[1]] else NA) #pt return indice
    tab_n3 <- table(pt_n3)
    df <- data.frame(
                type = names(tab_n3),
                nb_point = as.numeric(tab_n3),
                proportion = round((as.numeric(tab_n3)/nrow(df))*100, digit = 2)
            )

    return(df)

}