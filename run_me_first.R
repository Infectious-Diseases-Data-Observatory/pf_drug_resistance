# OPEN VERSION

library(shiny)
library(viridisLite)
library(tidyverse)
library(DT)
library(markdown)
library(terra)
#library(plotfunctions)
library(sf)
library(sortable)
library(cowplot)
library(leaflet)


# table summarising covariates for each district
# added a column here for product of k13 average and uncertainty
district_attributes <- read.csv("district_summary.csv")
# district_attributes$prodk13mediank13sd = district_attributes$k13median * district_attributes$k13sd
# use shp_index column for district lookup (with reference to the shp object)


# table associating each pixel in raster with a district:
#   this operation is completed using the location of the pixel's centroid,
#   rather than the district which contains the *majority* of the pixel, which
#   is the rule used by raster::mask ... I think ...
#   as a result, some pixels are not included in summaries in district_attributes,
#   which was created using raster::mask
pix_to_distrix <- read.csv("pix_to_distrix_nonempty.csv")
# (this table was more relevant when we were looking at pixel feasibility as a condition
# for including districts)

# read in district shapes for plotting
# (shapefile not attached to remote repo)
sf_use_s2(FALSE)
ind_shp = st_read("districts")
ind_shp <- ind_shp[district_attributes$shp_index,] %>%
  cbind(district_attributes) %>%
  dplyr::select(-c(District, STATE, REMARKS)) %>%
  st_simplify(dTolerance = 0.05)

ind_map <- rast("ind_map.grd")

ind_outline <- as.polygons(ind_map)

####################

# lookup list for variables involved in filtering
filter_variables = list(access="Accessibility",
                        hpop="Human Population Density",
                        temp_suitability="Pf Temperature Suitability",
                        parasite_rate="Pf Parasite Rate",
                        spmedian="dhps Median",
                        spsd="dhps SD",
                        k13median="kelch13 Median",
                        k13sd="kelch13 SD",
                        # (removing data not to be released)
                        api="Annual Parasite Index",
                        afi="Annual Falciparum Index",
                        spr="Slide Positivity Rate",
                        sfr="Slide Pf Rate",
                        pfpc="Pf Percentage"
                        )


# npal <- 100
# 
# to_plot <- ind_shp %>%
#   pivot_longer(cols = access:k13sd) %>%
#   filter(name %in% names(filter_variables)) %>%
#   mutate(value = ifelse(name == "hpop", 10**(value - 0.01), value)) %>%
#   mutate(name = unlist(filter_variables[name])) %>%
#   st_as_sf()
# 
# to_plot %>%
#   split(.$name) %>%
#   map(~ ggplot(., aes(fill = value)) +
#         geom_sf(linewidth = 0.1) +
#         facet_wrap(~name) +
#         scale_fill_viridis_c() +
#         theme_bw() +
#         theme(legend.position = "bottom",
#               legend.title = element_blank(),
#               strip.background = element_blank(),
#               legend.key.width = unit(1, "cm"))) %>%
#   cowplot::plot_grid(plotlist = .)
# 
# ggsave("covt_summary_districts.png", height=7.2, width=5, scale = 1.5)
# 
# # # ignore warning about NaNs ... comes from logging the logged hpop
# # # should rectify that at some point
# 
# to_plot <- ind_shp %>%
#   pivot_longer(cols = access:k13sd) %>%
#   filter(name %in% names(filter_variables)) %>%
#   mutate(value = ifelse(name != "hpop", log10(value), value)) %>%
#   mutate(name = unlist(filter_variables[name])) %>%
#   st_as_sf() %>%
#   suppressWarnings()
# 
# to_plot %>%
#   split(.$name) %>%
#   map(~ ggplot(., aes(fill = value)) +
#         geom_sf(linewidth = 0.1) +
#         facet_wrap(~name) +
#         scale_fill_viridis_c() +
#         theme_bw() +
#         theme(legend.position = "bottom",
#               legend.title = element_blank(),
#               strip.background = element_blank(),
#               legend.key.width = unit(1, "cm"))) %>%
#   cowplot::plot_grid(plotlist = .)
# 
# ggsave("covt_summary_districts_log.png", height=7.2, width=5, scale = 1.5)




