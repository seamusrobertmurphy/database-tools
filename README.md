# SQLite Database Tools in R


- [Install packages](#install-packages)
- [Import dummy dataset](#import-dummy-dataset)
- [Build sqlite database](#build-sqlite-database)
- [Convert to R.script](#convert-to-rscript)

## Install packages

``` r
#devtools::install_github("skranz/restorepoint") # dbmisc dependency
#install.packages("dbmisc", repos = c("https://skranz-repo.github.io/drat/")) # dbmisc package

#install.packages("easypackages")
easypackages::packages(
  "animation",
  "BIOMASS",
  "dataMaid",
  "DBI",
  "dplyr",
  "extrafont",
  "htmltools",
  "janitor",
  "kableExtra",
  "knitr",
  "readxl",
  "RSQLite",
  "tinytex")
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE,
  error = TRUE, comment = NA, tidy.opts = list(width.cutoff = 60)) 
options(htmltools.dir.version = FALSE, htmltools.preserve.raw = FALSE)
sf::sf_use_s2(use_s2 = FALSE)
```

## Import dummy dataset

``` r
set.seed(333)
dataset_tidy <- read.csv("./R/dataset_tidy.csv")
dataset_tidy
```

| stratum_i | plot_sp | species_j | tree_l | volume | bcef_r |  cf |   d |
|----------:|--------:|:----------|:-------|-------:|-------:|----:|----:|
|         1 |       1 | Sp1       | t1     |   3.30 |    0.7 | 0.5 | 0.5 |
|         1 |       1 | Sp1       | t2     |   4.80 |    0.7 | 0.5 | 0.5 |
|         1 |       1 | Sp1       | t3     |   4.08 |    0.7 | 0.5 | 0.5 |
|         1 |       2 | Sp4       | t1     |   1.50 |    0.7 | 0.5 | 0.5 |
|         1 |       2 | Sp4       | t2     |   1.68 |    0.7 | 0.5 | 0.5 |
|         2 |       1 | Sp1       | t1     |   1.38 |    0.7 | 0.5 | 0.5 |
|         2 |       1 | Sp2       | t2     |   3.24 |    0.7 | 0.5 | 0.5 |
|         2 |       1 | Sp3       | t3     |   3.72 |    0.7 | 0.5 | 0.5 |
|         2 |       1 | Sp4       | t4     |   2.94 |    0.7 | 0.5 | 0.5 |
|         2 |       1 | Sp5       | t5     |   3.36 |    0.7 | 0.5 | 0.5 |

## Build sqlite database

To create a new SQLite database from scratch, simply supply the filename
to `dbConnect()`:

``` r
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.sqlite")
dbDisconnect(db_connection)

# for temporary on-disk database, use filename ""
# for temporary in-memory database, use filename  ":memory:"
#mydb <- dbConnect(RSQLite::SQLite(), "")
#mydb <- dbConnect(RSQLite::SQLite(), ":memory:")
```

To copy from an R dataframe into a new SQLite database, use
`dbWriteTable()` functions:

``` r
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.sqlite")
DBI::dbWriteTable(db_connection, "dataset_tidy", dataset_tidy, overwite = T, append = T)
dbListTables(db_connection)
```

    [1] "dataset_tidy"

``` r
dbDisconnect(db_connection)

# alternative workflow; requires empty database to copy into
db_connection <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
RSQLite::initExtension(db_connection)
dplyr::copy_to(db_connection, dataset_tidy)
table_query = dplyr::tbl(db_connection, "dataset_tidy") 
dbplyr::remote_query(table_query)
```

    <SQL> SELECT *
    FROM `dataset_tidy`

``` r
dbDisconnect(db_connection)
```

## Convert to R.script

``` r
knitr::purl("database-tools.qmd")
```
