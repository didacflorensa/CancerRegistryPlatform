getAge <- function(edat){
  edats = str_split_fixed(edat, "-", 2)
  return(edats)
}

# ----------------------
# Filters
# ----------------------

get_filters <- function(minDate, maxDate){
        return(sidebarPanel(id="filters", width=15,
                            fluidRow(
                                column(3, sliderInput("Any", list(icon("calendar"),"Period"),
                                width=200, min = minDate, max = maxDate,
                                value = c(maxDate, maxDate), step = 1)),
                                column(3, selectInput("sexeSelector", list(icon("user"), "Gender"), choices=list("Homes i Dones", "Homes", "Dones"), selected="Homes i Dones", width=150)),
                                column(3, selectInput("ageSelector", 
                                                    list(icon("address-card"),"Age rang"),
                                                    choices=list("0-120", "80-120", "75-79", "70-74", "65-69", "60-64", "55-59", "50-54", "45-49", "40-44", 
                                                    "35-39", "30-34", "25-29", "20-24", "15-19", "10-14", "5-9", "0-4" ),
                                                    selected="Tots", width=150)),
                                column(3, selectInput("poblacioSelector", 
                                                    list(icon("home"), "Population"), 
                                                    choices=list("Poblacional", "Hospitalari" ),
                                                    selected="Poblacional", width=150))
                            ),
                            fluidRow(
                                column(12, downloadButton('report', 'Export tables'))
                            )
                        ))
}

get_incident_filter <- function(loc3_map){
    #loc3_map.rev <- split(rep(names(loc3_map), lengths(loc3_map)), unlist(loc3_map))
    loc3_map <-  loc3_map[names(loc3_map) %in% "C44(NoMelanoma)" == FALSE] 
    names(loc3_map)[which(names(loc3_map) == "C44(Melonama)")] <- "C44"
    aux_loc3 <- names(loc3_map)
    aux <- c()
    for(i in names(loc3_map)){
        aux <- c(aux, paste(i, "-", loc3_map[i]))
    }
    names(aux_loc3) <- aux
    aux_loc3 = aux_loc3[order(names(aux_loc3))]
    #aux_aux = c("Tots")
    #names(aux_aux) <- c("Tots")

    #aux_loc3 <- rbind(aux_loc3, aux_aux)
    aux_loc3 <- c(Tots="Tots", aux_loc3)

    return(sidebarPanel(id="incidents_filters", width=15,
                            fluidRow(
                                column(6,
                                    selectInput("loc3Selector",
                                    list(icon("address-card"),"Tumour location"),
                                    choices=aux_loc3,
                                    selected=1),                        
                                ),
                                column(6,
                                    selectInput("loc3YearSelector",
                                    list(icon("address-card"),"Analysis year"),
                                    choices=list("2012","2013", "2014", "2015", "2016"),
                                    selected="2012")
                                )
    )))
}

# ----------------------
# Filter data
# ----------------------
filter_data <- function(data, sexe, edat, selected_population){
  aux <- data
  # Filter sexe (0 -> All)
  if(as.numeric(sexe) != 0){
    aux <- aux[aux$sexe==sexe, ]
  }
  if(selected_population == "Poblacional"){
      aux <- aux[aux["patient.codi_postal"] > 25000 & aux["patient.codi_postal"] < 25999, ]
  }else if(selected_population == "Hospitalari"){
      aux <- aux[aux["patient.codi_postal"] > 0 & aux["patient.codi_postal"] < 100000, ]
  }
  aux <- aux[aux$age>as.numeric(edat[1]) &
              aux$age<as.numeric(edat[2]) , ]
  return(aux)
}

filter_data_parse_sexe <- function(data, selected_sex, selected_population, edat){
    aux <- data
    sexe <- 0
    if(selected_sex =="Homes"){
        sexe <- 1
    }else if(selected_sex == "Dones"){
        sexe <- 2
    }
    aux <- filter_data(data, sexe, edat, selected_population) 
    return(aux)
}

# ----------------------
# KPIs
# ----------------------
get_total_pathines_by_sex <- function(data, sexe, selected_population, edat){   
    aux <- filter_data(data, sexe, edat, selected_population)
    length(unique(aux[,'id_pacient'])) 
}

