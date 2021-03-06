library(shinydashboard)
library(shiny)
library(sf)
library(leaflet)

#### Header ####
header <- dashboardHeader(
  # Top Left Corner
  title = tags$a(href='https://hawaiiwildfire.org',
                 tags$img(src='hwmo_logo_white.svg',
                          title = "HWMO Home", 
                          height = "45px"),
                 alt = "HWMO"),

  ### Top right corner ###
  tags$li(a(href = 'appHelp.html',
    icon("question-circle-o"),
    title = "Help",
    style = "padding-top:10px; padding-bottom:10px;",
    target= "_blank"),
    class = "dropdown"
  ),
  tags$li(a(href = 'https://github.com/niklaslollo/HWMO_webapp',
            icon("file-code-o"),
            title = "Github",
            style = "padding-top:10px; padding-bottom:10px;"),
          class = "dropdown")
  )

#### Sidebar ####
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Map", tabName = "Map"),
    menuItem("Explore your area", tabName = "area"),
    menuItem("Take Action", tabName = "action"),
    menuItem("About", tabName = "FAQ"),
    menuItem("Data Downloads", tabname = "Downloads",
             menuSubItem("Community Meeting Info", 
                      tabName = "community"),
             menuSubItem("Hazards", 
                      tabName = "explore")),
    menuItem("Links", tabName = "Links", 
             menuSubItem("Hawaii Wildfire Website", icon = icon("home"), 
                         href = "https://hawaiiwildfire.org", 
                         newtab = T),
             menuSubItem("Source code (Github)", icon = icon("file-code-o"), 
             href = "https://github.com/niklaslollo/hwmo_data_tool", 
             newtab = T))
  ))

