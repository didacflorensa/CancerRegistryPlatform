#ui.R
# Install dependencies
source('dependencies.R')

# load all packages
lapply(required_packages, require, character.only = TRUE)
library(shiny)


estil <- tags$head(
  tags$link(
    rel = "stylesheet", 
    type = "text/css", 
    href = "style.css")
)

# -----------------
# Dashboard
# ----------------------------------------------------------------------------------------------------

    header <- dashboardHeader(title = "Registre de càncer de Lleida",
        titleWidth = 300,
        dropdownMenu(
            type = "notifications", 
            headerText = strong("Menú"), 
            icon = icon("list-alt"), 
            badgeStatus = NULL,
            notificationItem(
                text = ("Inici"),
                icon = icon("home")
            ),
            notificationItem(
                text = "Dades obertes",
                icon = icon("list-alt")
            ),
            notificationItem(
                text = "Contacte",
                icon = icon("phone")
            )
        ),
        dropdownMenu(
            type = "notifications", 
            headerText = strong("AJUDA"), 
            icon = icon("question"), 
            badgeStatus = NULL,
            notificationItem(
                text = ("Temps de càrrega"),
                icon = icon("spinner")
            ),
            notificationItem(
                text = "Filtre per període",
                icon = icon("calendar")
            ),
            notificationItem(
                text = "Filtre per sexe",
                icon = icon("user")
            ),
            notificationItem(
                text = "Filtre per rang d'edat",
                icon = icon("address-card")
            ),
            notificationItem(
                text = "Filtre per població",
                icon = icon("home")
            )
        ),
        tags$li(
            a(
                strong("Log out"),
                height = 40,
                title = "",
                target = "_blank"
            ),
            class = "dropdown"
        )
)


  # -----------------
  # Sidebar menu
  # -----------------
  sidebar <- dashboardSidebar(
    sidebarMenu(
      sidebarSearchForm(textId = "searchbar", buttonId = "searchbtn", label = "Buscar..."),
      menuItem("Main menu", tabName = "resum", icon = icon("tachometer-alt")),
      menuItem("Incidence", tabName = "incidencia", icon = icon("map")),
      menuItem("Risk factors", tabName = "riskfactors", icon = icon("times")),
      #menuItem("Subsequents tumours", tabName = "subsequent", icon = icon("table"),
      #          startExpanded = FALSE,
      #          menuSubItem("Subsequents information", tabName = "subsInfo"),
      #          menuSubItem("Subsequents prediction", tabName="prediction", icon = icon("subsInfo", verify_fa = FALSE)),
      #          menuSubItem("Subsequents association", tabName="association", icon = icon("subsInfo", verify_fa = FALSE))
      #          ),
      menuItem("Mortality", tabName = "mortality", icon = icon("ribbon"))
      #menuItem("Survival", tabName = "survival", icon = icon("infinity"))
    )
  )

  # -----------------
  # Main body
  # -----------------
  body <- dashboardBody(
    useShinyjs(),
    tabItems(
        tabItem(
            tabName = "resum",
            fluidRow(
                column(12, 
                    sidebarPanel(width=15,
                            fluidRow(
                                column(3, sliderInput("Any", list(icon("calendar"),"Period"),
                                width=200, min = 2012, max = 2016,
                                value = c(2016, 2016), step = 1)),
                                column(3, selectInput("sexeSelector", list(icon("user"), "Gender"), choices=list("Both"="Both", "Men"="Men", "Women"="Women"), selected="Both", width=150)),
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
                        )
                )
            ),
            fluidRow(
                column(4, id="vboxMalesCol", withSpinner(valueBoxOutput("vboxMales", width = 12),  type = 4, color = "#5E95C3",size = 0.4)),
                column(4, id="vboxWomansCol", withSpinner(valueBoxOutput("vboxWomans", width = 12), type = 4, color = "#5E95C3", size = 0.4)),
                column(4, id="vboxAvgAgeCol", withSpinner(valueBoxOutput("vboxAvgAge", width = 12),  type = 4, color = "#5E95C3", size = 0.4)),
            ),
            fluidRow(
                column(
                    12,
                    div(
                        style = "position: relative",
                        tabBox(id = "plot_pat_select_box", width = NULL,height = 400,
                            tabPanel(
                                title = p("Most frequency cancer",
                                    dropdown(radioGroupButtons(inputId = "box_pat1",label = NULL, choices = c("Tots", "Top 10"), selected = "Tots", direction = "vertical"),
                                        size = "xs",icon = icon("cogs", class = "opt", verify_fa = FALSE),  up = TRUE)
                                ), 
                                withSpinner(
                                    plotlyOutput("plot_pat_select", height = 300),
                                    type = 4,
                                    color = "#5E95C3", 
                                    size = 0.5     
                                )),
                                div(
                                    style = "position: absolute; right: 0.5em; bottom: 0.5em;",
                                    
                                    actionBttn(
                                        inputId = "plot_pat_select_ab",
                                        icon = icon("search-plus", class = "opt"),
                                        style = "fill",
                                        color = "danger",
                                        size = "xs"
                                        )    
                            )
                        )
                        
                    )
                )
            ),
            
            fluidRow(
                column(6, 
                    div(
                        style = "position: relative",
                        tabBox(id = "distribution_plot_box", width = NULL,height = 400,
                            tabPanel(
                                title = "Age Pyramid",
                                withSpinner(plotlyOutput("distribution_plot", height = 300),type = 4, color = "#5E95C3",size = 0.5)
                            ),
                            div(
                                style = "position: absolute; right: 0.5em; bottom: 0.5em;",
                                conditionalPanel("input.distribution_plot_box == 'Piràmide'",
                                    actionBttn(
                                    inputId = "distribution_plot_ab",
                                    icon = icon("search-plus", class = "opt"),
                                    style = "fill",
                                    color = "danger",
                                    size = "xs"
                                    )
                                )
                            ),
                        )
                    )               
                ), # piramide
                column(6, 
                    div(
                        style = "position: relative",
                        tabBox(id = "evolution_plot_box", width = NULL,height = 400,
                            tabPanel(
                            title = "Cases evolution", withSpinner(plotlyOutput("evolution_plot", height = 300),type = 4, color = "#5E95C3",size = 0.5)
                            ),
                            div(
                            style = "position: absolute; right: 0.5em; bottom: 0.5em;",
                            conditionalPanel("input.evolution_plot_box == 'Evolució de casos'",
                                actionBttn(
                                inputId = "evolution_plot_ab",
                                icon = icon("search-plus", class = "opt"),
                                style = "fill",
                                color = "danger",
                                size = "xs"
                                )
                            )
                            ),
                        )
                    )     
                ), # Evolucio de casos
            ),
            fluidRow(
                column(
                    12,
                    box(width=0,title="Cases table by gender",
                        withSpinner(
                            DT::dataTableOutput("table_pat_all"),
                            type = 4,
                            color = "#5E95C3",
                            size = 0.7
                        )
                    )
                ),
                
            )
        ),
        tabItem( # Todo correct this (need to be antother windows)
            tabName = "incidencia",
            fluidRow(
                column(12, h3("Incidence"))
            ),
            fluidRow(
                column(12, box(width=0, title="Filtre", withSpinner(uiOutput("incident_filter"))))
            ),
            fluidRow(
                column(6, height=400,
                    box(width=0, height= "100%", title="Incidence",
                    actionButton("buttonmap", "Map", style="color: #fff; background-color: #008000; border-color: #2e6da4; margin-bottom: 5px;"), 
                    actionButton("buttonbarplot", "Bar plot", style="color: #fff; background-color: #337ab7; border-color: #2e6da4; margin-bottom: 5px;"),
                    div(id="div_map",                   
                        tags$style(
                            ".leaflet .legend {
                            line-height: 11px;
                            font-size: 10px;
                            }",
                            ".leaflet .element.style{
                                height: 355px;
                            }"
                        ),
                        withSpinner(leafletOutput("incident_map", height=336))
                    ),

                    div(id="div_barplot",                   
                        withSpinner(plotlyOutput("incident_barplot", height = 336))
                    )

                )),
                column(6, height=400, box(width=0,title="Incidence table",
                        withSpinner(
                            DT::dataTableOutput("incident_table"),
                            type = 4,
                            color = "#5E95C3",
                            size = 0.7
                        )
                    )
                )
            ),
            fluidRow(
                column(6, box(width=0,title="Evolució de casos",withSpinner(plotlyOutput("evolution_plot_incident"), type = 4,color = "#5E95C3",size = 0.5 ))), # Evolucio de casos incidencia
                column(6, box(width=0,title="Piramide",withSpinner(plotlyOutput("piramide_incident"), type = 4,color = "#5E95C3",size = 0.5 ))), # Piramide incidenci    
            )
        ),

        tabItem(
            tabName = 'riskfactors',
            fluidRow(
                valueBoxOutput("alcohol", width=3),
                valueBoxOutput("excesweight", width=3),
                valueBoxOutput("diabetes", width=3),
                valueBoxOutput("smoking", width=3)
            ),
            fluidRow(
                column(6, box(width=0,title="Alcohol consumption",
                        withSpinner(plotlyOutput("pie1"))
                    )
                ),
                column(6, box(width=0,title="BMI",
                        withSpinner(plotlyOutput("pie2"))
                    )
                )
                
            ),
            fluidRow(
                column(6, box(width=0,title="Smoking",
                        withSpinner(plotlyOutput("pie3"))
                    )
                ),
                column(6, box(width=0,title="Diabetes",
                        withSpinner(plotlyOutput("pie4"))
                    )
                ) 
            )
        ),

        tabItem(
            tabName = 'mortality',

            fluidRow(
                column(12, box(
                    width=0, title=NULL, headerBorder = FALSE,
                    column(3,  sliderInput("yearSelectorMortality", "Period", 2012, 2019, c(2012, 2019), width='50%'), icon="calendar"),
                    column(3,  selectInput("sexSelectorMortality", "Sex",
                            list("Both" = "B", 
                            "Men" = "M",
                            "Women" = "W"), width='50%'), selected = 'B'),
                    column(3,  selectInput("cancerSelectorMortality", "Cancer location",
                            c("--" = "--"), width='100%', selected = "C00 - Neoplasia maligna de labio"))
                ))
            ),

            fluidRow(
                valueBoxOutput("males_mortality", width=6),
                valueBoxOutput("females_mortality", width=6)
            ),

            fluidRow(
                column(6, box(width=0, title="Total cases by location",
                    withSpinner(plotlyOutput("cases_plot_mortality")))
                ),
                column(6, box(width=0, title="Age pyramid",
                    withSpinner(plotlyOutput("pyramid_mortality")))
                )
            ),
            fluidRow(
                column(6, box(
                    width=0,
                    withSpinner(
                        DT::dataTableOutput("table_mortality"),
                        type = 4,
                        color = "#5E95C3",
                        size = 1.0
                    )
                )),
                column(6, box(width=0, title="Evolution",
                    withSpinner(plotlyOutput("evolution_mortality")))
                )
            )
        )
    )
)



