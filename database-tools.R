## ----setup-------------------------------------------------------------------------------------------------------------
#| warning: false
#| message: false
#| error: false
#| echo: true
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


## ----------------------------------------------------------------------------------------------------------------------
set.seed(333)
excel_data <- read.csv("./R/dataset_tidy.csv")
excel_data


## ----------------------------------------------------------------------------------------------------------------------
# enable additional extensions in RSQLite
RSQLite::initExtension(db_connection, extension = c("math", "regexp", "series", "csv", "uuid"))

# establish connection / create empty database
db_connection <- DBI::dbConnect(RSQLite::SQLite(), "/Users/seamus/Repos/database-tools/R/database.db")
#db_connection = dbConnect(RSQLite::SQLite(), "")         #temporary on-disk database
#db_connection = dbConnect(RSQLite::SQLite(), ":memory:") #temporary in-memory database
DBI::dbDisconnect(db_connection)


## ----------------------------------------------------------------------------------------------------------------------
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
DBI::dbListFields(db_connection, name = "tree_init")


## ----------------------------------------------------------------------------------------------------------------------
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
species_volume_2


## ----------------------------------------------------------------------------------------------------------------------
create_table = DBI::dbExecute(db_connection, "CREATE TABLE tree_init (
  stratum_i : INTEGER,
  plot_sp   : INTEGER,
  tree_l    : CHAR,
  volume    : INTEGER,
  bcef_r    : INTEGER,
  cf        : INTEGER,
  f         : INTEGER
  )") 


## ----------------------------------------------------------------------------------------------------------------------
#| eval: false
# knitr::purl("database-tools.qmd")

