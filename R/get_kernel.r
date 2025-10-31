#' get_data_eval
#'
#' @description Create list to evaluate data before creating mouvement models
#'
#'
#' @param bdd DataFrame. The input data containing GPS coordinates.
#' @param corresp_tab DataFrame. Correspondence table for DeviceID and individual names.
#'
#' @return Name Variable
#'
#' @export 


get_data_eval <- function(bdd, corresp_tab = NULL){

    # Use Timestamp
    bdd$Timestamp <- as.POSIXct(paste(paste(bdd$Year, bdd$Month, bdd$Day, sep = "-"), 
                                            paste(bdd$Hour, bdd$Minute, bdd$Second, sep = ":"), 
                                    sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

    # Stock the number of individuals for later if you work with one individual only
    number_ind <- unique(bdd$DeviceID)

    bdd_sub <- bdd[, c("DeviceID", "Longitudedecimal", "Latitudedecimal", "Timestamp", "Hdop")]
    colnames(bdd_sub) <- c("ID", "longitude", "latitude", "timestamp", "HDOP")

    tel <- ctmm::as.telemetry(bdd_sub, projection = "EPSG:2975", datum = "WGS84")
    
    # Check if list of individuals or only one individual
    dimTel <- dim(tel) 
    if(is.null(dimTel)){ # if NULL list of individuals
        step <- c(1:length(tel))
    }else {
        step <- 1 # only one individual
    }

    # Create several plot by 
    viz_data <- lapply(step, function(x){

        if(is.null(dimTel)){
            tel_sub <- tel[[x]]
            id_tag <- tel[[x]]@info$identity
            nb_all <- length(tel)
        }else {
            tel_sub <- tel
            id_tag <- number_ind
            nb_all <- 1
        }

        if(!is.null(corresp_tab)){
            id_tag <- corresp_tab[corresp_tab$DeviceID == id_tag, "nom_individu"] # get the individual name
        }

        # Create variogram
        message("## Start plot creation for individual ", id_tag, " (", x, "/", nb_all, ")")
        svf <- ctmm::variogram(tel_sub)

        # Create periodogram
        prdg <- ctmm::periodogram(tel_sub)

        return(list(DeviceID = id_tag, bdd.ctmm = tel_sub, svf = svf, prdg = prdg))

    })

    return(viz_data)

}

#' get_moveMod
#'
#' @description Calculate movement models with CTMM package
#'
#'
#' @param bdd DataFrame. The input data containing GPS coordinates.
#' @param hdop_error Logical. If TRUE, include location error in the model.
#' @param corresp_tab DataFrame. Correspondence table to change the DeviceID number by the name of individual.
#'
#' @return list with deviceID, models and UD for each individual
#'
#' @export shapefiles if you want to export individual kernel shapefiles
#' 
#' 

get_moveMod <- function(bdd, hdop_error, corresp_tab = NULL){

    set.seed(123)

    # Use Timestamp
    bdd$Timestamp <- as.POSIXct(paste(paste(bdd$Year, bdd$Month, bdd$Day, sep = "-"), 
                                            paste(bdd$Hour, bdd$Minute, bdd$Second, sep = ":"), 
                                    sep = " "), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

    # Stock the number of individuals for later if you work with one individual only
    number_ind <- unique(bdd$DeviceID)

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

    # Check if list of individuals or only one individual
    dimTel <- dim(tel) 
    if(is.null(dimTel)){ # if NULL list of individuals
        step <- c(1:length(tel))
    }else {
        step <- 1 # only one individual
    }

    # Create all individual kernel
    k_analysis <- lapply(step, function(x){

        if(is.null(dimTel)){
            tel_sub <- tel[[x]]
            id_tag <- tel[[x]]@info$identity
            nb_all <- length(tel)
        }else {
            tel_sub <- tel
            id_tag <- number_ind
            nb_all <- 1
        }

        if(!is.null(corresp_tab)){
            id_tag <- corresp_tab[corresp_tab$DeviceID == id_tag, "nom_individu"] # get the individual name
        }

        message("## Start modeling for individual ", id_tag, " (", x, "/", nb_all, ")")
        svf <- ctmm::variogram(tel_sub)

        # Initialize and found the best model
        message("#### Initialize and found the best model for individual ", id_tag)
        guessMod <- ctmm::ctmm.guess(tel_sub, CTMM = ctmm(error = hdop_error), variogram = NULL, name = "GUESS", interactive = FALSE)
        mod <- ctmm::ctmm.select(tel_sub, guessMod, verbose = FALSE, method = 'pHREML')
        sum_mod <- summary(mod)

        # Calculate kernel to remove bias with common grid
        message("#### Calculate kernel for individual ", id_tag)
        ud <- ctmm::akde(tel_sub, mod, grid = common_grid, debias = TRUE, weights = TRUE, dt.plot = FALSE)
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
#' @param k_analysis List. Output from get_moveMod function.
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
        ud_mean <- mean(ud_list, sample = TRUE)
    } else if(method == "pkde") {
        #ud_mean <- ctmm::pkde(k_analysis$bdd.ctmm, ud_list)
    } else {
        stop("Error with method name used, see argument 'method'")
    }

    return(ud_mean)

}

#' get_kernel_plot
#'
#' @description Plot kernels create with get_moveMod and get_kernel_mean functions.
#'
#'
#' @param bdd DataFrame. GPS points used to create the kernel.
#' @param UD UD object. Kernel utput from get_moveMod or get_kernel_mean function.
#' @param deviceID Character. Individual ID.
#' @param level.UD Numeric. Level of the UD to plot (for exemple 50 or 95).
#' @param level.IC Numeric. Confidence level to plot the IC of kernel.
#' @param osm.lvl Numeric. Level of zoom for the OSM background.
#'
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_kernel_plot <- function(bdd = NULL, UD, deviceID = NULL, level.UD, level.IC = 0.95, osm.lvl){

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
        plot <- plot + ggtitle(paste0("Individu ", deviceID))
    }

    plot <- plot + theme(
                        legend.position = "bottom",
                        axis.line.x.bottom = element_line(),
                        axis.line.y.left = element_line(),
                        axis.text.y = element_text(angle = 90, hjust = 0.5),
                    )

    return(plot)

}


#' get_locKer_plot
#'
#' @description Together plot of all individual kernels create with get_moveMod function.
#'
#'
#' @param k_analysis List. Output from get_moveMod function.
#' @param level.UD Numeric. Level of the UD to plot (for exemple 50 or 95).
#' @param level.IC Numeric. Confidence level to plot the IC of kernel.
#' @param osm.lvl Numeric. Level of zoom for the OSM background.
#' 
#' @return ggplot object
#'
#' @export NULL
#' 
#' 

get_locKer_plot <- function(k_analysis, level.UD, level.IC = 0.95, osm.lvl) {

    list_ud <- lapply(k_analysis, function(x) {x$UDs})
    deviceID <- sapply(k_analysis, function(x) {x$DeviceID})
    col <- ctmm::color(list_ud, by = "individual")

    # Create list by kernel and IC
    sf_kernel <- do.call(rbind, lapply(seq_along(list_ud), function(i){

        ud <- sf::st_as_sf(ctmm::SpatialPolygonsDataFrame.UD(list_ud[[i]], level.UD = level.UD, level = level.IC))
        ud$name[grep(ud$name, pattern = "est")] <- paste0("kernel ", level.UD*100, "%")

        ud_mean <- ud[grep(ud$name, pattern = "%$"), ]
        ud_mean$deviceID <- deviceID[i] #add deviceID column for ggplot aes fill
        ud_mean

    }))

    # sf_ic_low <- do.call(rbind, lapply(seq_along(list_ud), function(i){

    #     ud <- sf::st_as_sf(ctmm::SpatialPolygonsDataFrame.UD(list_ud[[i]], level.UD = level.UD, level = level.IC))
    #     ud$name[grep(ud$name, pattern = "low")] <- paste0("kernel ", level.UD*100, "% borne basse")

    #     ud[grep(ud$name, pattern = "basse"), ]

    # }))

    # sf_ic_high <- do.call(rbind, lapply(seq_along(list_ud), function(i){

    #     ud <- sf::st_as_sf(ctmm::SpatialPolygonsDataFrame.UD(list_ud[[i]], level.UD = level.UD, level = level.IC))
    #     ud$name[grep(ud$name, pattern = "high")] <- paste0("kernel ", level.UD*100, "% borne haute")

    #     ud[grep(ud$name, pattern = "haute"), ]

    # }))

    plot <- ggplot() +
            ggspatial::annotation_map_tile(type = "osm", zoom = osm.lvl) +
            geom_sf(data = sf_kernel, fill = NA, aes(color = deviceID), linewidth = 1, alpha = 0.8) +
            #geom_sf(data = sf_ic_high, aes(linetype = "Borne haute"), fill = NA, color = col, alpha = 1) +
            #geom_sf(data = sf_ic_low, aes(linetype = "Borne basse"), fill = NA, color = col, alpha = 1) +
            #scale_linetype_manual(values = c("Borne haute" = "dashed", "Borne basse" = "solid")) +
            scale_color_manual(values = col) +
            guides(
                fill = guide_legend(order = 2, title = NULL),
                color = guide_legend(order = 1, title = NULL),
                linetype = guide_legend(order = 3, title = paste0("IC à ", level.IC*100, "%"))
            ) + theme(
                        legend.position = "bottom",
                        axis.line.x.bottom = element_line(),
                        axis.line.y.left = element_line(),
                        axis.text.y = element_text(angle = 90, hjust = 0.5),
                    )

    return(plot)

}

#' get_surfKer_plot
#'
#' @description Calculate surface kernel plot with CTMM package
#'
#'
#' @param k_analysis List. Output from get_moveMod function.
#' @param level.UD Numeric. Level of the UD to plot (for exemple 50 or 95).
#' @param level.IC Numeric. Confidence level to plot the IC of kernel.
#' 
#' @return ctmm plot
#'
#' @export NULL
#' 
#' 

get_surfKer_plot <- function(k_analysis, level.UD, level.IC = 0.95){  

    list_ud <- lapply(k_analysis, function(x) {x$UDs})
    deviceID <- sapply(k_analysis, function(x) {x$DeviceID})

    # Change number ID by the name of individual
    list_ud <- lapply(1:length(list_ud), function(x) {
        list_ud[[x]]@info$identity <- deviceID[x]
        return(list_ud[[x]])
    })

    ctmm::meta(   
                list_ud,
                col = "black",
                level.UD = level.UD,
                level = level.IC,
                verbose = TRUE,
                sort = TRUE,
                mean = TRUE
            )
}
