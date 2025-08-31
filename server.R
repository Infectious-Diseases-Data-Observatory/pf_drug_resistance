# OPEN VERSION

server <- (function(input, output, session){
  
  sidebar_inits <- c(25,50,75,100,150,200,250,300)
  
  # sidebar inputs:
  filter_tags <- eventReactive(
    eventExpr = input$to_list,
    valueExpr = {
      purrr::map(1:length(input$to_list), function(i) {
        if (length(input$to_list) > 0){
          list(
            numericInput(
              paste0(input$to_list[i], "_num"), 
              label = filter_variables[[input$to_list[i]]],
              min = 1,
              max = nrow(district_attributes),
              value = sidebar_inits[length(input$to_list) - i + 1]
            ) 
            # not sure if I want to settle with numeric; might install sliders still ...
            # extra bits like a slider go in that there list ^
          )
        } else {return()}
      })
    }
  )
  
  
  output$filters <- renderUI({tagList(unlist(filter_tags(), recursive = FALSE))})
  
  # update filter_mat when the button is clicked!
  filter_mat <- reactiveValues(d = data.frame(shp_index = district_attributes$shp_index))
  
  observeEvent(input$update, {
    # I don't recall where this warning message was supposed to pop up ..
    validate(need(input$to_list, "Add some filtering variables in the Edit Sidebar tab!"))
    tmp = district_attributes
    filter_mat$d = data.frame(cbind(district_attributes$shp_index,
                                    matrix(0, nrow = nrow(district_attributes),
                                            ncol = length(input$to_list))))
    for (i in 1:length(input$to_list)){
      # this is a bottleneck
      filter_bottom = min(input[[paste0(input$to_list[i], "_num")]], nrow(tmp))
      # order site IDs by var of interest and remove bottom rows
      tmp = tmp[order(tmp[[input$to_list[i]]], decreasing = TRUE),]
      tmp = tmp[1: filter_bottom,]
      # edit filter mat
      filter_mat$d[which(filter_mat$d[, 1] %in% tmp$shp_index), i+1] = 1
    }
    
    names(filter_mat$d) <- c("idx", input$to_list)
    
  })
  
  
  indiv_filter_plot_height = reactive(
    return(max(100, ifelse(length(input$to_list) < 5,
                           400*ceiling(length(input$to_list)/2),
                           400*ceiling(length(input$to_list)/3))))
  )
  
  # filtering plots!
  output$indiv_filter_plots <- renderPlot({
    validate(need(indiv_filter_plot_height() > 100, "Add some filtering variables in the Edit Sidebar tab"))
    validate(need(length(names(filter_mat$d)) > 1, "Click 'Update filters' to apply filters"))
    # there has to be a ggplot way of doing this ...
    
    fmat <- filter_mat$d %>%
      pivot_longer(cols = unlist(input$to_list),
                   names_to = "name",
                   values_to = "value") %>%
      filter(value == 1) %>%
      left_join(ind_shp, by = join_by(idx == shp_index)) %>%
      split(.$name)
    
    i <- 0
    plots <- lapply(input$to_list, function(col){
      i <<- i + 1 # TIL how global vars work in R ?
      message(i)
      ggplot() +
        geom_sf(data = st_as_sf(ind_outline)) +
        geom_sf(data = fmat[[col]] %>% st_as_sf(),
                mapping = aes(fill = fmat[[col]][[col]]),
                linewidth = 0.1) +
        scale_fill_viridis_c(name = "") +
        theme_bw() +
        theme(legend.position = "bottom",
              strip.background = element_blank(),
              legend.key.width = unit(1, "cm")) +
        labs(title = paste0("Filter ", i, ":\n", filter_variables[[col]]))
      
    })
    cowplot::plot_grid(plotlist = plots)
    
  }, width=800, height=function() indiv_filter_plot_height()) 
  # height is reactive to number of filters
  
  
  # final table !
  ranked_districts = reactiveValues(d=setNames(data.frame(matrix(NA, ncol=ncol(district_attributes), nrow=0)), 
                                               colnames(district_attributes)))
  # Could add in ranking on the table tab (can actually do it within the table object)
  observeEvent(input$update, {
    selected_indices = filter_mat$d[which(filter_mat$d[,ncol(filter_mat$d)] == 1), 1]
    ranked_districts$d = district_attributes[district_attributes$shp_index %in% selected_indices,]
  })
  
  output$districts_table <- renderDataTable({
    # order columns by filters!
    datatable(ranked_districts$d[,c("district","state", input$to_list)],
              colnames=c("district","state", input$to_list)) %>%
      formatRound(columns=3:(length(input$to_list) + 2), digits=3)
  }, options=list(pageLength=10))
  
  output$district_all_covts <- renderImage({
    if (input$log_covt_plots == FALSE){
      message(getwd())
      list(src="covt_summary_districts.png", width=1000, height=1350)
    } else {
      list(src="covt_summary_districts_log.png", width=1000, height=1350)
    }
  }, deleteFile=FALSE)
  
  output$download_districts <- downloadHandler(
    filename = function(){"ranked_districts.csv"},
    content = function(fname){
      write.csv(ranked_districts$d, fname, row.names = FALSE)
    }
  )
  
  output$leaflet <- renderLeaflet({
    # applying the same checks as for the individual filtering plots
    validate(need(indiv_filter_plot_height() > 100, "Add some filtering variables in the Edit Sidebar tab"))
    validate(need(length(names(filter_mat$d)) > 1, "Click 'Update filters' to apply filters"))
    
    polys_to_show <- filter_mat$d %>%
      rename(final = ncol(filter_mat$d)) %>%
      dplyr::select(idx, final) %>%
      filter(final == 1) %>%
      left_join(ind_shp, by = join_by(idx == shp_index))
    
    message(nrow(polys_to_show))
    
    # drop polyg geometry and reset to polyg centroid
    # probably a simpler way to get at this ...
    pts_to_show <- polys_to_show %>%
      st_drop_geometry() %>%
      st_as_sf(coords = c("lon_centroid", "lat_centroid"), crs = 4326) %>%
      mutate(summary = pmap_chr(across(input$to_list), ~ {
        cols <- names(across(input$to_list))
        vals <- list(...)
        paste(cols, round(as.numeric(vals), 3), sep = ": ", collapse = ", </br>")
      }),
      summary = paste0("<strong>", district, ",</strong> ", state, "</br>", summary))
    
    
    leaflet() %>%
      addTiles() %>%
      setView(80, 21, zoom = 4) %>%
      addPolygons(data = polys_to_show %>% st_as_sf(),
                  color = "#14B1E7",
                  fillOpacity = 0.3) %>%
      addMarkers(data = pts_to_show,
                 label = ~summary %>%
                   lapply(htmltools::HTML))
  })
})