get_number_of_males <- function(data, selected_population, edat){ 
    nm <- get_total_pathines_by_sex(data, 1, selected_population, edat)
    return(nm)
}

get_number_of_female <- function(data, selected_population, edat){
    return(get_total_pathines_by_sex(data, 2, selected_population, edat))
}

get_avg_age <- function(data, selected_sex, selected_population, edat){
  aux <-filter_data_parse_sexe(data, selected_sex, selected_population, edat)
  return(mean(aux[!is.na(aux$age), ]$age))
}


# ----------------------
# Piramide
# ----------------------

plotPyramide <- function(data, selected_sex, selected_population, edat){
  aux_data <-filter_data_parse_sexe(data, selected_sex, selected_population, edat)
  tumor_by_age <- aggregate(x=aux_data$id_tumor, by = list(aux_data$age, aux_data$sexe), FUN = length)
  colnames(tumor_by_age) <- c("age", "sexe", "n_tumors")
  tumor_by_age <- aggregate(x=tumor_by_age$age, by = tumor_by_age, FUN = function(x){
      aux_x <- as.numeric(x)
      if(aux_x>=85){
          ">=85"
      }else{
          aux_x <- as.integer(aux_x/5)
          paste(aux_x*5, "a", aux_x*5+4)   
      }
  })
  colnames(tumor_by_age) <- c("age", "sexe", "n_tumors", "Range")
  tumor_by_age <- tumor_by_age[order(-tumor_by_age[,"age"]),]
  tumor_by_age <- aggregate(x=tumor_by_age$n_tumors, by = list(tumor_by_age$Range, tumor_by_age$sexe), FUN = sum)
  colnames(tumor_by_age) <- c("Range", "Sexe", "Casos")
  pirmide = data.frame(Range="0 a 4", Home=0 ,Dona=0, Total=0)
  p_ranges <- c("0 a 4")
  names(pirmide) <- c("Range", "Home", "Dona", "Total")
  for(i in seq(5,80, by=5)){
    pirmide <- rbind(pirmide, data.frame(Range=paste(i,"a",i+4), Home=0 ,Dona=0, Total=0))
    p_ranges <- rbind(p_ranges, paste(i,"a",i+4)) 
  }
  pirmide <- rbind(pirmide, data.frame(Range=">=85", Home=0 ,Dona=0, Total=0))
  p_ranges <- rbind(p_ranges, ">=85") 
  for(i in 1:nrow(tumor_by_age)){
      # 2 -> Sexe
      if(tumor_by_age[i,][["Sexe"]]==1){
          pirmide[pirmide$Range==tumor_by_age[i,][["Range"]],][,2] <- tumor_by_age[i,][["Casos"]]
      }else{
          pirmide[pirmide$Range==tumor_by_age[i,][["Range"]],][,3] <- tumor_by_age[i,][["Casos"]]
      }
          pirmide[pirmide$Range==tumor_by_age[i,][["Range"]],][,4] <- pirmide[pirmide$Range==tumor_by_age[i,][["Range"]],][,4] + tumor_by_age[i,][["Casos"]]
  }
  pirmide$Range <- factor(pirmide$Range,levels = p_ranges)
  return(pirmide)  
}


# ----------------------
# Casos freqüents er
# ----------------------

get_plot_pat_select <- function(data, selected_sex, selected_population, edat){
      aux_data <-filter_data_parse_sexe(data, selected_sex, selected_population, edat)
      aux_data <- aux_data[!(aux_data$loc3=="C44(NoMelanoma)"),]

      

      tumors_by_loc3 <- aggregate(x=aux_data$loc3, by = list(aux_data$loc3), FUN = length)
      colnames(tumors_by_loc3) <- c("TipusCancer", "Casos")
      
      tumors_by_loc3[tumors_by_loc3$TipusCancer=="C44(Melonama)","TipusCancer"] <- "C44"
      
      tumors_by_loc3 <- tumors_by_loc3[order(tumors_by_loc3$Casos),]
      return(tumors_by_loc3)
}

