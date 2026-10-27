# GitHub Repository Popularity Dashboard
# This app explores trending GitHub repositories and tests a simple regression model.

library(shiny)

# Read the dataset saved beside this file.
data_file <- file.path("data", "github_trending_repos.csv")
if (!file.exists(data_file)) {
  stop("Dataset not found. Keep the data folder beside app.R.")
}
repos <- read.csv(data_file, stringsAsFactors = FALSE)

# Make sure the values used in the charts and model are numbers.
number_cols <- c("stars", "forks", "stars_period")
for (col in number_cols) {
  repos[[col]] <- as.numeric(gsub(",", "", repos[[col]]))
}
repos <- repos[!is.na(repos$forks) & !is.na(repos$stars_period) &
                 repos$forks >= 0 & repos$stars_period >= 0, ]
repos$language[is.na(repos$language) | repos$language == ""] <- "Not specified"

# Colours used throughout the dashboard.
navy <- "#172554"
blue <- "#2563eb"
teal <- "#0f766e"
muted <- "#64748b"
grid_col <- "#e2e8f0"

# Build the page layout and its responsive design.
ui <- fluidPage(
  tags$head(
    tags$title("GitHub Popularity | Data Explorer"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$style(HTML(paste0("\n      body { background:#f4f7fb; color:#172033; font-family:Inter,Segoe UI,Arial,sans-serif; }\n      .container-fluid { max-width:1500px; padding:26px 30px 36px; }\n      .hero { background:linear-gradient(120deg,#14213D 0%,#1D4ED8 72%,#4F7CFF 100%); color:white; padding:30px 32px; border-radius:20px; margin-bottom:22px; box-shadow:0 14px 32px rgba(30,64,175,.18); position:relative; overflow:hidden; }\n      .hero h1 { margin:0 0 10px; font-size:clamp(24px,3vw,36px); line-height:1.2; font-weight:800; letter-spacing:-.6px; }\n      .hero p { margin:0; color:#dbeafe; font-size:15px; line-height:1.6; max-width:850px; }\n      .hero-tag { display:inline-block; margin-top:14px; padding:5px 10px; border:1px solid rgba(255,255,255,.3); border-radius:20px; color:#eff6ff; font-size:12px; }\n      .filter-card, .chart-card, .info-card { background:white; border:1px solid #e5ebf4; border-radius:17px; padding:20px 22px; margin-bottom:20px; box-shadow:0 5px 18px rgba(15,23,42,.04); }\n      .section-title { color:#172554; font-size:18px; font-weight:750; margin:0 0 5px; }\n      .section-note { color:#64748b; font-size:13px; margin-bottom:15px; }\n      .form-group { margin-bottom:4px; }\n      .control-label { color:#334155; font-size:13px; font-weight:650; }\n      .form-control { border:1px solid #dbe3ef; border-radius:9px; height:40px; box-shadow:none; }\n      .kpi { background:white; border:1px solid #e5ebf4; border-radius:16px; padding:19px 20px; min-height:122px; margin-bottom:20px; box-shadow:0 5px 18px rgba(15,23,42,.04); border-top:4px solid #2563eb; }\n      .kpi-label { color:#64748b; font-size:11px; text-transform:uppercase; letter-spacing:.8px; font-weight:800; }\n      .kpi-value { color:#172554; font-size:clamp(23px,2.3vw,31px); font-weight:800; margin-top:7px; line-height:1.15; overflow-wrap:anywhere; }\n      .kpi-help { color:#94a3b8; font-size:12px; margin-top:6px; }\n      .chart-card h3 { font-size:16px; font-weight:800; color:#172554; margin:0 0 5px; }\n      .chart-card .hint { color:#64748b; font-size:12px; margin-bottom:12px; }\n      .nav-tabs { border-bottom:1px solid #dbe3ef; margin-bottom:18px; }\n      .nav-tabs>li>a { color:#475569; font-weight:650; border-radius:9px 9px 0 0; }\n      .nav-tabs>li.active>a, .nav-tabs>li.active>a:hover { color:#1d4ed8; border:1px solid #dbe3ef; border-bottom-color:white; background:white; }\n      table { font-size:13px; }\n      .table { margin-bottom:0; min-width:640px; }
      .table-responsive { overflow-x:auto; border-radius:10px; }
      .shiny-plot-output { max-width:100%; }\n      .table>thead>tr>th { color:#475569; background:#f8fafc; border-bottom:1px solid #e2e8f0; }\n      .table>tbody>tr>td { vertical-align:middle; }\n      .note { color:#64748b; font-size:12px; line-height:1.65; }\n      .metric-line { padding:9px 0; border-bottom:1px solid #edf2f7; color:#475569; }\n      .metric-line strong { color:#172554; float:right; }\n      .footer-note { text-align:center; color:#94a3b8; font-size:12px; padding:12px 0 2px; }\n      @media(max-width:767px) { .container-fluid { padding:12px; } .hero { padding:23px 18px; border-radius:15px; } .hero p { font-size:14px; } .filter-card,.chart-card,.info-card { padding:15px; border-radius:14px; } .kpi { min-height:100px; padding:14px; border-radius:13px; } .kpi-value { font-size:24px; } .nav-tabs>li>a { padding:10px 11px; font-size:12px; } .shiny-plot-output { width:100% !important; } }\n          "))),
      tags$style(HTML("
        body { background:#f3f6fb; color:#172033; font-family:Inter,-apple-system,BlinkMacSystemFont,Segoe UI,Arial,sans-serif; }
        .container-fluid { max-width:1440px; padding:30px 34px 40px; }
        .hero { background:linear-gradient(118deg,#101d3c 0%,#173b83 58%,#2563eb 100%); color:white; padding:38px 42px; border-radius:24px; margin-bottom:24px; box-shadow:0 18px 42px rgba(23,59,131,.2); position:relative; overflow:hidden; }
        .hero:after { content:''; position:absolute; width:340px; height:340px; right:-90px; top:-180px; border:1px solid rgba(255,255,255,.15); border-radius:50%; box-shadow:0 0 0 34px rgba(255,255,255,.035),0 0 0 70px rgba(255,255,255,.025); pointer-events:none; }
        .hero-eyebrow { color:#bfdbfe; font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:1.7px; margin-bottom:13px; }
        .hero h1 { margin:0 0 12px; max-width:780px; font-size:clamp(27px,3.2vw,40px); line-height:1.12; font-weight:800; letter-spacing:-1px; }
        .hero p { margin:0; color:#dbeafe; font-size:15px; line-height:1.7; max-width:760px; }
        .hero-tag { display:inline-flex; margin-top:19px; padding:7px 12px; background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.22); border-radius:999px; color:#eff6ff; font-size:11px; font-weight:700; letter-spacing:.35px; }
        .filter-card, .chart-card, .info-card { background:#fff; border:1px solid #e6ebf3; border-radius:18px; padding:22px 24px; margin-bottom:20px; box-shadow:0 5px 20px rgba(15,23,42,.035); }
        .section-title { color:#14264b; font-size:18px; font-weight:750; margin:0 0 5px; letter-spacing:-.25px; }
        .section-note { color:#718096; font-size:13px; margin-bottom:17px; }
        .form-group { margin-bottom:4px; }
        .control-label { color:#34445f; font-size:12px; font-weight:750; margin-bottom:7px; }
        .form-control { border:1px solid #dce4ef; border-radius:10px; height:42px; box-shadow:none; color:#1e293b; transition:border-color .15s,box-shadow .15s; }
        .form-control:focus { border-color:#4f83ef; box-shadow:0 0 0 3px rgba(37,99,235,.12); }
        .kpi { background:#fff; border:1px solid #e6ebf3; border-radius:17px; padding:20px 21px; min-height:128px; margin-bottom:20px; box-shadow:0 5px 20px rgba(15,23,42,.035); border-top:3px solid #3b72e8; transition:transform .16s,box-shadow .16s; }
        .kpi:hover { transform:translateY(-2px); box-shadow:0 10px 24px rgba(15,23,42,.08); }
        .kpi-label { color:#718096; font-size:10px; text-transform:uppercase; letter-spacing:1px; font-weight:800; }
        .kpi-value { color:#14264b; font-size:clamp(23px,2.3vw,31px); font-weight:800; margin-top:9px; line-height:1.15; overflow-wrap:anywhere; }
        .kpi-value .shiny-text-output { display:inline; }
        .kpi-help { color:#94a3b8; font-size:12px; margin-top:7px; }
        .chart-card h3 { font-size:16px; font-weight:800; color:#172b52; margin:0 0 6px; letter-spacing:-.2px; }
        .chart-card .hint { color:#7b8799; font-size:12px; line-height:1.55; margin-bottom:13px; }
        .nav-tabs { display:flex; gap:7px; border-bottom:1px solid #e3e9f2; margin-bottom:20px; padding:0 4px; }
        .nav-tabs>li { float:none; margin-bottom:-1px; }
        .nav-tabs>li>a { color:#64748b; font-size:13px; font-weight:700; border:1px solid transparent; border-radius:10px 10px 0 0; padding:12px 17px; transition:color .15s,background .15s; }
        .nav-tabs>li>a:hover { color:#1d4ed8; background:#f4f7fc; border-color:transparent; }
        .nav-tabs>li.active>a, .nav-tabs>li.active>a:hover, .nav-tabs>li.active>a:focus { color:#1d4ed8; border:1px solid #e3e9f2; border-bottom-color:#fff; background:#fff; }
        table { font-size:13px; }
        .table { margin-bottom:0; min-width:640px; }
        .table-responsive { overflow-x:auto; border:1px solid #e8edf4; border-radius:12px; }
        .shiny-plot-output { max-width:100%; }
        .table>thead>tr>th { color:#475569; background:#f7f9fc; border-bottom:1px solid #e5eaf2; padding:12px 14px; }
        .table>tbody>tr>td { vertical-align:middle; padding:11px 14px; }
        .table>tbody>tr:hover { background:#f8faff; }
        .note { color:#718096; font-size:12px; line-height:1.7; margin-bottom:0; }
        .metric-line { padding:10px 0; border-bottom:1px solid #edf1f6; color:#5b687b; font-size:13px; }
        .metric-line strong { color:#172b52; float:right; }
        .footer-note { text-align:center; color:#9aa5b5; font-size:12px; padding:14px 0 2px; }
        @media(max-width:767px) {
          .container-fluid { padding:15px 13px 25px; }
          .hero { padding:28px 23px; border-radius:19px; }
          .hero h1 { font-size:29px; }
          .hero p { font-size:14px; }
          .filter-card,.chart-card,.info-card { padding:17px; border-radius:15px; }
          .kpi { min-height:108px; padding:15px; border-radius:14px; }
          .kpi-value { font-size:23px; }
          .nav-tabs { gap:0; }
          .nav-tabs>li>a { padding:10px 11px; font-size:12px; }
          .shiny-plot-output { width:100% !important; }
        }
        @media(max-width:420px) {
          .hero h1 { font-size:25px; }
          .nav-tabs>li>a { padding:9px 8px; font-size:11px; }
        }
      "))
  ),

  div(class = "hero",
        div(class = "hero-eyebrow", "GitHub data explorer  /  Trending repository analysis"),
        h1("What Makes a GitHub Repository Popular?"),
      p("Explore the patterns behind trending repositories, compare programming languages, and test whether repository forks help explain stars gained during the trending period."),
      span(class = "hero-tag", "DATA SCIENCE PROJECT  •  EXPLORATORY ANALYSIS + LINEAR REGRESSION")
  ),

  div(class = "filter-card",
      div(class = "section-title", "Explore the data"),
      div(class = "section-note", "Use these filters to update the charts, summary numbers, and repository list."),
      fluidRow(
        column(6, selectInput("timeframe", "Trending timeframe",
                              choices = c("All timeframes" = "All", sort(unique(repos$timeframe))), selected = "All", width = "100%")),
        column(6, selectInput("search_language", "Language group",
                              choices = c("All languages" = "All", sort(unique(repos$search_language))), selected = "All", width = "100%"))
      )
  ),

  fluidRow(
    column(3, div(class = "kpi", div(class = "kpi-label", "Repository records"), div(class = "kpi-value", textOutput("row_count", inline = TRUE)), div(class = "kpi-help", "Rows matching your filters"))),
    column(3, div(class = "kpi", div(class = "kpi-label", "Average star gains"), div(class = "kpi-value", textOutput("avg_period_stars", inline = TRUE)), div(class = "kpi-help", "Stars gained in the period"))),
    column(3, div(class = "kpi", div(class = "kpi-label", "Median forks"), div(class = "kpi-value", textOutput("median_forks", inline = TRUE)), div(class = "kpi-help", "Middle value of fork counts"))),
    column(3, div(class = "kpi", div(class = "kpi-label", "Languages shown"), div(class = "kpi-value", textOutput("language_count", inline = TRUE)), div(class = "kpi-help", "Different primary languages")))
  ),

  tabsetPanel(
    id = "main_tabs",
    tabPanel("Overview",
      br(),
      fluidRow(
        column(6, div(class = "chart-card", h3("Most common languages"), div(class = "hint", "Top 10 languages in the filtered records"), plotOutput("language_plot", height = "350px", width = "100%"))),
        column(6, div(class = "chart-card", h3("Forks and star gains"), div(class = "hint", "Both axes use log(1 + value) so large values do not hide smaller ones"), plotOutput("scatter_plot", height = "350px", width = "100%")))
      ),
      div(class = "info-card", div(class = "section-title", "How to read this dashboard"),
          p(class = "note", "Each row is a repository record collected in a trending context, so a repository may appear more than once. The charts describe this dataset; they do not prove that forks cause popularity. The contributor count is zero throughout this dataset, so it is not used as a predictor."))
    ),
    tabPanel("Regression model",
      br(),
      div(class = "chart-card", h3("Linear regression: forks and star gains"),
          p(class = "hint", "The model uses log(1 + forks) to predict log(1 + stars gained). It is tested on a separate 20% sample."),
          fluidRow(
            column(4, div(class = "info-card", h4("Model summary", style = "margin-top:0;color:#172554;font-weight:750"), uiOutput("model_metrics"))),
            column(8, div(class = "chart-card", h3("Actual vs predicted star gains"), div(class = "hint", "Points closer to the dashed line are more accurate predictions"), plotOutput("prediction_plot", height = "390px", width = "100%")))
          )
      ),
      div(class = "info-card", div(class = "section-title", "What the scores mean"),
          p(class = "note", "MAE is the average size of the prediction error. RMSE gives larger errors more weight. Test R-squared compares the predictions with a simple average-based baseline; a low or negative value means this one-variable model does not predict well. These scores are for this dataset and split only."))
    ),
    tabPanel("Top repositories",
      br(),
      div(class = "chart-card", h3("Repositories with the largest star gains"), div(class = "hint", "Sorted by stars gained during the trending period"), div(class = "table-responsive", tableOutput("top_repositories"))),
      br(),
      p(class = "note", "Repository records can repeat across timeframes or collection groups. Open a repository using its GitHub link for more context.")
    )
  ),
  div(class = "footer-note", "Built with R and Shiny • GitHub trending dataset • Educational analysis")
)

# Update the dashboard when a filter changes.
server <- function(input, output, session) {

  # Keep only rows that match the selected filters.
  filtered_repos <- reactive({
    d <- repos
    if (input$timeframe != "All") d <- d[d$timeframe == input$timeframe, ]
    if (input$search_language != "All") d <- d[d$search_language == input$search_language, ]
    d
  })

  # Show the main numbers at the top of the dashboard.
  output$row_count <- renderText(format(nrow(filtered_repos()), big.mark = ","))
  output$avg_period_stars <- renderText({
    d <- filtered_repos()
    if (nrow(d) == 0) return("—")
    format(round(mean(d$stars_period, na.rm = TRUE), 1), big.mark = ",")
  })
  output$median_forks <- renderText({
    d <- filtered_repos()
    if (nrow(d) == 0) return("—")
    format(round(median(d$forks, na.rm = TRUE), 1), big.mark = ",")
  })
  output$language_count <- renderText({
    d <- filtered_repos()
    if (nrow(d) == 0) return("0")
    as.character(length(unique(d$language)))
  })

  # Draw a horizontal bar chart for the ten most common languages.
  output$language_plot <- renderPlot({
    d <- filtered_repos()
    validate(need(nrow(d) > 0, "No records match these filters."))
    counts <- head(sort(table(d$language), decreasing = TRUE), 10)
    counts <- sort(counts)
    old <- par(mar = c(4, 10, 1.5, 1), las = 1)
    on.exit(par(old))
    positions <- barplot(counts, horiz = TRUE, col = blue, border = NA,
      xlab = "Repository records", axes = FALSE, xlim = c(0, max(counts) * 1.12),
      cex.names = 0.9)
    axis(1, col = grid_col, col.axis = muted)
    abline(v = pretty(c(0, max(counts))), col = grid_col, lty = 1)
    barplot(counts, horiz = TRUE, col = blue, border = NA, axes = FALSE,
            add = TRUE, names.arg = rep("", length(counts)))
  }, res = 100)

  # Compare forks with star gains using a log scale to make the pattern easier to see.
  output$scatter_plot <- renderPlot({
    d <- filtered_repos()
    validate(need(nrow(d) > 2, "Not enough records to draw this chart."))
    x <- log1p(d$forks)
    y <- log1p(d$stars_period)
    old <- par(mar = c(4.5, 4.5, 2, 1))
    on.exit(par(old))
    plot(x, y, type = "n", xlab = "log(1 + forks)", ylab = "log(1 + stars gained)",
         main = "", las = 1, bty = "l", col.axis = muted, col.lab = navy)
    grid(col = grid_col, lty = 1)
    points(x, y, pch = 21, bg = grDevices::adjustcolor(blue, alpha.f = 0.3),
           col = grDevices::adjustcolor(blue, alpha.f = 0.55), cex = 0.85)
    if (length(unique(x)) > 1) abline(lm(y ~ x), col = teal, lwd = 2.5)
  }, res = 96)

  # Train the model on 80% of the rows and test it on the other 20%.
  model_result <- reactive({
    d <- filtered_repos()
    validate(need(nrow(d) >= 20, "Select filters that leave at least 20 records to run the model."))
    d$log_forks <- log1p(d$forks)
    d$log_stars_period <- log1p(d$stars_period)
    set.seed(42)
    train_ids <- sample(seq_len(nrow(d)), floor(0.8 * nrow(d)))
    train <- d[train_ids, ]
    test <- d[-train_ids, ]
    fit <- lm(log_stars_period ~ log_forks, data = train)
    predicted <- pmax(0, expm1(predict(fit, newdata = test)))
    actual <- test$stars_period
    mae <- mean(abs(actual - predicted))
    rmse <- sqrt(mean((actual - predicted)^2))
    baseline <- sum((actual - mean(actual))^2)
    r2 <- if (baseline > 0) 1 - sum((actual - predicted)^2) / baseline else NA_real_
    list(model = fit, train_n = nrow(train), actual = actual,
         predicted = predicted, mae = mae, rmse = rmse, r2 = r2)
  })

  # Show the model scores in plain language.
  output$model_metrics <- renderUI({
    r <- model_result()
    score <- function(x) if (is.finite(x)) format(round(x, 3), big.mark = ",") else "Not available"
    tagList(
      div(class = "metric-line", "Training records", tags$strong(format(r$train_n, big.mark = ","))),
      div(class = "metric-line", "Test records", tags$strong(format(length(r$actual), big.mark = ","))),
      div(class = "metric-line", "Average error (MAE)", tags$strong(score(r$mae))),
      div(class = "metric-line", "Larger-error score (RMSE)", tags$strong(score(r$rmse))),
      div(class = "metric-line", "Test R-squared", tags$strong(score(r$r2))),
      br(),
      p(class = "note", paste("Model equation: log(1 + star gains) predicted from log(1 + forks)."))
    )
  })

  # Compare the predicted values with the real values.
  output$prediction_plot <- renderPlot({
    r <- model_result()
    validate(need(length(r$actual) > 1, "Not enough test records to draw this chart."))
    x <- log1p(r$actual)
    y <- log1p(r$predicted)
    limits <- range(c(x, y), finite = TRUE)
    old <- par(mar = c(4.5, 4.5, 2, 1))
    on.exit(par(old))
    plot(x, y, pch = 21, bg = grDevices::adjustcolor(teal, alpha.f = 0.4),
         col = grDevices::adjustcolor(teal, alpha.f = 0.6), cex = 1,
         xlim = limits, ylim = limits, xlab = "log(1 + actual star gains)",
         ylab = "log(1 + predicted star gains)", main = "", las = 1,
         bty = "l", col.axis = muted, col.lab = navy)
    grid(col = grid_col, lty = 1)
    abline(a = 0, b = 1, lty = 2, lwd = 2, col = blue)
  }, res = 96)

  # List the ten repositories with the most star gains.
  output$top_repositories <- renderTable({
    d <- filtered_repos()
    if (nrow(d) == 0) return(data.frame(Message = "No records match these filters."))
    d <- d[order(d$stars_period, decreasing = TRUE), ]
    d <- head(d, 10)
    d <- d[, c("full_name", "language", "stars", "forks", "stars_period", "url")]
    names(d) <- c("Repository", "Language", "Total stars", "Forks", "Stars gained", "GitHub URL")
    d
  }, striped = TRUE, bordered = FALSE, spacing = "m", hover = TRUE, na = "—")
}

# Start the dashboard.
shinyApp(ui = ui, server = server)
