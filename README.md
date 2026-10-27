# GitHub Repository Popularity — R Project

This project contains a commented R notebook, a small interactive R Shiny dashboard, and the supplied CSV files.

## Files
- `GitHub_Popularity_Analysis_R.ipynb` — notebook with EDA and a simple Linear Regression model. It uses an **R kernel**.
- `app.R` — interactive dashboard with filters, summary metrics, charts, and regression evaluation.
- `data/github_trending_repos.csv` — main dataset (1,587 rows, 13 columns).
- `data/language_summary.csv` and `data/top_owners.csv` — supporting summary CSVs from the supplied archive.

## Dataset analysis notes
- Main dataset: 1,587 rows and 13 columns.
- `description` has 36 missing values; it is not required by this model.
- `contributors_count` is 0 in all rows, so it is excluded as a predictor.
- `full_name` has 1,049 unique values across 1,587 rows; repositories can appear in multiple search-language/timeframe contexts.
- The notebook/dashboard use `forks` as the one predictor and `stars_period` as the target. Log transforms reduce skew from very large counts.
- The dataset consists of repositories already captured as trending. Results describe associations in this dataset and do not prove causation or generalize automatically to all GitHub repositories.

## Run the notebook
1. Install R from https://cran.r-project.org/bin/windows/base/
2. Install Jupyter and the R kernel (`IRkernel`) if you want to open the `.ipynb` in Jupyter.
3. In an R console, install the kernel once:
   ```r
   install.packages("IRkernel")
   IRkernel::installspec()
   ```
4. Open Jupyter, select the **R** kernel, and run the notebook from the project root folder so the `data/` directory is visible.
5. The notebook uses base R only; it does not require machine-learning packages.

## Run the dashboard
1. Open R or RStudio in the project root folder.
2. Install Shiny once if needed:
   ```r
   install.packages("shiny")
   ```
3. Start the dashboard:
   ```r
   shiny::runApp()
   ```
   Or open `app.R` in RStudio and click **Run App**.

## Metrics
- **MAE**: average absolute prediction error, in stars.
- **RMSE**: prediction error that penalizes large errors more strongly.
- **Test R-squared**: compares the model against predicting the test-set mean. It can be negative.

## Suggested report structure (10 marks)
1. **2 marks — Relevance/problem/objectives/source:** use the problem statement and objectives in the notebook.
2. **3 marks — EDA:** show the summary, language bar chart, scatter plot and correlation output.
3. **5 marks — Model/demo/report:** show the regression formula, coefficients, test metrics, actual-vs-predicted chart, and limitations.


## Run the dashboard (Windows)

1. Open PowerShell in the `github_popularity_project` folder.
2. Install Shiny once if needed: `Rscript -e "install.packages('shiny', repos='https://cloud.r-project.org')"`. If the default R library is not writable, install it in your user library.
3. Start the dashboard: `Rscript -e "shiny::runApp('.')"`.
4. Keep the terminal open and open the local URL shown by R.

The dashboard uses only **Shiny** and base R for charts, so no plotting package is required. The layout adjusts for smaller screens.


## Run the improved dashboard

1. Open PowerShell in the folder that contains `app.R`.
2. Install Shiny once if needed:

   ```r
   install.packages("shiny", repos = "https://cloud.r-project.org")
   ```

3. Start the dashboard:

   ```r
   shiny::runApp(".")
   ```

   If R is not on your PATH, run this in PowerShell instead:

   ```powershell
   & "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" -e "shiny::runApp('.')"
   ```

The dashboard uses only the `shiny` package. Keep the `data` folder beside `app.R`.
