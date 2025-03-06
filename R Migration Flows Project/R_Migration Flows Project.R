# 1. Import packages for Data Frames
library(readr)
library(dplyr)


# 2. Data Importing and Preprocessing

USdata <- read_csv("/Users/southern.lights/Desktop/Migration_Flows_from_2010_to_2019.csv")

# The link to download the dataset is: https://www.kaggle.com/datasets/finnegannguyen/statetostate-migration-flows-from-2010-to-2019?resource=download

# 2.1 Data Exploration

head(USdata) #Print the first 6 rows
tail(USdata) #Print the last 6 rows
summary(USdata) #Display summary statistics
colnames(USdata) #Get column names
str(USdata) #Check the data types of columns
ncol(USdata) #Check the total number of columns
nrow(USdata) #Check the total number of rows

# 2.2 Data Cleaning and Preparation

sum(is.na(USdata)) #Check for missing values

duplicates <- duplicated(USdata) #Check for duplicates 
sum(duplicates)

USdata <- USdata %>%
  rename(original_region = from) #Rename the "from" column to "original_state" column

colnames(USdata)  #Verify the name of "from" column has been changed to "original_state" 


# 3. Data Aggregates and Visualisations
# Import the package 'ggplot2'

library(ggplot2)
library(scales)

# 3.1 The total number of MIGRANTS moving in by YEAR 

# a. Aggregation
yearly_migration <- USdata %>%
  distinct(year, current_state, number_of_people) %>%  #Choose distinct values 
  group_by(year) %>% 
  summarise(yearly_total_migrants = sum(`number_of_people`, na.rm = TRUE))  #Sum distinct values for each year

print(yearly_migration)

# b. Line chart for MIGRATION by YEAR

line_Year <- ggplot(yearly_migration, aes(x = factor(year), y = yearly_total_migrants, group = 1)) +
  geom_point(color = "blue") + #Fill the colour for points
  geom_line(color = "skyblue") + #Fill the colour for line
  labs(title = "US Migration by Year (2010 - 2019)",
       x = "Year",
       y = "Total Migrants") +
  scale_y_continuous(labels = comma) + #Scale the labels of Total Migrants
  theme_minimal()

line_Year #Display the line chart

# 3.2 The total number of MIGRANTS moving in by STATE

# a. Aggregation
state_migration <- USdata %>%
  distinct(year, current_state, number_of_people) %>% #Choose distinct values 
  group_by(current_state) %>%
  summarise(state_total_migrants = sum(`number_of_people`, na.rm = TRUE))

print(state_migration, n = 54) #Show all of rows including all states

# b. Bar chart for MIGRATION by STATE

bar_State <- ggplot(state_migration, aes(x = state_total_migrants, y = current_state)) +
  geom_bar(position = "dodge", stat = "identity", fill = 'royalblue2') +
  labs(title = "US Migration by State",
       x = "Total Migrants",
       y = "State") +
  scale_x_continuous(labels = comma) + #Scale the labels of Total Migrants
  theme_minimal()

bar_State #Display the bar chart

# 3.3 The total number of MIGRANTS moving in by YEAR and STATE

# a. Aggregation

year_state_migration <- USdata %>%
  distinct(year, current_state, number_of_people) %>% #Choose distinct values 
  group_by(year, current_state) %>%
  summarise(total_migrants = sum(`number_of_people`, na.rm = TRUE))

print(year_state_migration, n = 600) #Show all rows of year_state_migration

# b. Heatmap for total MIGRANTS by YEAR and STATE
heatmap_YearState <- ggplot(year_state_migration, aes(x = factor(year), y = current_state, fill = total_migrants)) +
  geom_tile(color = "black") +  # Use tile to create heatmap
  scale_fill_gradient(low = "lightblue", high = "darkblue", #Set gradient colour
                      name = "Total Migrants",
                      labels = label_number(scale = 1e-6, suffix = "M", accuracy = 0.1)) +  # Correctly format in millions
  labs(title = "Total Migrants by Year and State",
       x = "Year",
       y = "State") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

heatmap_YearState #Display the heatmap