#### Body ####
body <- dashboardBody(
  # Load CSS
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  tabItems(
    ### Map Tab - First Tab ####
    tabItem(tabName = "Map",
            fluidRow(
              # Map output
              column(width = 9,  
              box(width = NULL, 
                    solidHeader = T,
                    leafletOutput("leafmap", height = 500))),
              # Right content bar
              column(width = 3,
                     box(width =NULL,
                         status = "danger", # Makes header red
                         # Select map data
                         #title = "Map Data",
                         #for choices, 1st is for the menu, second for the legend
                         selectInput(inputId = "dataset",
                                     label = "Map Data",
                                     selectize = FALSE,
                                     choices = list(
                                       "Overall Wildfire Hazard" = "Overall Wildfire Hazard",
                                       "Fire Protection" = "Fire Protection",
                                       "Subdivision" = "Subdivision",
                                       "Vegetation" = "Vegetation",
                                       "Buildings" = "Buildings",
                                       "Fire Environment" = "Fire Environment",
                                       "Median Household Income ($)" = "Median Household Income",
                                       "Native Hawaiians (%)" = "Native Hawaiians",
                                       "Homeownership (%)" = "Homeownership",
                                       "Vacant Housing Units (%)" = "Vacant Housing Units",
                                       "Population Density (pop/sq.mi)" = "Population Density"
                                      ),
                                     selected = "overall_score")),
                     # Fires showing in map plot
                     box(width = NULL, 
                         status = "danger",
                         solidHeader = T, title = "Fires showing in map",
                         plotOutput(outputId = "timeFire",
                                    height = 175),
                         selectInput(inputId = "histY",
                                     label = "Statistic",
                                     selectize = FALSE,
                                     choices = c("Number of fires" = "count",
                                                 "Total acres burned" = "total_acres",
                                                 "Avg acres burned per fire" = "avg_acres"),
                                     selected = "count"),
                         selectInput(inputId = "histX",
                                     label = "Time",
                                     selectize = FALSE,
                                     choices = c("Month" = "month",
                                                 "Year" = "year"),
                                     selected = "year"))))
            ),
    #### Explore Your Area Tab ######
    tabItem(tabName = "area",
            fluidRow(
              box(width = 12, solidHeader = T,
                  tags$h4("Pick an area and hazard to see the hazard score."))),
            fluidRow(
              # Select area
              box(id = "inlineLab",
                width = 6, 
                  status = "danger",
                  selectInput(inputId = "island2",
                              selectize = FALSE,
                              label = "Island",
                              choices = c("Sort by island..."="",
                                          sort(unique(haz_tidy$Island))
                              ),
                              multiple = F),
                  selectInput(inputId = "areaname2", 
                              label = "Area", 
                              selectize = FALSE,
                              choices = c("Pick an area..."="",
                                          sort(unique(haz_tidy$AreaName))), 
                              multiple=F,
                              selected = "Hanalei")
                  ),
              # Select hazard
              box(id = "inlineLab",
                  width = 6, 
                  status = "danger",
                  selectInput(inputId = "category2", 
                              label = "Hazard Category",
                              selectize = FALSE,
                              choices = c("Sort by hazard category..."="",
                                          "Subdivision" = "Subdivision",
                                          "Fire Protection" = "Fire Protection",
                                          "Vegetation" = "Vegetation",
                                          "Building" = "Building",
                                          "Fire Environment" = "Fire Environment"), 
                              multiple=F),
                  selectInput(inputId = "hazard2", 
                              label = "Hazard",
                              selectize = FALSE,
                              choices = c("Pick a hazard..."="",
                                          sort(unique(haz_tidy$hazard_full))
                              ), 
                              multiple=F,
                              selected = "Road Width")
                  )
            ),
            # Hazard score for area
            fluidRow(
              valueBoxOutput("scoreBox", width = 12)
            ),
            fluidRow(
              box(width = 3, solidHeader = T,
                tags$h4("How was this scored?"))),
            # Reasons for scoring
            fluidRow(
              infoBoxOutput("hiScoreBox", width = 4),
              infoBoxOutput("medScoreBox", width = 4),
              infoBoxOutput("lowScoreBox", width = 4))
            ),
############## Informational (Markdown) Tabs ############################    
    #### Take Action Tab #######
     tabItem(tabName = "action",
             column(
               width = 9,
             fluidRow(
             box(
               width = 12,
               solidHeader = T,
               title = "Raise Awareness",
               status = "success",
               collapsible = T,
               collapsed = T,
               includeMarkdown("docs/TA_awareness.md")
             )),
             fluidRow(
               box(
                 width = 12,
                 solidHeader = T,
                 title = "Protect Your Home",
                 status = "primary",
                 collapsible = T,
                 collapsed = T,
                 includeMarkdown("docs/TA_protectHome.md")
               )),
             fluidRow(
               box(
                 width = 12,
                 solidHeader = T,
                 title = "Protect Your Community",
                 status = "warning",
                 collapsible = T,
                 collapsed = T,
                 includeMarkdown("docs/TA_protectComm.md")
               )),
             fluidRow(
               box(
                 width = 12,
                 solidHeader = T,
                 title = "Attend a Future Event",
                 status = "info",
                 collapsible = T,
                 collapsed = T,
                 includeMarkdown("docs/TA_event.md")
               )),
          fluidRow(
            box(
              width = 12,
              solidHeader = F,
              title = "Donate",
              includeMarkdown("docs/TA_donate.md")
            ))),
          # Social Icons
          column(
            width = 3,
            fluidRow(
            box(
              width = 12,
              solidHeader = F,
              title = "Connect",
              includeMarkdown("docs/TA_social.md")
            )))
          ),
    #### About Tab #####
     tabItem(tabName = "FAQ",
             fluidRow(
             box(width = 12, solidHeader = T,
                 includeMarkdown("docs/about.md")))),
    
################## Data Tabs ###################################
    ### Community data tab ######
    tabItem(tabName = "community",
            fluidRow(
              box(width = 4, 
                  status = "danger",
                  selectInput(inputId = "focus",
                              selectize = FALSE,
                              label = "Strategic Focus", 
                              choices = c("Pick a focus..."="",
                                          "Prevention" = "P",
                                          "Pre-suppression" = "PS",
                                          "Suppression" = "S",
                                          "Post-fire" = "PF"), 
                              multiple=TRUE)),
              box(width = 4, 
                  status = "danger",
                  selectInput(inputId = "region",
                              label = "Region(s)", 
                              selectize = FALSE,
                              choices = c("Pick a region..."="", 
                                          "Kauai" = "Kauai",
                                          "Molokai" = "Molokai",
                                          "South Maui" = "South Maui",
                                          "Upcountry Maui" = "Upcountry Maui",
                                          "Western Oahu" = "W. Oahu"), 
                              multiple=TRUE),
                  conditionalPanel("input.region",
                                   selectInput(inputId = "meeting", 
                                               selectize = FALSE,
                                               label = "Meeting Location(s)", 
                                               choices = c("Pick a meeting location"=""), 
                                               multiple=TRUE))),
              # Download buttons
              box(width = 3,
                  status = "danger",
                  title = "Download",
                  downloadButton("download_all_data",
                                 "All Data"),
                  tags$br(),
                  # License
                  includeMarkdown("docs/license_small_short.md")
              )
            ),
            # Show data
            fluidRow(
              box(width = 12, solidHeader = T,
                  DT::dataTableOutput("dt"))
            )
    ),
    ################### Hazard data tab ##########
    tabItem(tabName = "explore",
            fluidRow(
              box(width = 4, 
                  status = "danger",
                  selectInput(inputId = "island",
                              selectize = FALSE,
                              label = "Island",
                              choices = c("Pick an island..."="",
                                          "Hawaii Island" = "Hawaii Island",
                                          "Kahoolawe" = "Kahoolawe",
                                          "Kauai" = "Kauai",
                                          "Lanai" = "Lanai",
                                          "Lehua" = "Lehua",
                                          "Maui" = "Maui",
                                          "Molokai" = "Molokai",
                                          "Molokini Atoll" = "Molokini Atoll",
                                          "Niihau" = "Niihau",
                                          "Oahu" = "Oahu"),
                              multiple = TRUE),
                  conditionalPanel("input.island",
                                   selectInput(inputId = "areaname",
                                               selectize = FALSE,
                                               label = "Area", 
                                               choices = c("Pick an area..."=""), 
                                               multiple=TRUE))),
              box(width = 4, 
                  status = "danger",
                  selectInput(inputId = "category", 
                              selectize = FALSE,
                              label = "Hazard Category", 
                              choices = c("Pick a hazard category..."="",
                                          "Subdivision" = "Subdivision",
                                          "Fire Protection" = "Fire Protection",
                                          "Vegetation" = "Vegetation",
                                          "Building" = "Building",
                                          "Fire Environment" = "Fire Environment"), 
                              multiple=TRUE), 
                  conditionalPanel("input.category",
                                   selectInput(inputId = "hazard", 
                                               selectize = FALSE,
                                               label = "Hazard(s)", 
                                               choices = c("Pick a hazard..."=""), 
                                               multiple=TRUE))
                  ),
              # Download buttons
            box(width = 3, status = "danger",
                title = "Download",
                  downloadButton("download_all_haz",
                                 "All Data"), 
                tags$br(),
                # License
                includeMarkdown("docs/license_small_short.md")
              )),
            # Show data
            fluidRow(
              box(width = 12, solidHeader = T,
                  DT::dataTableOutput("dt_haz"))
            )))
  )

# Call the dashboard elements            
dashboardPage(
  title = "HWMO WebApp",
  skin = "red",
  header,
  sidebar,
  body)
