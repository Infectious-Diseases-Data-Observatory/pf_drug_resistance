library(terra)
library(viridisLite)
library(sf)
library(tidyverse)
library(cowplot)
library(ggnewscale)
library(iddoPal)

model_outs <- rast("data/ind_covs.grd") %>%
  trim()
model_outs <- model_outs[[c("k13median", "k13sd", "spmedian", "spsd")]]

ind_shp <- st_read("districts")
ind_shp <- ind_shp[district_attributes$shp_index,] %>%
  cbind(district_attributes) %>%
  dplyr::select(-c(District, STATE, REMARKS))

states <- st_read("data/states/STATE_BOUNDARY.shp")

district_attributes <- read.csv("district_summary.csv")

ind_states = st_read("Administrative Boundary Database Oct 2022/STATE_BOUNDARY.shp")
ind_states = st_transform(ind_states, "+proj=longlat +datum=WGS84")
sf_use_s2(FALSE)

# give_me_breaks = function(vals, nbreaks){
#   tmp = cut(vals, breaks=nbreaks) %>%
#     levels() %>%
#     gsub(pattern = "[^.0-9]", replacement = " ")
#   tmp = read.table(text = tmp,
#                    col.names = c("lower", "upper")) # not sure how to tidily link this up
#   return(c(tmp$lower, tmp$upper[nbreaks]))
#   
# }
# 
# nbreaks = 100
# k13medbreaks = give_me_breaks(values(model_outs$k13median), nbreaks)
# spmedbreaks = give_me_breaks(values(model_outs$spmedian), nbreaks)
# spsdbreaks = give_me_breaks(values(model_outs$spsd), nbreaks)
# k13sdbreaks = give_me_breaks(values(model_outs$k13sd), nbreaks)
# contpal = viridis(nbreaks)

k13medlim = range(values(model_outs$k13median), na.rm=TRUE)
spmedlim = range(values(model_outs$spmedian), na.rm=TRUE)
k13sdlim = range(values(model_outs$k13sd), na.rm=TRUE)
spsdlim = range(values(model_outs$spsd), na.rm=TRUE)

#############################################################################
# the RIGMAROLE of it all

shp_plot <- function(shp, llim, xlim, ylim, lab = ""){
  # would like to add states over the top
  ggplot(shp) +
    geom_sf(linewidth = 0.1, aes(fill = value)) +
    scale_fill_viridis_c(limits = llim, guide = "none") +
    geom_text(data = data.frame(matrix(NA, ncol=3)), # dummy row
              aes(x = 70, y = 35, label = lab)) +
    geom_sf(data = states, fill = NA, col = "grey") +
    theme_bw() +
    xlim(xlim) +
    ylim(ylim) +
    theme(axis.title.x=element_blank(),
          axis.title.y = element_blank())
}

ras_plot <- function(df, ras, llim, shp, legtitle, xlim, ylim, leg = FALSE, lab = ""){
  p <- ggplot(df) +
    geom_sf(data = shp, fill = NA) +
    geom_text(data = data.frame(matrix(NA, ncol=3)), # dummy row
              aes(x = 70, y = 35, label = lab)) +
    geom_tile(aes(x = x, y = y, fill = eval(parse(text=ras)))) +
    scale_fill_viridis_c(limits = llim) +
    labs(fill = legtitle) +
    theme_bw() +
    guides(fill = guide_colourbar(title.position = "left")) +
    xlim(xlim) +
    ylim(ylim)
    
  if (leg){
    p + theme(axis.title.x=element_blank(),
              axis.title.y = element_blank(),
              legend.title = element_text(angle = 90, hjust = 0.5),
              legend.key.width = unit(dev.size()[1] / 35, "inches"),
              legend.key.height = unit(dev.size()[1] / 8, "inches"))
  } else {
    p + theme(legend.position = "none",
              axis.title.x=element_blank(),
              axis.title.y = element_blank())
  }
}

#ras_plot(ras_df, "k13median", k13medlim, to_plot, "Median pfkelch13 estimated prevalence", xlim, ylim)


to_plot <- ind_shp %>%
  pivot_longer(cols = c(k13_median, dhps_median, k13_sd, dhps_sd)) %>%
  st_as_sf()

ras_df <- cbind(xyFromCell(model_outs, cells(model_outs)), 
                as.data.frame(model_outs))

xlim = c(68,98)
ylim = c(6,38)

#############################################################################
# Here's Figure 2:

p1 <- ras_plot(ras_df, "k13median", k13medlim, to_plot, 
               "", xlim, ylim, lab = "(a)")
p2 <- shp_plot(filter(to_plot, name == "k13_median"), llim = k13medlim, 
               xlim, ylim, lab = "(c)")
