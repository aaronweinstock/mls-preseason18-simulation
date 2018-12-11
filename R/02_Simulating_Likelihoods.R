# Pre-season simulation involves the following general steps
# 1. Repeat the following process 'n' times
#   A. For each game:
#     i. For the home team:
#       a. Make a random draw from the home_score and home_concede estimated distributions
#     ii. For the away team:
#       b. Make a random draw from the away_score and away_concede estimated distributions
#     iii. Estimate home goals as average of home_score and away_concede draws
#     iv. Estimate away goals as average of away_score and home_concede draws
#     v. Assign points (3, 1, 0) based on relative magnitudes of home and away goals, keeping
#        track of esimated goals scored and W/L/T for each team
#   B. Once all matches have been simulated:
#     i. For each conference
#       a. Count points, wins, differential, goals-for for each team
#       b. Sort teams in order of points, wins, differential, and goals-for (in that rel. order)
#       c. Identify the top six teams as getting a "posteason berth"
#          Identify the top two teams as getting "first round byes"
# 2. Create a plot (split by conference) to show estimated playoff probabilities.
# 3. Compare to actual MLS results, other predictions

# install.packages("purrr")
library(purrr)

# Read in data
para = readRDS("Data/R_Data/Goal_Parameters.rds")
seasons = read.csv("Data/Results_Files/MLS_Results.csv", 
                   colClasses = c("character","double","double","double","character",
                                  "character","character","double","double"),
                   row.names=NULL)
seasons = seasons[,-1]

# Identify teams by conference
eastern = c("Atlanta United", "Chicago Fire", "Columbus Crew", "DC United",
            "Montreal Impact", "New England Revolution", "New York City",
            "New York Red Bulls", "Orlando City", "Philadelphia Union",
            "Toronto FC")
western = sort(setdiff(unique(seasons$home), c(eastern, "Chivas USA")))

# Simulation function
simulator18 = function(){
  # Use previous Poisson estimations to predict games
  games = seasons[seasons$year == 2018, 5:6]
  points = t(apply(games, 1, function(x){
    home = para[para$team == x[1], "home_est"]
    away = para[para$team == x[2], "away_est"]
    guess_home_score = rpois(1, lambda = home[1])
    guess_away_score = rpois(1, lambda = away[1])
    guess_home_concede = rpois(1, lambda = home[2])
    guess_away_concede = rpois(1, lambda = away[2])
    home_goals = mean(c(guess_home_score, guess_away_concede))
    away_goals = mean(c(guess_away_score, guess_home_concede))
    if(home_goals - away_goals == 0){
      return(c(1, 1, home_goals, away_goals, "tie"))
    }
    if(0 < home_goals - away_goals){
      return(c(3, 0, home_goals, away_goals, "home"))
    }
    if(0 > home_goals - away_goals){
      return(c(0, 3, home_goals, away_goals, "away"))
    }
  }))
  games = cbind(games, points)
  names(games)[3:7] = c("home_points", "away_points", "home_goals", "away_goals", "win")
  games[,3:6] = sapply(games[,3:6], function(x){as.numeric(as.character(x))})
  games[,7] = as.character(games[,7])
  # Identify playoff teams in each conference
  conferences = lapply(list(eastern, western), function(x){
    tab = lapply(x, function(y){
      points = sum(games$home_points[games$home == y]) + sum(games$away_points[games$away == y])
      wins = nrow(games[(games$home == y & games$win == "home") | 
                          (games$away == y & games$win == "away"),])
      diff = sum(games$home_goals[games$home == y]) - sum(games$away_goals[games$home == y]) +
        sum(games$away_goals[games$away == y]) - sum(games$home_goals[games$away == y])
      gf = sum(games$home_goals[games$home == y]) + sum(games$away_goals[games$away == y])
      return(data.frame(y, points, wins, diff, gf))            
    })
    tab = data.frame(rbindlist(tab))
    names(tab) = c("team","points","wins","diff","gf")
    tab[,2:5] = sapply(tab[,2:5], function(x){as.numeric(as.character(x))})
    tab[,1] = as.character(tab[,1])
    tab = tab[order(tab$points, tab$wins, tab$diff, tab$gf, decreasing = TRUE),]
    post = tab$team[1:6]
    return(post)
  })
  # Return postseason teams
  post = unlist(conferences)
  return(post)
}

# Run the simulation: this example will use 10,000 simulations
n = 10000
run = rerun(n, simulator18())
saveRDS(run, "Data/R_Data/Example_Simulation.rds")

# Create a table of playoff probabilities for each conference
posttest = unlist(run)
east_bye = posttest[c(seq(1, 1+12*9999, by=12), seq(2, 2+12*9999, by=12))]
west_bye = posttest[c(seq(7, 7+12*9999, by=12), seq(8, 8+12*9999, by=12))]
east_table = lapply(eastern, function(x){
  playoff = sum(posttest == x)/n
  bye = sum(east_bye == x)/n
  return(data.frame(team = x, playoff, bye, conf = "East"))
})
east_table = data.frame(rbindlist(east_table))
west_table = lapply(western, function(x){
  playoff = sum(posttest == x)/n
  bye = sum(west_bye == x)/n
  return(data.frame(team = x, playoff, bye, conf = "West"))
})
west_table = data.frame(rbindlist(west_table))
prob = rbind(east_table, west_table)
prob[,c(1,4)] = sapply(prob[,c(1,4)], as.character)
prob = prob[order(prob$playoff, prob$bye, decreasing=TRUE),]

# Save this table as an Example to the Data folder
saveRDS(prob, "Data/R_Data/Example_Probabilities.rds")
