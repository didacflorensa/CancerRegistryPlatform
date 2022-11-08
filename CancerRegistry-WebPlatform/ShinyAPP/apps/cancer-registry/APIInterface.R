# read configuration
config <- config::get()

# ----------------------
# getProvinces 
# ----------------------
getProvinces <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/provinces')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


# ----------------------
# getEvolutionData
# ----------------------
getEvolution <- function(sexe, population, edat){
    #paramsJson = paste('{"year_max": ',year_max,', "year_min": ',year_min,'}')
    
    paramsJson = '{'
    
    # paramsJson = paste(paramsJson, '"age_min":', edat[1],', "age_max":', edat[2], sep="") #TODO correct backend to make it work
    if(population == "Poblacional"){
        paramsJson = paste(paramsJson, '"cp_min": 25000, "cp_max": 25999')
    }else{ # "Hospitalari"
        paramsJson = paste(paramsJson, '"cp_min": 0, "cp_max": 100000')
    }
    if(as.numeric(sexe) != 0){
         paramsJson = paste(paramsJson, paste(', "sexe":', sexe))  
    }
    paramsJson = paste(paramsJson,'}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service, '/evolution/didac')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


# ----------------------
# getEvolutionDataDidac
# ----------------------
getEvolutionDidac <- function(sexe, age_min, age_max){
    paramsJson = paste('{"age_min": ',age_min,', "age_max": ',age_max)
        
    # paramsJson = paste(paramsJson, '"age_min":', edat[1],', "age_max":', edat[2], sep="") #TODO correct backend to make it work
    
    if(as.numeric(sexe) != 0){
         paramsJson = paste(paramsJson, paste(', "sexe":', sexe, '}'))  
    }
    else {
        paramsJson = paste(paramsJson, '}')
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service, '/evolution/didac')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


# ----------------------
# GetAllByDate 
# ----------------------
getAllByDate <- function(year_min, year_max){
    path = "/all_by_year"
    paramsJson = paste('{"year_max": ',year_max,', "year_min": ',year_min,'}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service, path)), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


# ----------------------
# GetAllByDateIncident
# ----------------------
getAllByDateIncience <- function(year, loc3){
    path = "/all_by_year"

    if(loc3 != 'Tots'){
        paramsJson = paste('{"year_max": ',year,', "year_min": ',year,', "loc3": "',loc3,'"}', sep="")
    }else{
        paramsJson = paste('{"year_max": ',year,', "year_min": ',year,'}', sep="")
    }
    
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service, path)), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}

# ----------------------
# GetInicidenceByCounties
# ----------------------
getInicidenceByCounties <- function(loc3, year){
    path = "/incidence_by_counties"
    paramsJson={}
    loc3_aux = loc3
    if(loc3 != 'Tots'){
        if(loc3 == 'C44(Melonama)' || loc3 == "C44(NoMelanoma)"){
            loc3_aux="C44"
        }

        if(length(loc3)<2){
            paramsJson = paste(sep = "", '{"loc3": "',loc3_aux,'", "year":',year,'}')
        }
    }else{
         paramsJson = paste(sep = "", '{"year":',year,'}')
    }
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service, path)), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    result <- rjson::fromJSON(aux_result)
    return(result)
}

# ----------------------
# getEvolutionData
# ----------------------
getEvolutionInicidence <- function(loc3){
    #paramsJson = paste('{"year_max": ',year_max,', "year_min": ',year_min,'}')
    paramsJson = '{}'
    if(loc3 != "Tots"){
        paramsJson = paste('{"loc3": "', loc3,'"}', sep="")
    }
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service, '/evolution/didac')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


# ----------------------
# GetMinDate 
# ----------------------
getMinDate <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/year/min')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    result <- rjson::fromJSON(aux_result)
    result <- result[[1]]["year"][[1]]
    return(result)
}

# ----------------------
# GetMaxDate 
# ----------------------
getMaxDate <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/year/max')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    result <- rjson::fromJSON(aux_result)
    result <- result[[1]]["year"][[1]]
    return(result)
}

# ----------------------
# GetLoc3 
# ----------------------
getLoc3 <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/loc3')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}



#----------------
# Get overweight
# --------------
getTotalOverweightPatient <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/overweight')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}

#----------------
# Get obesity
# --------------
getTotalObesePatient <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/obesity')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}

#----------------
# Get Alcohol patients
# --------------
getTotalAlcoholicPatient <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/alcoholism')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


#----------------
# Get Smoker patients
# --------------
getTotalSmokerPatient <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/smoking')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


