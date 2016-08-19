#!/usr/bin/env Rscript
usage = "\
        Rscript sample_distance.r [count matrix file]
"
Sys.time()

args <- commandArgs(trailingOnly = TRUE)
my.packages=c("DESeq2","dplyr","tools","pheatmap","RColorBrewer","preprocessCore")
for (p in my.packages){
    suppressPackageStartupMessages(library(p,character.only=TRUE,verbose=FALSE))
}

if (length(args)!=1) { write(usage,stderr()); quit(save='no'); }

sessionInfo()

mymatrix=as.matrix(read.table(args[1],header=T,row.names=1))
temp=normalize.quantiles(mymatrix)
rownames(temp)=rownames(mymatrix)
colnames(temp)=colnames(mymatrix)
mymatrix=temp
sampleDists <- dist(t(mymatrix))
sampleDistMatrix <- as.matrix( sampleDists )
rownames(sampleDistMatrix) <- colnames(mymatrix)
colnames(sampleDistMatrix) <- colnames(mymatrix)
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pdf(file="sample_distance.pdf",,width = 7,height=6,onefile = F)
pheatmap(sampleDistMatrix, clustering_distance_rows=sampleDists, clustering_distance_cols=sampleDists, col=colors, main="Distance Between Samples")
dev.off()

png(filename="sample_distance.png")
pheatmap(sampleDistMatrix, clustering_distance_rows=sampleDists, clustering_distance_cols=sampleDists, col=colors, main="Distance Between Samples")
dev.off()
