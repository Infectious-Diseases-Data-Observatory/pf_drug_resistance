*P. falciparum* site selection support tool
================

*To run the app locally, ensure `run_me_first.R` is run before
application code to initialise covariate data!*

### Site selection workflow

1.  Start with all districts in India
2.  Districts are filtered and ranked by modelling outputs + other
    relevant epidemiological covariates
3.  Shortlisted districts are grouped into transmission (low, medium,
    high) using national state-level data, and districts are selected
    from each group based on local transmission and infrastructure for
    surveillance (*not implemented in app*)

### How to use the tool

- To operate the application, navigate to the Edit Sidebar tab. Drag
  filtering covariates from left to right, and edit the order of
  covariates if needed. Set the number of districts to be retained by
  each filter once it appears in the sidebar at far left.

- Press the **“Update filters”** button to see your preferences
  reflected in the Filtering Maps, Inspect Districts, and Filtering
  Table tabs:

  - The filters are visualised in sequence in the Filtering Maps tab.
  - The shortlisted districts are visualised in a scrollable map in the
    Inspect Districts tab, and
  - The final set of districts are downloadable from the Filtering Table
    tab.

- To view all available filtering covariates, summarised by district,
  navigate to the All Covariates tab. Log-transfrom the covariates if
  needed.

### Covariate layers

There are several covariates included in this tool:

- ***Plasmodium falciparum* temperature suitability, 2010 (Malaria Atlas
  Project)**  
  This layer shows the temperature suitability for *Plasmodium
  falciparum* transmission globally, calculated using a dynamic
  biological model and spatial time series temperature data. The
  temperature data used was a time series across an average year
  (1950-2000).  
  *Gething PW., Van Boeckel TP., Smith DL., Guerra CA., Patil AP., Snow
  RW., Hay SI., Modelling the global constraints of temperature on
  transmission of Plasmodium falciparum and P. vivax Parasites &
  Vectors. May 2011 4: 92.* <https://doi.org/10.1186/1756-3305-4-92>

- ***Plasmodium falciparum* parasite rate, 2021 (Malaria Atlas
  Project)**  
  This layer is a time-aware mosaic data set showing predicted
  age-standardised parasite rate for *Plasmodium falciparum* malaria for
  children two to ten years of age (PfPR2-10) for each year. We are
  using PfPR2-10 estimates for 2021.  
  *Weiss DJ, Lucas TCD, Nguyen M, et al. Mapping the global prevalence,
  incidence, and mortality of Plasmodium falciparum, 2000–17: a spatial
  and temporal modelling study. Lancet 2019; published online June 19.*
  <https://doi.org/10.1016/S0140-6736(19)31097-9>  

- **Predicted travel time to nearest cities in 2015 (Malaria Atlas
  Project)**  
  This is a predictive map showing the estimated time to travel (in
  minutes) from every point on earth to the nearest city (in terms of
  travel time). Contains data from OpenStreetMap © OpenStreetMap
  contributors.  
  *Weiss DJ., Nelson A., Gibson HS., Temperley WH., Peedell S., Lieber
  A., Hancher M., Poyart E., Belchior S., Fullman N., Mappin B.,
  Dalrymple U., Rozier J., Lucas TCD., Howes RE., Tusting LS., Kang SY.,
  Cameron E., Bisanzio D., Battle KE., Bhatt S., Gething PW., A global
  map of travel time to cities to assess inequalities in accessibility
  in 2015 Nature. January 2018 553: 333–336.*
  <http://doi.org/10.1038/nature25181>

- **Human population density estimates (WorldPop project)**  
  WorldPop program provides high resolution, open and contemporary data
  on human population distributions.  
  <https://www.worldpop.org/methods/populations>

- **dhps540E predicted resistance, 2021**  
  Predicted median estimated prevalence of the dhp540E marker.

- **dhps540E predicted resistance (uncertainty), 2021**  
  Standard deviate of the estimated prevalence of the dhp540E marker.

