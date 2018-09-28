#' Download CCI Landcover data
#'
#' \code{download.CCI} Downloads CCI Landcover map into temporary directory
#'
#' @param targetDEM : DEM that will be simulated.
#' @return Global CCI Landcover map
#' @export
download.CCI <- function(targetDEM)
  {
  if (missing(targetDEM))
    stop("No DEM to simulate selected")
  downloadurl <- 'ftp://geo10.elie.ucl.ac.be/v207/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2000-v2.0.7.tif'
temp <- tempfile()
download.file(downloadurl,temp,mode='wb')
lcmap_ras <- raster::raster(temp)
ex<- raster::extent(targetDEM)
lcmap_rascrop <- raster::crop(lcmap_ras,ex) #Crop CCI
CCI <-raster::resample(lcmap_rascrop,targetDEM,method='ngb')
return (CCI)
}
