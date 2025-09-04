# Surveillance site selection visualisation tool (3.1)

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


