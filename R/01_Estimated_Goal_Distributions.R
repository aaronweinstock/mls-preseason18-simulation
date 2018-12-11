# Simulation will take the approach of estimating goals scored and goals conceded,
# based on distribution of teams' home/away scored/conceded between 2013-2017.
# Distributions are assumed to be Poisson, so the rate parameter is estimated
# using maximum likelihood estimation

# The result is an estimated lambda for each team's home goals scored, away goals
# scored, home goals conceded, and away goals conceded. This information is
# collected, organized, and saved to "Data/Goal_Parameters.rds"

# install.packages("fitdistrplus")
# install.packages("data.table")
library(fitdistrplus)
library(data.table)

# Read in the data, delete the column for row names entered by read.csv
seasons = read.csv("Data/Results_Files/MLS_Results.csv", 
                   colClasses = c("character","double","double","double","character",
                                  "character","character","double","double"),
                   row.names=NULL)
seasons = seasons[,-1]

# Set up the "training set" as 2013-2017
train = seasons[seasons$year < 2018,]
trainteams = sort(unique(train$home))

# For each team in the training data, obtain estimates of lambda 
# for Poisson distributions of home and away goals
goal_parameters = lapply(trainteams, function(x){
  home_score = train$home_goals[train$home == x]
  away_score = train$away_goals[train$away == x]
  home_concede = train$away_goals[train$home == x]
  away_concede = train$home_goals[train$away == x]
  home_score_dist = fitdist(home_score, "pois")
  away_score_dist = fitdist(away_score, "pois")
  home_concede_dist = fitdist(home_concede, "pois")
  away_concede_dist = fitdist(away_concede, "pois")
  vals = data.frame(home_est = c(home_score_dist$estimate,
                                 home_concede_dist$estimate),
                    home_sd = c(home_score_dist$sd,
                                home_concede_dist$sd),
                    away_est = c(away_score_dist$estimate,
                                 away_concede_dist$estimate),
                    away_sd = c(away_score_dist$sd,
                                away_concede_dist$sd),
                    type = c("score", "concede"),
                    team = rep(x, each=2))
  return(vals)
})
goal_parameters = rbindlist(goal_parameters)

# LAFC wasn't around until 2018, so set their parameters as the "average" of
# the first year of the 4 expansion teams coming between 2013-2017
la_hsco = train$home_goals[(train$home == "Minnesota United" & train$year == 2017) |
                             (train$home == "Atlanta United" & train$year == 2017) |
                             (train$home == "New York City" & train$year == 2015) |
                             (train$home == "Orlando City" & train$year == 2015)]
la_asco = train$away_goals[(train$away == "Minnesota United" & train$year == 2017) |
                             (train$away == "Atlanta United" & train$year == 2017) |
                             (train$away == "New York City" & train$year == 2015) |
                             (train$away == "Orlando City" & train$year == 2015)]
la_hcon = train$away_goals[(train$home == "Minnesota United" & train$year == 2017) |
                             (train$home == "Atlanta United" & train$year == 2017) |
                             (train$home == "New York City" & train$year == 2015) |
                             (train$home == "Orlando City" & train$year == 2015)]
la_acon = train$home_goals[(train$away == "Minnesota United" & train$year == 2017) |
                             (train$away == "Atlanta United" & train$year == 2017) |
                             (train$away == "New York City" & train$year == 2015) |
                             (train$away == "Orlando City" & train$year == 2015)]
lafc = data.frame(home_est = c(fitdist(la_hsco, "pois")$estimate,
                               fitdist(la_hcon, "pois")$estimate),
                  home_sd = c(fitdist(la_hsco, "pois")$sd,
                              fitdist(la_hcon, "pois")$sd),
                  away_est = c(fitdist(la_asco, "pois")$estimate,
                               fitdist(la_acon, "pois")$estimate),
                  away_sd = c(fitdist(la_asco, "pois")$sd,
                              fitdist(la_asco, "pois")$sd),
                  type = c("score", "concede"),
                  team = rep("Los Angeles FC", 2))
goal_parameters = rbind(goal_parameters[1:16,], lafc, goal_parameters[17:46,])
goal_parameters = goal_parameters[,c(6,5,1:4)]
goal_parameters = data.frame(goal_parameters)

# Save the output to the Data folder
saveRDS(goal_parameters, "Data/R_Data/Goal_Parameters.rds")
