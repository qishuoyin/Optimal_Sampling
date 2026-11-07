# Compatibility fixture transcribed from the authoritative manuscript Table 1
# and supplement Tables S5--S7.  These are the reported 95%-of-maximum analysis
# fraction ranges, not a replacement for fresh computation.

published_fraction_data <- function() {
  I_values <- c(100L, 200L, 500L, 1000L)
  records <- list()
  add <- function(K, Gamma, method, lower, upper) {
    records[[length(records) + 1L]] <<- data.frame(
      I = I_values, K = as.integer(K), Gamma = Gamma, method = method,
      zeta_near_lower = lower, zeta_near_upper = upper,
      stringsAsFactors = FALSE
    )
  }

  # K = 10
  add(10, 1, "Naive split", c(.53,.4,.48,.39), c(.99,.8,.72,.73))
  add(10, 1, "Optimal Split FWER", c(.99,.4,.48,.4), c(.99,.8,.78,.74))
  add(10, 1, "Optimal Split FDR", c(.95,.95,.91,.63), c(.96,.99,.99,.99))
  add(10, 1.25, "Naive split", c(.55,.44,.2,.12), c(.83,.76,.92,.96))
  add(10, 1.25, "Optimal Split FWER", c(.55,.44,.2,.12), c(.83,.78,.92,.96))
  add(10, 1.25, "Optimal Split FDR", c(.9,.77,.31,.17), c(.98,.99,.99,.99))
  add(10, 1.5, "Naive split", c(.05,.05,.01,.05), c(.41,.05,.19,.05))
  add(10, 1.5, "Optimal Split FWER", c(.05,.05,.01,.05), c(.41,.05,.19,.05))
  add(10, 1.5, "Optimal Split FDR", c(.15,.05,.38,.04), c(.15,.81,.38,.04))
  add(10, 1.75, "Naive split", c(.06,.07,.02,.02), c(.46,.09,.02,.02))
  add(10, 1.75, "Optimal Split FWER", c(.06,.07,.02,.02), c(.46,.09,.02,.02))
  add(10, 1.75, "Optimal Split FDR", c(.09,.15,.01,.01), c(.31,.36,.99,.99))
  add(10, 2, "Naive split", c(.67,.76,.49,.23), c(.86,.86,.92,.97))
  add(10, 2, "Optimal Split FWER", c(.67,.76,.49,.23), c(.86,.86,.92,.97))
  add(10, 2, "Optimal Split FDR", c(.96,.95,.75,.39), c(.97,.99,.99,.99))

  # K = 100
  add(100, 1, "Naive split", c(.45,.44,.14,.11), c(.73,.74,.86,.94))
  add(100, 1, "Optimal Split FWER", c(.54,.56,.46,.42), c(.65,.67,.75,.76))
  add(100, 1, "Optimal Split FDR", c(.93,.88,.92,.93), c(.97,.99,.99,.99))
  add(100, 1.25, "Naive split", c(.43,.27,.09,.04), c(.7,.87,.96,.97))
  add(100, 1.25, "Optimal Split FWER", c(.5,.5,.5,.48), c(.71,.66,.7,.72))
  add(100, 1.25, "Optimal Split FDR", c(.92,.97,.97,.79), c(.97,.98,.99,.99))
  add(100, 1.5, "Naive split", c(.64,.67,.39,.15), c(.73,.83,.93,.97))
  add(100, 1.5, "Optimal Split FWER", c(.64,.55,.52,.46), c(.64,.71,.73,.72))
  add(100, 1.5, "Optimal Split FDR", c(.96,.97,.99,.94), c(.97,.99,.99,.99))
  add(100, 1.75, "Naive split", c(.43,.54,.6,.45), c(.68,.75,.8,.81))
  add(100, 1.75, "Optimal Split FWER", c(.43,.54,.79,.49), c(.68,.75,.8,.81))
  add(100, 1.75, "Optimal Split FDR", c(.91,.99,.99,.99), c(.91,.99,.99,.99))
  add(100, 2, "Naive split", c(.43,.18,.08,.05), c(.71,.82,.94,.97))
  add(100, 2, "Optimal Split FWER", c(.45,.31,.47,.32), c(.77,.78,.63,.79))
  add(100, 2, "Optimal Split FDR", c(.96,.96,.92,.94), c(.97,.99,.99,.99))

  # K = 500
  add(500, 1, "Naive split", c(.33,.16,.07,.03), c(.83,.92,.97,.98))
  add(500, 1, "Optimal Split FWER", c(.6,.59,.54,.46), c(.73,.73,.77,.81))
  add(500, 1, "Optimal Split FDR", c(.91,.89,.87,.83), c(.97,.99,.99,.99))
  add(500, 1.25, "Naive split", c(.35,.16,.05,.03), c(.81,.92,.97,.98))
  add(500, 1.25, "Optimal Split FWER", c(.58,.58,.55,.44), c(.74,.75,.74,.79))
  add(500, 1.25, "Optimal Split FDR", c(.95,.95,.93,.79), c(.98,.99,.99,.99))
  add(500, 1.5, "Naive split", c(.5,.21,.08,.04), c(.76,.9,.96,.98))
  add(500, 1.5, "Optimal Split FWER", c(.62,.56,.53,.46), c(.69,.71,.76,.76))
  add(500, 1.5, "Optimal Split FDR", c(.95,.98,.96,.93), c(.99,.99,.99,.99))
  add(500, 1.75, "Naive split", c(.77,.53,.2,.1), c(.77,.85,.92,.97))
  add(500, 1.75, "Optimal Split FWER", c(.63,.56,.61,.51), c(.77,.72,.68,.73))
  add(500, 1.75, "Optimal Split FDR", c(.96,.98,.99,.97), c(.96,.99,.99,.99))
  add(500, 2, "Naive split", c(.59,.27,.09,.06), c(.7,.9,.97,.98))
  add(500, 2, "Optimal Split FWER", c(.57,.54,.47,.43), c(.69,.72,.72,.79))
  add(500, 2, "Optimal Split FDR", c(.97,.98,.98,.75), c(.98,.99,.99,.99))

  # K = 1000
  add(1000, 1, "Naive split", c(.09,.04,.02,.01), c(.89,.99,.97,.99))
  add(1000, 1, "Optimal Split FWER", c(.6,.58,.49,.46), c(.8,.76,.8,.83))
  add(1000, 1, "Optimal Split FDR", c(.91,.9,.84,.8), c(.97,.99,.99,.99))
  add(1000, 1.25, "Naive split", c(.15,.08,.03,.02), c(.84,.94,.97,.99))
  add(1000, 1.25, "Optimal Split FWER", c(.59,.57,.53,.52), c(.77,.77,.8,.8))
  add(1000, 1.25, "Optimal Split FDR", c(.92,.93,.94,.89), c(.98,.99,.99,.99))
  add(1000, 1.5, "Naive split", c(.78,.5,.21,.1), c(.8,.87,.95,.97))
  add(1000, 1.5, "Optimal Split FWER", c(.7,.57,.57,.48), c(.7,.76,.73,.77))
  add(1000, 1.5, "Optimal Split FDR", c(.95,.97,.98,.98), c(.96,.99,.99,.99))
  add(1000, 1.75, "Naive split", c(.24,.12,.05,.03), c(.81,.93,.97,.98))
  add(1000, 1.75, "Optimal Split FWER", c(.53,.6,.56,.55), c(.69,.77,.74,.74))
  add(1000, 1.75, "Optimal Split FDR", c(.95,.98,.98,.98), c(.98,.99,.99,.99))
  add(1000, 2, "Naive split", c(.27,.14,.05,.03), c(.74,.89,.96,.97))
  add(1000, 2, "Optimal Split FWER", c(.48,.5,.5,.48), c(.78,.69,.7,.74))
  add(1000, 2, "Optimal Split FDR", c(.95,.98,.99,.99), c(.98,.99,.99,.99))

  output <- do.call(rbind, records)
  output <- output[order(output$K, output$I, output$Gamma, output$method), ]
  row.names(output) <- NULL
  stopifnot(
    nrow(output) == 240L,
    !anyDuplicated(output[c("I", "K", "Gamma", "method")]),
    all(output$zeta_near_lower <= output$zeta_near_upper)
  )
  output
}