# -----------------
# Main page
# ----------------------------------------------------------------------------------------------------
  
  # -------------
  # Login
  # -------------
  login <- fluidPage( # TODO transform to row/colum format (RShiny native)
    useShinyjs(),
      div(
        id = "login-basic", 
        style = "width: 400px; max-width: 100%; margin: 0 auto;",
        div(
          class = "well",
          h4(class = "text-center", "Identifica't"),
          textInput("ti_user_name_basic", 
            label       = tagList(icon("user"), 
                                  "Usuari"),
            value = "",
            placeholder = "Id personal"
          ),
          passwordInput("ti_password_basic", 
            label       = tagList(icon("unlock-alt"), 
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
  barraNavegacio <- navbarPage( # TODO transform to row/colum format (RShiny native)
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
        tabPanel("INICI", icon = icon("home"), 
                 titlePanel("El càncer a la província de Lleida"),
                 "Tota la informació de càncer de la província de Lleida.",
                 hr()),
                 
        #------ Dades obertes -------
        tabPanel("DADES OBERTES", icon = icon("list-alt"), 
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
        tabPanel("REGISTRE CÀNCER", icon = icon("lock"),
                 titlePanel("Registre de càncer de Lleida: dades privades"),
                 hr(),
                 "Accés limitat al personal sanitari de l'hospital Arnau de Vilanova de Lleida.",
                 br(), br(),
                 login), 
        
        #------ Contacte -------
        tabPanel("CONTACTE", icon = icon("phone"),
                 titlePanel("Registre de càncer de Lleida: contacte"),
                 hr())
  )



# -----------
# UI
# --------------------------------------------------------------------------

dashboardPage(
    skin = "purple",
    header,
    sidebar,
    body
)


