#!/usr/bin/env Rscript

## A script that produce a taxa summary plot in phyloseq where the taxonomy is handed and not imported from a database.

## Created by Moa Hammarstroem

helpstr <- c('-i OTU table in classic format.\n-m Mapping file.\n-t Taxonomy.\n-o Output name.')

allowed.args <- list('-i' = NULL, '-m' = NULL, '-t' = NULL, '-o' = NULL)

"parse.args" <- function(allowed.args,helplist=NULL){
    argv <- commandArgs(trailingOnly=TRUE)
    # print help string if requested
    if(!is.null(helpstr) && sum(argv == '-h')>0){
        cat('',helpstr,'',sep='\n')
        q(runLast=FALSE)
    }
    argpos <- 4
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

# Parse arg list
arglist <- parse.args(allowed.args)

# Load required packages
require(phyloseq)
require(ggplot2)

# Handle the input data.
otu_table = toString(arglist[['-i']])
mapping_file = toString(arglist[['-m']])
taxa = toString(arglist[['-t']])
output_name = toString(arglist[['-o']])

# Import the data to phyloseq fromat.
otus = read.table(otu_table,header=T,row.names=1,sep='\t',comment='')
taxa = read.table(taxa,header=T,row.names=1,sep='\t',comment='')
map = import_qiime_sample_data(mapfilename=mapping_file)
OTU = otu_table(otus, taxa_are_rows = TRUE)
taxa2=as.matrix(taxa)
TAX=tax_table(taxa2)
qiimedata=phyloseq(OTU,TAX,map)


# 
gp <- prune_taxa(names(sort(taxa_sums(qiimedata),decreasing = T)), qiimedata)
gp_m <- tax_glom(gp, 'Phylum',NArm=F)
proportional <- merge_taxa(gp_m,'Phylum')
proportional_to_plot <- transform_sample_counts(proportional,function(x) 100 * x/sum(x))

# Melt the phyloseq data to be able to produce the desired plot in ggplot2.
physeq <- psmelt(proportional_to_plot)
mdf <- physeq[order(physeq[,ncol(physeq)]),]
p <- ggplot(mdf, aes_string(x='Sample', y='Abundance', fill='Phylum'))
p <- p + geom_bar(stat="identity", position=position_stack(reverse=TRUE), color="black")
p <- p + theme_bw()
p <- p + theme(axis.text.x=element_text(angle=-90, hjust=0))

# The following faceting was used to produce the plot in the manuscript:
#p <- p + facet_grid(~Treatment, scales = 'free')

# Create output.
pdf_name <- paste(output_name,'pdf',sep='.')
eps_name <- paste(output_name,'eps',sep='.')
pdf(pdf_name)
p
dev.off()
postscript(eps_name)
p
dev.off()

