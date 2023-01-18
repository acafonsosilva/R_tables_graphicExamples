library(tidyverse)
library(here)
library(gt)
library(shiny)
library(shinyFiles)

ui <- fluidPage(
  titlePanel("Producing pretty tables with icons"),
  
  # Sidebar with two input widgets
  sidebarLayout(
    sidebarPanel(
      
      p("1. Select folder with design elements from illustrator"),
      p(""),
      shinyDirButton(id = "iconsFolder", label = "Select icons",
                     title = "Select directory with icons"), ### to add Icons
      p(""),
      p("2. Upload data file in csv format"),
      fileInput(inputId = "dataset",
                label = "Find file", accept = c(".csv")),       ### to add dataset
      p("3. Type height of the icons in pixels"), 
      numericInput("iconHeight", "Height", value = 30),
      br(),
      br(),
      br(),
      p("4. Export table as pdf"), 
      downloadButton("download", "table.pdf"),
      p("Exporting function doesn't export as the html version.\nIncrease icon height until row padding is more suitable.")),      
    
    mainPanel(
      h5("\nListed icons"), 
      gt_output("icons"),
      h5("Raw table"), 
      tableOutput("table0"),
      br(),
      h5("\nPretty table"), 
      gt_output(outputId = "Table"),
      p("\n")
    ) 
  ),
)

server <- function(input, output, session){
  ## select folder with design elements
  volumes = c(wd=here())
  
  shinyDirChoose(input, 'iconsFolder', roots = volumes, 
                 filetypes = 'svg')
  
  icons0 <- reactive({
    data.frame(icons = list.files(parseDirPath(volumes, input$iconsFolder), 
                                         pattern = "svg", full.names = TRUE)) %>%
      mutate(columns = basename(tools::file_path_sans_ext(icons))) %>%
      filter(str_detect(columns, "_")) %>%
      separate(columns, into = c("column","content"), sep = "_", extra = "drop",
               remove = TRUE, fill = 'left')
    })
  
  output$icons <- render_gt(height = px(200),{
    gt(icons0()) %>%
      text_transform(locations = cells_body(columns = icons, rows = everything()),
                     fn = function(x) { map_chr(x, ~ local_image(filename = .x,
                                                                 height = input$iconHeight))})   ### <-
    
  })
  
  ## read data input file and makes it a reactive element
  input_dataset <- reactive({
    req(input$dataset)   ### <-
    read.csv(input$dataset$datapath, 
             na.strings = "NA",
             colClasses = "character")
  })
  
  output$table0 <- renderTable(input_dataset())
    
  tableOut <- reactive({
    if (is.null(input_dataset)) {
      return(NULL)}
    
    icons <- icons0() 
    data0 <- input_dataset() 
    
    rowHeader <- icons %>% 
      filter(!column %in% c('content','header')) %>% 
      pull(column) %>% 
      unique()
    
   if(length(rowHeader) == 1){ # make sure there are icons for only one row header

      # prepare column header
      colData <- data.frame(content = colnames(data0)) %>%
        left_join(filter(icons, column %in% 'header'), by = "content") %>%
        pivot_wider(names_from = content, values_from = icons) %>%
        select(-column)
  
      # prepare row header
      rowData <- data.frame(content = pull(select(data0, !!as.symbol(rowHeader)))) %>%
        left_join(filter(icons, column %in% rowHeader), by = "content") %>%
        rename(!!rowHeader := "icons") %>%
        select(-column, -content)

      # prepare content
      data1 <- data0 %>%
        select(-!!as.symbol(rowHeader)) %>%
        mutate(row = row_number()) %>%
        pivot_longer(cols = -row, names_to = "column", values_to = "content",
                     values_ptypes = as.character()) %>%
        replace_na(list(content = "NA")) %>%
        left_join(select(filter(icons, column %in% 'content'),-column),
                  by = 'content') %>%
        pivot_wider(id_cols = row, names_from = column, values_from = icons) %>%
        select(-row)

      dataIcons <- colData %>%
        bind_rows(cbind(rowData, data1))

      
   gt(dataIcons) %>%
     opt_table_font(font = list(google_font("Mina"), default_fonts())) %>%
     text_transform(locations = cells_body(columns = everything(), rows = everything()),
                    fn = function(x) { map_chr(x, ~ local_image(filename = .x,
                                                                height = input$iconHeight))}) %>%  ### <-
     tab_style(
       style = "padding:0px;",
       locations = cells_body(columns = everything(), rows = everything())
     ) %>%
     tab_options(column_labels.hidden = TRUE, ## remove header without icons paths
                 table.border.top.style = "hidden",
                 table.border.bottom.style = "hidden",
                 table_body.hlines.style = "hidden")
   }
  })
  
  output$Table <- render_gt({
    tableOut()
  })
  
  output$download <- downloadHandler(
    filename = function() {
      here("table.pdf")
    } ,
    content = function(file1) {
      gtsave(tableOut(), file1, vwidth = input$iconHeight*(nrow(input_dataset())/2)) #, vheight = input$iconHeight*0.1 <- doesn't do anything
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server, options = list(port=4184))

