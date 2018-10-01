#' Simulate DEMs based on a semi-variogram
#'
#' \code{demsimulation} returns simulated DEMs
#'
#' @param DEM raster: The raster to make simulations from.This should
#'   be projected. It is advised to set water bodies to NA using a water mask
#'   (e.g Pekel et al., 2016). See Hawker et al., 2018 for guidance.
#' @param sv Semi-variogram set to use. Either 'MERIT' or 'SRTM'
#' @param lc Landcover type. Use names(MERIT_Avg_LC) to see list of options
#' @param maxdist number(optional): from the gstat package to consider only
#'   observations within a distance of maxdist from the target_raster location
#'   are used for prediction or simulation. Default = 0.01
#' @param nsim number(optional): Number of simulations. Default = 10
#' @param debuglevel (optional)  Useful values for debug.level: 0: suppres any output except warning and error messages; 1:
#' normal output (default): short data report, program action and mode, program progress in %, total
#' execution time; 2: print the value of all global variables, all files read and written, and include
#' source file name and line number in error messages; 4: print OLS and WLS fit diagnostics; 8: print
#' all data after reading them; 16: print the neighbourhood selection for each prediction location; 32:
#' print (generalised) covariance matrices, design matrices, solutions, kriging weights, etc.; 64: print
#' variogram fit diagnostics (number of iterations and variogram model in each iteration step) and
#' order relation violations (indicator kriging values before and after order relation correction); 512:
#' print block (or area) discretization data for each prediction location. To combine settings, sum their
#' respective values. Negative values for debug.level are equal to positive, but cause the progress
#' counter to work
#' @return Simulated Rasters: In the form of a raster stack
#' @export
demsimulation <- function(DEM, sv='MERIT',lc='Overall', maxdist=0.01, nsim=10, debuglevel=-1) {
  #Read in data to use
  #data("MERIT_semi_variograms_NoNugget_Threshold90")
  #Convert target raster to dataframe
  if (missing(DEM))
    stop("Raster to simulate missing")
  target_dem_df <- raster::as.data.frame(DEM, xy = TRUE, na.rm = TRUE)  #Data frame with simulation locations
  names(target_dem_df) <- c("X", "Y", "MERIT_Z")  # Rename
  # Read in model to use
  # Read in model to use
  if (sv == 'MERIT'){
    model <- MERIT_Avg_LC
    print('Using MERIT Semi-variograms')
  }else if (sv == 'SRTM'){
    model <- SRTM_Avg_LC
    print('Using SRTM Semi-variograms')
  } else {
    stop('Specify MERIT or SRTM')}
  if (missing(model))
    stop("Missing Semi-variogram")
  if (missing(lc)) message('Setting lc to Overall (Average floodplain semivariogram)')
  modelselect <- model[[lc]] #select model
  if (is.null(modelselect))
    stop("No such landcover type. Please reselect")
  print(paste0('Using ',lc,' semi-variograms'))
  # set max dist
  if (missing(maxdist)) message('Setting maxdist to 0.01')
  #maxdist = 0.01
  #maxdist = maxdist #set default as 0.01
  # set number of simulations
  if (missing(nsim))  message('Setting nsim to 10')
  #nsim = 10#set default as 10
  #nsim = nsim
  # Generate gstat object
  gobj <- gstat(formula = MERIT_Z ~ 1, locations = ~X + Y, dummy = TRUE, beta = 1, model = modelselect, maxdist = maxdist)
  # Simulate
  sims <- predict(gobj, newdata = target_dem_df, nsim = nsim, na.action = "na.exclude",debug.level=debuglevel)
  #Add simulations to target rasters
  simDEM <- raster::stack()
  for (i in 1:nsim)
  {simxy <- sims[c('X','Y',paste0('sim',i))] #Read in xyz of simulations
  simraster <- rasterFromXYZ(simxy) #Generate raster from xyz
  simraster <- simraster+DEM #Add simulations to target raster
  simDEM <- raster::stack(simDEM,simraster) #create a raster stack of simulated DEMs
  }
  return(simDEM)
}

