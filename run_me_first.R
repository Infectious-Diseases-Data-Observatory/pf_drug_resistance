library(shiny)
library(viridisLite)
library(dplyr)
library(DT)
library(markdown)
library(raster)
library(plotfunctions)
library(sf)
library(sortable)

# new outputs from Jen
# setwd("~/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/Jen-Lucy share folder (pf)")
# raster_folder <- "raster for app/modelling rasters (May 2023)/"
# 
# mess_around_readin = function(from, to){
#   to$band1 = from$band1
#   return(to$band1)
# }
# 
# k13median=readGDAL(paste0(raster_folder,"Resistance_median_2021_K13.flt")) %>%
#   mess_around_readin(indapp_covs$access)
# k13sd=readGDAL(paste0(raster_folder, "Resistance_sd_2021_K13.flt")) %>%
#   mess_around_readin(indapp_covs$access)
# spmedian=readGDAL(paste0(raster_folder, "Resistance_median_2021_dhps540.flt")) %>%
#   mess_around_readin(indapp_covs$access)
# spsd=readGDAL(paste0(raster_folder, "Resistance_sd_2021_dhps540.flt")) %>%
#   mess_around_readin(indapp_covs$access)
# 
# tmp = stack(k13median, k13sd, spmedian, spsd)
# names(tmp) = c("k13median", "k13sd", "spmedian", "spsd")
# 
# indapp_covs$k13median = tmp$k13median
# indapp_covs$k13sd = tmp$k13sd
# indapp_covs$spmedian = tmp$spmedian
# indapp_covs$spsd = tmp$spsd
# 
# # save this with the app ...
# writeRaster(indapp_covs,
#             paste0(getwd(),"/shinyapp_May2023/indapp_covs"),
#             overwrite=TRUE)

# read in covariate rasters and transform human pop for visualisation
indapp_covs = stack("indapp_covs.grd")
indapp_covs$hpop = log10(indapp_covs$hpop+0.01)
ind_map = raster("ind_map.grd")
#indapp_covs$access = 1/(indapp_covs$access + 1)


# table summarising covariates for each district
# added a column here for product of k13 average and uncertainty
district_attributes = read.csv("district_summary.csv")
# district_attributes$prodk13mediank13sd = district_attributes$k13median * district_attributes$k13sd
# use shp_index column for district lookup (with reference to the shp object)

###############################################################################
# Code chunk joining district-wise summary of model outs and covts with added
# district-wise Pf case data, writing back to district_summary.csv
# NAs signify districts missing from Pf case dataset.

# # read in Pf case data:
# pf_case = read.csv("districts_pf_2018.csv")
# pf_case = pf_case[-which(pf_case$District == "MAHE"),] # Mahe ended up excluded earlier .. too small
# 
# # extend district_attributes table
# tmp = names(district_attributes)
# district_attributes = cbind(district_attributes,
#                             matrix(NA, nrow=nrow(district_attributes), ncol=5))
# names(district_attributes) = c(tmp, "pfpc", "api", "afi", "spr", "sfr")
# 
# # there are some duplicated district names across different states
# # (i.e. not true duplicates, but require an additional joining column)
# duplicated_district_names = unique(c(pf_case$District[duplicated(pf_case$District)],
#                               district_attributes$district[duplicated(district_attributes$district)]))
# # perform the join
# tab_link = sapply(1:nrow(pf_case), function(i){
#   if (pf_case$District[i] %in% duplicated_district_names){
#     message(i)
#     return(which(district_attributes$district == pf_case$District[i] & district_attributes$state == toupper(pf_case$State[i]))      )
#   }
#   else {return(which(district_attributes$district == pf_case$District[i]))}
# })
# 
# # fill out our new columns in district_attributes
# district_attributes[unlist(tab_link),
#                     c("pfpc", "api", "afr", "spr", "sfr")] = pf_case[, c("PFpc", "API", "AFI", "SPR", "SFR")]
# 
# # and write!
# write.csv(district_attributes, "district_summary.csv")
###############################################################################

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
setwd("/Users/harrisonl2/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/Jen-Lucy share folder (pf)/shiny_app_May1")
ind_shp = st_read("districts") # may be error if not written elsewhere
ind_shp = ind_shp[district_attributes$shp_index,]
ind_shp = cbind(ind_shp, district_attributes)
ind_shp = subset(ind_shp, select= -c(District, STATE, REMARKS))
setwd("/Users/harrisonl2/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/Jen-Lucy share folder (pf)/shinyapp_May2023")

# some example starting threshold values for the app - edit these if you would like
# to start somewhere different ...
# jens_thresholds = list(access = 3161,
#                        hpop = log10(120),
#                        parasite_rate = 0.001,
#                        temp_suitability = 0.4,
#                        spmedian = 0.075,
#                        spsd = 0.275,
#                        k13median = 0.03,
#                        k13sd = 0.05)
# extreme_thresholds = list(access = maxValue(indapp_covs$access),
#                           hpop = minValue(indapp_covs$hpop),
#                           parasite_rate = minValue(indapp_covs$parasite_rate),
#                           temp_suitability = minValue(indapp_covs$temp_suitability),
#                           spmedian = minValue(indapp_covs$spmedian),
#                           spsd = minValue(indapp_covs$spsd),
#                           k13median = minValue(indapp_covs$k13median),
#                           k13sd = minValue(indapp_covs$k13sd))

# change this line if you would like to start with different thresholds ...
# init_thresholds = extreme_thresholds

####################

# lookup list for variables involved in filtering
filter_variables = list(api="Annual Parasite Index",
                        afi="Annual Falciparum Index",
                        spr="Slide Positivity Rate",
                        sfr="Slide Pf Rate",
                        pfpc="Pf Percentage",
                        access="Accessibility",
                        hpop="Human Population Density",
                        temp_suitability="Pf Temperature Suitability",
                        parasite_rate="Pf Parasite Rate",
                        spmedian="Dhps Median",
                        spsd="Dhps SD",
                        k13median="K13 Median",
                        k13sd="K13 SD")

# run this if we update the input data for the app:
# summary plots that end up on the last tab of the app
# (also run for log)
png("covt_summary_districts_log.png",
    width=2000,
    height=3000,
    pointsize=50)
par(mfrow=c(ceiling(length(filter_variables)/3), 3),
    mar=c(0.1,0.1,2.1,4.1), bty="n")
#par(mfrow=c(1,1), mar=c(5.1,5.1,5.1,5.1))
for (i in 1:length(filter_variables)){
  plot(trim(ind_map), col="grey80", legend=F, main=unlist(filter_variables)[i],
       xlab="", ylab="", xaxt="n", yaxt="n")
  plot(ind_shp[names(filter_variables)[i]],
       col = viridis(100)[as.numeric(cut(log10(district_attributes[,names(filter_variables)[i]] + 0.0000000001),
                                          breaks=100))],
       # col = viridis(100)[as.numeric(cut(district_attributes[,names(filter_variables)[i]],
       #                                     breaks=100))],
       border=NA, add=TRUE)
  # okay the legend is MIA
}
dev.off()







