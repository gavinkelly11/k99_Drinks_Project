# EMA Data Processing Pipeline: Real-Time Drink Preferences

**Overview**
This repository contains the R Markdown data pipeline used to process, merge, and prepare Ecological Momentary Assessment (EMA) and choice-task data for statistical analysis. The pipeline transforms raw survey and experimental data into a clean, unified dataset designed for modeling behavioral choices between alcoholic and non-alcoholic beverages across varying real-world contexts.

## Pipeline Architecture

The data processing workflow is divided into modular `.Rmd` scripts, executing in three primary stages: data cleaning, merging, and exploratory output.

### 1. Data Cleaning & Level Processing
These scripts process the raw data at three distinct observational levels:
*   `k99_baseline_data.Rmd` — Cleans and standardizes participant-level baseline demographic and trait data.
*   `k99_survey_data.Rmd` — Processes the EMA survey responses, handling timestamp alignments and contextual environmental variables.
*   `k99_choicetask_data.Rmd` — Cleans the high-volume experimental choice task data (~950,000 observations).

### 2. Merging & Preparation
*   `k99_data_merging.Rmd` — Merges the baseline, survey, and choice-task data into a single, cohesive relational dataset.
*   `k99_analysis_data.Rmd` — Finalizes data preparation, including any final variable transformations or factor coding required for the statistical modeling phase.

### 3. Exploration & Visualizations
*   `k99_descriptive_statistics.Rmd` — Extracts quantitative summary statistics for baseline demographics and contextual variables.
*   `k99_data_plots.Rmd` — Generates data visualizations mapping preference shifts and choice distributions.

## Tech Stack
*   **Language:** R
*   **Environment:** RStudio / R Markdown
*   **Key Packages:** `tidyverse`, `ggplot2`
