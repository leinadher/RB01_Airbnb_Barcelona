# Barcelona Airbnb Insights
## Data scraping and analysis of largest Swiss phone resellers
**Authors:** Daniel Herrera, Ramon Burkhard & Jack Brown

**Date:** 13/05/2024

---

## 1. Project Overview

The project involves full Extraction-Transform-Load (ETL) process, from the retrieval of the raw data via web scraping from 3 different Swiss electronics resellers to the analysis and reporting of the transformed and stored data. Because it is a group effort, data from the three resellers has been transformed to follow a group-agreed standardization and structure, prior to loading onto the final database. The three sources are **Galaxus**, **Interdiscount** and **MediaMarkt**.

As the repository is maintained by myself, I have only included my own segment of the code, corresponding to the **Interdiscount** online store, as well as the final assembled dataset and exploratory data analysis in a Jupyter Notebook.

## 2. Repository structure:

- 📁 'exploration': Contains the assembled dataset as well as the EDA report under `ExploratoryDataAnalysis.ipynb`.
- 📁 'ETL_interdiscount': Contains the ETL sequence split into its phases for the reseller Interdiscount.
- 📄 `README.md`: This readme file.

## 3. Additional notes

- 📂 Working Directory: The R working directory (wd) is configured to be the directory of the file itself, ensuring it looks for the data sets there.
- 🔄 Automatic Data Import: The R code automatically creates data frames assigned to variables from the contents of the 'Data' folder, as long as they include the `listings.csv` file. This import workflow was initially designed for a project covering multiple cities' data.
- 🌐 API Import: The second data set, imported via API, can be found in `2023_pad_mdbas_sexe.csv` in the 'Data' folder as an alternative import source.
