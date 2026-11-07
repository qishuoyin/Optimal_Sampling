# Compatibility fixture: checked transcription of the power rows in the
# authoritative main-paper Table 1 (K=1000) and supplement Tables S5--S7
# (K=10,100,500). Split-fraction ranges live in published_fractions.R.

published_power_data <- function() {
  I_values <- c(100L, 200L, 500L, 1000L)
  records <- list()
  append_block <- function(K, Gamma, Bonferroni, Naive, Select, Rank, source_document, source_table) {
    source_document <- if (K == 1000L) "biomtemplate.pdf" else "supplement.pdf"
    source_table <- if (K == 1000L) "Table 1" else paste0("Table S", match(K, c(10L, 100L, 500L)) + 4L)
    values <- list(
      "Bonferroni" = Bonferroni,
      "Naive split" = Naive,
      "Optimal Split FWER" = Select,
      "Optimal Split FDR" = Rank
    )
    for (method in names(values)) {
      records[[length(records) + 1L]] <<- data.frame(
        I = I_values, K = as.integer(K), Gamma = Gamma, method = method,
        power = as.numeric(values[[method]]), source_document = source_document,
        source_table = source_table, stringsAsFactors = FALSE
      )
    }
  }

  append_block(10, 1,    c(.10,.34,.92,1), c(.24,.40,.87,1), c(.24,.39,.86,1), c(.28,.47,.95,1), "submitted-supplement.pdf", "Table 1")
  append_block(10, 1.25, c(.68,.98,1,1), c(.76,.99,1,1), c(.76,.99,1,1), c(.75,.99,1,1), "submitted-supplement.pdf", "Table 1")
  append_block(10, 1.5,  c(0,0,0,0), c(.02,.04,.02,.03), c(.02,.04,.02,.03), c(.03,.01,.01,.01), "submitted-supplement.pdf", "Table 1")
  append_block(10, 1.75, c(0,0,0,0), c(.01,.02,.02,.01), c(.01,.02,.02,.01), c(.01,.01,0,0), "submitted-supplement.pdf", "Table 1")
  append_block(10, 2,    c(.24,.55,.99,1), c(.57,.84,1,1), c(.57,.84,1,1), c(.33,.62,1,1), "submitted-supplement.pdf", "Table 1")

  append_block(100, 1,    c(.147,.269,.382,.442), c(.081,.098,.1,.1), c(.135,.245,.357,.419), c(.28,.379,.516,.599), "submitted-supplement.pdf", "Table 2")
  append_block(100, 1.25, c(.175,.276,.474,.650), c(.096,.1,.1,.1), c(.167,.268,.432,.612), c(.298,.438,.618,.69), "submitted-supplement.pdf", "Table 2")
  append_block(100, 1.5,  c(.045,.164,.359,.496), c(.066,.092,.1,.1), c(.078,.168,.324,.472), c(.161,.317,.474,.57), "submitted-supplement.pdf", "Table 2")
  append_block(100, 1.75, c(.001,.007,.029,.091), c(.021,.035,.082,.099), c(.020,.037,.083,.104), c(.022,.033,.074,.125), "submitted-supplement.pdf", "Table 2")
  append_block(100, 2,    c(.097,.111,.184,.201), c(.098,.1,.1,.1), c(.105,.123,.189,.203), c(.120,.151,.202,.218), "submitted-supplement.pdf", "Table 2")

  append_block(500, 1,    c(.226,.371,.585,.694), c(.02,.02,.02,.02), c(.1922,.3316,.55,.6564), c(.4712,.5694,.7412,.8172), "submitted-supplement.pdf", "Table 3")
  append_block(500, 1.25, c(.080,.185,.355,.434), c(.0198,.02,.02,.02), c(.0884,.1744,.3356,.4248), c(.2274,.3314,.4378,.476), "submitted-supplement.pdf", "Table 3")
  append_block(500, 1.5,  c(.064,.155,.255,.342), c(.0196,.02,.02,.02), c(.0762,.1554,.2496,.3312), c(.16,.2674,.3476,.3892), "submitted-supplement.pdf", "Table 3")
  append_block(500, 1.75, c(.003,.030,.129,.218), c(.0128,.0182,.02,.02), c(.016,.0434,.1346,.211), c(.0512,.1098,.2132,.2602), "submitted-supplement.pdf", "Table 3")
  append_block(500, 2,    c(.016,.057,.130,.156), c(.0186,.02,.02,.02), c(.0316,.0694,.1326,.157), c(.0576,.1056,.1572,.1678), "submitted-supplement.pdf", "Table 3")

  append_block(1000, 1,    c(.186,.350,.500,.596), c(.01,.01,.01,.01), c(.167,.3066,.4739,.5653), c(.3989,.5343,.6357,.7083), "submitted-manuscript.pdf", "Table 1")
  append_block(1000, 1.25, c(.136,.264,.404,.517), c(.01,.01,.01,.01), c(.1359,.2469,.3839,.4926), c(.3096,.438,.5568,.6304), "submitted-manuscript.pdf", "Table 1")
  append_block(1000, 1.5,  c(.004,.030,.104,.162), c(.0075,.0092,.01,.01), c(.0148,.0385,.1057,.161), c(.0555,.0992,.1774,.2203), "submitted-manuscript.pdf", "Table 1")
  append_block(1000, 1.75, c(.029,.043,.096,.156), c(.01,.01,.01,.01), c(.0334,.0523,.0989,.1559), c(.0626,.1099,.1708,.2157), "submitted-manuscript.pdf", "Table 1")
  append_block(1000, 2,    c(.010,.017,.049,.061), c(.01,.01,.01,.01), c(.0144,.0262,.0528,.0661), c(.0235,.0411,.0688,.0829), "submitted-manuscript.pdf", "Table 1")

  output <- do.call(rbind, records)
  output <- output[order(output$K, output$I, output$Gamma, output$method), ]
  row.names(output) <- NULL
  stopifnot(nrow(output) == 320L, !anyDuplicated(output[c("I", "K", "Gamma", "method")]),
            all(output$power >= 0 & output$power <= 1))
  output
}

