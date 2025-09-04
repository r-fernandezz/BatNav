#' Get PNR Table
#'
#' @description This function generates a table summarizing GPS points within PNR areas.
#'
#' @param df_gpsRCT Data frame containing GPS data.
#' @param PNR_shp Shapefile of the PNR areas.
#'
#' @return Data frame summarizing the points within each PNR area.
#'
#' @export
#' 
#' 

get_PNR_table <- function(df_gpsRCT, PNR_shp) {  

    gps_sf <- st_as_sf(df_gpsRCT, coords = c("Longitudedecimal", "Latitudedecimal"), crs = st_crs("EPSG:4326"))
    gps_sf <- st_transform(gps_sf, st_crs(PNR_shp))
    pt <- st_within(gps_sf, PNR_shp, sparse = FALSE)
    colnames(pt) <- gsub(" ", "_", PNR_shp$Type)
    
    df <- data.frame(
            inside  = colSums(pt == TRUE),
            proportion = (colSums(pt == TRUE)/nrow(df_gpsRCT))*100,
            row.names = gsub("_", " ", colnames(pt))
    )

    df <- cbind(row.names(df), df)
    row.names(df) <- NULL
    colnames(df) <- c("zones", "inside", "proportion") #temporary names

    df <- df[!(df$zones == "Aire ouverte à l'Adhésion"), ] #remove one category
    df <- rbind(df, data.frame( zones = "Hors du parc", 
                                inside = as.numeric(nrow(df_gpsRCT) - sum(df$inside)), 
                                proportion = as.numeric(((nrow(df_gpsRCT) - sum(df$inside))/nrow(df_gpsRCT))*100))) # add line outside PNR
    colnames(df) <- c("Zones du Parc", "Nombre de points l'intérieur", "Pourcentage")


    return(df)

}