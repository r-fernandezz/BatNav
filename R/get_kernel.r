#' get_kernel_ind
#'
#' @description Calculate kernel individual with CTMM package
#'
#'
#' @param bdd DataFrame. The input data containing GPS coordinates.
#' @param hdop_error Logical. If TRUE, include location error in the model.
#'
#' @return list with deviceID, models and UD for each individual
#'
#' @export shapefiles if you want to export individual kernel shapefiles
#' 
#' 

get_kernel_ind <- function(bdd, hdop_error){

    set.seed(123)

    # Use Timestamp
    bdd$Timestamp <- as.POSIXct(paste(paste(bdd$Year, bdd$Month, bdd$Day, sep = "-"), 
                                            paste(bdd$Hour, bdd$Minute, bdd$Second, sep = ":"), 
                                    sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

    bdd_sub <- bdd[, c("DeviceID", "Longitudedecimal", "Latitudedecimal", "Timestamp", "Hdop")]
    colnames(bdd_sub) <- c("ID", "longitude", "latitude", "timestamp", "HDOP")

    tel <- ctmm::as.telemetry(bdd_sub, projection = "EPSG:2975", datum = "WGS84")

    # Create common grid with resolution of 100 meters and open with raster package (necessary for ctmm package)
    common_grid <- terra::rast( 
                        xmin = 314305, 
                        xmax = 380161, 
                        ymin = 7633645, 
                        ymax = 7692275, 
                        res = 100, 
                        crs = "EPSG:2975",
                        vals = 1
                    )

    terra::writeRaster(
        common_grid,
        filename = here::here("grille_100m_WGS84.tif"),
        filetype = "GTiff",
        overwrite = TRUE
    )
    common_grid <- raster::raster(here::here("grille_100m_WGS84.tif"))
    file.remove(here::here("grille_100m_WGS84.tif"))

    # Create all individual kernel
    k_analysis <- lapply(c(1:length(tel)), function(x){

        tel_sub <- tel[[x]]
        id_tag <- tel[[x]]@info$identity

        message("## Start modeling for individual ", id_tag, " (", x, "/", length(tel), ")")
        svf <- ctmm::variogram(tel_sub)

        # Initialize and found the best model
        message("#### Initialize and found the best model for individual ", id_tag)
        guessMod <- ctmm::ctmm.guess(tel_sub, CTMM = ctmm(error = hdop_error), variogram = NULL, name = "GUESS", interactive = FALSE)
        mod <- ctmm::ctmm.select(tel_sub, guessMod, verbose = FALSE, method = 'pHREML')
        sum_mod <- summary(mod)

        # Calculate kernel to remove bias with common grid
        message("#### Calculate kernel for individual ", id_tag)
        ud <- ctmm::akde(tel_sub, mod, grid = common_grid, debias = TRUE, weights = TRUE)
        sum_ud <- summary(ud)

        return(list(DeviceID = id_tag, bdd.ctmm = tel_sub, models = mod, UDs = ud, svf = svf, sum_mod = sum_mod, sum_ud = sum_ud))

    })

    return(k_analysis)

}

#' get_kernel_mean
#'
#' @description Calculate mean kernel with CTMM package
#'
#'
#' @param k_analysis List. Output from get_kernel_ind function.
#' @param method Character. Method to calculate mean kernel, either "mean" or "pkde". 
#' "mean" use the mean function from ctmm package, "pkde" use the pKDE function from ctmm package.
#'
#' @return Name Variable
#'
#' @export shapefiles if you want to export mean kernel shapefiles


get_kernel_mean <- function(k_analysis, method = "mean"){

    set.seed(123)

    # Mean UD individuals
    ud_list <- lapply(k_analysis, function(x) x$UDs)
    message("#### Calculate kernel with mean model")

    if(method == "mean"){
        message("#### Method : mean")
        ud_mean <- mean(ud_list)
    } else if(method == "pkde") {
        #ud_mean <- ctmm::pkde(k_analysis$bdd.ctmm, ud_list)
    } else {
        stop("Error with method name used, see argument 'method'")
    }

    return(ud_mean)

}

#' get_kernel_plot
#'
#' @description Plot kernels create with get_kernel_ind and get_kernel_mean.
#'
#'
#' @param bdd DataFrame. GPS points used to create the kernel.
#' @param UD UD object. Kernel utput from get_kernel_ind or get_kernel_mean function.
#' @param deviceID Character. Individual ID.
#' @param level.UD Numeric. Level of the UD to plot (for exemple 0.5 or 0.95).
#' @param level.IC Numeric. Confidence level to plot the IC of kernel.
#' @param osm.lvl Numeric. Level of zoom for the OSM background.
#'
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_kernel_plot <- function(bdd = NULL, UD, deviceID = NULL, level.UD = input$kernel_lvl/100, level.IC = 0.95, osm.lvl = 11){

    # Plot with ggplot2 in Rshiny
    ud <- sf::st_as_sf(ctmm::SpatialPolygonsDataFrame.UD(UD, level.UD = level.UD, level = level.IC))

    # Rename levels
    ud$name[grep(ud$name, pattern = "est")] <- paste0("kernel ", level.UD*100, "%")
    ud$name[grep(ud$name, pattern = "low")] <- paste0("kernel ", level.UD*100, "% borne basse")
    ud$name[grep(ud$name, pattern = "high")] <- paste0("kernel ", level.UD*100, "% borne haute")

    if(!is.null(bdd)){
        points_sf <- ctmm::SpatialPointsDataFrame.telemetry(bdd)
        points_sf <- sf::st_as_sf(points_sf, coords = c("longitude", "latitude"), crs = 2975)
    }

    # Create plot
    plot <- ggplot() +
            ggspatial::annotation_map_tile(type = "osm", zoom = osm.lvl)

    if(!is.null(bdd)){
        plot <- plot + 
            geom_sf(data = points_sf, aes(color = "Points GPS"), fill = NA, size = 0.5) +
            scale_color_manual(values = c("Points GPS" = "blue"))
    }

    plot <- plot +
            geom_sf(data = ud[grep(ud$name, pattern = "%$"), ], aes(fill = "kernel"), color = NA, alpha = 0.8) +
            geom_sf(data = ud[grep(ud$name, pattern = "haute"), ], aes(linetype = "Borne haute"), fill = NA, color = "black", alpha = 1) +
            geom_sf(data = ud[grep(ud$name, pattern = "basse"), ], aes(linetype = "Borne basse"), fill = NA, color = "black", alpha = 1) +
            scale_linetype_manual(values = c("Borne haute" = "dashed", "Borne basse" = "solid")) +
            scale_fill_manual(values = c("kernel" = "#ff00dd"), labels = paste("Kernel ", level.UD*100)) +
            guides(
                fill = guide_legend(order = 2, title = NULL),
                color = guide_legend(order = 1, title = NULL),
                linetype = guide_legend(order = 3, title = paste0("IC à ", level.IC*100, "%"))
            ) 
    
    if(!is.null(deviceID)){
        plot <- plot + ggtitle(paste0("Individu n°", deviceID))
    }

    plot <- plot + theme(
                        legend.position = "bottom",
                        axis.line.x.bottom = element_line(),
                        axis.line.y.left = element_line(),
                        axis.text.y = element_text(angle = 90, hjust = 0.5),
                    )

    return(plot)

}
