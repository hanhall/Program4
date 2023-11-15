# Project:  CS 330
# Program:  State machines
# Purpose:  Provide example implementation of hard-coded state machine.
# Author:   Mikel D. Petty, Ph.D., 256-824-6140, pettym@uah.edu
# Created:  2021-4-7
# Revised:  2022-4-3
# Sources:  I. Millington, Artificial Intelligence for Games,
#           Third Edition, CRC Press, Boca Raton FL, 2019.
#           Y. Papelis and P. Madhavan, �Modeling Human Behavior�
#           in Modeling and Simulation Fundamentals:  Theoretical Underpinnings
#           and Practical Domains, in J. Sokolowski and C. Banks, editors,
#           John Wiley & Sons, Hokoben NJ, 2010.

rm(list = ls())      # Clear workspace
options(scipen=999)  # Suppress scientific notation

# Select scenario and set scenario-specific parameters.

scenario               <- 1  # Should be 1 or 2
scenario.trace         <- c(TRUE, FALSE)[scenario]
scenario.iterations    <- c(100, 1000000)[scenario]
scenario.interval      <- c(1, 10000)[scenario]
transition.probability <- list(c(0.8, 0.4, 0.3, 0.4, 0.3, 0.3, 0.8, 0.8, 0.8),
                               c(0.9, 0.6, 0.3, 0.2, 0.2, 0.4, 0.7, 0.9, 0.7))[[scenario]]
state.sequence         <- list(1:7, c(7, 1:6))[[scenario]]
transition.sequence    <- list(1:9, c(9, 1:8))[[scenario]]                                  

# Define support functions.

write.text <- function(textfile, msg, first=FALSE) { write(msg, textfile, ncolumns=1, append=!first) }
num.width  <- function(x, left, right) { format(round(x, right),  nsmall=right, width=(left + right + ifelse(right > 0, 1, 0))) }

# Initialize output file and report program begin to output file.

computer    <- 2
output.path <- c("C:/Users/mpetty/Desktop/Working, CS 330/", "Z:/UAH/CS330 Fall 2022/Source Material/R Code/")[computer]
output.file <- paste(output.path, "CS 330, State machines, Scenario ", scenario, " ", Sys.Date(), ".txt", sep="")

write.text(output.file, paste("CS 330, State machines, Begin", Sys.time(), "\n"), TRUE)

# Initialize constants used for states.

FOLLOW         <- 1
PULL.OUT       <- 2
ACCELERATE     <- 3
PULL.IN.AHEAD  <- 4
PULL.IN.BEHIND <- 5
DECELERATE     <- 6
DONE           <- 7

# Initialize program state and transition counters.

state.count      <- rep(0, 7)
transition.count <- rep(0, 9)

# Define state "action" functions (stubs).

follow.action <- function() {
  if (scenario.trace) { write.text(output.file, paste("state= 1 Follow"))         }
  state.count[FOLLOW] <<- state.count[FOLLOW] + 1
}

pull.out.action <- function() { 
  if (scenario.trace) { write.text(output.file, paste("state= 2 Pull out"))       }
  state.count[PULL.OUT] <<- state.count[PULL.OUT] + 1
}

accelerate.action <- function() {
  if (scenario.trace) { write.text(output.file, paste("state= 3 Accelerate"))     }
  state.count[ACCELERATE] <<- state.count[ACCELERATE] + 1
}

pull.in.ahead.action <- function() {
  if (scenario.trace) { write.text(output.file, paste("state= 4 Pull in ahead"))  }
  state.count[PULL.IN.AHEAD] <<- state.count[PULL.IN.AHEAD] + 1
}

pull.in.behind.action <- function() {
  if (scenario.trace) { write.text(output.file, paste("state= 5 Pull in behind")) }
  state.count[PULL.IN.BEHIND] <<- state.count[PULL.IN.BEHIND] + 1
}

decelerate.action <- function() {
  if (scenario.trace) { write.text(output.file, paste("state= 6 Decelerate"))     }
  state.count[DECELERATE] <<- state.count[DECELERATE] + 1
}

done.action <- function() {
  if (scenario.trace) { write.text(output.file, paste("state= 7 Done", "\n"))     }
  state.count[DONE] <<- state.count[DONE] + 1
}

# Execute iterations and transitions.

