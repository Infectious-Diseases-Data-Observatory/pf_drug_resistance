# script to create district_summary.csv

library(sf)
library(rgeos)

# district shapes
setwd("/Users/harrisonl2/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/Jen-Lucy share folder (pf)/shiny_app_May1")
ind_shp = st_read("districts") # may be error if not written elsewhere

setwd("/Users/harrisonl2/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/Jen-Lucy share folder (pf)/shinyapp_May2023")
ind_covs = stack("indapp_covs.grd")
ind_covs$hpop = log10(ind_covs$hpop+0.01)
ind_map = raster("ind_map.grd")

district_summarise = function(district, covts, plot=FALSE, site_name="",
                              plotpath="~/Desktop/pf_ind/output/site_summaries/"){
  tmp = trim(mask(covts, district))
  if (plot == TRUE){
    # summarise with maps and histograms!
    # (avoid using this for all sites at once but handy for selected sites)
    png(paste0(plotpath, tolower(site_name), '.png'),
        width = 3000,
        height = 2400,
        pointsize = 30)
    par(mfrow=n2mfrow(nlayers(tmp)*2), oma=c(0,0,3,0), mar=c(5.1,4.1,4.1,0.1), bty="n")
    for (covt in 1:nlayers(tmp)){
      plot(tmp[[covt]], col=viridis(100), main=paste0(names(tmp)[covt], " map"),
           xaxt="n", yaxt="n", legend.mar=20, legend.width=1.3)
      hist(tmp[[covt]], main=paste0(names(tmp)[covt], " values"), xlab="", breaks=20)
    }
    mtext(site_name, outer=TRUE, cex=1.3)
    dev.off()
  }
  
  retlst = list()
  for (covt in 1:nlayers(tmp)){
    # mean of covariate layer in district - MAP covts, model median predictions and sds
    retlst[names(tmp)[covt]] = mean(values(tmp[[covt]]), na.rm=TRUE) # change back to mean!
    if (grepl("median", names(tmp)[covt], fixed = TRUE)){
      # for model medians, also provide sds of the medians
      retlst[paste0(names(tmp)[covt], "sd")] = sd(values(tmp[[covt]]), na.rm=TRUE)
    }
  }
  
  # need npixel!
  retlst$npixel = sum(!is.na(values(tmp[[1]])))
  retlst$name = site_name
  
  #centroid = st_coordinates(st_centroid(district))
  #retlst$lon_centroid = centroid[1]
  #retlst$lat_centroid = centroid[2]
  tmp = extent(district)
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
district_summary = t(sapply(1:nrow(nonempty_shp), function(x){
  message(x)
  district_summarise(nonempty_shp[x,],ind_covs,site_name=nonempty_shp$District[x]) # changed ind_covs to indapp_covs
}))


district_summary = as.data.frame(apply(district_summary,2, unlist))
district_summary$shp_index = seq(1, nrow(ind_shp))[-empty_distrs]

states = nonempty_shp$STATE
states = gsub(">", "A", states)
states = gsub("\\|", "I", states)

districts = nonempty_shp$District
districts = gsub(">", "A", districts)
districts = gsub("@", "U", districts)
districts = gsub("\\|", "I", districts)

district_summary$district = districts
district_summary$state = states

write.csv(district_summary, "district_summary.csv", row.names=FALSE)



# read in Pf case data:
pf_case = read.csv("districts_pf_2018.csv")
pf_case = pf_case[-which(pf_case$District == "MAHE"),] # Mahe ended up excluded earlier .. too small

# extend district_attributes table
tmp = names(district_summary)
district_summary = cbind(district_summary,
                            matrix(NA, nrow=nrow(district_summary), ncol=5))
names(district_summary) = c(tmp, "pfpc", "api", "afi", "spr", "sfr")

# there are some duplicated district names across different states
# (i.e. not true duplicates, but require an additional joining column)
duplicated_district_names = unique(c(pf_case$District[duplicated(pf_case$District)],
                              district_summary$district[duplicated(district_summary$district)]))
# perform the join
tab_link = sapply(1:nrow(pf_case), function(i){
  if (pf_case$District[i] %in% duplicated_district_names){
    message(i)
    return(which(district_summary$district == pf_case$District[i] & district_summary$state == toupper(pf_case$State[i])))
  }
  else {return(which(district_summary$district == pf_case$District[i]))}
})

# fill out our new columns in district_summary
district_summary[unlist(tab_link),
                    c("pfpc", "api", "afi", "spr", "sfr")] = pf_case[, c("PFpc", "API", "AFI", "SPR", "SFR")]

# and write!
district_summary = district_summary[,-which(names(district_summary) == "name")]
write.csv(district_summary, "district_summary.csv", row.names=FALSE)




