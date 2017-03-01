#!/usr/bin/env Rscript

## A script that produce a line chart plot using ggplot2.
## The script requires that the input file has the columns Day, NutrientLevel,
## Protozoa and Replicate in accordance to the data used to produce the plots of the manuscript.
## Created by Moa Hammarstroem

helpstr <- c('-i File with the data to plot (.txt).\n -o Output name')

allowed.args <- list('-i' = NULL, '-o' = NULL)

"parse.args" <- function(allowed.args,helplist=NULL){
    argv <- commandArgs(trailingOnly=TRUE)
    # print help string if requested
    if(!is.null(helpstr) && sum(argv == '-h')>0){
        cat('',helpstr,'',sep='\n')
        q(runLast=FALSE)
    }
    argpos <- 1
    for(name in names(allowed.args)){
        argpos <- which(argv == name)
        if(length(argpos) > 0){
            # test for flag without argument
            if(argpos == length(argv) || substring(argv[argpos + 1],1,1) == '-')
                allowed.args[[name]] <- TRUE
            else {
                allowed.args[[name]] <- argv[argpos + 1]
            }
        }
    }
    return(allowed.args)
}

# parse arg list
arglist <- parse.args(allowed.args)

require(ggplot2)
require(reshape)

# Prepare the input data.
original_data = read.table(arglist[['-i']],header=T,row.names=1,sep='\t',comment='')
original_data$Day=factor(original_data$Day)
original_data$NutrientLevel=factor(original_data$NutrientLevel)
original_data$Protozoa=factor(original_data$Protozoa)
original_data$Replicate=factor(original_data$Replicate)
to_plot = melt(original_data)

## Function available at http://www.cookbook-r.com/Manipulating_data/Summarizing_data/. 
## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
    library(plyr)

    # New version of length which can handle NA's: if na.rm==T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm) sum(!is.na(x))
        else       length(x)
    }

    # This does the summary. For each group's data frame, return a vector with
    # N, mean, and sd
    datac <- ddply(data, groupvars, .drop=.drop,
      .fun = function(xx, col) {
        c(N    = length2(xx[[col]], na.rm=na.rm),
          mean = mean   (xx[[col]], na.rm=na.rm),
          sd   = sd     (xx[[col]], na.rm=na.rm)
        )
      },
      measurevar
    )

    # Rename the "mean" column    
    datac <- rename(datac, c("mean" = measurevar))

    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval: 
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult

    return(datac)
}

tgc = summarySE(to_plot,measurevar='value',groupvars=c('variable','NutrientLevel','Protozoa','Day'),na.rm=T)

postscript(sprintf("%s.eps", arglist[['-o']]))
qplot(Day,value,data=tgc,color=NutrientLevel,fill='white',shape=NutrientLevel)+facet_grid(variable~Protozoa,scales='free_y')+ geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.1) + geom_line(aes(group=NutrientLevel,linetype=NutrientLevel)) + geom_point(size=1)+theme_bw()
dev.off()