# 3.4 The total number of INFLOW and OUTFLOW DOMESTIC MIGRANTS by STATE

# a. Aggregate The total number of INFLOW DOMESTIC MIGRANTS by STATE

domestic_inflow <- USdata %>%
  distinct(current_state, year, from_different_state_Total) %>% #Choose distinct values
  group_by(current_state) %>%
  summarise(domestic_migrants = sum(`from_different_state_Total`, na.rm = TRUE))

print(domestic_inflow, n = 54) #Show all of rows including all states

# b. Aggregate The total number of OUTFLOW DOMESTIC MIGRANTS by STATE

#Filter out foreign regions
domestic_region <- USdata %>%
  filter(original_region != 'abroad_ForeignCountry' & original_region != 'abroad_USIslandArea')

#Sum number_of_people from domestic_region, outlow domestic migrants
domestic_outflow <- domestic_region %>% #Choose the table that excludes 'abroad_ForeignCountry' and 'abroad_USIslandArea'
  distinct(year, original_region, number_of_people) %>% #Choose distinct values
  group_by(original_region) %>%
  summarise(domestic_leavers = sum(`number_of_people`, na.rm = TRUE))

print(domestic_outflow, n = 54) #Show all of rows including all states

# c. Symmetrical Column chart for Domestic INFLOW and OUTFLOW Migration

# Prepare inflow data
inflow_migration <- domestic_inflow %>%
  rename(state = current_state) %>%
  mutate(migrants = domestic_migrants, type = "Inflow") #Type for inflow

# Prepare outflow data
outflow_migration <- domestic_outflow %>%
  rename(state = original_region) %>%
  mutate(migrants = -domestic_leavers, type = "Outflow") #Transform outflow values to negative values

# Combine inflow and outflow data
inflow_vs_outflow <- bind_rows(inflow_migration, outflow_migration)

# Mirror bar chart for Domestic INFLOW and OUTFLOW Migration
column_InflowOutflow <- ggplot(inflow_vs_outflow, aes(x = migrants, y = state, fill = type)) +
  geom_bar(stat = "identity") +
  labs(title = "Domestic Migration Inflows and Outflows by State",
       x = "Number of Migrants",
       y = "State") +
  scale_x_continuous(labels = comma) + #Scale x-axis labels
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("Inflow" = "dodgerblue", "Outflow" = "coral")) #Distinguish colours

column_InflowOutflow #Display the column chart


# 3.5 The total number of MIGRANTS from ABROAD by YEAR

# a. Aggregation
yearly_abroad_migration <- USdata %>%
  distinct(year, current_state, abroad_Total) %>% #Choose distinct values in year, current_state, and abroad_Total columns
  group_by(year) %>%
  summarise(yearly_abroad_migrants = sum(`abroad_Total`, na.rm = TRUE)) 
print(yearly_abroad_migration)

# b. Line chart for MIGRATION from ABROAD by YEAR

line_AbroadYear <- ggplot(yearly_abroad_migration, aes(x = factor(year), y = yearly_abroad_migrants, group = 1)) +
  geom_point(color = "violetred") + #Fill the colour for points
  geom_line(color = "palevioletred") + #Fill the colour for line
  labs(title = "US Migration from Abroad by Year (2010 - 2019)",
       x = "Year",
       y = "Total Migrants") +
  scale_y_continuous(labels = comma) + #Scale the labels of Total Migrants
  theme_minimal()

line_AbroadYear #Display the line chart


# 3.6 The total number of MIGRANTS from ABROAD by STATE

# a. Aggregation

state_abroad_migration <- USdata %>%
  distinct(year, current_state, abroad_Total) %>% #Choose distinct values in year, current_state, and abroad_Total columns
  group_by(current_state) %>%
  summarise(state_abroad_migrants = sum(`abroad_Total`, na.rm = TRUE)) 

print(state_abroad_migration, n = 54) #Show all of rows including all states

# b. Bar chart for MIGRATION from ABROAD by STATE

