#' Name function
#'
#' @description 
#'
#'
#' @param Variable Type. Explication.
#' @param Variable Type. Explication.
#'
#' @return Name Variable
#'
#' @export 
#' 
#' 

get_hist_vegeONForg <- function(df_gpsRCT){

    df <- get_tab_vegeONF(df_gpsRCT, arg_shp = "VEG_ORIGIN", namecol = "Origine de la végétation")
    df$'Origine de la végétation' <- factor(df$'Origine de la végétation', 
                                            levels = c("Anthropique", "Naturelle", "Hors catégories"))

    ggplot(df, aes(x = `Origine de la végétation`, y = `Proportion`, fill = `Origine de la végétation`)) +
        geom_bar(stat = "identity") +
        geom_text(
            aes(x = `Origine de la végétation`, y = Proportion + 2, label = `Nombre de points`),
            size = 2.5,
            fontface = "italic"
        ) +
        theme_minimal() +
        theme(legend.position = "none") +
        labs(x = "Origine de la végétation", y = "Proportion de points") +
        scale_fill_manual(values = c(   "Anthropique" = "#fcc5ac", 
                                        "Naturelle" = "#acfcb3",
                                        "Hors catégories" = "#acfce2"
                                    )) +
        guides(fill = guide_legend(label.theme = element_text(face = "italic")))
}