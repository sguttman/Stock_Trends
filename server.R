#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
#

# -------------------- initialize --------------------------------------
   
# -------------------- getQuotes --------------------------------------
# function for getting a set of stock quotes and putting results into a data frame

     warningText = ""  

getQuotes = function(stickers) {
     
     # Check to see whether there are any ticker symbols
    allQuotes = data.frame()
    ticks = trimws(unlist(strsplit(stickers, ",")))
     
     if(!length(ticks))
          stop("No stock symbols found")
     
     # Parse string of ticker symbols
     
     for(i in 1:length(ticks)) {
          tryCatch({
               returns = getReturns(ticks[i], start=tenyears, end=tday)
               quotes = returns$full[[ticks[i]]]
               quotes$Date = ymd(as.character(quotes$Date))
               quotes = quotes %>% mutate(ticker = toupper(ticks[i]), date= ymd(as.character(quotes$Date)) ) 
               if(nrow(quotes) == 0)
                    next
               allQuotes = rbind(allQuotes, quotes)
               
               }, 
               error=function(e) {warningText = cat(warningText,ticks[i],"is not a valid symbol\n")},
               warning=function(w) {#warningText = cat(warningText,ticks[i],"is not a valid symbol\n");
                    }
          )
     }
     allQuotes
}

     
# -------------------- plotStocks --------------------------------------
# function for plotting a set of stock symbols, incl linear regression line

plotStocks = function(quo, startt, endd, perf) {
     
# Filter quotes for start and end dates, then normalize to get relative performance based on 0% at start date
# Normalize the quotes by subtracting the first close and then dividing by the first close     
     qquo = filter(quo, date >= startt & date <= endd)
     qquo.lst = split(qquo, qquo$ticker)
     for(i in 1:length(qquo.lst)){
          qquo.lst[[i]] = qquo.lst[[i]] %>% arrange(date) %>% mutate(Adj.Percent = (Adj.Close - Adj.Close[1])/Adj.Close[1])
     }
     qquo = do.call("rbind", qquo.lst)

# Plot it     
     colrs = c("#000000", "#FFFF00", "#1CE6FF", "#FF34FF", "#FF4A46", "#008941", "#006FA6", "#A30059",
               "#00489C", "#6F0062", "#0CBD66", "#EEC3FF", "#456D75", "#B77B68", "#7A87A1", "#788D66")

# If "perf" show relative performance as percentage, otherwise plot stock values     
     if(perf) {
          g = ggplot(qquo, aes(x=date, y=Adj.Percent))
          g = g + scale_y_continuous(labels=percent) + ylab("Relative Performance")
          }
          else {
          g = ggplot(qquo, aes(x=date, y=Close))
          g = g  + ylab("Stock Price")
          }
     
     g = g + geom_line(aes(color=ticker), stat="identity", size=1)
     g = g + geom_smooth(method="lm")
     g = g + xlab(NULL) 
     g = g + theme_bw()

     g = g + theme(legend.position="bottom", legend.direction="horizontal",legend.title = element_blank(),
                   legend.text=element_text(size=10))
     g = g + geom_text(data = subset(qquo, date == endd), aes(label = round(qquo$Adj.Close[date == endd],2) ))
     g  
}
# ----------------------------------------------------------------------------------
# Define server logic req'd for shiny app

shinyServer(function(input, output, session) {

     shinyjs::disable("goButton")
     removeClass("goButton","buttonOn")
     
          observeEvent(input$sectors, {
          updateTextInput(session, "tickers", value = input$sectors); 
          # html("element",input$sectors)
          })

     observeEvent(input$tickers, {
          if(input$tickers != stockTicks()){
               enable("goButton")
               addClass("goButton","buttonOn")
               }
          }) 
     observeEvent(input$goButton, {
          disable("goButton")
          removeClass("goButton","buttonOn")
     }) 
     onclick("info", {
          info("STOCK TRENDS SHINY APP  

               This shiny app allows viewing and experimenting with (small) 
               stock portfolios. You can edit the current set of ticker 
               symbols in the top input field or choose pre-populated
               sets (based on securities from various sectors) from the 
               drop-down below it. Securities must be separated by commas. 
               Click the SUBMIT button to update the chart.
               
               You can adjust the date range on the chart. It pull a 
               maximum of ten years worth of stock data starting at 
               today's date and going back 10 years. You can adjust
               the start and end dates within that range. Uncheck 
               the relative performance checkbox if you'd prefer seeing 
               absolute prices over time. The trend line is useful to 
               gauge whether certain sectors are increasing or decreasing 
               over time.")
     })
      stockTicks = reactive({
            input$goButton
            isolate(input$tickers)
  })
#  output$oTickers = renderText(print(input$sectors))

  output$stockPlot <- renderPlot({
            perf = input$perf
            startEnd = input$range
            theQuotes = getQuotes(unlist(stockTicks()))
            plotStocks(theQuotes, startEnd[1], startEnd[2], perf)
           })
          

})
