#' get_tab_vegeONF
#'
#' @description Create data frame with the number and proportion of GPS points within each category of vegetation typology from ONF shapefile.
#'
#'
#' @param df_gps Data frame containing GPS points.
#' @param shp Spatial object representing the vegetation typology shapefile.
#' @param arg_shp Character string representing the name of the vegetation typology column in the shapefile.
#'
#' @return Data frame with the number and proportion of GPS points within each vegetation typology category.
#'
#' @export NULL
#' 
#' 

get_tab_vegeONF <- function(df_gps, arg_shp = "VEG_LEGEND", namecol = "Typologie de végétation") {


    df <- pt_within_poly(df_gps, shp = vegONF_shp, arg_shp)

    df$type <- gsub("<ita>", "", df$type)
    df$type <- gsub("</ita>", "", df$type)

    nb_pt_ext <- nrow(df_gps) - sum(df$nb_point)
    pr_pt_ext <- round(nb_pt_ext / nrow(df_gps) * 100, 2)
    df <- rbind(df, data.frame(type = "Hors catégories", nb_point = nb_pt_ext, proportion = pr_pt_ext))
    colnames(df) <- c(namecol, "Nombre de points", "Proportion")

    return(df)

}
