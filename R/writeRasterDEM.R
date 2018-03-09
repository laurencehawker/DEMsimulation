
#' Save Simulated DEM
#'
#' \code{writeRasterDEM} returns simulated DEMs
#'
#' @param DEMStack rasterStack: Raster stack of simulated DEMs
#' generated using demgeneration
#' @return Simulated Rasters: In the form of indidual rasters
#' @export

writeRasterDEM <- function(DEMStack,filename="",format="GTiff"){
  if (missing(DEMStack))
    stop("Raster Missing")
  raster::unstack(DEMStack)
  outputnames <- paste(seq_along(DEMStack))
  for(i in seq_along(d2)){raster::writeRaster(d2[[i]], file=paste0(filename,outputnames2[i]), format=format,overwrite=TRUE)}
}
