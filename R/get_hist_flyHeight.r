#' get_hist_flyHeight
#'
#' @description Create histogram of flight height above ground with all values.
#'
#'
#' @param df Data frame containing altitude corrections.
#' @param inter Integer. Interval for histogram bins.
#'
#' @return ggplot object
#'
#' @export 
#' 
#' 

get_hist_flyHeight <- function(df, inter){

    min <- floor(min(df$alti_cor, na.rm = TRUE) / 10) * 10
    max <- ceiling(max(df$alti_cor, na.rm = TRUE) / 10) * 10

    df$alti_cor_classe <- cut(df$alti_cor,
                                breaks = seq(min, max, by = inter), 
                                labels = paste(seq(min, max-inter, by = inter),
                                               seq(min+inter, max, by = inter), sep = "\nà\n"),
                                right = FALSE)

    ggplot <-   ggplot(df, aes(x = as.factor(alti_cor_classe))) +
                geom_histogram(stat = "count", fill = "#a2f8b8", color = "black") +
                labs(x = "Altitude (m)", y = "Nombre de points") +
                theme_minimal()

    return(ggplot)

}