# OPEN VERSION

library(shiny)
library(viridisLite)
library(dplyr)
library(DT)
library(markdown)
library(raster)
library(plotfunctions)
library(sf)
library(sortable)


# table summarising covariates for each district
# added a column here for product of k13 average and uncertainty
district_attributes = read.csv("district_summary.csv")
# district_attributes$prodk13mediank13sd = district_attributes$k13median * district_attributes$k13sd
# use shp_index column for district lookup (with reference to the shp object)


# table associating each pixel in raster with a district:
#   this operation is completed using the location of the pixel's centroid,
#   rather than the district which contains the *majority* of the pixel, which
#   is the rule used by raster::mask ... I think ...
#   as a result, some pixels are not included in summaries in district_attributes,
#   which was created using raster::mask
pix_to_distrix = read.csv("pix_to_distrix_nonempty.csv")
# (this table was more relevant when we were looking at pixel feasibility as a condition
# for including districts)

# read in district shapes for plotting
# (shapefile not attached to remote repo)
ind_shp = st_read("districts")

ind_shp <- ind_shp[district_attributes$shp_index,] %>%
  cbind(district_attributes) %>%
  dplyr::select(-c(District, STATE, REMARKS)) %>%
  st_simplify(dTolerance = )

####################

# lookup list for variables involved in filtering
filter_variables = list(access="Accessibility",
                        hpop="Human Population Density",
                        temp_suitability="Pf Temperature Suitability",
                        parasite_rate="Pf Parasite Rate",
                        spmedian="Dhps Median",
                        spsd="Dhps SD",
                        k13median="K13 Median",
                        k13sd="K13 SD"
                        # (removing data not to be released)
                        # api="Annual Parasite Index",
                        # afi="Annual Falciparum Index",
                        # spr="Slide Positivity Rate",
                        # sfr="Slide Pf Rate",
                        # pfpc="Pf Percentage",
                        )


npal <- 100
# {png("covt_summary_districts.png",
#     width=2000,
#     height=2200,
#     pointsize=50)
# par(mfrow=c(3, 3),
#     mar=c(0.1,0.1,2.1,4.1), bty="n")
# for (i in 1:1){
#   var <- names(filter_variables)[i]
#   plot(trim(ind_map), col="grey80", legend = F, main = filter_variables[var],
#        xlab = "", ylab = "", xaxt = "n", yaxt = "n")
#   if (var != "hpop"){
#     cols <- district_attributes[, var] %>%
#       cut(breaks = npal) %>%
#       as.numeric()
#     plot(st_geometry(ind_shp),
#          col = viridis(npal)[cols],
#          border = NA, add = TRUE)
#   } else { 
#     # special case for hpop because it was logged
#     tmp = 10**district_attributes[,names(filter_variables)[i]] - 0.01
#     plot(ind_shp[names(filter_variables)[i]],
#          col = viridis(100)[as.numeric(cut(tmp, breaks=100))],
#          border=NA, add=TRUE)
#   }
# 
#   # okay the legend is MIA
# }
# dev.off()}

to_plot <- ind_shp %>%
  pivot_longer(cols = access:k13sd) %>%
  filter(name %in% names(filter_variables)) %>%
  mutate(name = unlist(filter_variables[name])) %>%
  st_as_sf()

ggplot(to_plot) +
  geom_sf(aes(fill = value)) +
  facet_wrap(~name) +
  scale_fill_viridis_c()

ggsave()

# 
# # ignore warning about NaNs ... comes from logging the logged hpop
# # should rectify that at some point
# {png("covt_summary_districts_log.png",
#     width=2000,
#     height=2200,
#     pointsize=50)
# par(mfrow=c(ceiling(length(filter_variables)/3), 3),
#     mar=c(0.1,0.1,2.1,4.1), bty="n")
# for (i in 1:length(filter_variables)){
#   plot(trim(ind_map), col="grey80", legend=F, main=unlist(filter_variables)[i],
#        xlab="", ylab="", xaxt="n", yaxt="n")
#   if (i != 2){
#     plot(ind_shp[names(filter_variables)[i]],
#          col = viridis(100)[as.numeric(cut(log10(district_attributes[,names(filter_variables)[i]] + 0.0000000001),
#                                            breaks=100))],
#          border=NA, add=TRUE)
#   } else {
#     plot(ind_shp[names(filter_variables)[i]],
#          col = viridis(100)[as.numeric(cut(district_attributes[,names(filter_variables)[i]],
#                                            breaks=100))],
#          border=NA, add=TRUE)
#   }
# 
# }
# dev.off()}






