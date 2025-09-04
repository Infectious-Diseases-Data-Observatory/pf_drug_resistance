# OPEN VERSION
source("server.R")

ui <- fluidPage(
  
  # Application title
  titlePanel("Pf molecular surveillance district filtering"),
  
  # sidebar
  sidebarLayout(
    sidebarPanel(width=3,
      # here are the filters:
      h3("Filters"),
      h5("Enter the number of districts to retain for each filter:"),
      uiOutput("filters"),
      
      # button to apply changes to filters:
      actionButton("update", "Update filters"),
      
      br(),
      
    ),
    
    mainPanel(width=9,
      tabsetPanel(
        # landing tab
        tabPanel("Get Started",
                 br(),
                 includeMarkdown("get_started.md")
        ),
        
        # tab to drag and drop filters
        tabPanel("Edit Sidebar",
                 br(),
                 fluidRow(
                   column(
                     tags$b("Sidebar Filters"),
                     width = 12,
                     bucket_list(
                       header = "Drag new filters from left, then order sidebar filtering variables at right",
                       group_name = "sidebar_bucket_list",
                       orientation = "horizontal",
                       add_rank_list(
                         text = "Drag from here",
                         labels = filter_variables,
                         input_id = "from_list"
                       ),
                       add_rank_list(
                         text = "to here",
                         labels = NULL,
                         input_id = "to_list"
                        )
                      )
                    )
                  )
                ),
        
        # tab grid of maps of different covariate layers, with thresholds applied
        tabPanel("Filtering Maps",
                 br(),
                 plotOutput("indiv_filter_plots")
                ),
        
        tabPanel("Inspect Districts",
                 br(),
                 leafletOutput("leaflet", height = 1000)),
        
        # aggregate thresholding in indiv_cov_maps tab
        tabPanel("Filtering Table",
                 br(),
                 # presents table of ranked sites
                 dataTableOutput("districts_table"),
                 downloadButton("download_districts", "Download ranked districts"),
                 ),
        
        # now that we have feasible districts, do some ranking ...
        # tabPanel("Site Feasibility",
        #          br()#,
        #          
        # ),
        
        # extra tab to look at district summaries without filters applied
        tabPanel("All Covariates",
                 br(),
                 checkboxInput("log_covt_plots", "Log the plots!"),
                 br(),
                 plotOutput("district_all_covts"))
    ))
  )
)