leg3 <- ras_plot(ras_df, "k13median", k13medlim, to_plot, 
                "Median pfk13 estimated prevalence", xlim, ylim, leg = TRUE) %>%
  get_legend() %>%
  suppressWarnings()

p4 <- ras_plot(ras_df, "spmedian", spmedlim, to_plot, 
               "", xlim, ylim, lab = "(b)")
p5 <- shp_plot(filter(to_plot, name == "dhps_median"), llim = spmedlim, 
               xlim, ylim, lab = "(d)")
leg6 <- ras_plot(ras_df, "spmedian", spmedlim, to_plot, 
                 "Median pfdhps540E estimated prevalence", xlim, ylim, leg = TRUE) %>%
  get_legend() %>%
  suppressWarnings()

fig2 <- plot_grid(plot_grid(p1, p2, nrow = 2), leg3,
               plot_grid(p4, p5, nrow = 2), leg6,
          nrow=1, rel_widths = c(1,0.2,1,0.2))
ggsave("figs/medians.png", fig2, height = 9, width = 10, scale=0.9)

#############################################################################
# Here's Figure 3

p1 <- ras_plot(ras_df, "k13sd", k13sdlim, to_plot, 
               "", xlim, ylim, lab = "(a)")
p2 <- shp_plot(filter(to_plot, name == "k13_sd"), llim = k13sdlim, 
               xlim, ylim, lab = "(c)")
leg3 <- ras_plot(ras_df, "k13sd", k13sdlim, to_plot, 
                 "Pfk13 estimated prevalence standard deviation", xlim, ylim, leg = TRUE) %>%
  get_legend() %>%
  suppressWarnings()

p4 <- ras_plot(ras_df, "spsd", spsdlim, to_plot, 
               "", xlim, ylim, lab = "(b)")
p5 <- shp_plot(filter(to_plot, name == "dhps_sd"), llim = spsdlim, 
               xlim, ylim, lab = "(d)")
leg6 <- ras_plot(ras_df, "spsd", spsdlim, to_plot, 
                 "Pfdhps540E estimated prevalence standard deviation", xlim, ylim, leg = TRUE) %>%
  get_legend() %>%
  suppressWarnings()

fig3 <- plot_grid(plot_grid(p1, p2, nrow = 2), leg3,
                  plot_grid(p4, p5, nrow = 2), leg6,
                  nrow=1, rel_widths = c(1,0.2,1,0.2))
ggsave("figs/sds.png", fig3, height = 9, width = 10, scale=0.9)

#############################################################################
# And here's Figure 5

# grab shortlist
shortlist <- read.csv("data/ranked_districts.csv")

tmp <- ind_shp %>%
  mutate(shortlist = ifelse(district %in% shortlist$district, "Shortlisted districts", ""),
         selected = factor(case_when(district == "UTTARA  KANNADA" ~ "Low",
                              district %in% c("SOUTH GOA", "LAKHIMPUR") ~ "Medium",
                              district == "BOKARO" ~ "High",
                              TRUE ~ NA),
                           levels = c(NA, "Low", "Medium", "High")))

selected <- tmp %>% filter(!is.na(selected)) %>%
  mutate(label = c("Bokaro", "South Goa", "Uttar Kannada", "Lakhimpur"),
         lon_lab = c(87, 70, 73, 94),
         lat_lab = c(17, 12, 10, 20))

# a hack
lns <- bind_rows(dplyr::select(selected, district, lon_lab, lat_lab),
                dplyr::select(selected, district, lon_centroid, lat_centroid) %>% 
                  rename(lon_lab = lon_centroid,
                         lat_lab = lat_centroid))

fig5 <- ggplot(tmp) +
  geom_sf(fill = "white", col = "grey80") +
  geom_sf(data = tmp %>% 
            filter(shortlist == "Shortlisted districts"), 
          aes(fill = shortlist), col = "grey50") +
  scale_fill_manual(values = "grey80", "") +
  new_scale_fill() +
  geom_sf(data = tmp %>%
            filter(!is.na(selected)),
          aes(fill = selected), col = "grey50") +
  scale_fill_manual(values = c(iddo_palettes$iddo[1], "orange", iddo_palettes$iddo[2]),
                    "Pf Positivity Rate") +
  geom_sf(data = states, col = "grey30", fill = NA, lwd = 0.2) +
  geom_line(data = lns, aes(x = lon_lab, y = lat_lab, group = district), lwd = 0.2) +
  geom_text(data = selected, aes(x = lon_lab, y = lat_lab, label = label), vjust = 1.5) +
  theme_bw() +
  theme(axis.title = element_blank(),
        legend.text=element_text(size=10))
ggsave("figs/selected_districts.png", fig5, height = 8, width = 10, scale = 0.8)


