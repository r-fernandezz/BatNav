#' filterGPSdata
#'
#' @description Remove data after importation in Shiny application
#'
#'
#' @param df Dataframe. Dataframe merged and imported in Shiny application
#' @param DataMin Numeric. Year of the first GPS deployment. Imported into the Shiny application by the user. 
#' @param DataMax Numeric. Year of the last GPS deployment. Imported into the Shiny application by the user. 
#' @param speedZero Logical. If TRUE only points where speed is zero are conserved. Imported into the Shiny application by the user.
#' @param filterWindow Logical. If TRUE points outside the window (10°S–30°S, 40°E–65°E) will be removed. Imported into the Shiny application by the user.

#' @return Dataframe filtered
#'
#' @export 

filterGPSdata <- function(df, DataMin, DataMax, speedZero, filterWindow){

    # Filter points with deployment date
    df$full_date <- as.Date(paste(df$Year, df$Month, df$Day, sep = "-"), format = "%Y-%m-%d")
    df_sub <- subset(df, full_date < DataMax)
    df_sub <- subset(df_sub, full_date > DataMin)
    df_sub <- df_sub[ , !(colnames(df_sub) == "full_date")]

    # Keep only points where speed is zero
    if(speedZero == TRUE){
        df_sub$Speed <- as.numeric(df_sub$Speed)
        df_sub <- subset(df_sub, Speed == 0)
    }

    # Filter points with a windows
    if(filterWindow == TRUE){
        df_sub <- subset(df_sub, Longitudedecimal > 40)
        df_sub <- subset(df_sub, Longitudedecimal < 65)
        df_sub <- subset(df_sub, Latitudedecimal > -30)
        df_sub <- subset(df_sub, Latitudedecimal < -10)
    }

    return(df_sub)

}
