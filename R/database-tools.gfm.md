---
title: "SQLite Database Tools in R"
format: 
  gfm:
    toc: true
    toc-location: right
    toc-title: "**Contents**"
    toc-depth: 5
    toc-expand: 4
    theme: [minimal, ./R/styles.scss]
df-print: kable
keep-md: true
prefer-html: true
---




## Install packages



::: {.cell}

```{.r .cell-code}
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
  "readxl",
  "RSQLite",
  "tinytex")
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE,
  error = TRUE, comment = NA, tidy.opts = list(width.cutoff = 60)) 
options(htmltools.dir.version = FALSE, htmltools.preserve.raw = FALSE)
sf::sf_use_s2(use_s2 = FALSE)
```
:::



## Import excel data



::: {.cell}

```{.r .cell-code}
set.seed(333)
excel_data <- read.csv("./R/dataset_tidy.csv")
excel_data
```

::: {.cell-output-display}

| stratum_i| plot_sp|species_j |tree_l | volume| bcef_r|  cf|   d|
|---------:|-------:|:---------|:------|------:|------:|---:|---:|
|         1|       1|Sp1       |t1     |   3.30|    0.7| 0.5| 0.5|
|         1|       1|Sp1       |t2     |   4.80|    0.7| 0.5| 0.5|
|         1|       1|Sp1       |t3     |   4.08|    0.7| 0.5| 0.5|
|         1|       2|Sp4       |t1     |   1.50|    0.7| 0.5| 0.5|
|         1|       2|Sp4       |t2     |   1.68|    0.7| 0.5| 0.5|
|         2|       1|Sp1       |t1     |   1.38|    0.7| 0.5| 0.5|
|         2|       1|Sp2       |t2     |   3.24|    0.7| 0.5| 0.5|
|         2|       1|Sp3       |t3     |   3.72|    0.7| 0.5| 0.5|
|         2|       1|Sp4       |t4     |   2.94|    0.7| 0.5| 0.5|
|         2|       1|Sp5       |t5     |   3.36|    0.7| 0.5| 0.5|

:::
:::



## Build sql database

To create an empty SQL database from scratch, simply supply the filename to `dbConnect()`:



::: {.cell}

```{.r .cell-code}
# establish connection / create empty database
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.db")
#db_connection = dbConnect(RSQLite::SQLite(), "")         #temporary on-disk database
#db_connection = dbConnect(RSQLite::SQLite(), ":memory:") #temporary in-memory database

# enable additional extensions in RSQLite
RSQLite::initExtension(db_connection, extension = c("math", "regexp", "series", "csv", "uuid"))

# disconnect
#DBI::dbDisconnect(db_connection)
```
:::



To add content from a dataframe or excel file to the new SQL database, use `dbWriteTable()` functions: 



::: {.cell}

```{.r .cell-code}
# connect
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.db")

# write new table
DBI::dbWriteTable(
  conn      = db_connection, 
  name      = "tree_init", 
  value     = excel_data, 
  overwite  = T, 
  append    = T
  )

# review content
DBI::dbListTables(db_connection)
```

::: {.cell-output .cell-output-stdout}

```
[1] "dataset_tidy" "tree_init"   
```


:::

```{.r .cell-code}
DBI::dbListFields(db_connection, name = "tree_init")
```

::: {.cell-output .cell-output-stdout}

```
[1] "stratum_i" "plot_sp"   "species_j" "tree_l"    "volume"    "bcef_r"   
[7] "cf"        "d"        
```


:::
:::



## Query sql database



::: {.cell}

```{.r .cell-code}
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

::: {.cell-output-display}

|species_j | volume|
|:---------|------:|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|

:::

```{.r .cell-code}
species_volume_2
```

::: {.cell-output-display}

|species_j | volume|
|:---------|------:|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|
|Sp1       |   3.30|
|Sp1       |   4.80|
|Sp1       |   4.08|
|Sp1       |   1.38|

:::
:::



## Disconnect dql database




::: {.cell}

```{.r .cell-code}
DBI::dbDisconnect(db_connection)
```
:::



 
## Convert to R.script



::: {.cell}

```{.r .cell-code}
knitr::purl("database-tools.qmd")
```
:::
