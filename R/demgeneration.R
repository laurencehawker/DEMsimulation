
#' Simulate DEMs based on a semi-variogram
#'
#' \code{demgeneration} returns simulated DEMs
#'
#' @param target_raster raster: The raster to make simulations from.This should
#'   be projected. It is advised to set water bodies to NA using a water mask
#'   (e.g Pekel et al., 2016). See Hawker et al., 2018 for guidance.
#' @param sv_model variogramModel: Select one from the pre-computed options
#'   using modelselect or create your own
#' @param maxdist number(optional): from the gstat package to consider only
#'   observations within a distance of maxdist from the target_raster location
#'   are used for prediction or simulation. Default = 0.01
#' @param nsim number(optional): Number of simulations. Default = 10
#' @return Simulated Rasters: In the form of a raster stack
#' @export
demgeneration <- function(target_raster, sv_model, maxdist=0.01, nsim=10) {
    #Read in data to use
    #data("MERIT_semi_variograms_NoNugget_Threshold90")
    #Convert target raster to dataframe
    if (missing(target_raster))
        stop("Raster to simulate missing")
    target_dem_df <- raster::as.data.frame(target_raster, xy = TRUE, na.rm = TRUE)  #Data frame with simulation locations
    names(target_dem_df) <- c("X", "Y", "MERIT_Z")  # Rename
    # Read in model to use
    model <- vgm_sum_fit
    if (missing(model))
        stop("Missing Semi-variogram")
    # set max dist
    if (missing(maxdist)) message('Setting maxdist to 0.01')
    #maxdist = 0.01
    #maxdist = maxdist #set default as 0.01
    # set number of simulations
    if (missing(nsim))  message('Setting nsim to 10')
    #nsim = 10#set default as 10
    #nsim = nsim
    # Generate gstat object
    gobj <- gstat(formula = MERIT_Z ~ 1, locations = ~X + Y, dummy = TRUE, beta = 1, model = model, maxdist = maxdist)
    # Simulate
    sims <- predict(gobj, newdata = target_dem_df, nsim = nsim, na.action = "na.exclude",debug.level=-1)
    #Add simulations to target rasters
    simDEM <- raster::stack()
for (i in 1:nsim)
{simxy <- sims[c('X','Y',paste0('sim',i))] #Read in xyz of simulations
simraster <- rasterFromXYZ(simxy) #Generate raster from xyz
simraster <- simraster+target_raster #Add simulations to target raster
simDEM <- raster::stack(simDEM,simraster) #create a raster stack of simulated DEMs
}
   return(simDEM)
}

