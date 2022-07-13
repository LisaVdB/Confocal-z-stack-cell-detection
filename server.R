#Get directories
lsm_input = paste(getwd(), "/in/", sep = "")
png_output = paste(getwd(), "/out/", sep = "")
bf_output = paste(getwd(), "/bf/", sep = "")
gc_output = paste(getwd(), "/gc/", sep = "")

shinyServer(function(input, output) {
  
  withProgress(message = 'Setting up your environment, please wait...', value = 0, {
    n = 2
    incProgress(1/n, detail = paste("Part", 1, "- Loading python"))
    reticulate::source_python("./src/BF_BlobDetector.py")
    reticulate::source_python("./src/GC_BlobDetector.py")
    incProgress(2/n, detail = paste("Part", 2, "- Initializing ImageJ"))
    reticulate::source_python("./src/ImageJ.py") 
    
  })
  
  observeEvent( 
    input$run, {
      color = input$color
      circ = input$circularity
      conv = input$convexity
      area = input$area
      th = input$threshold
      number = input$number
      type = input$type
      area2 = input$area2
      th2 = input$threshold2
      if ("ch1l" %in% input$type2) {
        ch1l = "ch1l"
      } else {
        ch1l = ""
      }
      if ("ch1i" %in% input$type2) {
        ch1i = "ch1i"
      } else {
        ch1i = ""
      }
      area3 = input$area3
      th3 = input$threshold3
      if ("ch1l" %in% input$type3) {
        ch1l2 = "ch1l"
      } else {
        ch1l2 = ""
      }
      if ("ch1i" %in% input$type3) {
        ch1i2 = "ch1i"
      } else {
        ch1i2 = ""
      }
      
      print(number)
      print(type)
      print(area2)
      print(area3)
      print(th2)
      print(th3)
      print(ch1i2)
      print(ch1l2)
      
      unlink(paste(png_output, list.files(path = png_output, pattern = "png$"), sep = ""))
      unlink(paste(bf_output, list.files(path = bf_output, pattern = "png$"), sep = ""))
      unlink(paste(gc_output, list.files(path = gc_output, pattern = "png$"), sep = ""))
      
      if (number == 1) {
        print("I am at number 1")
        if (("BF" %in% input$type) & ("GC" %in% input$type)) {
          print("I am with BF & GC")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 4
            incProgress(1/n, detail = paste("Part", 1, "- performing z-projection"))
            png_converter(lsm_input, png_output)
            
            incProgress(1/n, detail = paste("Part", 2, "- quantifying cells in the brightfield channel"))
            thresholdStep = 2
            bfCounts = blob_detector(png_output, bf_output, th[1], th[2], thresholdStep, 
                                     area[1], area[2], circ, conv, color)
            bfCounts = bfCounts %>% as.data.frame() %>% setNames(c("Image", "Cell_counts"))
            
            incProgress(1/n, detail = paste("Part", 3, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector(lsm_input, gc_output, ch1i, ch1l, area2, th2)
            gcCounts = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% bind_cols(bfCounts %>% select(Image)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 4, "- displaying output tables"))
            output$slick_bf <- renderSlickR({
              imgs <- list.files(path = bf_output, pattern=".png", full.names = TRUE)
              slickR(imgs, slideId = "slide")
            })
            output$slick_gc <- renderSlickR({
              imgs1 <- list.files(path = gc_output, pattern=".png", full.names = TRUE)
              slickR(imgs1, slideId = "slide1")
            })
            
            output$bfTable = DT::renderDT(
              bfCounts
            )
            output$gcTable = DT::renderDT(
              gcCounts
            )
            
            Results = bfCounts %>% rename(Cell_counts_bf = Cell_counts) %>%
              left_join(gcCounts %>% rename(Cell_counts_fch = Cell_counts))
            write.csv(Results, "Results.csv")
          })
          
        } else if ("BF" %in% input$type) {
          print("I am with BF")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 3
            incProgress(1/n, detail = paste("Part", 1, "- performing z-projection"))
            png_converter(lsm_input, png_output)
            
            incProgress(1/n, detail = paste("Part", 2, "- quantifying cells in the brightfield channel"))
            thresholdStep = 2
            bfCounts = blob_detector(png_output, bf_output, th[1], th[2], thresholdStep, 
                                     area[1], area[2], circ, conv, color)
            bfCounts = bfCounts %>% as.data.frame() %>% setNames(c("Image", "Cell_counts")) 
            
            incProgress(1/n, detail = paste("Part", 3, "- displaying output tables"))
            output$slick_bf <- renderSlickR({
              imgs <- list.files(path = bf_output, pattern=".png", full.names = TRUE)
              slickR(imgs, slideId = "slide")
            })
            
            output$bfTable = DT::renderDT(
              bfCounts
            )
            Results = bfCounts %>% rename(Cell_counts_bf = Cell_counts)
            write.csv(Results, "Results.csv")
          })
        } else if ("GC" %in% input$type) {
          print("I am with GC")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 2
            incProgress(1/n, detail = paste("Part", 1, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector(lsm_input, gc_output, ch1i, ch1l, area2, th2)
            gcCounts = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% 
              bind_cols(as.data.frame(list.files(lsm_input, full.names = F)) %>% rename(Image = 1)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 2, "- displaying output tables"))
            output$slick_gc <- renderSlickR({
              imgs <- list.files(path = gc_output, pattern=".png", full.names = TRUE)
              slickR(imgs, slideId = "slide")
            })
            
            output$gcTable = DT::renderDT(
              gcCounts
            )
            
            Results = gcCounts %>% rename(Cell_counts_fch = Cell_counts)
            write.csv(Results, "Results.csv")
          })
        }
        
      }
      if (number == 2) {
        print("I am at number 2")
        if (("BF" %in% input$type) & ("GC" %in% input$type) & ("GC2" %in% input$type)){
          print("I am with BF & GC & GC2")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 4
            incProgress(1/n, detail = paste("Part", 1, "- performing z-projection"))
            png_converter_2(lsm_input, png_output)
            
            incProgress(1/n, detail = paste("Part", 2, "- quantifying cells in the brightfield channel"))
            thresholdStep = 2
            bfCounts = blob_detector(png_output, bf_output, th[1], th[2], thresholdStep, 
                                     area[1], area[2], circ, conv, color)
            bfCounts = bfCounts %>% as.data.frame() %>% setNames(c("Image", "Cell_counts"))
            
            incProgress(1/n, detail = paste("Part", 3, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector_2(lsm_input, gc_output, ch1i, ch1l, area2, th2)
            gcCounts = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% bind_cols(bfCounts %>% select(Image)) %>%
              relocate(Image)
            
            gc_blob_detector_3(lsm_input, gc_output, ch1i2, ch1l2, area3, th3)
            gcCounts2 = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% bind_cols(bfCounts %>% select(Image)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 4, "- displaying output tables"))
            output$slick_bf <- renderSlickR({
              imgs <- list.files(path = bf_output, pattern=".png$", full.names = TRUE)
              slickR(imgs, slideId = "slide2")
            })
            
            output$slick_gc <- renderSlickR({
              imgs1 <- list.files(path = gc_output, pattern="FCh1.png", full.names = TRUE)
              slickR(imgs1, slideId = "slide1")
            })

            output$slick_gc2 <- renderSlickR({
              imgs2 <- list.files(path = gc_output, pattern="FCh2.png", full.names = TRUE)
              slickR(imgs2, slideId = "slide")
            })
            
            output$bfTable = DT::renderDT(
              bfCounts
            )
            output$gcTable = DT::renderDT(
              gcCounts
            )
            output$gcTable2 = DT::renderDT(
              gcCounts2
            )

            Results = bfCounts %>% rename(Cell_counts_bf = Cell_counts) %>%
              left_join(gcCounts %>% rename(Cell_counts_fch1 = Cell_counts)) %>%
              left_join(gcCounts2 %>% rename(Cell_counts_fch2 = Cell_counts))
            write.csv(Results, "Results.csv")
          })

        } else if (("BF" %in% input$type) & ("GC" %in% input$type)) {
          print("I am with BF & GC")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 4
            incProgress(1/n, detail = paste("Part", 1, "- performing z-projection"))
            png_converter_2(lsm_input, png_output)
            
            incProgress(1/n, detail = paste("Part", 2, "- quantifying cells in the brightfield channel"))
            thresholdStep = 2
            bfCounts = blob_detector(png_output, bf_output, th[1], th[2], thresholdStep, 
                                     area[1], area[2], circ, conv, color)
            bfCounts = bfCounts %>% as.data.frame() %>% setNames(c("Image", "Cell_counts"))
            
            incProgress(1/n, detail = paste("Part", 3, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector_2(lsm_input, gc_output, ch1i, ch1l, area2, th2)
            gcCounts = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% bind_cols(bfCounts %>% select(Image)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 4, "- displaying output tables"))
            output$slick_bf <- renderSlickR({
              imgs <- list.files(path = bf_output, pattern=".png", full.names = TRUE)
              slickR(imgs, slideId = "slide")
            })
            output$slick_gc <- renderSlickR({
              imgs1 <- list.files(path = gc_output, pattern="FCh1.png", full.names = TRUE)
              slickR(imgs1, slideId = "slide1")
            })
            
            output$bfTable = DT::renderDT(
              bfCounts
            )
            output$gcTable = DT::renderDT(
              gcCounts
            )
            
            Results = bfCounts %>% rename(Cell_counts_bf = Cell_counts) %>%
              left_join(gcCounts %>% rename(Cell_counts_fch1 = Cell_counts))
            write.csv(Results, "Results.csv")
          })
          
        } else if (("BF" %in% input$type) & ("GC2" %in% input$type)) {
          print("I am with BF & GC2")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 4
            incProgress(1/n, detail = paste("Part", 1, "- performing z-projection"))
            png_converter_2(lsm_input, png_output)
            
            incProgress(1/n, detail = paste("Part", 2, "- quantifying cells in the brightfield channel"))
            thresholdStep = 2
            bfCounts = blob_detector(png_output, bf_output, th[1], th[2], thresholdStep, 
                                     area[1], area[2], circ, conv, color)
            bfCounts = bfCounts %>% as.data.frame() %>% setNames(c("Image", "Cell_counts"))
            
            incProgress(1/n, detail = paste("Part", 3, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector_3(lsm_input, gc_output, ch1i2, ch1l2, area3, th3)
            gcCounts2 = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% bind_cols(bfCounts %>% select(Image)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 4, "- displaying output tables"))
            output$slick_bf <- renderSlickR({
              imgs <- list.files(path = bf_output, pattern=".png", full.names = TRUE)
              slickR(imgs, slideId = "slide2")
            })
            output$slick_gc2 <- renderSlickR({
              imgs1 <- list.files(path = gc_output, pattern="FCh2.png", full.names = TRUE)
              slickR(imgs1, slideId = "slide")
            })
            
            output$bfTable = DT::renderDT(
              bfCounts
            )
            output$gcTable2 = DT::renderDT(
              gcCounts2
            )
            
            Results = bfCounts %>% rename(Cell_counts_bf = Cell_counts) %>%
              left_join(gcCounts2 %>% rename(Cell_counts_fch2 = Cell_counts))
            write.csv(Results, "Results.csv")
          })
          
        } else if (("GC" %in% input$type) & ("GC2" %in% input$type)) {
          print("I am with GC2 & GC")
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 2
            incProgress(1/n, detail = paste("Part", 1, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector_2(lsm_input, gc_output, ch1i, ch1l, area2, th2)
            gcCounts = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% 
              bind_cols(as.data.frame(list.files(lsm_input, full.names = F)) %>% rename(Image = 1)) %>%
              relocate(Image)
            gc_blob_detector_3(lsm_input, gc_output, ch1i2, ch1l2, area3, th3)
            gcCounts2 = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% 
              bind_cols(as.data.frame(list.files(lsm_input, full.names = F)) %>% rename(Image = 1)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 2, "- displaying output tables"))
            output$slick_gc <- renderSlickR({
              imgs <- list.files(path = gc_output, pattern="FCh1.png", full.names = TRUE)
              slickR(imgs, slideId = "slide1")
            })
            output$slick_gc2 <- renderSlickR({
              imgs1 <- list.files(path = gc_output, pattern="FCh2.png", full.names = TRUE)
              slickR(imgs1, slideId = "slide")
            })
            
            output$gcTable = DT::renderDT(
              gcCounts
            )
            output$gcTable2 = DT::renderDT(
              gcCounts2
            )
            
            Results = gcCounts %>% rename(Cell_counts_fch1 = Cell_counts) %>%
              left_join(gcCounts2 %>% rename(Cell_counts_fch2 = Cell_counts))
            write.csv(Results, "Results.csv")
          })
        } else if ("BF" %in% input$type) {
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 3
            incProgress(1/n, detail = paste("Part", 1, "- performing z-projection"))
            png_converter_2(lsm_input, png_output)
            
            incProgress(1/n, detail = paste("Part", 2, "- quantifying cells in the brightfield channel"))
            thresholdStep = 2
            bfCounts = blob_detector(png_output, bf_output, th[1], th[2], thresholdStep, 
                                     area[1], area[2], circ, conv, color)
            bfCounts = bfCounts %>% as.data.frame() %>% setNames(c("Image", "Cell_counts"))
            
            incProgress(1/n, detail = paste("Part", 3, "- displaying output tables"))
            output$slick_bf <- renderSlickR({
              imgs <- list.files(path = bf_output, pattern=".png", full.names = TRUE)
              slickR(imgs, slideId = "slide")
            })
            
            output$bfTable = DT::renderDT(
              bfCounts
            )

            Results = bfCounts %>% rename(Cell_counts_bf = Cell_counts)
            write.csv(Results, "Results.csv")
          })
        } else if ("GC" %in% input$type) {
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 2
            incProgress(1/n, detail = paste("Part", 1, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector_2(lsm_input, gc_output, ch1i, ch1l, area2, th2)
            gcCounts = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% 
              bind_cols(as.data.frame(list.files(lsm_input, full.names = F)) %>% rename(Image = 1)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 2, "- displaying output tables"))
            output$slick_gc <- renderSlickR({
              imgs <- list.files(path = gc_output, pattern="FCh1.png", full.names = TRUE)
              slickR(imgs, slideId = "slide1")
            })
            
            output$gcTable = DT::renderDT(
              gcCounts
            )
            
            Results = gcCounts %>% rename(Cell_counts_fch1 = Cell_counts)
            write.csv(Results, "Results.csv")
          })
        } else if ("GC2" %in% input$type) {
          withProgress(message = 'Analyzing your confocal images, please wait...', value = 0, {
            n = 2
            incProgress(1/n, detail = paste("Part", 1, "- quantifying cells in the fluorescent channel"))
            gc_blob_detector_3(lsm_input, gc_output, ch1i2, ch1l2, area3, th3)
            gcCounts2 = read.csv("Results.csv") %>% select(Number_of_Particles) %>%
              rename(Cell_counts = Number_of_Particles) %>% 
              bind_cols(as.data.frame(list.files(lsm_input, full.names = F)) %>% rename(Image = 1)) %>%
              relocate(Image)
            
            incProgress(1/n, detail = paste("Part", 2, "- displaying output tables"))
            output$slick_gc2 <- renderSlickR({
              imgs1 <- list.files(path = gc_output, pattern="FCh2.png", full.names = TRUE)
              slickR(imgs1, slideId = "slide")
            })
            
            output$gcTable2 = DT::renderDT(
              gcCounts2
            )
            
            Results = gcCounts2 %>% rename(Cell_counts_fch2 = Cell_counts)
            write.csv(Results, "Results.csv")
          })
        }
      }
      
      meta = data.frame("Channel type" = c(rep("BF", 7), rep("FCh1", 4), rep("FCh2", 4)), 
                        "Parameter" = c("Minimum area", "Maximum area", "Minimum threshold", "Maximum threshold",
                                        "Minimum circularity", "Minimum convexity", "Color", "Area", "Threshold", 
                                        "Include larger cells", "Split larger cells", "Area", "Threshold",
                                        "Include larger cells", "Split larger cells"), 
                        "Value" = c(area[1], area[2], th[1], th[2], circ, conv, color, 
                                    area2, th2, ch1l, ch1i, area3, th3, ch1l2, ch1i2))
      list_of_datasets = list("Cell Counts" = Results, "Metadata" = meta)
      
      output$download <- downloadHandler(
        filename = paste("CellCounts_", Sys.Date(), ".xlsx", sep = ""),
        content = function(file) {
          print("Starting download...")
          #write.csv(Results, file, row.names = FALSE)
          write.xlsx(list_of_datasets, file)
          print("Finished download.")
        })
      
    })
})
