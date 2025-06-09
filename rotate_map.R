# creates a local oblique Mercator projection that rotates maps to a specified rotation angle. Make sure to use the same angle when adding a North arrow on maps (e.g., using `tm_compass()` in the `tmap` environment)

library(sf)

crs_rotated = function(x, angle_deg){
  x_centroid = st_centroid(st_union(x))
  x_centroid = st_transform(x_centroid, crs=4326)
  lon = st_coordinates(x_centroid)[,1]
  lat = st_coordinates(x_centroid)[,2]
  return(paste0("+proj=omerc +lat_0=",
               lat,
               " +lonc=",
               lon,
               " +alpha=0 +gamma=",
               angle_deg,
               " +k=1 +datum=WGS84 +units=m +no_defs")
  )
}



