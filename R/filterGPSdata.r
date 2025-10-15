#' filterGPSdata
#'
#' @description Remove data after importation in Shiny application. Remove automatically duplicated points.
#'
#'
#' @param df Dataframe. Dataframe merged and imported in Shiny application
#' @param DataMin Numeric. Year of the first GPS deployment. Imported into the Shiny application by the user. 
#' @param DataMax Numeric. Year of the last GPS deployment. Imported into the Shiny application by the user. 
#' @param speedZero Logical. If TRUE only points where speed is zero are conserved. Imported into the Shiny application by the user.
#' @param filterWindow Logical. If TRUE points outside the window (10°S–30°S, 40°E–65°E) will be removed. Imported into the Shiny application by the user.
#' @param resampleSwitch Logical. If TRUE resampling is applied when more than 48 points per day. Imported into the Shiny application by the user.
#' 
#' @return Dataframe filtered
#'
#' @export 

filterGPSdata <- function(df, DataMin, DataMax, speedZero, filterWindow, resampleSwitch){

    # Filter points with deployment date
    df$full_date <- as.Date(paste(df$Year, df$Month, df$Day, sep = "-"), format = "%Y-%m-%d")
    df_sub <- subset(df, full_date < DataMax)
    df_sub <- subset(df_sub, full_date > DataMin)
    df_sub <- df_sub[ , !(colnames(df_sub) == "full_date")]

    # Remove duplicated points
    df_sub$DateTime <- as.POSIXct(paste(paste(df_sub$Year, df_sub$Month, df_sub$Day, sep = "-"), 
                                            paste(df_sub$Hour, df_sub$Minute, df_sub$Second, sep = ":"), 
                                    sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    df_sub <- df_sub[!duplicated(df_sub[, c("DeviceID", "DateTime")]), ]

    # Remove 5 points of device 987004 ("Dondon") outside deployment period
    if(987004 %in% unique(df_sub$DeviceID)){
        df_sub <- df_sub[!(df_sub$DeviceID == 987004 & as.character(df_sub$DateTime) %in% c("2018-12-05 19:11:37",
                                                                            "2018-12-05 19:11:43",
                                                                            "2018-12-05 19:26:49",
                                                                            "2018-12-05 19:42:06",
                                                                            "2018-12-05 19:56:50")), ]
    }
    df_sub <- df_sub[ , !(colnames(df_sub) == "DateTime")]

    # Filter points with a windows
    if(filterWindow == "SudOIFilter"){
        df_sub <- subset(df_sub, Longitudedecimal > 40)
        df_sub <- subset(df_sub, Longitudedecimal < 65)
        df_sub <- subset(df_sub, Latitudedecimal > -30)
        df_sub <- subset(df_sub, Latitudedecimal < -10)
    }

    if(filterWindow == "ReunionFilter"){
        df_sub <- subset(df_sub, Longitudedecimal > 55.2)
        df_sub <- subset(df_sub, Longitudedecimal < 55.9)
        df_sub <- subset(df_sub, Latitudedecimal > -21.4)
        df_sub <- subset(df_sub, Latitudedecimal < -20.8)
    }

    # Resample points if more than 48 points per day
    if(resampleSwitch == TRUE){

        df_sub$DateTime <- as.POSIXct(paste(paste(df_sub$Year, df_sub$Month, df_sub$Day, sep = "-"), 
                                            paste(df_sub$Hour, df_sub$Minute, df_sub$Second, sep = ":"), 
                                    sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

        df_sub <- df_sub[order(df_sub$DateTime), ]

        df_tot <- lapply(unique(df_sub$DeviceID), function(x){

            df_sub_ind <- subset(df_sub, DeviceID == x)

            print(paste("Processing DeviceID :", x))

            df <- do.call(rbind, lapply(unique(as.Date(df_sub_ind$DateTime)), function(y){

                print(paste("Resampling day :", y))

                min <- as.POSIXct(paste(y, "14:00:00"), format = "%Y-%m-%d %H:%M:%S", tz = "UTC") #UTC+4
                max <- as.POSIXct(paste(as.Date(y)+1, "02:00:00"), format = "%Y-%m-%d %H:%M:%S", tz = "UTC") #UTC+4

                #Considered the day y from 18:00 to 6:00 the next day
                df_sub_day <- subset(df_sub_ind, DateTime > min & DateTime < max)

                if(nrow(df_sub_day) > 0){

                    diffs <- as.numeric(difftime(   df_sub_day$DateTime[-1], 
                                                    df_sub_day$DateTime[-length(df_sub_day$DateTime)], 
                                                    units = "mins")
                                                    )

                    #if(mean(diffs) < 10){ #resample only if more than one point every 15 minutes (1 point by 5min)

                        time_seq <- seq(from = min, to = max, by = "15 min")

                        df_sub_day_resample <- do.call(rbind, lapply(time_seq, function(t) {

                            idx <- which.min(abs(as.numeric(difftime(df_sub_day$DateTime, t, units = "secs"))))
                            df_idx <- df_sub_day[idx, ]

                            if(abs(as.numeric(difftime(df_idx$DateTime, t, units = "mins"))) > 5){ #if the closest point is more than 5 minutes away, do not keep it

                                return(NULL) 

                            } else if (abs(difftime(df_idx$DateTime, t, units = "mins")) <= 5) {

                                df_sub_day <- df_sub_day[-idx, ] #remove selected row to avoid duplication
                                return(df_idx)

                            }
                        }))

                        df_sub_day <- df_sub_day_resample

                    #}

                }else{
                    print("No point for this day between 18:00 and 6:00 the next day")
                }

                return(df_sub_day)
            }))

        })

        df_sub <- do.call(rbind, df_tot)

    }

    # Keep only points where speed is zero
    if(speedZero == "0km/h"){
        df_sub$Speed <- as.numeric(df_sub$Speed)
        df_sub <- subset(df_sub, Speed == 0)
    }

    # Keep only points where speed is >0km/h
    if(speedZero == ">0km/h"){
        df_sub$Speed <- as.numeric(df_sub$Speed)
        df_sub <- subset(df_sub, Speed > 0)
    }

    return(df_sub)

}