# ----------------------
# Casos freqüents 
# ----------------------
get_table_pat_all <- function(data, selected_sex, selected_population, edat, loc3_map){
      t_tumors <-filter_data_parse_sexe(data, selected_sex, selected_population, edat)
      n_tumors <- nrow(t_tumors)
      n_tumors_man = nrow(t_tumors[t_tumors$sexe==1,])
      n_tumors_woman = nrow(t_tumors[t_tumors$sexe==2,])



        #pellMelanoma <- list("M-87203", "M-87213", "M-87423",
        #                "M-87433", "M-87443", "M-87453",
        #                "M-87723", "M-87223", "M-87233",
        #                "M-87303", "M-87403", "M-87413",
        #                "M-87463", "M-87613", "M-87703",
        #                "M-87713", "M-87803")

        tumor_by_loc3_aux1 <- t_tumors[c("id_tumor", "loc3", "morf", "sexe")]

        tumor_by_loc3_aux <- na.omit(tumor_by_loc3_aux1) 
        #for(i in 1:length(pellMelanoma)){
        #    if(nrow(tumor_by_loc3_aux[(tumor_by_loc3_aux$loc3=="C44" & tumor_by_loc3_aux$morf==pellMelanoma[[i]]),])!=0){
        #        tumor_by_loc3_aux[(tumor_by_loc3_aux$loc3=="C44" & tumor_by_loc3_aux$morf==pellMelanoma[[i]]),]['loc3'] <- "C44-1"
        #    } 
        #}




      tumor_by_loc3 <- aggregate(x=tumor_by_loc3_aux$id_tumor, by = list(tumor_by_loc3_aux$loc3, tumor_by_loc3_aux$sexe), FUN = length)
      colnames(tumor_by_loc3) <- c("loc3", "sexe", "n_tumors")
      tumor_by_loc3_male = subset(tumor_by_loc3, sexe==1)[,c("loc3", "n_tumors")]
      tumor_by_loc3_female = subset(tumor_by_loc3, sexe==2)[,c("loc3", "n_tumors")]
      colnames(tumor_by_loc3_male) <- c("loc3", "Home")
      colnames(tumor_by_loc3_female) <- c("loc3", "Dona")
      tumor_by_loc3_male <- merge(data.frame(loc3=unique(tumor_by_loc3[,"loc3"])),tumor_by_loc3_male,all.x=TRUE,by.x=c("loc3"),by.y=c("loc3"))
      tumor_by_loc3 <- merge(tumor_by_loc3_male,tumor_by_loc3_female,all.x=TRUE,by.x=c("loc3"),by.y=c("loc3"))
      tumor_by_loc3[, c("loc3")] <- sapply(tumor_by_loc3[, c("loc3")], as.character)
      tumor_by_loc3[is.na(tumor_by_loc3)] <- 0
      tumor_by_loc3$Total <- tumor_by_loc3$Home + tumor_by_loc3$Dona
      tumor_by_loc3$"Total%" <- round((tumor_by_loc3$Total / n_tumors) *100, 2)
      tumor_by_loc3$"Home%" <- round((tumor_by_loc3$Home / n_tumors_man) *100, 2)
      tumor_by_loc3$"Dona%" <- round((tumor_by_loc3$Dona / n_tumors_woman) *100, 2)
      tumor_by_loc3$loc3_desc <- lapply(tumor_by_loc3$loc3, function(x)loc3_map[x])
      tumor_by_loc3[, c("loc3_desc")] <- sapply(tumor_by_loc3[, c("loc3_desc")], as.character)
      tumor_by_loc3 <- tumor_by_loc3[order(tumor_by_loc3[,"loc3"]),]


        #if(nrow(tumor_by_loc3[tumor_by_loc3$loc3=="C44-1",])!=0){
        #    tumor_by_loc3[tumor_by_loc3$loc3=="C44-1",]["loc3_desc"] <- "Pell melanoma"  
        #}
        
        #if(nrow(tumor_by_loc3[tumor_by_loc3$loc3=="C44",])!=0){
        #    tumor_by_loc3[tumor_by_loc3$loc3=="C44",]["loc3_desc"] <- "Pell No melanoma"
        #}
                                
        #if(nrow(tumor_by_loc3[tumor_by_loc3$loc3=="C44-1",])){
        #    tumor_by_loc3[tumor_by_loc3$loc3=="C44-1",]["loc3"] <- "C44" 
        #}

      tumor_by_loc3_oder_by_total <- tumor_by_loc3 <- tumor_by_loc3[order(-tumor_by_loc3[,"Total"]),]

      reordered <- data.frame(
        c(tumor_by_loc3_oder_by_total$loc3),
        c(tumor_by_loc3_oder_by_total$loc3_desc),
        c(tumor_by_loc3_oder_by_total$Home),
        c(tumor_by_loc3_oder_by_total['Home%']),
        c(tumor_by_loc3_oder_by_total$Dona),
        c(tumor_by_loc3_oder_by_total['Dona%'])
        )
      names(reordered) <- c("Codi", "Descripcio", "Homes", "%", "Dones", "%")
      
      reordered[reordered$Codi=="C44(Melonama)","Codi"] <- "C44"
      reordered[reordered$Codi=="C44(NoMelanoma)","Codi"] <- "C44"


      return(reordered)
}


