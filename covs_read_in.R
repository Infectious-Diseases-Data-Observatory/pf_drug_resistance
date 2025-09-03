library(sf)
library(terra)
library(tidyverse)

# retrieve data
# call up MAP rasters where they're used
# read in model outputs also
ind_shp <- st_read("districts")

# here are all of the datasets that went into the original app:
razzes <- paste0("data/", list.files("data")) %>%
  as.data.frame() %>%
  filter(grepl(".flt$", .))
  

# here is a chunk to read in *all* of the rasters used in the original app:
# need to be a bit careful here as model inputs get read in in radians
# covs <- lapply(unlist(razzes), function(ras){
#   tmp <- rast(ras)
#   if (res(tmp)[1] < 0.001){
#     # values(ind_map) <- values(tmp)
#     # tmp <- ind_map
#     ext(tmp) <- as.vector(ext(tmp)) * 180 / pi
#   }
# 
#   tmp
# }) %>%
#   rast() %>%
#   trim()
# 
# covs
# writeRaster(covs, "data/ind_covs.grd")

razzes <- razzes %>%
  filter(grepl("Resistance", .) | grepl("Population", .))
# here is a chunk for just the rasters that we'll use:
covs <- lapply(unlist(razzes), function(ras){
  tmp <- rast(ras)
  if (res(tmp)[1] < 0.001){
    # values(ind_map) <- values(tmp)
    # tmp <- ind_map
    ext(tmp) <- as.vector(ext(tmp)) * 180 / pi
  }

  tmp
}) %>%
  rast() %>%
  trim()

names(covs) <- sub(".*/(.*?)\\.flt.*", "\\1", razzes$.)

# but anyway, here's how to get surfaces from MAP from scratch:
library(malariaAtlas)

all_dat <- listRaster(printed = FALSE)

# PFPR
# can grab 2021 or 2022 here:
all_dat$dataset_id[grep("Pf_Parasite_Rate", all_dat$dataset_id)]
all_dat[all_dat$dataset_id == "Malaria__202406_Global_Pf_Parasite_Rate",]
pfpr <- getRaster("Malaria__202406_Global_Pf_Parasite_Rate",
                  shp = ind_shp,
                  year = 2021)
# this new product looks very different to the old one so might leave as is for now
# all_dat[all_dat$dataset_id == "Malaria__202508_Global_Pf_Parasite_Rate",]
# pfpr <- getRaster("Malaria__202508_Global_Pf_Parasite_Rate",
#                   shp = ind_shp,
#                   year = 2019:2021)
pfpr <- as.list(pfpr) %>%
  rast()
# select median estimate for 2021 only
covs <- c(covs, 
          pfpr$`Proportion of Children 2 to 10 years of age showing, on a given year, detectable Plasmodium falciparum parasite 2000-2022-2021` %>%
              crop(covs) %>%
              project(covs))

# TEMPERATURE SUITABILITY
# probably want the index here:
all_dat$dataset_id[grep("TempSuitability.Pf", all_dat$dataset_id)]
all_dat[all_dat$dataset_id == "Explorer__2010_TempSuitability.Pf.Index.1k.global_Decompressed",]
temp_suit <- getRaster("Explorer__2010_TempSuitability.Pf.Index.1k.global_Decompressed",
                       shp = ind_shp)
covs <- c(covs,
         temp_suit %>%
           crop(covs) %>%
           project(covs))


# ACCESSIBILITY
# travel time to cities:
all_dat$dataset_id[grep("Access", all_dat$dataset_id)]
all_dat[all_dat$dataset_id == "Accessibility__201501_Global_Travel_Time_to_Cities",]
access <- getRaster("Accessibility__201501_Global_Travel_Time_to_Cities",
                    shp = ind_shp)

covs <- c(covs,
          access %>%
            crop(covs) %>%
            project(covs))

writeRaster(covs, "data/ind_covs.grd", overwrite=TRUE)




# compare existing surfaces and the surfaces we've just retrieved, if you like
# par(mfrow = c(1,2))
# plot(covs$AccessibilityIndia)
# plot(access)
# 
# plot(covs$India_pfpr_2019)
# plot(pfpr)
# 
# plot(covs$TemperatureSuitabilityIndia)
# plot(temp_suit)

# unfortunately, we can't do this as neatly with the worldpop surface so have just
# read in the original surface from file above

