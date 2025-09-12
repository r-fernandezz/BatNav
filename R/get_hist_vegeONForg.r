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
            aes(x = `Origine de la végétation`, y = `Proportion`, label = `Nombre de points`),
            size = 2.5,
            fontface = "italic"
        ) +
        theme_minimal() +
        theme(legend.position = "none") +
        labs(x = "Origine de la végétation", y = "Proportion de points") +
        scale_fill_manual(values = c(   "Anthropique" = "#E41A1C", 
                                        "Naturelle" = "#4DAF4A",
                                        "Hors catégories" = "#377EB8"
                                    )) +
        guides(fill = guide_legend(label.theme = element_text(face = "italic")))
}