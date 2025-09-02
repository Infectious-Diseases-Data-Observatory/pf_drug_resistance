# script to create district_summary.csv
# publish national data alongside? need to confirm?

library(sf)
library(terra)
library(dplyr)

# district shapes
ind_shp = st_read("districts")

# MAP covariates, model outputs
ind_covs <- rast("indapp_covs.grd")
ind_covs$hpop <- log10(ind_covs$hpop + 0.01)
# accessibility inverted from travel time to cities
ind_covs$access <- 1/(ind_covs$access + 1)
ind_map <- rast("ind_map.grd")

district_summarise <- function(district, 
                               covts, 
                               plot = FALSE, 
                               site_name = "",
                               plotpath = ""){
  # function to summarise surfaces in covts for a give district
  
  district_covts = covts %>%
    mask(district) %>%
    trim()
  
  if (plot == TRUE){
    # option to summarise with maps and histograms!
    # (avoid using this for all sites at once but handy for selected sites)
    png(paste0(plotpath, tolower(site_name), '.png'),
        width = 3000,
        height = 2400,
        pointsize = 30)
    par(mfrow = n2mfrow(nlyr(district_covts)*2), 
        oma = c(0,0,3,0), mar = c(5.1,4.1,4.1,0.1), bty="n")
    for (covt in 1:nlyr(district_covts)){
      plot(district_covts[[covt]], 
           col = viridis(100), 
           main = paste0(names(district_covts)[covt], " map"),
           xaxt = "n", yaxt = "n", 
           legend.mar = 20, 
           legend.width = 1.3)
      hist(district_covts[[covt]], 
           main = paste0(names(district_covts)[covt], " values"), 
           xlab = "", breaks = 20)
    }
    mtext(site_name, outer = TRUE, cex = 1.3)
    dev.off()
  }
  
  retlst = list()
  for (covt in 1:nlyr(district_covts)){
    # mean of covariate layer in district - MAP covts, model median predictions and sds
    retlst[names(district_covts)[covt]] = mean(values(district_covts[[covt]]), na.rm=TRUE)
    if (grepl("median", names(district_covts)[covt], fixed = TRUE)){
      # for model medians, also provide sds of the medians
      retlst[paste0(names(district_covts)[covt], "sd")] = sd(values(district_covts[[covt]]), na.rm=TRUE)
    }
  }
  
  # need npixel!
  retlst$npixel = sum(!is.na(values(district_covts[[1]])))
  retlst$name = site_name
  
  # centroids don't end up being important, but going for "point in middle of box"
  # rather than what st_centroid gives us?
  # centroid = st_coordinates(st_centroid(district))
  # retlst$lon_centroid = centroid[1]
  # retlst$lat_centroid = centroid[2]
  tmp = ext(district)
  retlst$lon_centroid = (tmp[2] + tmp[1])/2
  retlst$lat_centroid = (tmp[4] + tmp[3])/2
  
  return(retlst)
}

# expect 734 non-empty shps - the empty ones are often disputed areas, etc.
# see seld_shps.R for the skeleton of how I worked this out
empty_distrs = c(13,19,69,186,239,291,315,707,708,710)
nonempty_shp = ind_shp
nonempty_shp = ind_shp[-empty_distrs,]

# summarise non-empty shapes
district_summary <- sapply(1:nrow(nonempty_shp), function(x){
  message(x)
  district_summarise(nonempty_shp[x,],
                     ind_covs,
                     site_name = nonempty_shp$District[x]) 
  # changed ind_covs to indapp_covs for public version
}) %>%
  t()


district_summary <- district_summary %>%
  apply(2, unlist) %>%
  as.data.frame() %>%
  mutate(shp_index = seq(1, nrow(ind_shp))[-empty_distrs])

states = nonempty_shp$STATE
states = gsub(">", "A", states)
states = gsub("\\|", "I", states)

districts = nonempty_shp$District
districts = gsub(">", "A", districts)
districts = gsub("@", "U", districts)
districts = gsub("\\|", "I", districts)

district_summary$district = districts
district_summary$state = states

names(district_summary)

write.csv(district_summary %>%
            dplyr::select(-c(name)), "district_summary.csv", row.names=FALSE)

################################################################################
# here's the bit involving NMCP data:
# read in Pf case data:
# pf_case = read.csv("districts_pf_2018.csv")
# pf_case = pf_case[-which(pf_case$District == "MAHE"),] # Mahe ended up excluded earlier .. too small
# 
# # extend district_attributes table
# tmp = names(district_summary)
# district_summary = cbind(district_summary,
#                             matrix(NA, nrow=nrow(district_summary), ncol=5))
# names(district_summary) = c(tmp, "pfpc", "api", "afi", "spr", "sfr")
# 
# # there are some duplicated district names across different states
# # (i.e. not true duplicates, but require an additional joining column)
# duplicated_district_names = unique(c(pf_case$District[duplicated(pf_case$District)],
#                               district_summary$district[duplicated(district_summary$district)]))
# # perform the join
# tab_link = sapply(1:nrow(pf_case), function(i){
#   if (pf_case$District[i] %in% duplicated_district_names){
#     message(i)
#     return(which(district_summary$district == pf_case$District[i] & district_summary$state == toupper(pf_case$State[i])))
#   }
#   else {return(which(district_summary$district == pf_case$District[i]))}
# })
# 
# # fill out our new columns in district_summary
# district_summary[unlist(tab_link),
#                     c("pfpc", "api", "afi", "spr", "sfr")] = pf_case[, c("PFpc", "API", "AFI", "SPR", "SFR")]
# 
# # and write!
# district_summary = district_summary[,-which(names(district_summary) == "name")]
# write.csv(district_summary, "district_summary.csv", row.names=FALSE)




