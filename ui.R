
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
     
     shinyjs::useShinyjs(),

  # Application title
     flowLayout(
       titlePanel("Stock Trends"),img(id="info", src="inform.png", style="margin-top:15px")          
     ),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
         wellPanel(
         textInput("tickers","Enter/edit comma-separated tickers", "AAPL, SPY, GOOG, GILD, T"),
       selectInput("sectors", "or choose a pre-populated set", 
                   c('Miscellaneous' = 'AAPL, SPY, GOOG, GILD, T',
                    'Consumer Discretionary' = 'BJK,FDIS,PEJ,RXI,XHB',
                   'Consumer Staples' = 'CROP,FXG,IPS,PBJ,VDC',
                   'Energy' = 'EMLP,FENY,IEO,IXC,YMLP',
                   'Financial' = 'FNCL,IYG,KBWD,KIE,VFH',
                   'Fixed Income' = 'CORP,FBND,FCOR,FLTB,SLQD',
                   'Health Care' = 'FHLC,IHY,PBE,PJP,XHS',
                   'Industrials' = 'DIA,FIDU,IYJ,PPA,PSCI',
                   'Materials' = 'FMAT,LIT,PICK,WOOD,XME',
                   'Real Estate' = 'FREL,IFGL,IYR,REM,VNQ',
                   'Technology' = 'CIBR,FTEC,IPK,MTK,PNQI',
                   'Telecom' = 'FCOM,IST,IYZ,VOX')
                   ),
#       p(id = "element", "Watch what happens to me"),
      inlineCSS(".buttonOn { font-weight:bold; border-color: #66afe9; outline: 0;
                    -webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075), 0 0 8px rgba(102, 175, 233, 0.6);
                    box-shadow: inset 0 1px 1px rgba(0,0,0,.075), 0 0 8px rgba(102, 175, 233, 0.6);}"),
       actionButton("goButton", "Submit"),
          HTML("<div style='font-size:small; margin-top:12px'>Click <strong>Submit</strong> to plot</div> ")

         ),
     wellPanel(
       dateRangeInput("range", "Date range:",
                      start  = tenyears,
                      end    = tday,
                      min    = tenyears,
                      max    = tday,
                      format = "mm/dd/yyyy",
                     # startview = 'year',
                      separator = " to "),
       checkboxInput("perf", "Relative Performance (%)",value = TRUE),
       HTML("<div style='font-size:small; margin-top:15px'>Leave checked if you want to compare % increase over time. 
            Uncheck to compare actual stock prices.</div> ")
     )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
     textOutput('errorText'),
      plotOutput("stockPlot", height = "600px")
    )
  )
))
