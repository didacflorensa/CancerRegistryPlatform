
# Install dependencies
source('dependencies.R')

# load all packages
lapply(required_packages, require, character.only = TRUE)

# read configuration
config <- config::get()

# -------------
# Tags
# -------------
estil <- tags$head(
  tags$link(
    rel = "stylesheet", 
    type = "text/css", 
    href = "style.css")
)


getAge <- function(edat){
  edats = str_split_fixed(edat, "-", 2)
  return(edats)
}

fa_html_dependency()

# -------------
# Queries
# ----------------------------------------------------------------------------------------------------

  # ----------------------
  # Login 
  # ----------------------

  credentialsValidation <- function(username, pass){
    paramsJson = gsub(" ", "", paste('{"username":"',username,'", "password":"',pass,'"}'))
    cat(file=stderr(), paramsJson, "\n")
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$authentication_service,"/login")), httr::add_headers(.headers=headers), body=paramsJson)
    validation <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(validation)
    return(result)
  }

  # ----------------------
  # GetMinDate 
  # ----------------------
  getMinDate <- function(){
    paramsJson = paste('{"filters" : {"MinDate": []}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/tumors")), httr::add_headers(.headers=headers), body=paramsJson)
    totalMalesJson <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(totalMalesJson)
    return(result)
  }

  # ----------------------
  # GetMaxDate 
  # ----------------------
  getMaxDate <- function(){
    paramsJson = paste('{"filters" : {"MaxDate": []}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/tumors")), httr::add_headers(.headers=headers), body=paramsJson)
    totalMalesJson <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(totalMalesJson)
    return(result)
  }

  # ----------------------
  # Total homes i dones 
  # ----------------------
  getTotalPatients <- function(sexeValue, selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"Sexe": [',sexeValue,'], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    totalMalesJson <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(totalMalesJson)
    return(result)
  }

  # ----------------------
  # Edat mitja 
  # ----------------------
  getAvgAge <-function(selected_year_min, selected_year_max, cp_min, cp_max){
    paramsJson = paste('{"filters" : {"avgAge": [], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    totalMalesJson <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(totalMalesJson)
    list <- result$avgEdat
    return(list)
  }

  getAvgAgeSex <-function(sexValue, selected_year_min, selected_year_max, cp_min, cp_max){
    paramsJson = paste('{"filters" : {"sexe_avgAge": [',sexValue,'], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    totalMalesJson <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(totalMalesJson)
    list <- result$avgEdat
    return(list)
  }


  # ----------------------
  # Piramide edat 
  # ----------------------
  getSexeCount <- function(sexeValue, selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"SexeCount": [',sexeValue,'], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    sexeCount <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(sexeCount)
    return(result)
  }

  plotSexComparativePyramid <- function(selected_year_min, selected_year_max, selected_population, edat){
    if(selected_population == "Poblacional"){
      data <- getTotalFreqAllCasesSex(1, selected_year_min, selected_year_max, 25000, 25999, edat[1], edat[2])
      total <- data.frame()
      for(i in 1:nrow(data)){
          value <- data.frame(TipusCancer= data[i,1], Casos=data[i,2], Sexe="Home")
          total <-rbind(total, value)
      }
      data <- getTotalFreqAllCasesSex(2, selected_year_min, selected_year_max, 25000, 25999, edat[1], edat[2])
      for(i in 1:nrow(data)){
          value <- data.frame(TipusCancer= data[i,1], Casos=data[i,2], Sexe="Dona")
          total <-rbind(total, value)
      }
    }else if(selected_population == "Hospitalari"){
      data <- getTotalFreqAllCasesSex(1, selected_year_min, selected_year_max, 0, 100000, edat[1], edat[2])
      total <- data.frame()
        for(i in 1:nrow(data)){
            value <- data.frame(TipusCancer= data[i,1], Casos=data[i,2], Sexe="Home")
            total <-rbind(total, value)
        }
      data <- getTotalFreqAllCasesSex(2, selected_year_min, selected_year_max, 0, 100000, edat[1], edat[2])
      for(i in 1:nrow(data)){
          value <- data.frame(TipusCancer= data[i,1], Casos=data[i,2], Sexe="Dona")
          total <-rbind(total, value)
      }
    }

    p <- ggplot(total, aes(x = TipusCancer, y = Casos, fill = Sexe)) +
      geom_bar(data = subset(total, Sexe == "Dona"), stat = "identity") + scale_fill_manual(values=c("#DE0E67","#2270BC")) +
      geom_bar(data = subset(total, Sexe == "Home"), stat = "identity", aes(y=Casos*(-1))) +
      scale_y_continuous(breaks=seq(-2000,2000,20),labels=abs(seq(-2000,2000,20))) +
      coord_flip()

    return(p)  
  }

  plotPyramide <- function(selected_year_min, selected_year_max, selected_population, edat){
    if(selected_population == "Poblacional"){
      countHomes <- getSexeCount(1, selected_year_min, selected_year_max, 25000, 25999, edat[1], edat[2])
      countDones <- getSexeCount(2, selected_year_min, selected_year_max, 25000, 25999, edat[1], edat[2])
    }else if(selected_population == "Hospitalari"){
      countHomes <- getSexeCount(1, selected_year_min, selected_year_max, 0, 100000, edat[1], edat[2])
      countDones <- getSexeCount(2, selected_year_min, selected_year_max, 0, 100000, edat[1], edat[2])
    }
    total <- data.frame()

    ##MALE
    #0-4
    age1 = 0
    #5-9
    age2 = 0
    #10-14
    age3 = 0
    #15-19
    age4 = 0
    #20-24
    age5 = 0
    #25-29
    age6 = 0
    #30-34
    age7 = 0
    #35-39
    age8 = 0
    #40-44
    age9 = 0
    #45-49
    age10 = 0
    #50-54
    age11 = 0
    #55-59
    age12 = 0
    #60-64
    age13 = 0
    #65-69
    age14 = 0
    #70-74
    age15 = 0
    #75-79
    age16 = 0
    #+80
    age17 = 0

    for(i in 1:nrow(countHomes)){

      if(countHomes[i,1] >= 0 && countHomes[i,1] <=4){
        age1 = age1 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 5 && countHomes[i,1] <=9){
        age2 = age2 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 10 && countHomes[i,1] <=14){
        age3 = age3 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 15 && countHomes[i,1] <=19){
        age4 = age4 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 20 && countHomes[i,1] <=24){
        age5 = age5 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 25 && countHomes[i,1] <=29){
        age6 = age6 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 30 && countHomes[i,1] <=34){
        age7 = age7 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 35 && countHomes[i,1] <=39){
        age8 = age8 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 40 && countHomes[i,1] <=44){
        age9 = age9 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 45 && countHomes[i,1] <=49){
        age10 = age10 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 50 && countHomes[i,1] <=54){
        age11 = age11 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 55 && countHomes[i,1] <=59){
        age12 = age12 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 60 && countHomes[i,1] <=64){
        age13 = age13 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 65 && countHomes[i,1] <=69){
        age14 = age14 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 70 && countHomes[i,1] <=74){
        age15 = age15 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 75 && countHomes[i,1] <=79){
        age16 = age16 + countHomes[i,2]
      }
      else if(countHomes[i,1] >= 80){
        age17 = age17 + countHomes[i,2]
      }
    }

    value <- data.frame(Edat= "0-04", Sexe="Home", Població = age1)
    total <-rbind(total, value)

    value <- data.frame(Edat= "05-09", Sexe="Home", Població = age2)
    total <-rbind(total, value)

    value <- data.frame(Edat= "10-14", Sexe="Home", Població = age3)
    total <-rbind(total, value)

    value <- data.frame(Edat= "15-19", Sexe="Home", Població = age4)
    total <-rbind(total, value)

    value <- data.frame(Edat= "20-24", Sexe="Home", Població = age5)
    total <-rbind(total, value)

    value <- data.frame(Edat= "25-29", Sexe="Home", Població = age6)
    total <-rbind(total, value)

    value <- data.frame(Edat= "30-34", Sexe="Home", Població = age7)
    total <-rbind(total, value)

    value <- data.frame(Edat= "35-39", Sexe="Home", Població = age8)
    total <-rbind(total, value)

    value <- data.frame(Edat= "40-44", Sexe="Home", Població = age9)
    total <-rbind(total, value)

    value <- data.frame(Edat= "45-49", Sexe="Home", Població = age10)
    total <-rbind(total, value)

    value <- data.frame(Edat= "50-54", Sexe="Home", Població = age11)
    total <-rbind(total, value)

    value <- data.frame(Edat= "55-59", Sexe="Home", Població = age12)
    total <-rbind(total, value)

    value <- data.frame(Edat= "60-64", Sexe="Home", Població = age13)
    total <-rbind(total, value)

    value <- data.frame(Edat= "65-69", Sexe="Home", Població = age14)
    total <-rbind(total, value)

    value <- data.frame(Edat= "70-74", Sexe="Home", Població = age15)
    total <-rbind(total, value)

    value <- data.frame(Edat= "75-79", Sexe="Home", Població = age16)
    total <-rbind(total, value)

    value <- data.frame(Edat= "80+", Sexe="Home", Població = age17)
    total <-rbind(total, value)

    ##FEMALE
    #0-4
    age1 = 0
    #5-9
    age2 = 0
    #10-14
    age3 = 0
    #15-19
    age4 = 0
    #20-24
    age5 = 0
    #25-29
    age6 = 0
    #30-34
    age7 = 0
    #35-39
    age8 = 0
    #40-44
    age9 = 0
    #45-49
    age10 = 0
    #50-54
    age11 = 0
    #55-59
    age12 = 0
    #60-64
    age13 = 0
    #65-69
    age14 = 0
    #70-74
    age15 = 0
    #75-79
    age16 = 0
    #+80
    age17 = 0

    for(i in 1:nrow(countDones)){

      if(countDones[i,1] >= 0 && countDones[i,1] <=4){
        age1 = age1 + countDones[i,2]
      }
      else if(countDones[i,1] >= 5 && countDones[i,1] <=9){
        age2 = age2 + countDones[i,2]
      }
      else if(countDones[i,1] >= 10 && countDones[i,1] <=14){
        age3 = age3 + countDones[i,2]
      }
      else if(countDones[i,1] >= 15 && countDones[i,1] <=19){
        age4 = age4 + countDones[i,2]
      }
      else if(countDones[i,1] >= 20 && countDones[i,1] <=24){
        age5 = age5 + countDones[i,2]
      }
      else if(countDones[i,1] >= 25 && countDones[i,1] <=29){
        age6 = age6 + countDones[i,2]
      }
      else if(countDones[i,1] >= 30 && countDones[i,1] <=34){
        age7 = age7 + countDones[i,2]
      }
      else if(countDones[i,1] >= 35 && countDones[i,1] <=39){
        age8 = age8 + countDones[i,2]
      }
      else if(countDones[i,1] >= 40 && countDones[i,1] <=44){
        age9 = age9 + countDones[i,2]
      }
      else if(countDones[i,1] >= 45 && countDones[i,1] <=49){
        age10 = age10 + countDones[i,2]
      }
      else if(countDones[i,1] >= 50 && countDones[i,1] <=54){
        age11 = age11 + countDones[i,2]
      }
      else if(countDones[i,1] >= 55 && countDones[i,1] <=59){
        age12 = age12 + countDones[i,2]
      }
      else if(countDones[i,1] >= 60 && countDones[i,1] <=64){
        age13 = age13 + countDones[i,2]
      }
      else if(countDones[i,1] >= 65 && countDones[i,1] <=69){
        age14 = age14 + countDones[i,2]
      }
      else if(countDones[i,1] >= 70 && countDones[i,1] <=74){
        age15 = age15 + countDones[i,2]
      }
      else if(countDones[i,1] >= 75 && countDones[i,1] <=79){
        age16 = age16 + countDones[i,2]
      }
      else if(countDones[i,1] >= 80){
        age17 = age17 + countDones[i,2]
      }
    }

    value <- data.frame(Edat= "0-04", Sexe="Dona", Població = age1)
    total <-rbind(total, value)

    value <- data.frame(Edat= "05-09", Sexe="Dona", Població = age2)
    total <-rbind(total, value)

    value <- data.frame(Edat= "10-14", Sexe="Dona", Població = age3)
    total <-rbind(total, value)

    value <- data.frame(Edat= "15-19", Sexe="Dona", Població = age4)
    total <-rbind(total, value)

    value <- data.frame(Edat= "20-24", Sexe="Dona", Població = age5)
    total <-rbind(total, value)

    value <- data.frame(Edat= "25-29", Sexe="Dona", Població = age6)
    total <-rbind(total, value)

    value <- data.frame(Edat= "30-34", Sexe="Dona", Població = age7)
    total <-rbind(total, value)

    value <- data.frame(Edat= "35-39", Sexe="Dona", Població = age8)
    total <-rbind(total, value)

    value <- data.frame(Edat= "40-44", Sexe="Dona", Població = age9)
    total <-rbind(total, value)

    value <- data.frame(Edat= "45-49", Sexe="Dona", Població = age10)
    total <-rbind(total, value)

    value <- data.frame(Edat= "50-54", Sexe="Dona", Població = age11)
    total <-rbind(total, value)

    value <- data.frame(Edat= "55-59", Sexe="Dona", Població = age12)
    total <-rbind(total, value)

    value <- data.frame(Edat= "60-64", Sexe="Dona", Població = age13)
    total <-rbind(total, value)

    value <- data.frame(Edat= "65-69", Sexe="Dona", Població = age14)
    total <-rbind(total, value)

    value <- data.frame(Edat= "70-74", Sexe="Dona", Població = age15)
    total <-rbind(total, value)

    value <- data.frame(Edat= "75-79", Sexe="Dona", Població = age16)
    total <-rbind(total, value)

    value <- data.frame(Edat= "80+", Sexe="Dona", Població = age17)
    total <-rbind(total, value)

    p <- ggplot(total, aes(x = Edat, y = Població, fill = Sexe)) +
      geom_bar(data = subset(total, Sexe == "Dona"), stat = "identity") + scale_fill_manual(values=c("#DE0E67","#2270BC")) +
      geom_bar(data = subset(total, Sexe == "Home"), stat = "identity", aes(y=Població*(-1))) +
      scale_y_continuous(breaks=seq(-2000,2000,100),labels=abs(seq(-2000,2000,100))) +
      coord_flip()

    return(p)
  }


  # ----------------------
  # Casos freqüents 
  # ----------------------
  getFreqCases <- function(sexeValue, selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"FreqCases": [',sexeValue,'], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

  getTotalFreqCases <- function(selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"FreqTotalCases": [], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

  getTotalFreqAllCases <- function(selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"FreqTotalAllCases": [], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

  getTotalFreqAllCasesSex <- function(sexeValue, selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"FreqTotalAllCasesSex": [',sexeValue,'], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

  roundUpNice <- function(x, nice=c(1,2,4,5,6,8,10)) {
    if(length(x) != 1) stop("'x' must be of length 1")
    10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
  }

  plotLineRecep <- function(sexeValue, selected_year_min, selected_year_max, selected_population, edat){
    if(sexeValue==0){
      if(selected_population == "Poblacional"){
        data <- getTotalFreqCases(selected_year_min, selected_year_max, 25000, 25999, edat[1], edat[2])
      }else if(selected_population == "Hospitalari"){
        data <- getTotalFreqCases(selected_year_min, selected_year_max, 0, 100000, edat[1], edat[2])
      }
      color = "#48B799"
    }else{
      if(selected_population == "Poblacional"){
        data <- getFreqCases(sexeValue, selected_year_min, selected_year_max, 25000, 25999, edat[1], edat[2])
      }else if(selected_population == "Hospitalari"){
        data <- getFreqCases(sexeValue, selected_year_min, selected_year_max, 0, 100000, edat[1], edat[2])
      }
      if(sexeValue==1){
        color = "#2270BC"
      }else if(sexeValue==2){
        color = "#DE0E67"
      }
    }

    total <- data.frame()

    for(i in 1:nrow(data)){
      value <- data.frame(TipusCancer= data[i,1], Casos=data[i,2])
      total <-rbind(total, value)
    }

    maxValue <- max(total$Casos)
    partialValue <- roundUpNice(maxValue/10)

    p <- ggplot(total, aes(x = reorder(TipusCancer, +Casos), y = Casos)) +
        geom_bar(data = subset(total), stat = "identity", fill = color) +
        scale_y_continuous(breaks=seq(0,maxValue,partialValue),labels=abs(seq(0,maxValue,partialValue)))+
        labs(x = "Tipus de càncer", y="Nombre de Casos")+
        coord_flip()

      return(p)
  
  }

  # ---------------------------------------
  # Taula de casos freqüents homes i dones
  # ----------------------------------------
  getTableSexcases <- function(selected_year_min, selected_year_max, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"tableSexCases": [], "Year_min": [',selected_year_min,'], "Year_max": [',selected_year_max,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

  # ----------------------
  # Evolucio casos
  # ----------------------
  getEvolution <- function(cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"evolution": [], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

  getEvolutionSex <- function(sexe_value, cp_min, cp_max, age_min, age_max){
    paramsJson = paste('{"filters" : {"evolution_sex": [',sexe_value,'], "cp_Min": [',cp_min,'], "cp_Max": [',cp_max,'], "Edat_min": [',age_min,'], "Edat_max": [',age_max,']}}')
    headers = c('Content-Type' = 'application/json; charset=UTF-8')
    request <- httr::POST(url=gsub(" ", "",paste(config$database_service,"/pacients")), httr::add_headers(.headers=headers), body=paramsJson)
    FreqCases <- content(request, "text", encoding = "UTF-8")
    result <- fromJSON(FreqCases)
    return(result)
  }

# -----------------
# Dashboard
# ----------------------------------------------------------------------------------------------------

  # -----------------
  # Sidebar menu
  # -----------------
  sidebar <- dashboardSidebar(id="sidebar",
    sidebarMenu(
      sidebarSearchForm(textId = "searchbar", buttonId = "searchbtn", label = "Buscar..."),
      menuItem("Menú principal", tabName = "resum", icon = icon("dashboard", verify_fa = FALSE)),
      menuItem("Incidència", tabName = "incidencia", icon = icon("map", verify_fa = FALSE))
    )
  )

  # -----------------
  # Main body
  # -----------------
  body <- dashboardBody(
    useShinyjs(),
    uiOutput("filters"),
    tabItems(
      tabItem(tabName = "resum",
        fluidRow(
        div(
          id = "kpi_boxes", 
          column(
            width = 12,
            withSpinner(valueBoxOutput("vboxMales"), proxy.height=20, type = 4, color = "#5E95C3", size = 0.2),
            withSpinner(valueBoxOutput("vboxWomans"), proxy.height=20, type = 4, color = "#5E95C3", size = 0.2),
            withSpinner(valueBoxOutput("vboxAvgAge"), proxy.height=20, type = 4, color = "#5E95C3", size = 0.2)
          ),
        )),
        fluidRow(
        div(
          id = "patients_panel", 
          column(
            width = 12,
            introBox(data.step = 4, data.intro = "",
              uiOutput("box_pat")
            )),
          column(
            width = 6,
            uiOutput("pyramid_box"),
          ),
          column(
            width = 6,
            uiOutput("evolution_box"),
          ),
          column(
            width = 12,
            uiOutput("box_pat2")
          )  
          ))),
      tabItem(tabName = "incidencia",
              h3("Incidència")         
      )
    )
)


# -----------------
# Main page
# ----------------------------------------------------------------------------------------------------
  
  # -------------
  # Login
  # -------------
  login <- fluidPage(
    useShinyjs(),
      div(
        id = "login-basic", 
        style = "width: 400px; max-width: 100%; margin: 0 auto;",
        div(
          class = "well",
          h4(class = "text-center", "Identifica't"),
          textInput("ti_user_name_basic", 
            label       = tagList(icon("user", verify_fa = FALSE), 
                                  "Usuari"),
            value = "",
            placeholder = "Id personal"
          ),
          passwordInput("ti_password_basic", 
            label       = tagList(icon("unlock-alt", verify_fa = FALSE), 
                                  "Contrassenya"), 
            value = "",
            placeholder = "Contrassenya"
          ), 
          div(
            class = "text-center",
            actionButton(
              inputId = "ab_login_button_basic", 
              label = "Entra",
              class = "btn btn-primary"
            ),
          ),
        ),
      ),
  )


  # -------------
  # NavigationBar
  # ------------------------------------------------------------------------------------------------
  barraNavegacio <- navbarPage(
    tags$style(HTML("
      .navbar .navbar-nav {float: right; 
                           color: #000000; 
                           font-size: 13px; 
                           background-color: #5E95C3 ; } 
      .navbar.navbar-default.navbar-static-top{ color: #000000; 
                                      font-size: 25px; 
                                      background-color: #5E95C3 ;}
      .navbar .navbar-header {float: left; } 
      .navbar-default .navbar-brand { color: #000000; 
                                      font-size: 20px; 
                                      text-align: left;
                                      font-weight: bold;
                                      background-color: #5E95C3 ;} 
      #sidebar {
        background-color: #D8E4EA;
      }
      .skin-blue .main-header .logo {
                              background-color: #f4b943;
                              }")),
        title=div(
            img(src="Arnau_logo.png", height = '90px', width = '140px', style = "margin:5px 5px"), 
            img(src="Salut_logo.png", height = '20px', width = '70px', style = "margin:5px 5px"),  
            img(src="GSS_logo.png", height = '20px', width = '80px', style = "margin:5px 15px"),
        "Registre de Cancer"),

        
        #------ Inici -------
        tabPanel("INICI", icon = icon("home", verify_fa = FALSE), 
                 titlePanel("El càncer a la província de Lleida"),
                 "Tota la informació de càncer de la província de Lleida.",
                 hr()),
                 
        #------ Dades obertes -------
        tabPanel("DADES OBERTES", icon = icon("list-alt", verify_fa = FALSE), 
                 titlePanel("Registre de càncer de Lleida: dades obertes"),
                 hr(),
                 actionButton("style", "Global"),
                 actionButton("style", "Cap i coll"),
                 actionButton("style", "Sistema digestiu"),
                 actionButton("style", "Sistema respiratori"),
                 actionButton("style", "Òssos i teixits tous"),
                 actionButton("style", "Pell melanoma"),
                 actionButton("style", "Mama"),
                 actionButton("style", "Òrgans genitals femenins"),
                 actionButton("style", "Òrgans genitals maculins"),
                 actionButton("style", "Sistema urinari"),
                 actionButton("style", "Sistema nerviós"),
                 actionButton("style", "Sistema endocrí"),
                ),
        
        #------ Registre cancer -------
        tabPanel("REGISTRE CÀNCER", icon = icon("lock", verify_fa = FALSE),
                 titlePanel("Registre de càncer de Lleida: dades privades"),
                 hr(),
                 "Accés limitat al personal sanitari de l'hospital Arnau de Vilanova de Lleida.",
                 br(), br(),
                 login), 
        
        #------ Contacte -------
        tabPanel("CONTACTE", icon = icon("phone", verify_fa = FALSE),
                 titlePanel("Registre de càncer de Lleida: contacte"),
                 hr())
  )



# -----------
# UI
# --------------------------------------------------------------------------
ui <- fluidPage(estil,
  fluidPage(id= "navbar", useShinyjs(),
  barraNavegacio), 
  uiOutput(outputId = "display_dashboard"))
      
      
  
# -----------
# Server
# -----------------------------------------------------------------------------
server <- function(input, output) {

  #Login authentication
  validate_password_basic <- eventReactive(input$ab_login_button_basic, {
    trimws(input$ti_user_name_basic)
    trimws(input$ti_password_basic)
    cat(file=stderr(), "User:",input$ti_user_name_basic,"\n")
    cat(file=stderr(), "Password:",input$ti_password_basic,"\n")
    cat(file=stderr(), gsub(" ", "",paste(config$authentication_service,"/login")))
    validate <- credentialsValidation(input$ti_user_name_basic, input$ti_password_basic)
        
    if (validate$message =="ok"){
     validate <- TRUE
    }
    else if (validate$message =="unauthorized"){
      showModal(modalDialog(
        title = "Permís d'accés denegat",
        "Usuari i/o contrassenya incorrectes",
        easyClose = TRUE,
        footer = 
            modalButton("Tanca")
      ))
     validate <- FALSE
     cat(file=stderr(), "Usuari i/o contrassenya incorrectes\n")
    }
  })

  #Dashboard
  output$display_dashboard <- renderUI({
        
    req(validate_password_basic())
    shinyjs::hide(id = "login-basic")
    shinyjs::hide(id ="navbar") # Oculta el navbar del 
    dashboardPage(skin = "blue",
      dashboardHeader(title = "Registre de càncer de Lleida",
        titleWidth = 300,
        dropdownMenu(
          type = "notifications", 
          headerText = strong("Menú"), 
          icon = icon("list-alt", verify_fa = FALSE), 
          badgeStatus = NULL,
          notificationItem(
            text = ("Inici"),
            icon = icon("home", verify_fa = FALSE)
          ),
          notificationItem(
            text = "Dades obertes",
            icon = icon("list-alt", verify_fa = FALSE)
          ),
          notificationItem(
            text = "Contacte",
            icon = icon("phone", verify_fa = FALSE)
          )),
        dropdownMenu(
          type = "notifications", 
          headerText = strong("AJUDA"), 
          icon = icon("question", verify_fa = FALSE), 
          badgeStatus = NULL,
          notificationItem(
            text = ("Temps de càrrega"),
            icon = icon("spinner", verify_fa = FALSE)
          ),
          notificationItem(
            text = "Filtre per període",
            icon = icon("calendar", verify_fa = FALSE)
          ),
          notificationItem(
            text = "Filtre per sexe",
            icon = icon("user", verify_fa = FALSE)
          ),
          notificationItem(
            text = "Filtre per rang d'edat",
            icon = icon("address-card", verify_fa = FALSE)
          ),
          notificationItem(
            text = "Filtre per població",
            icon = icon("home", verify_fa = FALSE)
          )
        ),
        tags$li(
          a(
            strong("Tanca sessió"),
            height = 40,
            title = "",
            target = "_blank"
          ),
          class = "dropdown"
        )
      ),
        sidebar,
        body)
  
  
  
  })

  data <- reactive({
        "hola"
    })

  #Download word report
  output$downloadword <- downloadHandler(
    filename = function(){"cancerreport.docx"},
    content = function(file) {  
      tempReport <- file.path(tempdir(),"markdown.Rmd")
      file.copy("markdown.Rmd", tempReport, overwrite = TRUE)
      rmarkdown::render("markdown.Rmd", output_format = "word_document", output_file = file,
                        params = list(table = data()), # here I'm passing data in params
                        envir = new.env(parent = globalenv()),clean=F,encoding="utf-8"
      ) 
    }
  )

 #Selector filtre per any
  output$filters <- renderUI({
    minDate <- getMinDate()
    maxDate <- getMaxDate()
    sidebarPanel(id= "filters", width=15,
          div(style="display: inline-block;vertical-align:top; width: 200px;",
            sliderInput("Any", list(icon("calendar", verify_fa = FALSE),"Període"), width=200,
              min = minDate$year, max = (maxDate$year)+1,
              value = c(maxDate$year, ((maxDate$year)+1)), step = 1)),
          div(style="display: inline-block;vertical-align:top; width: 70px;", ""),
          div(style="display: inline-block;vertical-align:top; width: 150px;",
            selectInput("sexeSelector", list(icon("user", verify_fa = FALSE), "Sexe"), choices=list("Homes i Dones", "Homes", "Dones"), selected="Homes i Dones", width=150)),
          div(style="display: inline-block;vertical-align:top; width: 70px;", ""),
          div(style="display: inline-block;vertical-align:top; width: 150px;", selectInput("ageSelector", 
          list(icon("address-card"),"Rang d'edat"), choices=list("0-120", "80-120", "75-79", "70-74", "65-69", "60-64", "55-59", "50-54", "45-49", "40-44", 
            "35-39", "30-34", "25-29", "20-24", "15-19", "10-14", "5-9", "0-4" ), selected="Tots", width=150)),
          div(style="display: inline-block;vertical-align:top; width: 70px;", ""),
          div(style="display: inline-block;vertical-align:top; width: 150px;", selectInput("poblacioSelector", list(icon("home"), "Població"), 
            choices=list("Poblacional", "Hospitalari" ), selected="Poblacional", width=150)),
          div(style="display: inline-block;vertical-align:top; width: 150px;", downloadButton('downloadword', 'Descarregar informe'))

    )    
  })

  #FILTERS
  #Any min
  selected_year_min <- reactive({
    req(input$Any[1])
    input$Any[1]
  })

  #Any max
  selected_year_max <- reactive({
    req( input$Any[2])
    input$Any[2]
  })

  #Sexe
  selected_sexe <- reactive({
    req( input$sexeSelector)
    input$sexeSelector
  })

  #Edat
  selected_age <- reactive({
    req(input$ageSelector)
    input$ageSelector
  })

  #Poblacio
  selected_population <- reactive({
    req( input$poblacioSelector)
    input$poblacioSelector
  })

  #Comprovar filtres
  checkFilters <- reactive({
    if(selected_sexe() == "Dones"){
      shinyjs::hide(id ="vboxMales")
      shinyjs::show(id ="vboxWomans")
    }
    else if(selected_sexe() == "Homes"){
      shinyjs::hide(id ="vboxWomans")
      shinyjs::show(id ="vboxMales")
    }
    else if(selected_sexe() == "Homes i Dones"){
      shinyjs::show(id ="vboxMales")
      shinyjs::show(id ="vboxWomans")
    }
    if(selected_age() == "0-120"){
      shinyjs::show(id ="vboxAvgAge")
    }
    else if(selected_age() != "0-120"){
      shinyjs::hide(id ="vboxAvgAge")
    }
  })

  #Total homes
  output$vboxMales <- renderValueBox({
    useShinyjs()
    checkFilters()
    edat <- getAge(selected_age())
    if(selected_population() == "Poblacional"){
      numMales <- getTotalPatients(1, selected_year_min(), selected_year_max(), 25000, 25999, edat[1], edat[2])
    }else if(selected_population() == "Hospitalari"){
      numMales <- getTotalPatients(1, selected_year_min(), selected_year_max(), 0, 100000, edat[1], edat[2])
    }
    valueBox(numMales, "Total Homes", icon = icon("male", verify_fa = FALSE), color = "blue")
  })

  #Total dones
  output$vboxWomans <- renderValueBox({
    useShinyjs()
    checkFilters()
    edat <- getAge(selected_age())
    if(selected_population() == "Poblacional"){
      numWomans <- getTotalPatients(2, selected_year_min(), selected_year_max(), 25000, 25999, edat[1], edat[2])
    }else if(selected_population() == "Hospitalari"){
      numWomans <- getTotalPatients(2, selected_year_min(), selected_year_max(), 0, 100000, edat[1], edat[2])
    }
    valueBox(numWomans, "Total Dones", icon = icon("female", verify_fa = FALSE), color = "maroon")
  })

  #Edat mitja
  output$vboxAvgAge <- renderValueBox({
    if(selected_population() == "Poblacional"){
      if(selected_sexe()=="Homes"){
        avgAge = getAvgAgeSex(1, selected_year_min(), selected_year_max(), 25000, 25999)
      }else if(selected_sexe() == "Dones"){
        avgAge = getAvgAgeSex(2, selected_year_min(), selected_year_max(), 25000, 25999)
      }else if(selected_sexe() == "Homes i Dones"){
        avgAge = getAvgAge(selected_year_min(), selected_year_max(), 25000, 25999)
      }
    }else if(selected_population() == "Hospitalari"){
      if(selected_sexe()=="Homes"){
        avgAge = getAvgAgeSex(1, selected_year_min(), selected_year_max(), 0, 100000)
      }else if(selected_sexe() == "Dones"){
        avgAge = getAvgAgeSex(2, selected_year_min(), selected_year_max(), 0, 100000)
      }else if(selected_sexe() == "Homes i Dones"){
        avgAge = getAvgAge(selected_year_min(), selected_year_max(), 0, 100000)
      }
    }
    roundedAVG <- round(as.double(avgAge[1]), digits=0)
    valueBox(roundedAVG, "Mitjana d'Edat", icon = icon("users", verify_fa = FALSE), color = "olive")
  })
        
  
  # Piramide d'Edat
  output$distribution_plot <- renderPlot({
    edat <- getAge(selected_age())
    if(edat[1] == 0 && edat[2] == 120){
      plotPyramide(selected_year_min(), selected_year_max(), selected_population(), edat)
    }else{
      plotSexComparativePyramid(selected_year_min(), selected_year_max(), selected_population(), edat)
    }
  })

  #Evoultion plot
  output$evolution_plot <- renderPlot({
    edat <- getAge(selected_age())
    if(selected_sexe() == "Homes i Dones"){
      if(selected_population() == "Hospitalari"){
        data <- getEvolutionDidac(0, 100000, edat[1], edat[2]) 
      }else{
        data <- getEvolutionDidac(25000, 25999, edat[1], edat[2])
      }
    }else if(selected_sexe() == "Homes"){
      if(selected_population() == "Hospitalari"){
        data <- getEvolutionDidac(1, 0, 100000, edat[1], edat[2]) 
      }else{
        data <- getEvolutionDidac(1, 25000, 25999, edat[1], edat[2])
      }
    }else if(selected_sexe() == "Dones"){
      if(selected_population() == "Hospitalari"){
        data <- getEvolutionDidac(2, 0, 100000, edat[1], edat[2]) 
      }else{
        data <- getEvolutionDidac(2, 25000, 25999, edat[1], edat[2])
      }
    }

    Cases <- data["cases"][[1]]
    Year <- data["_id.year_s"][[1]]

    data <- data.frame(Year , Cases)
    plot <- plot_ly(data, x = ~Year, y = ~Cases, type = 'scatter', mode = 'bar', colors = c("grey"))
    plot
  })

  #Gràfic tipus de casos més freqüents
  plot_pat_select <- reactive({
    edat <- getAge(selected_age())
    if (input$box_pat1 == "Top 10") {
      if(selected_sexe()=="Homes"){
        plotLineRecep(1, selected_year_min(), selected_year_max(), selected_population(), edat)
      }else if(selected_sexe() == "Dones"){
        plotLineRecep(2, selected_year_min(), selected_year_max(), selected_population(), edat)
      }else if(selected_sexe() == "Homes i Dones"){
        plotLineRecep(0, selected_year_min(), selected_year_max(), selected_population(), edat)
      }
    } else{
      if(selected_population() == "Poblacional"){
        cp_min = 25000
        cp_max = 25999
      }else if(selected_population() == "Hospitalari"){
        cp_min = 0
        cp_max = 100000
      }
      if(selected_sexe()=="Homes i Dones"){ 
        data <- getTotalFreqAllCases(selected_year_min(), selected_year_max(), cp_min, cp_max, edat[1], edat[2])  
      }
      else if(selected_sexe()=="Homes"){ 
        data <- getTotalFreqAllCasesSex(1, selected_year_min(), selected_year_max(), cp_min, cp_max, edat[1], edat[2])  
      }
      else if(selected_sexe()=="Dones"){ 
        data <- getTotalFreqAllCasesSex(2, selected_year_min(), selected_year_max(), cp_min, cp_max, edat[1], edat[2])  
      }
      total <- data.frame()
      for(i in 1:nrow(data)){
        value <- data.frame(TipusCancer= data[i,1], Casos=data[i,2])
        total <-rbind(total, value)
      }

    plot <- 
      ggplot(total, 
             aes(Casos, 
                 y = 0, 
                 group = TipusCancer, 
                 text = TipusCancer, 
                 count = Casos)) +
      geom_point(aes(size = Casos, fill = TipusCancer), 
                 alpha = 0.6, 
                 color = "black", 
                 shape = 21) +
      coord_cartesian(ylim = c(-2, 2)) +
      scale_size_area(max_size = 25) +
      guides(fill = FALSE, size = FALSE) +
      labs(x = "Nombre de casos per tipus de càncer") +
      scale_x_continuous(
        name = "Nombre de casos per tipus de càncer", 
        trans = "log10", 
        breaks = c(1, 10, 50, 100, 200, 400, 600, 800, 1000, 1500, 2000, 2500, 5000, 6500, 8500, 10000)) +
      scale_fill_viridis_d() + 
      theme(
        panel.grid.major = element_line(color = "lightgrey", size = 0.2),
        panel.grid.major.y = element_blank(),
        panel.background = element_rect(fill = "white"),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size = 6),
        axis.title.x = element_text(size = 10, margin = margin(t = 10)),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        plot.title = element_text(size = 10, hjust = 0),
        panel.border = element_rect(colour = "darkgrey", fill = NA, size = 1)
      )}
    
    
    style(
      hide_legend(
        ggplotly(tooltip = c("text", "Count"))), 
      hoverlabel = list(bgcolor = "white")
    )
  })
  
  output$plot_pat_select <- renderPlotly({
    plot_pat_select()
  })


  output$box_pat <- renderUI({
    div(
      style = "position: relative; backgroundColor: #ecf0f5",
      tabBox(
        id = "box_pat",
        width = NULL,
        height = 320,
        tabPanel(
          title = "Tipus de càncers més freqüents",
          div(
            style = "position: absolute; left: 0.5em; bottom: 0.5em;",
            introBox(data.step = 5, data.intro = "",
                     dropdown(
                       radioGroupButtons(
                         inputId = "box_pat1",
                         label = NULL, 
                         choices = c("Tots", "Top 10"), 
                         selected = "Tots", 
                         direction = "vertical"
                       ),
                       size = "xs",
                       icon = icon("cog" , verify_fa = FALSE), 
                       up = TRUE
                     )
            )
          ),
          withSpinner(
            plotlyOutput("plot_pat_select", height = 230),
            type = 4,
            color = "#5E95C3", 
            size = 0.7 
          )
        )
      )
    )
  })

  output$pyramid_box <- renderUI({
    div(
      style = "position: relative",
      tabBox(
        id = "pyramid_box",
        width = NULL,
        height = 480,
        tabPanel(
          title = "Piràmide",
          withSpinner(
            plotOutput("distribution_plot"),
            type = 4,
            color = "#5E95C3",
            size = 0.7
          ) 
        )
      )
    )
  })

  output$evolution_box <- renderUI({
    div(
      style = "position: relative",
      tabBox(
        id = "pyramid_box",
        width = NULL,
        height = 480,
        tabPanel(
          title = "Evolució de casos",
          withSpinner(
            plotOutput("evolution_plot"),
            type = 4,
            color = "#5E95C3",
            size = 0.7
          ) 
        )
      )
    )
  })


  #Taula casos frequents per sexe
  table_pat_all <- reactive(
    if(selected_sexe() == "Dones"){
      edat <- getAge(selected_age())
      if(selected_population() == "Poblacional"){
        cp_min = 25000
        cp_max = 25999
      }else if(selected_population() == "Hospitalari"){
        cp_min = 0
        cp_max = 100000
      }
      DT::datatable(
        getTableSexcases(selected_year_min(), selected_year_max(), cp_min, cp_max, edat[1], edat[2]),
        rownames = FALSE,
        options = list(
          dom = 'frtp',
          style = "bootstrap",
          lengthMenu = c(seq(5, 150, 5)),
          columnDefs = list(list(visible=FALSE, targets=1))
        )
      )
    }
    else if(selected_sexe() == "Homes i Dones"){
      edat <- getAge(selected_age())
      if(selected_population() == "Poblacional"){
          cp_min = 25000
          cp_max = 25999
      }else if(selected_population() == "Hospitalari"){
        cp_min = 0
        cp_max = 100000
      }
      DT::datatable(
        getTableSexcases(selected_year_min(), selected_year_max(), cp_min, cp_max, edat[1], edat[2]),
        rownames = FALSE,
        options = list(
          dom = 'frtp',
          style = "bootstrap",
          lengthMenu = c(seq(5, 150, 5))
        )
      )
    }
    else if(selected_sexe() == "Homes"){
      edat <- getAge(selected_age())
      if(selected_population() == "Poblacional"){
          cp_min = 25000
          cp_max = 25999
      }else if(selected_population() == "Hospitalari"){
        cp_min = 0
        cp_max = 100000
      }
      DT::datatable(
        getTableSexcases(selected_year_min(), selected_year_max(), cp_min, cp_max, edat[1], edat[2]),
        rownames = FALSE,
        options = list(
          dom = 'frtp',
          style = "bootstrap",
          lengthMenu = c(seq(5, 150, 5)),
          columnDefs = list(list(visible=FALSE, targets=2))
        )
      )
    }
  )

  
  output$table_pat_all <- DT::renderDataTable({
    table_pat_all()
  })


  output$box_pat2 <- renderUI({
  div(
    style = "position: relative",
    tabBox(
      id = "box_pat2",
      width = NULL,
      height = 400,
      tabPanel(
        title = "Casos per tipus - Taula",
        withSpinner(
          DT::dataTableOutput("table_pat_all"),
          type = 4,
          color = "#5E95C3",
          size = 0.7
        )
      ),
    )
  )
})
}
    
  
# -------------
# Shiny object
# ------------------------------------------------------------------
shinyApp(ui = ui, server = server)

