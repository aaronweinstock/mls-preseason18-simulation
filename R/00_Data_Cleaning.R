# Edits from style of 'MLS.xlsx' to create 'MLS_Results.csv'
# MLS.xlsx data was copied from https://www.flashscore.com/football/usa/mls/
# results pages from each season, and edited slightly
# (Deleted postseason, all star games, added field for year)

# install.packages("readxl")
# install.packages("data.table")
library(readxl)
library(data.table)

seasons = lapply(1:6, function(x){
  read_xlsx("Data/Results_Files/MLS.xlsx", sheet=x)
})
seasons = rbindlist(seasons)
names(seasons) = c("date_time", "home", "away", "score", "year")

datesplit = lapply(seasons$date_time, function(x){
  dmt = strsplit(x, split=".", fixed=TRUE)
  dmt = data.frame(day = as.double(dmt[[1]][1]),
                   month = as.double(dmt[[1]][2]),
                   time = as.character(dmt[[1]][3]))
  return(dmt)
})
datesplit = rbindlist(datesplit)
seasons$day = datesplit[,1]
seasons$month = datesplit[,2]
seasons$time = datesplit[,3]
rm(datesplit)
seasons = seasons[,c(5,7,6,8,2,3,4)]
seasons$time = as.character(seasons$time)

scoresplit = lapply(seasons$score, function(x){
  ha = strsplit(x, split="", fixed=TRUE)
  ha = data.frame(home_goals = as.double(ha[[1]][1]),
                  away_goals = as.double(ha[[1]][5]))
  return(ha)
})
scoresplit = rbindlist(scoresplit)
seasons$home_goals = scoresplit[,1]
seasons$away_goals = scoresplit[,2]
rm(scoresplit)
seasons = seasons[,-7]

teams = sort(unique(seasons$home))[seq(1, 47, by=2)]
for(i in teams){
  seasons$home[grep(i, seasons$home)] = i
  seasons$away[grep(i, seasons$away)] = i
}
seasons$home[seasons$home == "Minnesota"] = "Minnesota United"
seasons$away[seasons$away == "Minnesota"] = "Minnesota United"

write.csv(seasons, "Data/Results_Files/MLS_Results.csv")
