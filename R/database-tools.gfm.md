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
  "openxlsx",
  "RSQLite",
  "tidyverse",
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
csv_data = utils::read.csv("./R/dataset_tidy.csv")            # faster execution
xlsx_data = openxlsx::read.xlsx("./R/dataset_raw.xlsx")       # preserves naming & header data
xlsx_workbook = openxlsx::loadWorkbook("./R/dataset_raw.xlsx")# extract tab/sheet from workbook

# excel header sometimes needed to extract location & date 
header = xlsx_workbook$worksheets[[1]]$headerFooter$oddHeader[[2]]
header
```

::: {.cell-output .cell-output-stdout}

```
[1] "&amp;&quot;Times New Roman,Regular&quot;&amp;12&amp;A"
```


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
```
:::



To add content from a dataframe or excel file to the new SQL database, use `dbWriteTable()` functions: 



::: {.cell}

```{.r .cell-code}
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


## Preprocess database

Note that the `dbGetQuery()` function produces outputs in dataframe format, which we can clean using base R and tidyverse functions.



::: {.cell}

```{.r .cell-code}
# review structure
str(species_volume_1)
```

::: {.cell-output .cell-output-stdout}

```
'data.frame':	24 obs. of  2 variables:
 $ species_j: chr  "Sp1" "Sp1" "Sp1" "Sp1" ...
 $ volume   : num  3.3 4.8 4.08 1.38 3.3 4.8 4.08 1.38 3.3 4.8 ...
```


:::

```{.r .cell-code}
# review categoricals 
dplyr::count(species_volume_1, species_j)
```

::: {.cell-output-display}

|species_j |  n|
|:---------|--:|
|Sp1       | 24|

:::

```{.r .cell-code}
# relabel columns
species_volume_1_renamed = dplyr::rename(species_volume_1, species = 'species_j')

# check missing values
species_volume_1_renamed |>
  select(species, volume) |> # inspect specific columns
  summarise(across(.fns = ~sum(is.na(.)))) |>
  pivot_longer(everything())
```

::: {.cell-output-display}

|name    | value|
|:-------|-----:|
|species |     0|
|volume  |     0|

:::

```{.r .cell-code}
# drop missing values
species_volume_1_renamed_cleaned = species_volume_1_renamed |> drop_na()
```
:::



## Disconnect sql database



::: {.cell}

```{.r .cell-code}
DBI::dbDisconnect(db_connection)
```
:::



 
## Convert to script.R



::: {.cell}

```{.r .cell-code}
knitr::purl("database-tools.qmd")
```
:::
