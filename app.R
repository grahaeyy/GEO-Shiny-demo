library(shiny)
library(bslib)
library(bsicons)         # nicer icons than emoji — install.packages("bsicons") if missing
library(shinycssloaders) # loading spinners on plots — install.packages("shinycssloaders") if missing

############################################################
# UI
############################################################

ui <- page_navbar(
  
  title = tagList(bs_icon("activity"), "GEO Differential Expression Analysis"),
  
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2C7FB8",
    base_font = font_google("Inter"),
    heading_font = font_google("Poppins"),
    "navbar-bg" = "#2C7FB8"
  ),
  
  # Persistent sidebar: dataset controls stay visible on every tab
  sidebar = sidebar(
    title = "Dataset",
    width = 300,
    
    textInput(
      "geo",
      "GEO Accession",
      value = "GSE63514"
    ),
    
    actionButton(
      "run",
      tagList(bs_icon("play-fill"), "Run Analysis"),
      class = "btn-primary w-100"
    ),
    
    hr(),
    
    uiOutput("status_message")
  ),
  
  ############################################################
  # HOME
  ############################################################
  
  nav_panel(
    
    title = tagList(bs_icon("house-door"), "Home"),
    
    card(
      
      card_header("Pipeline Workflow"),
      
      tags$ol(
        class = "fs-5",
        tags$li("Download GEO Dataset"),
        tags$li("Quality Control"),
        tags$li("Normalization"),
        tags$li("Differential Expression"),
        tags$li("Visualization"),
        tags$li("Export Results")
      )
      
    )
    
  ),
  
  ############################################################
  # PREPROCESSING
  ############################################################
  
  nav_panel(
    
    title = tagList(bs_icon("folder2-open"), "Data & Preprocessing"),
    
    fluidPage(
      
      fluidRow(
        
        column(
          6,
          card(
            card_header("Before Normalization"),
            withSpinner(imageOutput("before", height = "380px", width = "100%"), color = "#2C7FB8")
          )
        ),
        
        column(
          6,
          card(
            card_header("After Normalization"),
            withSpinner(imageOutput("after", height = "380px", width = "100%"), color = "#2C7FB8")
          )
        )
        
      ),
      
      br(),
      
      fluidRow(
        column(
          12,
          card(
            card_header("Density Plot"),
            withSpinner(imageOutput("density", height = "450px", width = "100%"), color = "#2C7FB8")
          )
        )
      )
      
    )
    
  ),
  
  ############################################################
  # DIFFERENTIAL EXPRESSION
  ############################################################
  
  nav_panel(
    
    title = tagList(bs_icon("bar-chart-line"), "Differential Expression"),
    
    fluidPage(
      
      # Quick-glance stat callouts
      layout_column_wrap(
        width = 1/3,
        value_box(
          title = "Status",
          value = textOutput("vb_status"),
          showcase = bs_icon("check-circle"),
          theme = "success"
        ),
        value_box(
          title = "Significant Genes Shown",
          value = textOutput("vb_gene_count"),
          showcase = bs_icon("list-ol"),
          theme = "info"
        ),
        value_box(
          title = "Dataset",
          value = textOutput("vb_dataset"),
          showcase = bs_icon("database"),
          theme = "primary"
        )
      ),
      
      br(),
      
      card(
        card_header("Differential Expression Summary"),
        verbatimTextOutput("summary"),
        br(),
        tableOutput("sigtable")
      )
      
    )
    
  ),
  
  ############################################################
  # VISUALIZATIONS
  ############################################################
  
  nav_panel(
    
    title = tagList(bs_icon("graph-up"), "Visualizations"),
    
    fluidPage(
      
      card(
        card_header("Volcano Plot"),
        withSpinner(imageOutput("volcano", height = "550px", width = "100%"), color = "#2C7FB8")
      ),
      
      br(),
      
      card(
        card_header("PCA Plot"),
        withSpinner(imageOutput("pca", height = "500px", width = "100%"), color = "#2C7FB8")
      ),
      
      br(),
      
      card(
        card_header("Heatmap"),
        withSpinner(imageOutput("heatmap", height = "650px", width = "100%"), color = "#2C7FB8")
      )
      
    )
    
  ),
  
  ############################################################
  # DOWNLOADS
  ############################################################
  
  nav_panel(
    
    title = tagList(bs_icon("download"), "Downloads"),
    
    fluidPage(
      
      card(
        card_header("Download Analysis Results"),
        
        downloadButton("download_sig", "Download Significant Genes", class = "btn-outline-primary w-100"),
        
        br(), br(),
        
        downloadButton("download_all", "Download Complete Results", class = "btn-outline-primary w-100")
      )
      
    )
    
  )
  
)

############################################################
# SERVER
############################################################

