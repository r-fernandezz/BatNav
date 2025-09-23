#' get_tab_roost
#'
#' @description Get a formatted table of roosting points from roost analysis results.
#'
#' @param df_roostRCT DataFrame containing roosting points data.
#'
#'
#' @param df_roostRCT DataFrame containing roosting points data.
#'
#' @return DataFrame formatted for display and download.
#'
#' @export NULL
#' 
#' 

get_tab_roost <- function(df_roostRCT){

        # Shape dataframe for preview
        col <- c("DeviceID", "nom_individu", "full_date", "LatitudeDecimal", "LongitudeDecimal", "roost_distance")
        df_roostRCT <- as.data.frame(df_roostRCT)
        df_roostRCT <- df_roostRCT[, colnames(df_roostRCT) %in% col]
        df_roostRCT$full_date <- as.character(df_roostRCT$full_date)

        if("nom_individu" %in% colnames(df_roostRCT)){
            colnames(df_roostRCT) <- c( "Numéro de la balise", 
                                        "Nom de l'individu", 
                                        "Date d'arrivée sur le reposoir",
                                        "Distance entre le premier et le dernier point de la nuit (m)",
                                        "Longitude",
                                        "Latitude" 
                                    )
        } else if (!"nom_individu" %in% colnames(df_roostRCT)) {
            colnames(df_roostRCT) <- c( "Numéro de la balise",
                                        "Date d'arrivée sur le reposoir",
                                        "Distance entre le premier et le dernier point de la nuit (m)",
                                        "Longitude", 
                                        "Latitude" 
                                    )
        }

        return(df_roostRCT)

    }