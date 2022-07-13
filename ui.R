#
# Install required packages
if (!require(shiny)) install.packages('shiny')
if (!require(shinyWidgets)) install.packages('shinyWidgets')
if (!require(DT)) install.packages('DT')
if (!require(reticulate)) install.packages('reticulate')
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(slickR)) install.packages('slickR')
if (!require(openxlsx)) install.packages('openxlsx')

# Define UI for application
shinyUI(fluidPage(
    
    # Application title
    titlePanel(h1("Image analysis pipeline"), 
               p("This application takes confocal z-stacks with two channels, 
                 a brightfield channel and a fluorophore channel and 
                 quantifies the number of cells across the z-stack for each channel")),
    
    # Sidebar with input
    sidebarLayout(
        sidebarPanel(
            h3("Select your channel type. Multiple channels can be selected"),
            radioButtons("number", label = h4("Number of channels"),
                         choices = list("Two channels" = 1, "Three channels" = 2), 
                         selected = 1),
            checkboxGroupInput("type", label = h4("Confocal image type"),
                               choices = list("Brightfield" = "BF", "One fluorescent channel" = "GC", "Second fluorescent channel" = "GC2"),
                               selected = c("BF", "GC")),
            h3("Adjust the following parameters for brightfield cell detection"),
            sliderInput("area",
                        h4("Minimum and maximum area"),
                        min = 5,
                        max = 2000,
                        value = c(75, 1500), 
                        step = 5),
            sliderInput("threshold",
                        h4("Minimum and maximum threshold"),
                        min = 5,
                        max = 255,
                        value = c(10, 255),
                        step = 5),
            sliderInput("circularity",
                        h4("Minimum circularity"),
                        min = 0,
                        max = 1,
                        value = 0.3,
                        step = 0.05),
            sliderInput("convexity",
                        h4("Minimum convexity"),
                        min = 0,
                        max = 1,
                        value = 0.3,
                        step = 0.05),
            sliderInput("color",
                        h4("Color"),
                        min = 0,
                        max = 1,
                        value = 0,
                        step = 1),
            h3("Adjust the following parameters for fluorescent cell detection in the first channel"),
            sliderInput("area2",
                        h4("Area"),
                        min = 0,
                        max = 50,
                        value = 12,
                        step = 1),
            sliderInput("threshold2",
                        h4("Threshold"),
                        min = 0,
                        max = 50,
                        value = 8,
                        step = 1),
            checkboxGroupInput("type2", label = h4("Larger cells"),
                         choices = list("Include larger cells" = "ch1i", "Split larger cells" = "ch1l")),
            h3("Adjust the following parameters for fluorescent cell detection in the second channel"),
            sliderInput("area3",
                        h4("Area"),
                        min = 0,
                        max = 50,
                        value = 12,
                        step = 1),
            sliderInput("threshold3",
                        h4("Threshold"),
                        min = 0,
                        max = 50,
                        value = 8,
                        step = 1),
            checkboxGroupInput("type3", label = h4("Larger cells"),
                               choices = list("Include larger cells" = "ch1i", "Split larger cells" = "ch1l")),
            h3("Click 'Run analysis' when parameters are set"),
            actionButton("run", "Run analysis"), 
            downloadButton(
              outputId = "download",
              label = "Download Results Cell Counts"
            )),
        
        
        # Main Panel with results and images
        mainPanel(
            tags$head(
                tags$style(
                    HTML(".shiny-notification {
                            height: 100px;
                            width: 800px;
                            position:fixed;
                            top: calc(50% - 50px);;
                            left: calc(50% - 400px);;
                        }"
                    )
                )
            ),
            fluidRow(
                column(6,
                       h4("Example of detected cells in brightfield channel"),
                       p("All the output images from the brightfield analysis can be found in the ./bf folder"),
                       slickROutput("slick_bf",width='100%',height='100px'),
                       div(style = "height:400px;")),
                column(6,
                       DTOutput("bfTable"))
            ),
            hr(),

            fluidRow(
              column(6,
                     h4("Example of detected cells in first fluorescent channel"),
                     p("All the output images from the fluorescent analysis can be found in the ./gc folder"),
                     slickROutput("slick_gc",width='100%',height='100px'),
                     div(style = "height:400px;")),
                column(6,
                    DTOutput("gcTable"))
            ), 
            hr(),
            
            fluidRow(
              column(6,
                     h4("Example of detected cells in second fluorescent channel"),
                     p("All the output images from the fluorescent analysis can be found in the ./gc folder"),
                     slickROutput("slick_gc2",width='100%',height='100px'),
                     div(style = "height:400px;")),
              column(6,
                     DTOutput("gcTable2"))
              
            ),
            hr()
        )
    )
))
