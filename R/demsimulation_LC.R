#' Simulate DEMs based on a semi-variogram based on landcover
#'
#' \code{demsimulation_LC} returns simulated DEMs
#'
#' @param DEM raster: The raster to make simulations from.This should
#'   be projected. It is advised to set water bodies to NA using a water mask
#'   (e.g Pekel et al., 2016). See Hawker et al., 2018 for guidance.
#' @param LC_map Landcover map generated using download.CCI
#' @param maxdist number(optional): from the gstat package to consider only
#'   observations within a distance of maxdist from the target_raster location
#'   are used for prediction or simulation. Default = 0.01
#' @param nsim number(optional): Number of simulations. Default = 10
#' @return Simulated Rasters: In the form of a raster stack
#' @export
demsimulation_LC <- function(DEM, LC_map, maxdist=0.01, nsim=10) {
  #Read in data to use
  data("cci_lookup")
  data("MERIT_AvgSV_LC")
  #Convert target raster to dataframe
  if (missing(DEM))
    stop("DEM missing")
  target_dem_df <- raster::as.data.frame(DEM, xy = TRUE, na.rm = TRUE)  #Data frame with simulation locations
  names(target_dem_df) <- c("X", "Y", "MERIT_Z")  # Rename
  # Read in model to use
  model <- MERIT_Avg_LC
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
  #Set Water as NA in Landover
  CCI <- LC_map
  if (missing(CCI))
    stop("Missing Landcover Map")
  CCI[CCI==210] <- NA #Set water to NA
#Find out the landcover Types involved
  veg <- freq(CCI) ##Count cells of unique values
  veg <- data.frame(veg) #Get into a dataframe
  veg_to_analyse <- as.numeric(na.omit(veg[,1])) #Takes away any NA land class
  vegdf<-data.frame(veg_to_analyse) #veg to analyse as dataframe
  vegdf$name<-cci_lookup$LCCOwnLabel[match(vegdf$veg,cci_lookup$NB_LAB)] #Add new coloumn with names
  veg_names<-as.character(vegdf[,2]) #extract names of landcover
#Find index of Landcover matches in semi-variogram list
  sv_names <- names(model) #Get character vector of Landcover types in avg sv list
  sv_index <- match(veg_names,sv_names) #Get index of avg sv list that matches Lnadcover types in target raster
  sv_index[is.na(sv_index)] <- 1 # If no match use the overall average which is number 1 in list

    #Now to simulate

  simDEM <- raster::stack()

    veg_to_predict <- veg_to_analyse[i] #CCI number
    MERIT_veg_to_analyse <- overlay(DEM, CCI, fun = function(x, y) {
      x[y!=veg_to_predict] <- NA
      return(x)
    }) # Selects only MERIT Z that is within CCI

    target_dem_df <- as.data.frame(MERIT_veg_to_analyse, xy=TRUE, na.rm = TRUE) #Data frame with simulation locations
    names(target_dem_df) <- c('X','Y','MERIT_Z') # Rename
    #Note: Maybe change to target_dem_processed which excludes the water masked pixels

    #Select sv to use
    model <- model[[sv_index[i]]] #select which sv model to use

    #Generate gstat object
    gobj <- gstat(formula = MERIT_Z ~ 1, locations = ~ X + Y, dummy = TRUE,
                  beta = 1, model = model, maxdist = maxdist)

    #Predict simulations
    sims <- predict(gobj, newdata = target_dem_df, nsim = nsim, na.action = 'na.exclude',debug.level=-1)

    for (j in 1:nsim){
      simxy <- sims[c('X','Y',paste0('sim',j))] #Read in xyz of simulations
      simraster <- raster(DEM) 		# create empty raster
      cells <- cellFromXY(simraster, simxy[,1:2]) # compute cell numbers
      simraster[cells] <- simxy[,3] #Put in Heights from simulation
      names(simraster) <- paste0('Sim ',j) #Change raster name for stack
      simDEM <- raster::stack(simDEM,simraster) #create a raster stack of simulations
    }

  #Combine to make simulated Rasters

  simDEM_overall <- raster::stack() #Empty rasterstack
  DEM_Result <- stack() # Empty Raster Stack for simulated DEMs
  for (i in 1:nsim){
    simDEM_select <- seq(from=i,length.out=length(veg_to_analyse),by=nsim) #Generate vector to extract
    rsub <- subset(simDEM, simDEM_select) #Subset raster stack to cover all landcover types
    sim_overall <- overlay(rsub, fun=function(x){ mean(x[x!=0],na.rm=T)}) # Combine all landcover types
    simDEM_overall <- stack(simDEM_overall,sim_overall) # Create raster stack of simulations
    Simulated_DEM <- sim_overall+MERIT #Adds simulation to MERIT
    DEM_Result <- stack(DEM_Result,Simulated_DEM) # Creates raster stack of Resultant DEM
  }
  return(DEM_Result)
}

