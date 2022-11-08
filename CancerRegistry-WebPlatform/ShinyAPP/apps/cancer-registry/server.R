#server.R

library(shiny)
# Install dependencies
source('dependencies.R')

# load all packages
lapply(required_packages, require, character.only = TRUE)

# read configuration
config <- config::get()
source("APIInterface.R")
source("plotsManager.R")


options(shiny.trace = FALSE)
options(shiny.reactlog=TRUE) 

function(input, output){  # <-- SERVER FUNCTION
    # -----------
    # Reactive functions
    # -----------
    #FILTERS
    #Any min


    #Comprovar filtres
    checkFilters <- reactive({
        req(input$sexeSelector)
        useShinyjs()
        if(input$sexeSelector == "Women"){
            shinyjs::hide(id ="vboxMalesCol")
            shinyjs::show(id ="vboxWomansCol")
        }
        else if(input$sexeSelector == "Men"){
            shinyjs::hide(id ="vboxWomansCol")
            shinyjs::show(id ="vboxMalesCol")
        }
        else if(input$sexeSelector == "Both"){
            shinyjs::show(id ="vboxMalesCol")
            shinyjs::show(id ="vboxWomansCol")
        }
    })


    # -----------
    # Render Filter
    # -----------
    get_provinces <- reactive({

        province_map <- getProvinces()

        # @TODO -> Els camps poden venir filtrar a la petició. La línia següent no és necessaria.
        province_map <- province_map[, c("codi", "nom_catala")]
        province_map <- data.frame(lapply(province_map, as.character), stringsAsFactors=FALSE)

        # @TODO -> Per què necessites posar 0 davant dels valors d'una xifra OMG!
        province_map$codi <- lapply(province_map$codi, function(x){if(nchar(x)==1){paste("0", x, sep="")}else{x}})

        province_map
    })


    get_loc3_map <- reactive({
        jfile <- getLoc3()
        loc3_map <- jfile$Desc
        names(loc3_map) <- jfile$Code
        loc3_map
    })


    get_incident <- reactive({
        req(input$loc3Selector)
        req(input$loc3YearSelector)
        incidence <- getInicidenceByCounties(input$loc3Selector, input$loc3YearSelector)
        incidence
    })




 

    #Query for filters and set they (need DateToRenderThey)
    output$filters <- renderUI({
        minDate <- getMinDate()
        maxDate <- getMaxDate()
        get_filters(minDate, maxDate)
    })

    output$incident_filter <- renderUI({
        get_incident_filter(get_loc3_map())
    })


    


    # -----------
    # KPI
    # -----------
    

    observeEvent((input$sexeSelector), {
        checkFilters()
        #updateValueBoxMalesFemales(input$sexeSelector, input$Any[1], input$Any[2], input$ageSelector)
        buildTotalCasesPlot(input$Any[1], input$Any[2], input$sexeSelector, input$ageSelector)
        updateAverageAge(input$Any[1], input$Any[2], input$sexeSelector)
        buildDistributionAgeGroupsPlot(input$Any[1], input$Any[2], input$sexeSelector, input$ageSelector)
        evolution_plot_render(input$sexeSelector, input$ageSelector)
    })

    observeEvent((input$Any), {
        updateValueBoxMalesFemales(input$sexeSelector, input$Any[1], input$Any[2], input$ageSelector)
        buildTotalCasesPlot(input$Any[1], input$Any[2], input$sexeSelector, input$ageSelector)
        updateAverageAge(input$Any[1], input$Any[2], input$sexeSelector)
        buildDistributionAgeGroupsPlot(input$Any[1], input$Any[2], input$sexeSelector, input$ageSelector)
        createTableCancerCases(input$Any[1], input$Any[2])
    })

    observeEvent((input$ageSelector), {
        updateValueBoxMalesFemales(input$sexeSelector, input$Any[1], input$Any[2], input$ageSelector)
        buildTotalCasesPlot(input$Any[1], input$Any[2], input$sexeSelector, input$ageSelector)
        updateAverageAge(input$Any[1], input$Any[2], input$sexeSelector)
        buildDistributionAgeGroupsPlot(input$Any[1], input$Any[2], input$sexeSelector, input$ageSelector)
        createTableCancerCases(input$Any[1], input$Any[2])
        evolution_plot_render(input$sexeSelector, input$ageSelector)
    })

    updateValueBoxMalesFemales <- function(sex, year_min, year_max, age_group) {

        age_group_split <- strsplit(age_group, split = "-")
        age_min <- age_group_split[[1]][1]
        age_max <- age_group_split[[1]][2]

        total_patients <- getTotalPatientsBySexCancer(year_min, year_max, age_min, age_max)
        males <- 0
        females <- 0

        if (total_patients['_id'][[1]][1] == 1) {
            males <- total_patients['total'][[1]][1]
            females <- total_patients['total'][[1]][2]
        }
        else {
            females <- total_patients['total'][[1]][1]
            males <- total_patients['total'][[1]][2]
        }
        
        output$vboxMales <- renderValueBox({
            valueBox(
                format(round(as.numeric(males)), big.mark=","), "Men", icon = icon("male"),
                color = "blue"
                )
        })

        output$vboxWomans <- renderValueBox({
            valueBox(format(round(as.numeric(females)), big.mark=","),
                    "Women",
                    icon = icon("female"),
                    color = "maroon")
        })
        
        checkFilters()
    }

    #Edat mitja
    updateAverageAge <- function(year_min, year_max, sex) {
        avg_age <- getAverageAge(year_min, year_max, sex)
        age <- as.double(avg_age$ageS)

        output$vboxAvgAge <- renderValueBox({
            valueBox(format(round(age), big.mark=","),
                    "Average age",
                    icon = icon("users"),
                    color = "olive")
        })
    }





    # -----------
    # Piramide
    # -----------
    buildDistributionAgeGroupsPlot <- function(year_min, year_max, sex, age_group){

        age_group_split <- strsplit(age_group, split = "-")
        age_min <- age_group_split[[1]][1]
        age_max <- age_group_split[[1]][2]
        result <- getAgeGroupsCount(year_min, year_max, sex, age_min, age_max)

        df <- structure(list(Age = result["_id.age_group"][[1]], Gender = result['_id.sexe'][[1]], Total = result['count'][[1]]), class = "data.frame", row.names = c(NA, -length(result["_id.age_group"][[1]])))
        df <- df %>%
            group_by(Gender) %>% 
            mutate(
                Population = ifelse(Gender == "Female", Total,-Total),
                Percent = ifelse(Gender == "Female", 100 * (Total / sum(Total)),-100 * (Total / sum(Total))))
        
        #df$Age <- factor(df$Age, levels=unique(df$Age)) # To keep the original order of the character vector

        plot <- ggplot(df, aes(x = Age, Population, fill = Gender)) + 
        geom_bar(data = filter(df, Gender == "Female"), stat = "identity") + 
        geom_bar(data = filter(df, Gender == "Male"),  stat = "identity") + 
        scale_y_continuous(breaks = seq(-1000, 1000, 200), labels = abs(seq(-1000, 1000, 200)))+
        scale_fill_manual(values = c("Male" = '#00CCCC',  "Female" = "#FF9999")) + 
        coord_flip()


        output$distribution_plot <- renderPlotly({
            plot
        })
    }



    #Evoultion plot
    evolution_plot_render <- function(sex, age_group){

        age_group_split <- strsplit(age_group, split = "-")
        age_min <- age_group_split[[1]][1]
        age_max <- age_group_split[[1]][2]

        sexe <- 0
        if(sex =="Men"){
            sexe <- 1
        }else if(sex == "Women"){
            sexe <- 2
        }

        results <- getEvolutionDidac(sexe, age_min, age_max)

        Cases <- results["cases"][[1]]
        Year <- results["_id.year_s"][[1]]

        data <- data.frame(Year , Cases)
        plot <- plot_ly(data, x = ~Year, y = ~Cases, type = 'scatter', mode = 'bar', colors = c("grey"))

        output$evolution_plot <- renderPlotly({
            plot
        })

    }

    buildTotalCasesPlot <- function(year_min, year_max, sex, age_group) {

        age_group_split <- strsplit(age_group, split = "-")
        age_min <- age_group_split[[1]][1]
        age_max <- age_group_split[[1]][2]
        
        req(input$box_pat1)
        result <- getTotalCancerCasesGroupBySex(year_min, year_max, sex, age_min, age_max)

        if(input$box_pat1!="Tots"){
            result <- tail(result,10)
        }

        Location <- result["_id.loc3"][[1]]
        Location_descr <- result["_id.descr"][[1]]
        Cases <- c(result["cases"])[[1]]

        data <- data.frame(Location, Cases, stringsAsFactors = FALSE)
        data$Location <- factor(data$Location)

        output$plot_pat_select <- renderPlotly({  
            plot_ly(data, x = ~Location, y = ~Cases, type = "bar", name = '', orientation='v', text=paste("Location: ", Location_descr,
                         "<br>Cases: ", Cases))
        })

        
    }

    createTableCancerCases <- function(year_min, year_max) {

        total_cancer_cases <- getCancerCasesByLocationSex(year_min, year_max)

        output$table_pat_all <- DT::renderDataTable({
            df <- data.frame(structure(list(`Code` = total_cancer_cases["_id.loc3"][[1]], `Description` = total_cancer_cases["_id.location_desc"][[1]], `N` = total_cancer_cases["cases"] )
                        , class = "data.frame", row.names = total_cancer_cases["_id.loc3"][[1]]))
            DT::datatable(
                df,
                rownames = FALSE,
                options = list(
                    dom = 'frtp',
                    style = "bootstrap",
                    lengthMenu = c(seq(10, 150, 10)),
                    language = list(
                        paginate = list(previous = 'Enrere', `next` = 'Endavant'),
                        search = "Buscar: "
                    )
                )
            )
        })
    }



    # ---------------------INCIDENCE





    #Evoultion plot
    output$evolution_plot_incident <- renderPlotly({
        req(input$loc3Selector)
        req(input$loc3YearSelector)
        results <- get_evolution_data_incident(input$loc3Selector)


        Cases <- results["cases"][[1]]
        Year <- results["_id.year_s"][[1]]

        data <- data.frame(Year , Cases)
        plot <- plot_ly(data, x = ~Year, y = ~Cases, type = 'scatter', mode = 'bar', colors = c("grey"))
        plot
    
    })




    createplotincidence <- function() {
        dataset <- parse_incidence()
        plot_ly(dataset, x = ~Poblacio, y=~Incidencia, type='bar')

    }

    output$incident_barplot <- renderPlotly(
        createplotincidence()
    )

    createIncidenceDataTable <- function (loc3, year) {

        data <- getIncidenceByRegion(loc3, year)

        output$incident_table <- DT::renderDataTable({
            
            df <- data.frame(structure(list(`Region` = data["_id.comarca"][[1]], `Cases` = data["count"], `Incidence` = round(data["incidence"]) )
                            , class = "data.frame", row.names = data["_id.comarca"][[1]]))

            DT::datatable(
                df,
                rownames = FALSE,
                options = list(
                    dom = 'frtp',
                    style = "bootstrap",
                    lengthMenu = c(seq(7, 150, 10)),
                    language = list(
                        paginate = list(previous = 'Enrere', `next` = 'Endavant'),
                        search = "Buscar: "
                    )
                )
            )
        })

        require(leaflet)
        output$incident_map <- renderLeaflet({
            incidence <- round(data["incidence"])
            comarques <- data["_id.comarca"][[1]]
            generate_incidence_map(data, loc3)
        })

        Region <- data["_id.comarca"][[1]]
        Incidence <- round(data["incidence"][[1]])

        output$incident_barplot <- renderPlotly(
            plot_ly(data, x = ~Region, y=~Incidence, type='bar')
        )
    }

    



    buildDistributionAgeGroupsPlot_Incidence <- function(year_min, year_max, loc3) {

        result <- getAgeGroupsCountLoc3(year_min, year_max, loc3)

        df <- structure(list(Age = result["_id.age_group"][[1]], Gender = result['_id.sexe'][[1]], Total = result['count'][[1]]), class = "data.frame", row.names = c(NA, -length(result["_id.age_group"][[1]])))
        df <- df %>%
            group_by(Gender) %>% 
            mutate(
                Population = ifelse(Gender == "Female", Total,-Total),
                Percent = ifelse(Gender == "Female", 100 * (Total / sum(Total)),-100 * (Total / sum(Total))))
        
        #df$Age <- factor(df$Age, levels=unique(df$Age)) # To keep the original order of the character vector

        plot <- ggplot(df, aes(x = Age, Population, fill = Gender)) + 
        geom_bar(data = filter(df, Gender == "Female"), stat = "identity") + 
        geom_bar(data = filter(df, Gender == "Male"),  stat = "identity") + 
        scale_y_continuous(breaks = seq(-1000, 1000, 200), labels = abs(seq(-1000, 1000, 200)))+
        scale_fill_manual(values = c("Male" = '#00CCCC',  "Female" = "#FF9999")) + 
        coord_flip()

        output$piramide_incident <- renderPlotly({
            plot
        })
    }

    observeEvent((input$loc3YearSelector), {
        buildDistributionAgeGroupsPlot_Incidence(input$loc3YearSelector, input$loc3YearSelector, input$loc3Selector)
        createIncidenceDataTable(input$loc3Selector, input$loc3YearSelector)
    })

    observeEvent((input$loc3Selector), {
        buildDistributionAgeGroupsPlot_Incidence(input$loc3YearSelector, input$loc3YearSelector, input$loc3Selector)
        createIncidenceDataTable(input$loc3Selector, input$loc3YearSelector)
    })









    # -----------
    # Download Report
    # -----------
    output$report <- downloadHandler(
        filename = "report.doc",
        content = function(file) {
            tempReport <- file.path(tempdir(), "markdown.Rmd")
            file.copy("markdown.Rmd", tempReport, overwrite = TRUE)
            params_aux <- list(n = get_tumors_for_report() , n1 = get_provinces(), n2 = get_loc3_map())
            rmarkdown::render(tempReport, output_file = file,
               params = params_aux,
               envir = new.env(parent = globalenv())
            )
        }
    )


        # --------------------------------------------------- # 
    # Subsequents view
    # Prediction view
    # --------------------------------------------------- #
    hide(id = "metrics")
    hide(id = "curve")

    observeEvent(input$all, {
        if(input$all == TRUE) {
            shinyjs::disable("gender")
            shinyjs::disable("age")
            shinyjs::disable("bmi")
            shinyjs::disable("smoking")
            shinyjs::disable("primary")
            shinyjs::disable("alcohol")
            shinyjs::disable("diabetes")
        } else {
            shinyjs::enable("gender")
            shinyjs::enable("age")
            shinyjs::enable("bmi")
            shinyjs::enable("smoking")
            shinyjs::enable("primary")
            shinyjs::enable("alcohol")
            shinyjs::enable("diabetes")            
        }
    })

    observeEvent(input$buttonsubs, {
        shinyalert("Nice!", "Trainning the model...", type = "success")
        #hide(id = "metrics")
        #hide(id = "curve")

        if(input$buttonsubs %% 2 == 0){
            hide(id = "metrics")
            hide(id = "curve")
        }else{
            shinyjs::show(id = "metrics")
            shinyjs::show(id = "curve")
        }
    })

    data <- read_csv("www/results/results.csv")
    output$metrics_table <- DT::renderDataTable(data)

    output$roc <- renderImage({
        list(src="www/curve.png", align="center", height='100%')
    }, deleteFile = FALSE)

    hide(id="div_barplot")
    observeEvent(input$buttonbarplot, {
        hide(id = "div_map")
        shinyjs::show(id = "div_barplot")

    })

    observeEvent(input$buttonmap, {
        hide(id = "div_barplot")
        shinyjs::show(id = "div_map")
    })



    ###-------- RISK FACTORS ------- ###


      # for maintaining the current category (i.e. selection)
    current_category <- reactiveVal()


    createBMIPlot <- function () {
        patientsOverweight <- getTotalOverweightPatient()
        patientsObesity <- getTotalObesePatient()
        totalPatients <- 13030

        
        totalExcessWeight <- format(round(as.numeric(patientsObesity$obesity + patientsOverweight$overweight)), big.mark=",")
        
        output$excesweight <- renderValueBox({
            valueBox(
            totalExcessWeight, "Excess weight patients", icon = icon("weight"),
            color = "green"
            )
        })

        output$pie2 <- renderPlotly({
        plot_ly() %>%
        add_pie(
            labels = c("Normal", "Overweight", "Obesity"), 
            values = c(totalPatients-patientsOverweight$overweight-patientsObesity$obesity, patientsOverweight$overweight, patientsObesity$obesity), 
            customdata = c("Normal", "Overweight", "Obesity")
        ) %>%
        layout(title = current_category() %||% "BMI")
        })

    }

    createAlcoholismPlot <- function () {
        patientsAlcohol <- getTotalAlcoholicPatient()
        totalPatients <- 13030

        
        output$alcohol <- renderValueBox({
            valueBox(
            format(round(as.numeric(patientsAlcohol$alcoholism)), big.mark=","), "Alcohol consumers", icon = icon("beer"),
            color = "yellow"
            )
        })

        output$pie1 <- renderPlotly({
        plot_ly() %>%
        add_pie(
            labels = c("No consumption", "Consumption"), 
            values = c(totalPatients-patientsAlcohol$alcoholism, patientsAlcohol$alcoholism), 
            customdata = c("No consumption", "Consumption")
        ) %>%
        layout(title = current_category() %||% "Alcoholism")
        })

    }

    createSmokingPlot <- function () {
        patientsSmokers <- getTotalSmokerPatient()
        totalPatients <- 13030

        

        output$smoking <- renderValueBox({
            valueBox(
            format(round(as.numeric(patientsSmokers$fumador)), big.mark=","), "Smokers", icon = icon("smoking"),
            color = "blue"
            )
        })

        output$pie3 <- renderPlotly({
        plot_ly() %>%
        add_pie(
            labels = c("Non-Smokers", "Smokers"), 
            values = c(totalPatients-patientsSmokers$fumador, patientsSmokers$fumador), 
            customdata = c("Non-Smokers", "Smokers")
        ) %>%
        layout(title = current_category() %||% "Tobacco")
        })
    }


    createDiabetesPlot <- function () {
        patientsDiabetics <- getTotalDiabetesPatient()
        totalPatients <- 13030

        output$diabetes <- renderValueBox({
            valueBox(
            format(round(as.numeric(patientsDiabetics$diabetes)), big.mark=","), "Diabetics", icon = icon("disease"),
            color = "red"
            )
        })

        output$pie4 <- renderPlotly({
        plot_ly() %>%
        add_pie(
            labels = c("Non-diabetic", "Diabetic"), 
            values = c(totalPatients-patientsDiabetics$diabetes, patientsDiabetics$diabetes), 
            customdata = c("Non-diabetic", "Diabetic")
        ) %>%
        layout(title = current_category() %||% "Diabetes")
        })
    }

    createBMIPlot()
    createAlcoholismPlot()
    createSmokingPlot()
    createDiabetesPlot()


    #Mortality
        #Query for filters and set they (need DateToRenderThey)
    output$filters2 <- renderUI({
        minDate <- getMinDate()
        maxDate <- getMaxDate()
        get_filters(minDate, maxDate)
    })


    
    createSelectorCancerCim10 <- function() {
        dictionary_cim10 <- getCim10Dictionary()

        
        choices_cim10 <- c("All", sort(dictionary_cim10["_id.item"][[1]]))
        choices_sorted <- str_sort(choices_cim10)
        #values_cim10 <- unique(dictionary_cim10["_id.causa10"])
        updateSelectInput(inputId="cancerSelectorMortality", choices=choices_cim10)

    }

    createTableMortality <- function(sex, year_min, year_max) {

        if (sex == 'W') {
            sex <- 'Female'
        } else if (sex == 'M') {
            sex <- "Male"
        } else {
            sex <- ''
        }
        
        total_cases_mortality <- getMortalityCountBySex(sex, year_min, year_max)

        output$table_mortality <- DT::renderDataTable({
            df <- data.frame(structure(list(`Locations` = total_cases_mortality["_id.item"][[1]], `N` = total_cases_mortality["n_causa10"] )
                        , class = "data.frame", row.names = total_cases_mortality["_id.item"][[1]]))
            DT::datatable(
                df,
                rownames = FALSE,
                options = list(
                    dom = 'frtp',
                    style = "bootstrap",
                    lengthMenu = c(seq(10, 150, 10)),
                    language = list(
                        paginate = list(previous = 'Enrere', `next` = 'Endavant'),
                        search = "Buscar: "
                    )
                )
            )
        })
    }

    createCasesPlotMortality <- function(sex, any_inici, any_fi) {

        if (sex == 'W') {
            sex <- 'Female'
        } else if (sex == 'M') {
            sex <- "Male"
        } else {
            sex <- ''
        }

        dictionary_cim10 <- getMortalityCountBySex(sex, any_inici, any_fi)

        
        color_plot <- 'rgb(25, 162, 52)'

        if (sex == 'Male') {
           color_plot <- 'rgb(27, 131, 187)' 
        }
        else if (sex == 'Female') {
            color_plot <- 'rgb(179, 30, 18)'
        }

            
        Location <- dictionary_cim10["_id.item"][[1]][0:10]
        Cases <- c(dictionary_cim10["n_causa10"])[[1]][0:10]

        data <- data.frame(Location, Cases, stringsAsFactors = FALSE)
        data$Location <- factor(data$Location, levels = unique(data$Location)[order(data$Cases, decreasing = FALSE)])
        plot_ly(data, x = ~Location, y = ~Cases, type = "bar", name = '', orientation='h')

        output$cases_plot_mortality <- renderPlotly({
            plot_ly(data, x = ~Cases, y = ~Location, type = "bar", name = '', orientation='h') %>% layout(plot_bgcolor='#e5ecf6')
        })
    }

    output$result_cim10 <- renderText({
        cim10 <- str_split(input$cancerSelectorMortality, " - ")[[1]][1]        
        #paste("You chose", cim10)
    })


    createSelectorCancerCim10()
    #createCasesPlotMortality('')






    createPyramidPlotMortality <- function(sexe_selector, cancer_selector, any_inici, any_fi) {

        sex <- 'B'
        cancer_loc <- cancer_selector

        if (sexe_selector == 'M') {
            sex <- "Male"
        }
        else if (sexe_selector == 'W') {
            sex <- "Female"
        }

        if (cancer_loc == 'All') {
            cancer_loc <- 'A'
        }

        result <- getAgeGroups(sex, cancer_loc, any_inici, any_fi)

        df <- structure(list(Age = result["_id.age_group"][[1]], Gender = result['_id.sexe_descr'][[1]], Total = result['count'][[1]]), class = "data.frame", row.names = c(NA, -length(result["_id.age_group"][[1]])))
        df <- df %>%
            group_by(Gender) %>% 
            mutate(
                Population = ifelse(Gender == "Female", Total,-Total),
                Percent = ifelse(Gender == "Female", 100 * (Total / sum(Total)),-100 * (Total / sum(Total))))
        
        #df$Age <- factor(df$Age, levels=unique(df$Age)) # To keep the original order of the character vector

        plot <- ggplot(df, aes(x = Age, Population, fill = Gender)) + 
        geom_bar(data = filter(df, Gender == "Female"), stat = "identity") + 
        geom_bar(data = filter(df, Gender == "Male"),  stat = "identity") + 
        scale_y_continuous(breaks = seq(-1000, 1000, 200), labels = abs(seq(-1000, 1000, 200)))+
        scale_fill_manual(values = c("Male" = '#00CCCC',  "Female" = "#FF9999")) + 
        coord_flip()


        output$pyramid_mortality <- renderPlotly({
            plot
        })



    }


    createEvolutionMortalityPlot <- function(sexe_selector, cancer_selector) {
        sex <- 'B'
        cancer_loc <- cancer_selector

        if (sexe_selector == 'M') {
            sex <- "Male"
        }
        else if (sexe_selector == 'W') {
            sex <- "Female"
        }

        if (cancer_loc == 'All') {
            cancer_loc <- 'A'
        }

        results <- getEvolutionByYear(sex, cancer_loc)

        Cases <- results["any_n"][[1]]
        Year <- results["_id.any"][[1]]

        data <- data.frame(Year , Cases)
        plot <- plot_ly(data, x = ~Year, y = ~Cases, type = 'scatter', mode = 'lines')


        output$evolution_mortality <- renderPlotly({
            plot_ly(data, x = ~Year, y = ~Cases, type = 'scatter', mode = 'bar', colors = c("grey"))
        })
    
    }

    refreshFilters <- function(sex, location, years_filter) {
        if (location != '--') {
            if (location == 'All') {
                createPyramidPlotMortality(sex, 'A', years_filter[1], years_filter[2])
                createEvolutionMortalityPlot(sex, 'A')
            } else if (location == 'All - Locations') {
                createPyramidPlotMortality(sex, 'A', years_filter[1], years_filter[2])
                createEvolutionMortalityPlot(sex, 'A')
            }
            else {
                cim10_loc <- str_split(location, " - ")[[1]][1]
                createPyramidPlotMortality(sex, cim10_loc, years_filter[1], years_filter[2])
                createEvolutionMortalityPlot(sex, cim10_loc)
            }         
        }
        
    }

    #  When the user select different sex
    observeEvent(input$sexSelectorMortality, {
        refreshFilters(input$sexSelectorMortality, input$cancerSelectorMortality, input$yearSelectorMortality)
        createCasesPlotMortality(input$sexSelectorMortality, input$yearSelectorMortality[1], input$yearSelectorMortality[2])
        createTableMortality(input$sexSelectorMortality, input$yearSelectorMortality[1], input$yearSelectorMortality[2])
        buildValueBoxGenders(input$yearSelectorMortality[1], input$yearSelectorMortality[2], input$sexSelectorMortality)
    })

    # When the user select different cancer location
    observeEvent(input$cancerSelectorMortality, {
        refreshFilters(input$sexSelectorMortality, input$cancerSelectorMortality, input$yearSelectorMortality)
    })

    # When the years selector change
    observeEvent(input$yearSelectorMortality, {
        refreshFilters(input$sexSelectorMortality, input$cancerSelectorMortality, input$yearSelectorMortality)
        createCasesPlotMortality(input$sexSelectorMortality, input$yearSelectorMortality[1], input$yearSelectorMortality[2])
        createTableMortality(input$sexSelectorMortality, input$yearSelectorMortality[1], input$yearSelectorMortality[2])
        buildValueBoxGenders(input$yearSelectorMortality[1], input$yearSelectorMortality[2], input$sexSelectorMortality)
    })

    buildValueBoxGenders <- function(year_min, year_max, sex) {
        
        total <- getCountBySex(year_min, year_max)

        totalMales <- total["total"][[1]][1]
        totalFemales <- total["total"][[1]][2]

        if (sex == 'Men') {
            shinyjs::hide(id ="females_mortality")
            shinyjs::show(id ="males_mortality")
        }
        else if (sex == 'Women') {
            shinyjs::show(id ="females_mortality")
            shinyjs::hide(id ="males_mortality")
        }
        else {
            shinyjs::show(id ="females_mortality")
            shinyjs::show(id ="males_mortality")
        }

        # Value box Mortality
        output$males_mortality <- renderValueBox({
            valueBox(
                format(round(totalMales), big.mark=","), "Men", icon = icon("male"),
                color = "blue"
            )
        })

        output$females_mortality <- renderValueBox({
            valueBox(
                format(round(totalFemales), big.mark=","), "Women", icon = icon("female"),
                color = "maroon"
            )
        })

    }



    


}