server <- function(input, output, session) {
  
  # Tracks whether a pipeline run has completed successfully,
  # and stores the accession it ran for. Nothing tries to load
  # plots/tables until this is populated.
  pipeline_result <- reactiveVal(NULL)
  
  observeEvent(input$run, {
    
    accession <- trimws(input$geo)
    
    if (nchar(accession) == 0) {
      showNotification("Please enter a GEO accession.", type = "error")
      return(invisible(NULL))
    }
    
    withProgress(
      message = "Running GEO Pipeline...",
      value = 0,
      {
        
        incProgress(0.2, detail = "Loading pipeline...")
        
        result <- tryCatch({
          
          source("geo_pipeline.R")
          
          list(
            success = TRUE,
            accession = "GSE63514",
            error = NULL
          )
          
        }, error = function(e){
          
          list(
            success = FALSE,
            accession = "GSE63514",
            error = conditionMessage(e)
          )
          
        })
        
        incProgress(0.5, detail = "Generating plots...")
        
        incProgress(1, detail = "Completed!")
        pipeline_result(result)
        
      }
    )
    
  })
  
  ############################################################
  # STATUS MESSAGE (sidebar)
  ############################################################
  
  output$status_message <- renderUI({
    
    res <- pipeline_result()
    
    if (is.null(res)) {
      return(tags$em(class = "text-muted", "No analysis run yet."))
    }
    
    if (res$success) {
      tags$span(class = "text-success", bs_icon("check-circle-fill"), paste("Completed:", res$accession))
    } else {
      tags$span(class = "text-danger", bs_icon("x-circle-fill"), paste("Failed:", res$error))
    }
    
  })
  
  ############################################################
  # SIGNIFICANT GENES DATA (shared reactive so we don't re-read
  # the CSV separately for the table and the value box)
  ############################################################
  
  sig_genes <- reactive({
    
    res <- pipeline_result()
    req(!is.null(res) && res$success)
    
    file <- file.path("results", paste0(res$accession, "_significant_genes.csv"))
    req(file.exists(file))
    
    read.csv(file)
    
  })
  
  ############################################################
  # VALUE BOXES
  ############################################################
  
  output$vb_status <- renderText({
    res <- pipeline_result()
    if (is.null(res)) "Not run" else if (res$success) "Completed" else "Failed"
  })
  
  output$vb_gene_count <- renderText({
    df <- tryCatch(sig_genes(), error = function(e) NULL)
    if (is.null(df)) "—" else nrow(df)
  })
  
  output$vb_dataset <- renderText({
    res <- pipeline_result()
    if (is.null(res)) "—" else res$accession
  })
  
  ############################################################
  # SUMMARY
  ############################################################
  
  output$summary <- renderPrint({
    
    res <- pipeline_result()
    validate(need(!is.null(res) && res$success, "Run the analysis to see a summary."))
    
    cat("Dataset :", res$accession, "\n\n")
    cat("Pipeline : GEOquery + limma\n\n")
    cat("Status : Analysis Completed Successfully\n\n")
    cat("Outputs Generated:\n")
    cat("- Boxplots\n")
    cat("- Density Plot\n")
    cat("- Volcano Plot\n")
    cat("- PCA Plot\n")
    cat("- Heatmap\n")
    cat("- CSV Results\n")
    
  })
  
  ############################################################
  # SIGNIFICANT GENES TABLE
  ############################################################
  
  output$sigtable <- renderTable({
    validate(need(!is.null(pipeline_result()) && pipeline_result()$success, "No results yet."))
    head(sig_genes(), 10)
  })
  
  ############################################################
  # IMAGE HELPER
  # Waits for a successful pipeline run and checks the file
  # exists before trying to display it, instead of erroring out.
  ############################################################
  
  render_plot <- function(path, height, width) {
    
    renderImage({
      
      res <- pipeline_result()
      validate(need(!is.null(res) && res$success, "Run the analysis to generate this plot."))
      validate(need(file.exists(path), paste("Image not found:", path)))
      
      list(
        src = normalizePath(path),
        contentType = "image/png",
        height = height,
        width = width
      )
      
    }, deleteFile = FALSE)
    
  }
  
  ############################################################
  # IMAGE OUTPUTS
  ############################################################
  
  output$before   <- render_plot("figures/boxplot_before.png", height = 380, width = 700)
  output$after    <- render_plot("figures/boxplot_after.png",  height = 380, width = 700)
  output$density  <- render_plot("figures/density_before.png", height = 450, width = 850)
  output$volcano  <- render_plot("figures/volcano_plot.png",   height = 550, width = 850)
  output$pca      <- render_plot("figures/PCA.png",            height = 500, width = 700)
  output$heatmap  <- render_plot("figures/heatmap.png",        height = 650, width = 850)
  
  ############################################################
  # DOWNLOAD BUTTONS
  ############################################################
  
  output$download_sig <- downloadHandler(
    
    filename = function() {
      res <- pipeline_result()
      paste0(if (!is.null(res)) res$accession else "results", "_significant_genes.csv")
    },
    
    content = function(file) {
      res <- pipeline_result()
      src <- file.path("results", paste0(if (!is.null(res)) res$accession else "GSE63514", "_significant_genes.csv"))
      if (file.exists(src)) file.copy(src, file)
    }
    
  )
  
  output$download_all <- downloadHandler(
    
    filename = function() {
      res <- pipeline_result()
      paste0(if (!is.null(res)) res$accession else "results", "_all_results.csv")
    },
    
    content = function(file) {
      res <- pipeline_result()
      src <- file.path("results", paste0(if (!is.null(res)) res$accession else "GSE63514", "_all_results.csv"))
      if (file.exists(src)) file.copy(src, file)
    }
    
  )
  
}

############################################################
# RUN APP
############################################################

shinyApp(ui, server)