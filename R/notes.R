The `dbmisc` package builds a sql database using a `.yaml`. Guidance on formatting fields and values in this `.yaml` file are are available in the README of the `dbmisc` repository [here](https://skranz.github.io/dbmisc/). For example, the following text and indentation can be pasted into a yaml file and then saved as `database.yaml`.

```{r}
#| eval: true
table1:
  table:
    stratum_i : INTEGER
    plot_sp   : INTEGER
    tree_l    : CHAR
    volume    : INTEGER
    bcef_r    : INTEGER
    cf        : INTEGER
    f         : INTEGER
```

Using this `yaml` file, the `dbmisc` package generates a new SQLite database from its schema. This is done with the following commands. 

```{r}
#| eval: false

db.dir = "/Users/seamus/Repos/database-tools/R/"
schema.file = system.file("/Users/seamus/Repos/database-tools/R/database.yaml", package="dbmisc")

dbmisc::dbCreateSQLiteFromSchema(
  schema.file   = schema.file, 
  db.dir        = db.dir, 
  db.name       = "database.sqlite",
  )
```