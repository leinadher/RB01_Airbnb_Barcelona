# Barcelona Airbnb Insights

**Author:** Daniel Herrera & Rodrigo González

**Date:** 22/02/2024

---

## 1. Project Overview

The project is an observational study of Airbnb data from the city of Barcelona, aimed at extracting insights and drawing conclusions within the context of the city's increasingly saturated tourism industry and strained housing market. Our data-driven approach is complemented by an analysis of local policies and the latest information from Spanish media on the subject, ensuring a comprehensive perspective. The project has been developed using a GitHub repository to facilitate collaboration across multiple devices and to ensure reproducibility of the results.

## 2. Repository structure:

- 📁 'Data': contains the data sources used for analysis.
- 📁 'Assets': holds images embedded in the RMarkdown report.
- 📄 'Barcelona-AirBnB-Insights.Rmd': the main RMarkdown file for the report.
- 📄 'Barcelona-AirBnB-Insights.html': the exported RMarkdown report.
- 📁 'Barcelona-AirBnB-Insights_cache': caches some of the plots (especially maps) to speed up the knitting process.

## 3. Additional notes

- 📂 Working Directory: The R working directory (wd) is configured to be the directory of the file itself, ensuring it looks for the data sets there.
- 🔄 Automatic Data Import: The R code automatically creates data frames assigned to variables from the contents of the 'Data' folder, as long as they include the `listings.csv` file. This import workflow was initially designed for a project covering multiple cities' data.
- 🌐 API Import: The second data set, imported via API, can be found in 'Data/2023_pad_mdbas_sexe.csv' as an alternative import source.
