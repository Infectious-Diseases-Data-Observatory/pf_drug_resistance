# OPEN VERSION

ui <- fluidPage(
  
  # Application title
  titlePanel("Drug resistance district filtering"),
  
  # Sidebar with controls to provide a caption, select a dataset, and 
  # specify the number of observations to view. Note that changes made
  # to the caption in the textInput control are updated in the output
  # area immediately as you type
  sidebarLayout(
    sidebarPanel(width=3,
      h3("Filters"),
      uiOutput("filters"),
      
      # apply changes
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
        
        # grid of maps of different covariate layers, with thresholds applied
        tabPanel("Filtering Maps",
                 br(),
                 plotOutput("indiv_filter_plots")
                ),
        
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
        
        tabPanel("All Covariates",
                 br(),
                 checkboxInput("log_covt_plots", "Log the plots!"),
                 br(),
                 plotOutput("district_all_covts"))
    ))
  )
)






