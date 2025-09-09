#' get_tab_OCS
#'
#' @description Create table summarizing GPS points within OCS areas.
#'
#'
#' @param df_gpsRCT Dataframe. Data frame containing GPS data.
#' @param ocs_shp Shapefile. Spatial object representing OCS areas.
#'
#' @return Data frame summarizing the points within each OCS area.
#'
#' @export NULL

get_tab_OCS <- function(df_gpsRCT, ocs_shp) {

    df <- pt_within_poly(df_gpsRCT, ocs_shp, arg_shp = "Niveau3")

    nb_pt_ext <- nrow(df_gpsRCT) - sum(df$nb_point)
    pr_pt_ext <- round(nb_pt_ext / nrow(df_gpsRCT) * 100, 2)
    df <- rbind(df, data.frame(type = "Hors catégories", nb_point = nb_pt_ext, proportion = pr_pt_ext))
    colnames(df) <- c("Occupation du sol", "Nombre de points", "Proportion")

    return(df)

}