# ----------------------
# Evolution
# ----------------------
  get_evolution_data <- function(selected_sex, selected_population, edat){        
    results <-getEvolution(selected_sex, selected_population, edat)
    return(results)
}





# ----------------------
# Evolution
# ----------------------
  get_evolution_data_incident <- function(aux_data1){
    results <-getEvolutionInicidence(aux_data1)
    return(results)
}


generate_incidence_map <-function(incidence, loc3){
    result <-  incidence
    ########### Secció Inicial - Dashboard
    ##MAPA
    #Inicialitza les llistes de consum i de poblacio total per comarca
    list_comarques_consum <- vector(mode="list", length=11)
    names(list_comarques_consum) <- c('Urgell', 'Segrià', "Pla d'Urgell", "Val d'Aran", "Segarra",
                                  "Pallars Sobirà", "Pallars Jussà", "Noguera", "Alt Urgell",
                                  "Garrigues", "Alta Ribagorça")


    # Dídac: Aquest funció hauria de retornar els N de casos per comarca.
    #result <- getMapInformation("663680") #Aqui va el codi medicament que l'usuari seleccioni. Obte la informació relacionada amb el medicament

    #################

    # Parsejar el resultat de la peticio i ho afegeix a la llista de consum.
    # Parsejar el resultat de la peticio i ho afegeix a la llista de consum.
    for(i in 1:nrow(result)) {       # for-loop over rows
        comarca <- result["_id.comarca"][[1]][i]
        value <- result["incidence"][[1]][i]
        list_comarques_consum[[comarca]][1] <- value
    }
    # Crear la llista de poblacio per comarca amb les dades
    #list_comarques_poblacio <- comarques_habitants(list_comarques_poblacio)


    
    geojson <- readLines("comarques-lleida.geojson", warn = FALSE) %>%
    paste(collapse = "\n") %>%
    fromJSON(simplifyVector = FALSE)

    # Default styles for all features
    geojson$style = list(
        weight = 1,
        color = "#555555",
        opacity = 1,
        fillOpacity = 0.8
    )
    colors <- c("#BD0026", "#FC4E2A",  "#FEB24C",  "#FFEDA0", "#FEF9EA")

    getColor <- function(nom, list_comarques_consum) {
        out <- tryCatch(
            {
            result = 0
            consum = list_comarques_consum[[nom]]
            val = consum
            if(!is.null(val)){
                if(val >= 500){return(colors[1])}
                if(val >= 200 && val < 500){return(colors[2])}
                if(val >= 100 && val < 200){return(colors[3])}
                if(val >= 50 && val < 10){return(colors[4])}
                return(colors[5])
            }else{
                return("#FFFFFF")
            }
            },
            error=function(cond) {
            return("#FFFFFF")
            }
        )
    }

    geojson$features <- lapply(geojson$features, function(feat) {
        feat$properties$style <- list(
            fillColor = getColor(feat[['properties']][[3]], list_comarques_consum)
        )
        feat
    })

    leaflet() %>% addGeoJSON(geojson) %>%
        addLegend("bottomright",
                colors =colors,
                labels= c("+500", "500 - 200","200 - 100", "100 - 50", "0 - 50"),
                title= "Incidence (100.000 hab)",
                opacity = 1) %>%
        setView(lat = 41.9505 , lng = 0.8677, zoom = 7)
}