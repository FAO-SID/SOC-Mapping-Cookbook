library(raster)

soilmap <- shapefile("raw-data/MKD_SoilMappingUnitsMap/MK_Soil_20160113.shp")


pos <-  regexpr('/', soilmap$Symbol)
pos[pos<0] <- NA

changed = substr(soilmap$Symbol, 1, pos-1)

soilmap$Symbol[!is.na(changed)] <- changed[!is.na(changed)]

# names(soilmap@data)
#
# soilmap@data <- soilmap@data[, 8]

soilmap <- spTransform(soilmap, CRS("+init=epsg:4326"))

shapefile(soilmap, "MK_soilmap_simple.shp")
