# GEO-Shiny Demo: Gene Expression Analysis with R Shiny

An interactive R Shiny web application for exploring gene expression data and performing differential expression analysis using the **GSE63514 cervical cancer dataset** from the Gene Expression Omnibus (GEO).

The application integrates data processing, statistical analysis, and visualization into a single interface, allowing users to explore gene expression patterns without manually executing each analysis step.

## 🚀 Live Demo

**[Open the GEO-Shiny Application](http://98.87.152.147:3838/geo-app/)**

The application is deployed on an AWS EC2 instance running Ubuntu and Shiny Server.

> **Note:** The live demo depends on the availability of the AWS instance. The URL may change if the instance's public IP address changes.

---

## 📌 Project Overview

Gene expression analysis helps identify differences in gene activity between biological conditions. These differences can provide insights into disease-associated molecular changes and potential biomarkers.

This project provides a web-based workflow for analyzing the GSE63514 gene expression dataset, which contains cervical cancer and control samples.

The application enables users to:
- Load and process the selected gene expression dataset.
- Perform differential expression analysis.
- Identify statistically significant differentially expressed probes.
- Explore upregulated and downregulated genes.
- Visualize expression patterns using interactive analysis outputs.
- Download analysis results for further investigation.

The application is designed to make a bioinformatics workflow more accessible through an intuitive graphical interface.

## 🧬 Dataset

**Dataset:** GSE63514  
**Source:** [NCBI Gene Expression Omnibus (GEO)](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE63514)

The dataset contains gene expression measurements from cervical cancer and control samples.

| Attribute | Details |
|---|---|
| GEO accession | GSE63514 |
| Data type | Gene expression microarray |
| Platform | GPL570 |
| Control samples | 24 |
| Cancer samples | 28 |
| Total samples | 52 |
| Analysis type | Differential expression analysis |

The application uses the GEO series matrix and platform annotation data to support the analysis.

## ✨ Features

### 1. Automated Analysis Workflow
Run the analysis through the Shiny interface instead of executing the pipeline manually.

### 2. Differential Expression Analysis
Identify differentially expressed probes and examine their statistical results.

### 3. Gene Expression Visualization
The application generates visualizations to explore sample distributions, expression patterns, and differences between groups.

Available plots include:

- **Principal Component Analysis (PCA):** Explore sample-level expression patterns.
- **Boxplots before and after normalization:** Compare expression distributions.
- **Density plot:** Examine the distribution of expression values.
- **Heatmap:** Visualize expression patterns across samples.
- **Volcano plot:** Explore differential expression results by statistical significance and expression change.

### 4. Differential Expression Results
Explore the complete analysis results alongside filtered lists of significant, upregulated, and downregulated probes.

### 5. Downloadable Results
Download generated result tables for further analysis using R, Python, or other bioinformatics tools.

### 6. Cached Analysis Results
The application checks whether the required analysis outputs already exist before executing the pipeline.

When valid, non-empty output files are available for the supported dataset, the app reuses them instead of rerunning the computationally intensive analysis.

This improves the experience when reopening the application or requesting results again.

**Current limitation:** The caching implementation is designed for GSE63514 and its existing output files. It is not a general-purpose cache for arbitrary GEO accessions.

---

## 🔬 Analysis Workflow

The application follows this general workflow:

1. **Data acquisition:** Use the GSE63514 series matrix and GPL570 platform annotation files.
2. **Data preparation:** Prepare the expression data and sample information for downstream analysis.
3. **Normalization and quality assessment:** Examine expression distributions before and after normalization.
4. **Exploratory analysis:** Generate PCA plots and heatmaps to investigate sample-level expression patterns.
5. **Differential expression analysis:** Compare cancer and control samples to identify differentially expressed probes.
6. **Result filtering:** Separate significant probes into upregulated and downregulated groups according to the pipeline's analysis criteria.
7. **Visualization:** Generate boxplots, density plots, heatmaps, and a volcano plot.
8. **Result export:** Make the generated result tables available for download.
9. **Result reuse:** Load existing outputs when available, avoiding unnecessary pipeline execution.

The underlying analysis is implemented in `geo_pipeline.R`, while `app.R` provides the Shiny user interface and application logic.

---

## 📊 Analysis Results

The existing analysis of GSE63514 produced the following results:

| Metric | Result |
|---|---:|
| Control samples | 24 |
| Cancer samples | 28 |
| Total samples | 52 |
| Significant probes | 4,897 |
| Upregulated probes | 2,521 |
| Downregulated probes | 2,376 |

These counts reflect the current pipeline output and its filtering criteria.

**Important:** The results represent differentially expressed probes, not necessarily unique genes. Probe-level findings may require annotation and consolidation before interpreting them as gene-level results.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| R | Statistical computing and analysis |
| Shiny | Interactive web application |
| GEO data | Gene expression dataset |
| GPL570 annotation | Microarray platform annotation |
| PCA | Exploratory analysis of sample expression patterns |
| Data visualization in R | Expression plots and differential expression visualization |
| AWS EC2 | Cloud hosting infrastructure |
| Ubuntu | Server operating system |
| Shiny Server | Hosting the R Shiny application |
| Git and GitHub | Version control and source code management |

---

## 📁 Repository Structure

```text
GEO-Shiny-demo/
│
├── app.R
│   └── Shiny user interface, server logic, and result caching
│
├── geo_pipeline.R
│   └── Gene expression analysis pipeline
│
├── data/
│   ├── GSE63514_series_matrix.txt.gz
│   └── GPL570.soft.gz
│
├── results/
│   ├── GSE63514_all_results.csv
│   ├── GSE63514_significant_genes.csv
│   ├── GSE63514_upregulated.csv
│   └── GSE63514_downregulated.csv
│
├── figures/
│   ├── PCA.png
│   ├── boxplot_before.png
│   ├── boxplot_after.png
│   ├── density_before.png
│   ├── heatmap.png
│   └── volcano_plot.png
│
└── README.md
```

The result and figure files are generated by the analysis pipeline and reused by the application when available.

---

## 💻 Running the Application Locally

### Prerequisites

- R
- RStudio (recommended)
- The required R packages used by the application and analysis pipeline
- The dataset and annotation files in the expected directory structure

### 1. Clone the repository

```bash
git clone https://github.com/grahaeyy/GEO-Shiny-demo.git
cd GEO-Shiny-demo
```

### 2. Open the project

Open the project directory in RStudio.

Ensure that the working directory is the repository root, where `app.R` and `geo_pipeline.R` are located.

### 3. Install required packages

Install any packages required by the application and pipeline if they are not already available in your R environment.

For example, to install Shiny:

```r
install.packages("shiny")
```

Refer to the library imports in `app.R` and `geo_pipeline.R` for the remaining dependencies.

### 4. Run the application

In RStudio, execute:

```r
shiny::runApp()
```

Alternatively, use the **Run App** button when `app.R` is open in RStudio.

The application will open in your browser.

### 5. Run or reuse the analysis

For the supported GSE63514 dataset, the app can reuse existing results when the required output files are present and non-empty.

If the expected outputs are unavailable, the application can invoke the analysis pipeline.

---

## ☁️ AWS Deployment

The application is hosted on an AWS EC2 instance using Ubuntu and Shiny Server.

### Deployment Architecture

```text
User's Web Browser
        |
        v
AWS EC2 Public IP
        |
        v
Shiny Server
        |
        v
GEO-Shiny Application
        |
        +--------------------+
        |                    |
        v                    v
    app.R              geo_pipeline.R
        |                    |
        +----------+---------+
                   |
                   v
          Existing Analysis Outputs
                   |
          +--------+---------+
          |                  |
          v                  v
      Results CSVs       Plot Images
```

### Deployment Components

- **AWS EC2:** Provides the cloud computing instance.
- **Ubuntu:** Runs the application server environment.
- **Shiny Server:** Serves the Shiny application over HTTP.
- **Application directory:** `/srv/shiny-server/geo-app/`
- **Application entry point:** `app.R`
- **Analysis script:** `geo_pipeline.R`

### Deployment Process

The application was deployed by transferring the updated application code to the EC2 instance and placing it in the Shiny Server application directory.

The analysis outputs and datasets were retained on the server.

The caching update was tested locally before deployment, and the live application was subsequently verified in the browser.

### Version Control and Deployment

GitHub is used to maintain the source code, while the deployed application runs on AWS.

The current workflow is:

1. Modify the code locally.
2. Test the application in RStudio.
3. Commit the changes using Git.
4. Push the changes to GitHub.
5. Deploy the updated application code to AWS.
6. Verify the live application.

**Pushing to GitHub does not automatically deploy changes to AWS.** Deployment is currently a separate step.

---

## ⚡ Performance Improvement: Result Caching

Running a complete gene expression analysis can take longer than simply displaying previously generated outputs.

To reduce unnecessary computation, the application checks whether the expected result CSVs and plot images exist and are non-empty.

When the required files are available, the application initializes with the existing results and reuses them when the user requests the analysis again.

This approach:
- Reduces repeated computation.
- Makes reopening the application faster.
- Avoids regenerating plots and tables unnecessarily.
- Preserves the existing analysis pipeline.

The caching mechanism checks file availability and size. It does not independently validate file contents, dataset versions, or whether the results have become outdated.

---

## ⚠️ Current Limitations

- The application currently supports GSE63514 only.
- The cache relies on existing output files and does not validate their scientific freshness.
- Differential expression results are probe-level outputs; probe-to-gene annotation may be required for gene-level interpretation.
- The live demo depends on the availability and configuration of the AWS EC2 instance.
- The current deployment process is manual rather than an automated CI/CD workflow.
- The application is intended for exploratory bioinformatics analysis and does not independently establish clinical significance.

---

## 🔮 Future Improvements

Potential extensions include:

- Support for additional GEO accession numbers.
- More robust caching based on dataset identifiers and analysis parameters.
- Automatic detection of stale or incomplete results.
- More detailed gene annotation and biological interpretation.
- Additional enrichment and pathway analysis.
- Improved error handling and analysis progress reporting.
- Automated deployment from GitHub to AWS.
- Expanded documentation of statistical methods and filtering thresholds.

---

## 👩‍💻 Author

Developed as a bioinformatics project exploring gene expression analysis, differential expression, R Shiny application development, and cloud deployment.

---

## 📄 License

No license has been specified in this repository. Unless a license is added, others generally do not have permission to reuse, modify, or redistribute the code beyond applicable legal exceptions.

If you intend to make the repository public for reuse, consider adding an appropriate open-source license.
