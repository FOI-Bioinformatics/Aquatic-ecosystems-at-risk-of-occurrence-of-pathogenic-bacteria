# Predators and nutrient availability favor protozoa-resisting bacteria in aquatic systems

## Publication
<i>Coming soon...</i>

## create_line_chart.R
Script to visualize the data of the experiment. Mean values with indicated stardard deviations are plotted in a line chart. 
![Line chart](https://github.com/FOI-Bioinformatics/Aquatic-ecosystems-at-risk-of-occurrence-of-pathogenic-bacteria/blob/master/doc/line_chart.png)

#### Example
```
create_line_chart.R -i data_to_plot.txt -o line_chart
```

#### Dependencies
The following R packages are required to run the script:
* ggplot2
* reshape
* plyr


## create_taxa_summary.R
A script that creates a taxa summary form a OTU table in classic format, a mapping file and taxonomy file has to be given to the script as well. 
![Taxa summary](https://github.com/FOI-Bioinformatics/Aquatic-ecosystems-at-risk-of-occurrence-of-pathogenic-bacteria/blob/master/doc/taxa_summary.png)

#### Example
```
create_taxa_summary.R -i otu_table_classic.txt -m  mapping_file.txt -t taxonomy.txt -o taxa_summary_plot
```

#### Dependencies
The following R packages are required to run the script:
* phyloseq
* ggplot2

## glmer_commands.txt

#### Dependencies
The following R packages are required to run the model:
* lme4
* sjPlot