- **kelch13 predicted resistance, 2021**  
  Predicted median estimated prevalence of kelch13 markers (any markers,
  ie not wildtype).

- **kelch13 predicted resistance (uncertainty), 2021**  
  Standard deviate of the estimated prevalence of kelch13 markers (any
  markers, ie not wildtype).

### Data summarisation

Covariate data are summarised for each district in
`district_summary.csv`. For accessibility, human population density, Pf
parasite rate and Pf temperature suitability, these summaries are the
mean value of the dataset within the raster masked by the district
boundary. For model outputs, the mean of both the median model
prediction and model uncertainty are provided, as well as the standard
deviation of median model predictions (where the former is an average of
between-prediction uncertainty, and the latter is the a measure of
variation in median predictions across a district). There are the
columns `k13_median`, `k13_mediansd`, `k13_sd`. `k13_median` and
`k13_sd` are means of the median prediction and standard deviation of
the k13 model in the district, respectively, while `k13_mediansd` is the
standard deviation of model median predictions.

### R Version Control

All code successfully run with following software versions: (need to
update)

    R version 4.4.2 (2024-10-31)
    Platform: aarch64-apple-darwin20
    Running under: macOS Sequoia 15.1.1

    Matrix products: default
    BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
    LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0

    locale:
    [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

    time zone: Europe/London
    tzcode source: internal

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] rsconnect_1.5.0   leaflet_2.2.2     cowplot_1.1.3     sortable_0.5.0    sf_1.0-19        
     [6] terra_1.8-42      markdown_2.0      DT_0.33           lubridate_1.9.4   forcats_1.0.0    
    [11] stringr_1.5.1     dplyr_1.1.4       purrr_1.0.4       readr_2.1.5       tidyr_1.3.1      
    [16] tibble_3.3.0      ggplot2_3.5.2     tidyverse_2.0.0   viridisLite_0.4.2 shiny_1.10.0     

    loaded via a namespace (and not attached):
     [1] gtable_0.3.6       bslib_0.8.0        xfun_0.51          learnr_0.11.5     
     [5] htmlwidgets_1.6.4  tzdb_0.5.0         vctrs_0.6.5        tools_4.4.2       
     [9] crosstalk_1.2.1    generics_0.1.3     proxy_0.4-27       pkgconfig_2.0.3   
    [13] KernSmooth_2.23-24 RColorBrewer_1.1-3 assertthat_0.2.1   lifecycle_1.0.4   
    [17] compiler_4.4.2     farver_2.1.2       textshaping_0.4.1  fontawesome_0.5.3 
    [21] codetools_0.2-20   litedown_0.6       httpuv_1.6.15      sass_0.4.9        
    [25] htmltools_0.5.8.1  class_7.3-22       yaml_2.3.10        jquerylib_0.1.4   
    [29] later_1.4.1        pillar_1.11.0      ellipsis_0.3.2     classInt_0.4-11   
    [33] cachem_1.1.0       mime_0.12          commonmark_1.9.2   tidyselect_1.2.1  
    [37] digest_0.6.37      stringi_1.8.7      labeling_0.4.3     rprojroot_2.1.0   
    [41] fastmap_1.2.0      grid_4.4.2         cli_3.6.5          magrittr_2.0.3    
    [45] e1071_1.7-16       withr_3.0.2        scales_1.4.0       promises_1.3.2    
    [49] timechange_0.3.0   rmarkdown_2.29     ragg_1.3.3         hms_1.1.3         
    [53] memoise_2.0.1      evaluate_1.0.3     knitr_1.49         rlang_1.1.6       
    [57] Rcpp_1.1.0         xtable_1.8-4       glue_1.8.0         DBI_1.2.3         
    [61] rstudioapi_0.17.1  jsonlite_2.0.0     R6_2.6.1           systemfonts_1.1.0 
    [65] units_0.8-5   
