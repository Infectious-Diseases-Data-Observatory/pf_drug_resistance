# OPEN VERSION

server <- (function(input, output, session){
  
  sidebar_inits <- c(25,50,75,100,150,200)
  
  # sidebar inputs:
  filter_tags <- eventReactive(
    eventExpr = input$to_list,
    valueExpr = {
      purrr::map(1:length(input$to_list), function(i) {
        if (length(input$to_list) > 0){
          list(
            #h2(filter_variables[[var]]), 
            numericInput(
              paste0(input$to_list[i], "_num"), 
              label = paste0(filter_variables[[input$to_list[i]]], ": number of districts"),
              min = 1,
              max = nrow(district_attributes),
              value = sidebar_inits[length(input$to_list) - i + 1]
            ) # not sure if I want to settle with numeric; might install sliders still ...
            # extra bits like a slider go in that there list ^
          )
        } else {return()}
      })
    }
  )
  
  output$filters <- renderUI({tagList(unlist(filter_tags(), recursive = FALSE))})
  
  # update filter_mat when the button is clicked!
  filter_mat = reactiveValues(d=data.frame(shp_index=district_attributes$shp_index))
  
  observeEvent(input$update, {
    validate(need(input$to_list, "Add some filtering variables in the Edit Sidebar tab!"))
    tmp = district_attributes
    filter_mat$d = data.frame(cbind(district_attributes$shp_index,
                                    matrix(0, nrow = nrow(district_attributes),
                                            ncol = length(input$to_list))))
    for (i in 1:length(input$to_list)){
      filter_bottom = min(input[[paste0(input$to_list[i], "_num")]], nrow(tmp))
      # order site IDs by var of interest and remove bottom rows
      tmp = tmp[order(tmp[[input$to_list[i]]], decreasing = TRUE),]
      tmp = tmp[1: filter_bottom,]
      # edit filter mat
      filter_mat$d[which(filter_mat$d[,1] %in% tmp$shp_index), i+1] = 1
    }
  })
  
  
  # filtering plots!
  output$indiv_filter_plots <- renderPlot({
    validate(need(length(input$to_list) >= 1, "Add some filtering variables in the Edit Sidebar tab!"))
    par(mfrow = c(ceiling(length(input$to_list)/2), 2))
    old_selected = nrow(filter_mat$d)
    for (i in 1:length(input$to_list)){
      select_indices = filter_mat$d[which(filter_mat$d[,i+1] == 1), 1] # grabs shp_index column
      if (old_selected > length(select_indices)){
        par(bty="n", mar=c(0.1,0.1,4.1,0.1))
        plot(ind_map, xlab="", ylab="", xaxt="n", yaxt="n",
             main = paste0("Filter ", i, " - ", filter_variables[[input$to_list[i]]]),
             legend = FALSE, col="grey90", cex.main=2)
        plot(ind_shp[ind_shp$shp_index %in% select_indices, input$to_list[i]], add = TRUE,
             col = viridis(10)[as.numeric(cut(district_attributes[which(district_attributes$shp_index %in% select_indices), 
                                                                  input$to_list[i]],
                                              breaks=10))],
             border=NA)
        old_selected=length(select_indices)
      }
    }
  }, width=800, height=400*ceiling(length(input$to_list)/2)) # height is reactive to number of filters
  
  
  # final table !
  ranked_districts = reactiveValues(d=setNames(data.frame(matrix(NA, ncol=ncol(district_attributes), nrow=0)), 
                                               colnames(district_attributes)))
  # Could add in ranking on the table tab (can actually do it within the table object)
  observeEvent(input$update, {
    selected_indices = filter_mat$d[which(filter_mat$d[,ncol(filter_mat$d)] == 1), 1]
    message(length(selected_indices), "HERE")
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
      list(src="covt_summary_districts.png", width=1200, height=1350)
    } else {
      list(src="covt_summary_districts_log.png", width=1200, height=1350)
    }
  }, deleteFile=FALSE)
  
  output$download_districts = downloadHandler(
    filename = function(){"ranked_districts.csv"},
    content = function(fname){
      write.csv(ranked_districts$d, fname, row.names = FALSE)
    }
  )
})
