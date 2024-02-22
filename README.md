Barcelona Airbnb Insights
Daniel Herrera & Rodrigo González
22.02.2024

---

The project has been developed on a GitHub repository, to allow working from different devices and to ensure reproducibility. The URL to the repository is:

https://github.com/leinadher/RB01_AirBnB_TwoCities

NOTE: The visibility of the repository is set to private at the time of writing this readme file.

---

#### Repository structure:

- The data sources are stored in the 'Data' folder.
- Images embedded in the RMarkdown report can be located in the 'Assets' folder.
- The RMarkdown file can be found in 'Barcelona-AirBnB-Insights.Rmd'.
- The exported RMarkdown report is 'Barcelona-AirBnB-Insights.html'.
- To speed up the knitting of the report, some of the plots (specifically the maps) have been cached in 'Barcelona-AirBnB-Insights_cache'.

---

#### Additional notes:

- The R working directory (wd) is configured to be the directory of the file itself, and will look for the data sets there.
- The R code automatically creates data frames assigned to variables from the contents of 'Data', as long as they contain 'listings.csv' file. This import workflow was defined when the project aimed at covering more than one city's data.
- The second data set, imported via API, can be found in 'Data/2023_pad_mdbas_sexe.csv', as an alternative import source.