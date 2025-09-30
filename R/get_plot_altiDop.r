#' get_plot_altiDop
#'
#' @description Create histogram of horizontal and vertical dilution of precision (Hdop and Vdop) from a dataframe containing GPS points and Dop data.
#'
#'
#' @param df_gpsRCT DataFrame. Containing GPS points and hdop/Vdop information.
#' @param dop Character. Type of dilution of precision to plot ("Hdop" or "Vdop").
#'
#' @return ggplot object representing the histogram of Dop distribution.
#'
#' @export 
#' 
#' 

get_plot_altiDop <- function(df_gpsRCT, dop) {

    if(dop == "Hdop") valeur_dop <- df_gpsRCT$Hdop
    if(dop == "Vdop") valeur_dop <- df_gpsRCT$Vdop
    

    df_gpsRCT$classDop <- cut(valeur_dop,
                            breaks = seq(0, 50, by = 1), 
                            limits = c(0, 50),
                            labels = paste(seq(0, 49, by = 1), seq(1, 50, by = 1), sep = "\nà\n"),
                            right = FALSE)
    
    ggplot <- ggplot(df_gpsRCT, aes(x = classDop))

    if(dop == "Hdop") ggplot <- ggplot + geom_histogram(stat = "count", fill = "blue", color = "black") 
    if(dop == "Vdop") ggplot <- ggplot + geom_histogram(stat = "count", fill = "green", color = "black")

    if(dop == "Hdop") ggplot <- ggplot + labs(x = "Dillution horizontale (Hdop)", y = "Nombre de points")
    if(dop == "Vdop") ggplot <- ggplot + labs(x = "Dillution verticale (Vdop)", y = "Nombre de points")
    
    ggplot <- ggplot + theme_minimal()

    return(ggplot)

}