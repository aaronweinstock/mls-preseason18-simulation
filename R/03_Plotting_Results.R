# install.packages("ggplot2")
# install.packages("gridExtra")
library(ggplot2)
library(grid)
library(gridExtra)

# Read in simulation probabilities
prob = readRDS("Data/R_Data/Example_Probabilities.rds")

# Plot function
plot_sim_results = function(prob){
  # Reorganize simulated probabilities for plotting using ggplot
  oddsplot = data.frame(team=rep(prob$team, times=2),
                        odds=c(prob$playoff, prob$bye),
                        type=rep(c("playoff","bye"), each=23),
                        conf=rep(prob$conf), times=2)
  oddsplot$team = factor(oddsplot$team, levels = unique(oddsplot$team[order(oddsplot$odds[oddsplot$type=="playoff"],
                                                                            oddsplot$odds[oddsplot$type=="bye"])]))
  oddsplot$type = factor(oddsplot$type, levels=c("playoff","bye"))
  # Create the plot; split by conference for more relevant interpretation
  plots_by_conf = lapply(c("East","West"), function(x){
    ggplot(data=oddsplot[oddsplot$conf == x,]) +
      geom_tile(aes(x=type, y=team, fill=odds), 
                color="white") +
      geom_text(aes(x=type, y=team), 
                label=scales::percent(oddsplot$odds[oddsplot$conf == x]),
                size = 3) +
      scale_x_discrete(labels = c("Make Playoffs", "Win Division", "Get Wild Card"),
                       name = "",
                       expand = c(0,0),
                       position = "top") +
      scale_y_discrete(name = "",
                       expand = c(0,0)) +
      scale_fill_gradient(low = "#FFFFFF", high = "#FF0000", limits=c(0,1)) +
      labs(title = paste(x, "Playoff Odds")) +
      theme(axis.ticks.x = element_blank(),
            axis.ticks.y = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            plot.title = element_text(hjust = 0.5, face="bold"),
            legend.position="none")
  })
  # Add title and format using grid.arrange
  t = textGrob("Simulated Preseason MLS 2018 Playoff Likelihoods", 
               hjust=0.35,
               gp=gpar(fontsize=18,font=2))
  grid.arrange(plots_by_conf[[1]], plots_by_conf[[2]], ncol = 2,
               top = t)
}

plot_sim_results(prob)
