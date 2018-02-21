# the "Symbol" attribute from the vector layer will be used for the
# rasterization process. It has to be a factor
soilmap@data$Symbol <- as.factor(soilmap@data$Symbol)

#save the levels names in a character vector
Symbol.levels <- levels(soilmap$Symbol)

# The rasterization process needs a layer with the target grd
# system: spatial extent and cell size.
soilmap.r <- rasterize(x = soilmap, y = DEM, field = "Symbol")
# The DEM raster layer could be used for this.

plot(soilmap.r, col=rainbow(21))
legend("bottomright",legend = Symbol.levels, fill=rainbow(21),
       cex=0.5)
