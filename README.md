# PBCR Platform

[![DOI](https://zenodo.org/badge/563504610.svg)](https://zenodo.org/badge/latestdoi/563504610)

## About the team

* **Authors**:
    * Anna Torres <annattmail@gmail.com>
    * Sergi Lopez <sergi.lopez@udl.cat>
    * Dídac Florensa <didac.florensa@udl.cat>
    * Jordi Mateo <jordi.mateo@udl.cat> @github/JordiMateoUdL

## Background

This repository contains the design and implementation of a shiny app to assist cancer registers in conducting rapid descriptive and predictive analytics in a user-friendly, intuitive, portable and scalable way. We want to describe the design and implementation roadmap to inspire other population registers to exploit their datasets and develop similar tools and models.

## This repository

This repository contains all the code, scripts and services, such as the front-end and back-end, to deploy the cancer web platform.

* CancerRegistry-WebPlatform: This folder contains the scripts to deploy the API and the RShiny service (front-end views). The API was implemented by NodeJS. The RShiny platform is based on the R language.

* CancerRegistryDatabase: This folder contains the scripts to create and deploy the database. It is a non-relational database based on MongoDB. This directory also includes a script to import the data from a CSV file.

## Deployment - Cancer Database

The first step is to create and deploy the database. To do that, you have to move into the CancerRegistryDatabase directory. 

```
cd CancerRegistryDatabase
```

Edit the docker-compose.yml file to specify the name of the database you want to create (the first time) or deploy with a username and password to access it.

```
- MONGO_INITDB_DATABASE=<database_name>
- MONGO_INITDB_ROOT_USERNAME=<username>
- MONGO_INITDB_ROOT_PASSWORD=<password>
```

Avoid this next step if you do not want to use the script to add data and you want to use another system on your own.

To use the mongo seed and import dataset, please edit the [import.sh](CancerRegistryDatabase/mongo-seed/import.sh). Replace the user, pass and database_name with the parameters specified previously. Remember to uncomment the mongo-seed in the [docker-compose.yml](CancerRegistryDatabase/docker-compose.yml). Once the dataset has been uploaded, comment again to avoid the upload again.

```
tr ";" "\t" < /mongo-seed/file1.csv | mongoimport -u "<user>" -p "<pass>" --authenticationDatabase "<database_name>" --host database --db cancerDatabase --collection patients --type tsv  --headerline
```

Once these parameters are specified, run the next command which is going to build de docker container with the MongoDB.

```
docker-compose up -d
```

## Deployment - Cancer Database

To deploy the rshiny app and the API, move inside the CancerRegistry-WebPlatform.

```
cd CancerRegistry-WebPlatform
```
Before the deployment, you need to specify the database access with the parameters speficiy in the database step. Edit the next file [config.js](CancerRegistry-WebPlatform/server/src/config/config.js)

```
db_dialect: process.env.DB_DIALECT || '',
db_host: process.env.DB_HOST       || '',
db_port: process.env.DB_PORT || '27017',
db_name: process.env.DB_NAME || '',
db_user: process.env.DB_USER || '',
db_password: process.env.DB_PASSWORD   || ''
```

Once the acces to database is specified, to execute and deploy the services, run the next command in the CancerRegistry-WebPlatform directory. This command is going to create a docker container with the RShiny app and another container with the API.

```
docker-compose up -d
```

## How to cite
To cite this software, use the CITATION.cff
