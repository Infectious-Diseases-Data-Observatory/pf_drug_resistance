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
ind_shp = st_read("districts")
ind_shp = ind_shp[district_attributes$shp_index,]
ind_shp = cbind(ind_shp, district_attributes)
ind_shp = subset(ind_shp, select= -c(District, STATE, REMARKS))

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

# run this if we update the input data for the app:
# summary plots that end up on the last tab of the app
{png("covt_summary_districts.png",
    width=2000,
    height=2200,
    pointsize=50)
par(mfrow=c(ceiling(length(filter_variables)/3), 3),
    mar=c(0.1,0.1,2.1,4.1), bty="n")
for (i in 1:length(filter_variables)){
  plot(trim(ind_map), col="grey80", legend=F, main=unlist(filter_variables)[i],
       xlab="", ylab="", xaxt="n", yaxt="n")
  plot(ind_shp[names(filter_variables)[i]],
       col = viridis(100)[as.numeric(cut(district_attributes[,names(filter_variables)[i]],
                                           breaks=100))],
       border=NA, add=TRUE)
  # okay the legend is MIA
}
dev.off()}

# ignore warning about NaNs ... comes from logging the logged hpop
# should rectify that at some point
{png("covt_summary_districts_log.png",
    width=2000,
    height=2200,
    pointsize=50)
par(mfrow=c(ceiling(length(filter_variables)/3), 3),
    mar=c(0.1,0.1,2.1,4.1), bty="n")
for (i in 1:length(filter_variables)){
  plot(trim(ind_map), col="grey80", legend=F, main=unlist(filter_variables)[i],
       xlab="", ylab="", xaxt="n", yaxt="n")
  plot(ind_shp[names(filter_variables)[i]],
       col = viridis(100)[as.numeric(cut(log10(district_attributes[,names(filter_variables)[i]] + 0.0000000001),
                                         breaks=100))],
       border=NA, add=TRUE)
}
dev.off()}






