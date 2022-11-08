#! /bin/bash

tr ";" "\t" < /mongo-seed/file1.csv | mongoimport -u "<user>" -p "<pass>" --authenticationDatabase "<database_name>" --host database --db cancerDatabase --collection patients --type tsv  --headerline
tr ";" "\t" < /mongo-seed/file2.csv | mongoimport -u "<user>" -p "<pass>" --authenticationDatabase "<database_name>" --host database --db cancerDatabase --collection tumors --type tsv  --headerline