bar_AbroadState <- ggplot(state_abroad_migration, aes(x = state_abroad_migrants, y = current_state)) +
  geom_bar(position = "dodge", stat = "identity", fill = 'mediumorchid') +
  labs(title = "US Migration from Abroad by State",
       x = "Total Migrants",
       y = "State") +
  scale_x_continuous(labels = comma) + #Scale the labels of Total Migrants
  theme_minimal()

bar_AbroadState #Display the bar chart

# 3.7 The total number of MIGRANTS from ABROAD by YEAR and STATE

# a. Aggregation
foreign_migration <- USdata %>%
  distinct(year, current_state, abroad_Total) %>%  #Choose distinct values in year, current_state, and abroad_Total columns
  group_by(year, current_state) %>%                             
  summarise(total_abroad_migrants = sum(abroad_Total, na.rm = TRUE)) %>%  
  arrange(year, current_state)                                      

print(foreign_migration, n = 600) #Show all rows of foreign_migration

# b. Heatmap for total ABROAD migrants by YEAR and STATE 
heatmap_Abroad_YearState <- ggplot(foreign_migration, aes(x = factor(year), y = current_state, fill = total_abroad_migrants)) +
  geom_tile(color = "black") +  # Use tile to create heatmap
  scale_fill_gradient(low = "lavender", high = "red4", 
                      name = "Total Migrants",
                      labels = label_number(scale = 1e-6, suffix = "M", accuracy = 0.1)) +  # Correctly format in millions
  labs(title = "Total Abroad Migrants by Year and State",
       x = "Year",
       y = "State") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

heatmap_Abroad_YearState #Display the heatmap

# 3.8 DOMESTIC and ABROAD migration trends

# a. Aggregation

domestic_vs_abroad <- USdata %>%
  distinct(year, from_different_state_Total, abroad_Total) %>% #Choose distinct values
  group_by(year) %>%
  summarise(
    domestic_migrants = sum(from_different_state_Total, na.rm = TRUE),
    abroad_migrants = sum(abroad_Total, na.rm = TRUE)
  )

print(domestic_vs_abroad) 

# b. Line chart for Comparison between DOMESTIC Migration vs ABROAD Migration 

line_DomesticAbroad <- ggplot(domestic_vs_abroad, aes(x = year)) + 
  geom_line(aes(y = domestic_migrants, color = "Domestic Migrants"), size = 1) +
  geom_line(aes(y = abroad_migrants, color = "Abroad Migrants"), size = 1) +
  labs(title = "Domestic vs Abroad Migration Trends (2010-2019)",
       x = "Year", 
       y = "Number of Migrants",
       color = "Migration Type") +  
  scale_x_continuous(breaks = seq(2010, 2019, by = 1), labels = seq(2010, 2019, by = 1)) +  #Creating yearly labels
  scale_y_continuous(labels = comma) +  #Scale y-axis labels for readability
  scale_color_manual(values = c("Domestic Migrants" = "blue", "Abroad Migrants" = "red")) +  #Distinguish colours
  theme_minimal() +  
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels for better readability
        plot.title = element_text(hjust = 0.5))  #Center the title

line_DomesticAbroad #Display the line chart

# 3.9 Correlation between Population and abroad_Total

# a. Correlation 

population_abroadmigration <-cor(USdata$population, USdata$abroad_Total)

print(population_abroadmigration)

# b. Scatterplots for Correlation between Population and Abroad Migrants (abroad_Total)

# Create scatterplot with linear regression line
scatterplot_PopulationAbroad <- ggplot(USdata, aes(x = population, y = abroad_Total)) +
  geom_point(color = "darkblue", size = 1, alpha = 0.5) +  #Scatterplot points
  geom_smooth(method = "lm", color = "red", se = TRUE) +   #Linear regression line 
  labs(title = "Relationship between Population and Abroad Migrants",
       x = "Population",
       y = "Abroad Migrants") +
  theme_minimal() +
  scale_x_continuous(labels = comma) +  #Scale x-axis labels
  scale_y_continuous(labels = comma)    #Scale y-axis labels

scatterplot_PopulationAbroad #Display the scatter plot








