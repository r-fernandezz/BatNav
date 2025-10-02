#' altiProcess
#'
#' @description Calculate the flight height above ground from the altitude data.
#'
#'
#' @param df_filter Dataframe. Contains the filtered altitude data.
#'
#' @return Dataframe. Contains column with the altitude correction.
#'
#' @export NULL
#' 
#' 

altiProcess <- function(df_flyFilter){

    df_mntAlti <- value_lidarHD(df_flyFilter, lidarMNT, parm_slope = FALSE, parm_aspect = FALSE) #with column altitude only

    # Correct altitude from GPS
    alti_cor <- df_mntAlti$Altitude - df_mntAlti$'Altitude LidarHD'

    # Add altitude correction to dataframe
    df_mntAlti$alti_cor <- alti_cor

    return(df_mntAlti)

}
