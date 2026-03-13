
#' trip_animation
#'
#' 
#' @description Create animation tracking
#'
#' @param BDD_track dataframe with tracking data (columns : DeviceID, Longitudedecimal, Latitudedecimal, Year, Month, Day, Hour, Minute, Second)
#' @param title_anim Title of the animation
#' @param subtitle_anim Subtitle of the animation
#' @param map_res Resolution of the background map.
#' @param n_cores Number of cores to use for parallel processing.
#' @param corresp_tab DataFrame. Correspondence table to change the DeviceID number by the name of individual.
#' 
#' @return Frames object from moveVis package
#'
#' @export NULL
#' 
#' 


trip_animation <- function( BDD_track,
                            title_anim,
                            subtitle_anim,
                            map_res,
                            n_cores,
                            corresp_tab = NULL){
  
  message("Preparing data...")
  # Modify time column
  BDD_track$Timestamp <- as.POSIXct(paste(paste(BDD_track$Year, BDD_track$Month, BDD_track$Day, sep = "-"), 
                                          paste(BDD_track$Hour, BDD_track$Minute, BDD_track$Second, sep = ":"), 
                                          sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  BDD_track$timestamp <- BDD_track$Timestamp
  BDD_track <- BDD_track[ , colnames(BDD_track) != "Timestamp"]

  # Formate DeviceID column
  BDD_track$LON <- as.numeric(BDD_track$Longitudedecimal)
  BDD_track$LAT <- as.numeric(BDD_track$Latitudedecimal)
  legend_title <- "Tag number"

  if(!is.null(corresp_tab)){
    message("Applying correspondence table to DeviceID...")
    BDD_track$DeviceID <- BDD_track$nom_individu
    legend_title <- "Individuals"
  }

  message("Parallel and disk setup...")
  moveVis::use_multicore(n_cores = n_cores)
  
  # Create temporary folder for animation frames
  unlink(here::here("tempfolder"), recursive = TRUE) #remove previous temporary folder if exists
  dir.create(here::here("tempfolder"), showWarnings = FALSE)

  moveVis::use_disk( 
    frames_to_disk = TRUE, 
    dir_frames = here::here("tempfolder"),
    n_memory_frames = 100, 
    verbose = TRUE
  )

  message("Creating move2 object...")
  
  BDD_track <- BDD_track[order(BDD_track$DeviceID, BDD_track$timestamp), ]
  BDD_work <- move2::mt_as_move2( BDD_track, 
                                  coords = c("Longitudedecimal", "Latitudedecimal"), 
                                  crs = sf::st_crs("EPSG:4326"),
                                  time_column = "timestamp", 
                                  track_id_column = "DeviceID", 
                                  track_attributes = "")

  m <- moveVis::align_move(BDD_work, res = units::set_units(3, "hour"))

  message("Creating animation...")

  # Create colors vector
  hues <- seq(1, 360, length.out = length(unique(BDD_track$DeviceID))) 
  path_colours <- hsv(h = hues/360, s = 0.8, v = 0.9)

  frames <- moveVis::frames_spatial(
              m, 
              path_colours = path_colours,
              map_service = "mapbox", 
              map_type = "hybrid", 
              map_res = map_res,
              alpha = 0.5,
              map_token = token_animation
            )

  message("Adding elements to animation...")

  frames <- moveVis::add_labels( frames, 
                        x = "Longitude", 
                        y = "Latitude", 
                        title = title_anim,
                        subtitle = subtitle_anim)
  frames <- moveVis::add_northarrow(frames, height = 0.05, size = 2, position = "upperleft")
  frames <- moveVis::add_scalebar(frames, label_margin = 2) 
  frames <- moveVis::add_timestamps(frames, type = "label")
  frames <- moveVis::add_progress(frames)

  message("Animation frames created!")

  return(frames)

}
