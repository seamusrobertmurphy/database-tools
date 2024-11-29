# SQLite Database Tools in R


- [Install packages](#install-packages)
- [Import excel data](#import-excel-data)
- [Build sql database](#build-sql-database)
- [Query sql database](#query-sql-database)
- [Preprocess database](#preprocess-database)
- [Disconnect sql database](#disconnect-sql-database)
- [Convert to script.R](#convert-to-scriptr)

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
  "glue",
  "here",
  "htmltools",
  "janitor",
  "kableExtra",
  "knitr",
  "openxlsx",
  "RSQLite",
  "tidyverse",
  "tinytex")
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE,
  error = TRUE, comment = NA, tidy.opts = list(width.cutoff = 60)) 
options(htmltools.dir.version = FALSE, htmltools.preserve.raw = FALSE)
sf::sf_use_s2(use_s2 = FALSE)
```

## Import excel data

``` r
set.seed(333)
csv_data = utils::read.csv("./R/dataset_tidy.csv")            # faster execution
xlsx_data = openxlsx::read.xlsx("./R/dataset_raw.xlsx")       # preserves naming & header data
xlsx_workbook = openxlsx::loadWorkbook("./R/dataset_raw.xlsx")# extract tab/sheet from workbook

# excel header sometimes needed to extract location & date 
header = xlsx_workbook$worksheets[[1]]$headerFooter$oddHeader[[2]]
header
```

    [1] "&amp;&quot;Times New Roman,Regular&quot;&amp;12&amp;A"

## Build sql database

To create an empty SQL database from scratch, simply supply the filename
to `dbConnect()`:

``` r
# establish connection / create empty database
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.db")
#db_connection = dbConnect(RSQLite::SQLite(), "")         #temporary on-disk database
#db_connection = dbConnect(RSQLite::SQLite(), ":memory:") #temporary in-memory database

# enable additional extensions in RSQLite
RSQLite::initExtension(db_connection, extension = c("math", "regexp", "series", "csv", "uuid"))
```

To add content from a dataframe or excel file to the new SQL database,
use `dbWriteTable()` functions:

``` r
# connect
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.db")

# write table
DBI::dbWriteTable(
  conn      = db_connection, 
  name      = "tree_init", 
  value     = csv_data, 
  overwite  = T, 
  append    = T
  )

# review database
DBI::dbListTables(db_connection)
```

    [1] "dataset_tidy" "tree_init"   

``` r
DBI::dbListFields(db_connection, name = "tree_init")
```

    [1] "stratum_i" "plot_sp"   "species_j" "tree_l"    "volume"    "bcef_r"   
    [7] "cf"        "d"        

## Query sql database

``` r
# write sql query
query =  "SELECT species_j, volume
          FROM tree_init
          WHERE species_j == 'Sp1'"
        
species_volume_1 = DBI::dbGetQuery(db_connection, statement = query)

# dplyr sql query
species_volume_2 = db_connection |>
  dplyr::tbl("tree_init") |>
  dplyr::select(species_j, volume) |>
  dplyr::filter(species_j == 'Sp1') |>
  dplyr::collect()

# check if same
species_volume_1
```

| species_j | volume |
|:----------|-------:|
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |

``` r
species_volume_2
```

| species_j | volume |
|:----------|-------:|
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |
| Sp1       |   3.30 |
| Sp1       |   4.80 |
| Sp1       |   4.08 |
| Sp1       |   1.38 |

## Preprocess database

Note that the `dbGetQuery()` function produces outputs in dataframe
format, which we can clean using base R and tidyverse functions.

``` r
# review structure
str(species_volume_1)
```

    'data.frame':   24 obs. of  2 variables:
     $ species_j: chr  "Sp1" "Sp1" "Sp1" "Sp1" ...
     $ volume   : num  3.3 4.8 4.08 1.38 3.3 4.8 4.08 1.38 3.3 4.8 ...

``` r
# review categoricals 
dplyr::count(species_volume_1, species_j)
```

| species_j |   n |
|:----------|----:|
| Sp1       |  24 |

``` r
# relabel columns
species_volume_1_renamed = dplyr::rename(species_volume_1, species = 'species_j')

# check missing values
species_volume_1_renamed |>
  select(species, volume) |> # inspect specific columns
  summarise(across(.fns = ~sum(is.na(.)))) |>
  pivot_longer(everything())
```

| name    | value |
|:--------|------:|
| species |     0 |
| volume  |     0 |

``` r
# drop missing values
species_volume_1_renamed_cleaned = species_volume_1_renamed |> drop_na()
```

## Disconnect sql database

``` r
DBI::dbDisconnect(db_connection)
```

## Convert to script.R

``` r
knitr::purl("database-tools.qmd")
```
