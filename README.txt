Ensure run_me_first.R script is run before application code to initialise covariate data!
----------------------------------------------------------------------------------------
TODO
- update README :) + put into markdown
- pop licenses for external data up and get my own licence
- get it onto shiny's server :)

----------------------------------------------------------------------------------------
Columns in district_summary.csv and ranked_districts.csv

Covariate data are summarised for each district in district_summary.csv. For accessibility, human population density, Pf parasite rate and Pf temperature suitability, these summaries are the mean value of the dataset within the raster masked by the district boundary. For model outputs, the mean of both the median model prediction and model uncertainty are provided, as well as the standard deviation of model mean predictions.

For example, there are the columns k13median, k13mediansd, k13sd. k13median and k13sd are means of the median prediction and standard deviation of the k13 model in the district, respectively, while k13mediansd is the standard deviation of model median predictions.

----------------------------------------------------------------------------------------
R Version Control: all code successfully run with following software versions:

R version 4.1.2 (2021-11-01)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS Big Sur 11.6.4

Matrix products: default
LAPACK: /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRlapack.dylib

locale:
[1] en_AU.UTF-8/en_AU.UTF-8/en_AU.UTF-8/C/en_AU.UTF-8/en_AU.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] sf_1.0-7          plotfunctions_1.4 raster_3.5-15     sp_1.4-6          markdown_1.1      DT_0.21          
[7] dplyr_1.0.8       viridisLite_0.4.0 shiny_1.7.1      

loaded via a namespace (and not attached):
 [1] bslib_0.3.1        tidyselect_1.1.2   terra_1.5-21       xfun_0.30          purrr_0.3.4       
 [6] lattice_0.20-45    vctrs_0.3.8        generics_0.1.2     htmltools_0.5.2    yaml_2.3.5        
[11] utf8_1.2.2         rlang_1.0.2        jquerylib_0.1.4    e1071_1.7-9        later_1.3.0       
[16] pillar_1.7.0       glue_1.6.2         withr_2.5.0        DBI_1.1.2          lifecycle_1.0.1   
[21] fontawesome_0.2.2  htmlwidgets_1.5.4  codetools_0.2-18   evaluate_0.15      knitr_1.37        
[26] fastmap_1.1.0      crosstalk_1.2.0    httpuv_1.6.5       class_7.3-19       fansi_1.0.2       
[31] Rcpp_1.0.8.3       KernSmooth_2.23-20 xtable_1.8-4       promises_1.2.0.1   classInt_0.4-3    
[36] cachem_1.0.6       jsonlite_1.8.0     mime_0.12          digest_0.6.29      grid_4.1.2        
[41] rgdal_1.5-28       cli_3.2.0          tools_4.1.2        sass_0.4.0         magrittr_2.0.3    
[46] proxy_0.4-26       tibble_3.1.6       crayon_1.5.0       pkgconfig_2.0.3    ellipsis_0.3.2    
[51] data.table_1.14.2  rstudioapi_0.13    rmarkdown_2.13     R6_2.5.1           units_0.8-0       
[56] compiler_4.1.2  
