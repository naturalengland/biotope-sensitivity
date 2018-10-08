## install.packages("devtools")
## install.packages("DBI2)
## install.packages("Rcpp")
#  install.packages("RPostgres")

library(RPostgres)
library(DBI)
library(Rcpp)

pw<- {
  "password"
}

con <- dbConnect(RPostgres::Postgres()
                 , host='localhost'
                 , port='5432'
                 , dbname='postgis_24_sample'
                 , user='postgres'
                 , password=pw)


rm(pw) # removes the password

dbExistsTable(con, "county")
