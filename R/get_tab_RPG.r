#' get_tab_RPG
#'
#' @description Create a table with the number and proportion of GPS points within each RPG parcel type.
#'
#'
#' @param df_gps Data frame containing GPS data.
#'
#' @return Data frame summarizing the number and proportion of GPS points within each RPG parcel type.
#'
#' @return Name Variable
#'
#' @export NULL
#' 
#'

get_tab_RPG <- function(df_gps) {

    df <- pt_within_poly(df_gps, rpg_shp, arg_shp = "CODE_CULTU")
    df_merged <- merge(df, rpgRef_tab, by.x = "type", by.y = "CODE", all.x = TRUE)
    df_order <- df_merged[, c("LIBELLE_CULTURE","nb_point", "proportion")]
    
    nb_pt_ext <- nrow(df_gps) - sum(df_order$nb_point)
    df_order <- rbind(df_order, data.frame(LIBELLE_CULTURE = "Hors RPG", nb_point = nb_pt_ext, proportion = round(nb_pt_ext / nrow(df_gps) * 100, 2)))
    colnames(df_order) <- c("Types de parcelles", "Nombre de points", "Proportion")
    
    return(df_order)
}