#----------------
# Get Diabetic patients
# --------------
getTotalDiabetesPatient <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/diabetes')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}



#----------------
# Mortality
# -----------------

#--------------------------
# Get Cim10 Dictionary
# ------------------------
getCim10Dictionary <- function(){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/cim10/show')), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


#--------------------------
# Get Cim10 Dictionary
# ------------------------
getMortalityCountBySex <- function(sex, any_inici, any_fi){
    if (sex == '') {
        sex <- 'both'
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/mortality/count/show/', sex, '/', any_inici, '/', any_fi)), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


#--------------------------
# Get Age groups count
# ------------------------
getAgeGroups<- function(sex, location, any_inici, any_fi){

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/age/group/count/show/', sex, '/', location, '/', any_inici, '/', any_fi)), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


#--------------------------
# Get Age groups count
# ------------------------
getEvolutionByYear <- function(sex, location){
    
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/mortality/evolution/', sex, '/', location)), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


#--------------------------
# Get count by sex
# ------------------------
getCountBySex <- function(year_min, year_max){
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::GET(url=gsub(" ", "",paste(config$database_service, '/mortality/total/show/', year_min, '/', year_max)), httr::add_headers(.headers=headers))
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}



getTotalPatientsBySexCancer <- function(year_min, year_max, age_min, age_max){
    #paramsJson = paste('{"year_max": ', "year_min": ',2014','}', sep="")
    #paramsJson = '{"year_min": 2012, "year_max": 2014}'

    paramsJson <- paste('{"year_min":', year_min, ',"year_max":', year_max, ',"age_min":', age_min, ',"age_max":', age_max,'}')

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/cases/sex')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


getTotalCancerCasesGroupBySex <- function(year_min, year_max, sex, age_min, age_max){

    paramsJson <- paste('{"year_min":', year_min, ',"year_max":', year_max, ',"age_min":', age_min, ',"age_max":', age_max)

    if (sex == 'Men') {
        paramsJson <- paste(paramsJson, ', "sex":', 1, '}')
    } else if (sex == 'Women') {
        paramsJson <- paste(paramsJson, ', "sex":', 2, '}')
    } else {
        paramsJson <- paste(paramsJson, '}')
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/cases/location')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


getAverageAge <- function(year_min, year_max, sex){
    paramsJson <- ""
    paramsJson <- paste('{"year_min":', year_min, ',"year_max":', year_max)

    if (sex == 'Men') {
        paramsJson <- paste(paramsJson, ', "sex":', 1, '}')
    } else if (sex == 'Women') {
        paramsJson <- paste(paramsJson, ', "sex":', 2, '}')
    } else {
        paramsJson <- paste(paramsJson, '}')
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/age')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


getAgeGroupsCount <- function(year_min, year_max, sex, age_min, age_max){
    paramsJson <- ""
    paramsJson <- paste('{"year_min":', year_min, ',"year_max":', year_max, ',"age_min":', age_min, ',"age_max":', age_max)

    if (sex == 'Men') {
        paramsJson <- paste(paramsJson, ', "sex":', 1, '}')
    } else if (sex == 'Women') {
        paramsJson <- paste(paramsJson, ', "sex":', 2, '}')
    } else {
        paramsJson <- paste(paramsJson, '}')
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/age/groups')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


getAgeGroupsCountLoc3 <- function(year_min, year_max, loc3){
    paramsJson <- ""

    if(loc3 != 'Tots'){
        paramsJson = paste('{"year_min": ',year_min,', "year_max": ',year_max,', "loc3": "',loc3,'"}', sep="")
    }else{
        paramsJson = paste('{"year_min": ',year_min,', "year_max": ',year_max,'}', sep="")
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/age/groups')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}



getCancerCasesByLocationSex <- function(year_min, year_max){
    paramsJson <- ""
    paramsJson <- paste('{"year_min":', year_min, ',"year_max":', year_max,'}')

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/cases/location/sex')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}


getIncidenceByRegion <- function(loc3, year){
    paramsJson <- ""

    if(loc3 != 'Tots'){
        paramsJson = paste('{"year": ',year,', "loc3": "',loc3,'"}', sep="")
    }else{
        paramsJson = paste('{"year": ',year,'}', sep="")
    }

    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,'/cancer/incidence/regions')), httr::add_headers(.headers=headers), body=paramsJson)
    aux_result <- content(request, "text", encoding = "UTF-8")
    #result <- rjson::fromJSON(aux_result)
    result <- jsonlite::fromJSON(aux_result,simplifyVector = TRUE, flatten = TRUE)
    return(result)
}