# GEO Differential Expression Analysis — Shiny App

An interactive R Shiny application for exploring gene expression data and performing differential expression analysis using the Gene Expression Omnibus (GEO) dataset **GSE63514**.

The project demonstrates an R-based bioinformatics workflow, from gene expression data retrieval and preprocessing to statistical analysis, visualisation, and downloadable results.

## Live Demo

**[Launch the Shiny application](http://98.87.152.147:3838/geo-app/)**

> Note: The demo currently uses HTTP rather than HTTPS. Do not submit sensitive information through this application.

## Project Overview

Gene expression analysis helps identify genes whose expression differs between biological conditions. This application provides a graphical interface for exploring a GEO microarray dataset and examining the results of differential expression analysis.

The application combines R, Shiny, and bioinformatics packages to make the workflow accessible through an interactive web interface.

## Features

- Interactive Shiny interface for launching the analysis.
- GEO dataset retrieval and expression data preprocessing.
- Expression distribution visualisation before and after normalisation.
- Principal component analysis (PCA) for exploring sample-level variation.
- Differential expression analysis using the `limma` package.
- Volcano plot and heatmap visualisations.
- Downloadable CSV files containing analysis results.
- Separate output files for significant, upregulated, and downregulated genes.

## Analysis Workflow

The pipeline in `geo_pipeline.R` implements the following steps:

1. **Data retrieval:** Retrieves the GSE63514 expression dataset using GEOquery.
2. **Preprocessing:** Extracts the expression matrix and sample metadata and checks for missing values.
3. **Expression transformation:** Applies a log2 transformation when indicated by the expression-value distribution.
4. **Normalisation:** Performs quantile normalisation.
5. **Quality assessment:** Generates boxplots and density plots to examine expression distributions.
6. **Differential expression analysis:** Fits a linear model and applies empirical Bayes moderation using `limma`.
7. **Significance filtering:** Identifies candidate differentially expressed genes using adjusted p-value and log-fold-change thresholds.
8. **Visualisation:** Generates PCA, heatmap, and volcano plot figures.
9. **Result export:** Writes the analysis tables to CSV files.

The current significance thresholds are an adjusted p-value below 0.05 and an absolute log2 fold change greater than 1.

## Technologies Used

- **R** — data analysis and statistical computing
- **Shiny** — interactive web application
- **GEOquery** — retrieval of GEO datasets
- **Biobase** — expression data and sample metadata handling
- **limma** — differential expression analysis
- **preprocessCore** — quantile normalisation
- **ggplot2** — data visualisation
- **pheatmap** — heatmap generation
- **bslib** — Shiny interface styling
- **bsicons** — interface icons
- **shinycssloaders** — loading indicators

## Repository Structure

```text
geo-gse63514-shiny-demo/
├── app.R
├── geo_pipeline.R
├── geo-gse63514-shiny-demo.Rproj
├── README.md
├── .gitignore
├── figures/
│   ├── boxplot_before.png
│   ├── density_before.png
│   ├── boxplot_after.png
│   ├── PCA.png
│   ├── heatmap.png
│   └── volcano_plot.png
└── results/
    ├── GSE63514_all_results.csv
    ├── GSE63514_significant_genes.csv
    ├── GSE63514_upregulated.csv
    └── GSE63514_downregulated.csv
```

## Requirements

You will need:

- R
- RStudio (recommended)
- An internet connection for retrieving GEO data and installing missing packages
- The R packages used by the application and pipeline

The application uses `app.R` as its Shiny entry point and sources `geo_pipeline.R` to perform the analysis.

## Running Locally

1. Clone or download this repository.
2. Open `geo-gse63514-shiny-demo.Rproj` in RStudio.
3. Ensure the required R packages are installed.
4. Open `app.R`.
5. Click **Run App** in RStudio.

The pipeline creates `data/`, `figures/`, and `results/` directories as needed and writes its output files to the project directory.

If package installation or GEO data retrieval fails, check your internet connection and verify that the required R and Bioconductor packages are available.

## Output Files

### Figures

| File | Description |
|---|---|
| `boxplot_before.png` | Expression distributions before normalisation |
| `density_before.png` | Expression density before normalisation |
| `boxplot_after.png` | Expression distributions after normalisation |
| `PCA.png` | Principal component analysis visualisation |
| `heatmap.png` | Heatmap of selected genes |
| `volcano_plot.png` | Differential expression visualisation |

### Results

| File | Description |
|---|---|
| `GSE63514_all_results.csv` | Complete differential expression results |
| `GSE63514_significant_genes.csv` | Genes meeting the configured significance thresholds |
| `GSE63514_upregulated.csv` | Upregulated genes according to the pipeline's group contrast |
| `GSE63514_downregulated.csv` | Downregulated genes according to the pipeline's group contrast |

## Current Limitations

- The application is currently configured for **GSE63514**. Entering another accession in the interface does not currently make the analysis work with an arbitrary GEO dataset.
- Sample grouping and the direction of differential expression depend on the metadata and model contrast implemented in the pipeline.
- The selected significance thresholds are analysis settings and should not be interpreted as independent confirmation of biological importance.
- Results should be validated against the dataset's sample annotations and study design before drawing biological conclusions.
- The deployed demonstration uses HTTP rather than HTTPS.

## Future Improvements

- Support for additional GEO accessions with dataset-specific validation.
- More robust sample metadata selection and group configuration.
- Improved error handling and validation of generated output files.
- Interactive filtering and exploration of differential expression results.
- Reproducible package management and automated testing.

## Disclaimer

This project is intended for educational and portfolio demonstration purposes. Its outputs are computational analysis results and should be independently validated before being used to support biological or clinical conclusions.