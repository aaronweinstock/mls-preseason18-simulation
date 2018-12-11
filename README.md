## **Preseason MLS 2018 Simulated Playoff Likelihoods**

### **Introduction**
___
The data and code in this repository provide the functionality to produce estimated playoff likelihoods for the 2018 MLS season. These predictions were designed to be completed *prior* to the season. 

Specifically, predictions are based off of estimated Poisson distributions for goals scored and goals conceded both at home and away for each team. These distributions were estimated over the results of all matches between 2013 and 2017. A single simulation is completed as follows:

* For each match in 2018, consider a home team A and an away team B. A's goals are predicted to be the average of a random draw from A's home score and a random draw from B's away concede distributions; similarly, B's goals are predicted to be the average of a random draw from B's away score and a random draw from A's home concede distribution. The winner is the team with more predicted goals. Follow this process for each match in the 2018 season

* Playoff teams are identified as the top 6 teams in each conference at the end of the simulated season

Playoff probabilities are then calculated over 10,000 simulations, with probability equal to the number of simulations in which a team would reach the postseason.

### **Files**
___
In the `R` folder, four scripts can be found.

* `00_Data_Cleaning` cleans `Data/Results_Files/MLS.xlsx` to `Data/Results_Files/MLS_Results.csv`

* `01_Estimated_Goal_Distribution` uses match results from 2013 to 2017 to estimate a Poisson distribution of home goals scored, home goals conceded, away goals scored, and away goals conceded for each MLS team

* `02_Simulated_Likelihoods` performs the simulation to estimate preseason 2018 playoff likelihoods for each team

* `03_Plotting_Results` creates a polished plot of the playoff likelihoods

In the `Data` folder, two subfolders can be found.

* `R_Data` contains intermediates created for easier processing during simulation (the `Goal_Parameters` file is a dataframe of estimated Poisson parameters, while the `Example_Simulation` and `Example_Probabilities` files are examples of simulation outputs -- a list of playoff teams and a table of playoff probabilities, respectively)

* `Results_Files` includes the raw and cleaned data for match results between 2013 and 2017

