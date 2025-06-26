# Take any `sf` object (polygon or polyline) -- in this case, Bogota's localidades -- and a desired rotation angle -- in this case, 270 degrees

library(osmdata)
library(sf)
library(dplyr)
library(stringr)
library(smoothr)
library(tmap)

## bounding box from OSM
bogota_bb = getbb('Bogota')

## localidades names and boundaries
bogota = st_read('bogota_localidades.gpkg') |>
  mutate(LocNombre = str_to_title(LocNombre))

## roads
roads = bogota_bb |> 
  opq() |> 
  add_osm_feature('highway', c('motorway', 'primary', 'secondary')) |> 
  osmdata_sf() |> 
  _$osm_lines |> st_transform(crs = 3116) |>
  st_cast('LINESTRING') |>
  smooth(method = 'ksmooth', smoothness = 5)

## a selection of roads for labeling
roads_primary = filter(roads, highway=='primary' & !is.na(name))
set.seed(20)
roads_selection = roads[sample(nrow(roads_primary), 10),]

## ciclovia
ciclovia = st_read('ciclovia.gpkg') |>
  smooth(method = 'ksmooth', smoothness = 5)

## desired angle for the orientation of the map
angle = 270

## creating string with ad-hoc oblique Mercator projection
source('rotate_map.R')
proj_string = crs_rotated(bogota, 270)

# Plug the resulting string into a map using any mapping package

png('bogota_ciclovia.png', width = 2100, height = 1080, res = 300)
(map = tm_shape(roads) +
    tm_lines(col = 'darkgray', lwd = .75, col_alpha = .5) +
    tm_shape(roads_selection) +
    tm_labels('name',
              col = 'darkgray',
              size = .375,
              options = opt_tm_labels(remove_overlap = TRUE)) +
    tm_shape(ciclovia) +
    tm_lines(
      col = 'INDICATIVO',
      col.scale = tm_scale_ordinal(values = 'met.homer1'),
      lwd = 2,
      col.legend = tm_legend(
        title = 'TRAMO',
        position = tm_pos_in('left', 'top')
      )
    ) +
    tm_shape(bogota) +
    tm_text(text = 'LocNombre', size = .5) +
    tm_title('Bogotá\'s Ciclovía by Section (Tramo)') +
    tm_compass(
      north = angle, 
      size = 2,
      text.size = 0.75,
      position = tm_pos_in('right', 'top')
      ) +
    tm_scalebar(breaks = c(0,1,2.5,5,10),
                position = c('center', 'bottom'),
                ) +
    tm_credits(text = '@ferderon.bsky.social. Datos Abiertos Bogotá and
               OpenStreetMap contributors.',
               size = .375,
               just = FALSE,
               frame = TRUE,
               position = c('right', 'bottom')) +
    tm_scale(0.25) + 
    tm_crs(proj_string) +
    tm_shape(bbox = bogota_bb)
)
dev.off()