for (i in 1:scenario.iterations) {
  if (scenario.trace) { write.text(output.file, paste("iteration=", i)) }

  state <- FOLLOW
  follow.action()

  while (state != DONE) {

    # Get random number between 0 and 1.

    R <- runif(1, min=0.0, max=1.0)

    # Check transitions.

    if (state == FOLLOW) {
      if (R < transition.probability[1]) {
        transition.count[1] <- transition.count[1] + 1
        state <- PULL.OUT
        pull.out.action()
      } else {
        state <- FOLLOW
        follow.action()
      }

    } else if (state == PULL.OUT) {
      if (R < transition.probability[2]) {
        transition.count[2] <- transition.count[2] + 1
        state <- ACCELERATE
        accelerate.action()
      } else if (R < sum(transition.probability[c(2, 4)])) {
        transition.count[4] <- transition.count[4] + 1
        state <- PULL.IN.BEHIND
        pull.in.behind.action()
      } else {
        state <- PULL.OUT
        pull.out.action()
      }

    } else if (state == ACCELERATE) {
      if (R < transition.probability[3]) {
        transition.count[3] <- transition.count[3] + 1
        state <- PULL.IN.AHEAD
        pull.in.ahead.action()
      } else if (R < sum(transition.probability[c(3, 5)])) {
        transition.count[5] <- transition.count[5] + 1
        state <- PULL.IN.BEHIND
        pull.in.behind.action()
      } else if (R < sum(transition.probability[c(3, 5, 6)])) {
        transition.count[6] <- transition.count[6] + 1
        state <- DECELERATE
        decelerate.action()
      } else {
        state <- ACCELERATE
        accelerate.action()
      }

    } else if (state == PULL.IN.AHEAD) {
      if (R < transition.probability[9]) {
        transition.count[9] <- transition.count[9] + 1
        state <- DONE
        done.action()
      } else {
        state <- PULL.IN.AHEAD
        pull.in.ahead.action()
      }

    } else if (state == PULL.IN.BEHIND) {
      if (R < transition.probability[7]) {
        transition.count[7] <- transition.count[7] + 1
        state <- FOLLOW
        follow.action()
      } else {
        state <- PULL.IN.BEHIND
        pull.in.behind.action()
      }

    } else if (state == DECELERATE) {
      if (R < transition.probability[8]) {
        transition.count[8] <- transition.count[8] + 1
        state <- PULL.IN.BEHIND
        pull.in.behind.action()
      } else {
        state <- DECELERATE
        decelerate.action()
      }

    } else if (state == DONE) {
      cat("Error, unexpected state value=", state, "\n")
      stop()

    } else {
      cat("Error, unexpected state value=", state, "\n")
      stop()
    }
  }
  if ((i %% scenario.interval) == 0) { cat(".") }
}
cat("\n")

# Report scenario parameters and execution statistics to output file.

state.frequency      <- (state.count / sum(state.count))[state.sequence]
transition.frequency <- (transition.count / sum(transition.count))[transition.sequence]

write.text(output.file, paste("scenario                =", scenario))
write.text(output.file, paste("trace                   =", scenario.trace))
write.text(output.file, paste("iterations              =", scenario.iterations))
write.text(output.file, paste("transition probabilities=", paste(transition.probability, collapse=" ")))
write.text(output.file, paste("state counts            =", paste(state.count, collapse=" ")))
write.text(output.file, paste("state frequencies       =", paste(num.width(state.frequency, 1, 3), collapse=" ")))
write.text(output.file, paste("transition counts       =", paste(transition.count, collapse=" ")))
write.text(output.file, paste("transition frequencies  =", paste(num.width(transition.frequency, 1, 3), collapse=" ")))

# Verify counts.

error <- NA

if (state.count[1] <  transition.count[7])               { error <- 1  }
if (state.count[2] <  transition.count[1])               { error <- 2  }
if (state.count[3] <  transition.count[2])               { error <- 3  }
if (state.count[4] <  transition.count[3])               { error <- 4  }
if (state.count[5] <  sum(transition.count[c(4, 5, 8)])) { error <- 5  }
if (state.count[6] <  transition.count[6])               { error <- 6  }
if (state.count[7] <  transition.count[9])               { error <- 7  }
if (state.count[1] <  scenario.iterations)               { error <- 8  }
if (state.count[7] != scenario.iterations)               { error <- 9  }
if (transition.count[9] != scenario.iterations)          { error <- 10 }

if (is.na(error)) {
  cat("verification OK", "\n")
} else {
  cat("verification not OK, error=", error, "\n")
} 

# Report program end to output file.

write.text(output.file, paste("\n", "CS 330, State machines, End ", Sys.time(), sep=""))

# End of CS 330, State machines
