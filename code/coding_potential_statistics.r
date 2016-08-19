#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(cowplot))

file1=read.table(args[1],header=T) %>% mutate(Category=gsub("_for_table\\.txt","",basename(args[1])))
file2=read.table(args[2],header=T) %>% mutate(Category=gsub("_for_table\\.txt","",basename(args[2])))
file3=read.table(args[3],header=T) %>% mutate(Category=gsub("_for_table\\.txt","",basename(args[3])))

data=rbind(file1,file2,file3)

pdf("coding_potential.pdf",width = 7,height=3.5,onefile = F)
plot_grid(
  ggplot(data, aes(ORF_size,col=Category)) + stat_ecdf() + xlim(0,3000) + xlab("ORF Size") + ylab("Cumulative Distribution") + ggtitle("A.") + theme(axis.text=element_text(size=6),text = element_text(size=6),axis.title=element_text(size=8),plot.title = element_text(hjust = 0)),
  ggplot(data, aes(coding_prob,col=Category)) + stat_ecdf() + xlab("Coding Probability") + ylab("Cumulative Distribution")+ ggtitle("B.") + theme(axis.text=element_text(size=6),text = element_text(size=6),axis.title=element_text(size=8),plot.title = element_text(hjust = 0)) 
)
dev.off()
png(filename="coding_potential.png",width = 7,height=3.5,units="in",res=300)
plot_grid(
  ggplot(data, aes(ORF_size,col=Category)) + stat_ecdf() + xlim(0,3000) + xlab("ORF Size") + ylab("Cumulative Distribution") + ggtitle("A.") + theme(axis.text=element_text(size=6),text = element_text(size=6),axis.title=element_text(size=8),plot.title = element_text(hjust = 0)),
  ggplot(data, aes(coding_prob,col=Category)) + stat_ecdf() + xlab("Coding Probability") + ylab("Cumulative Distribution")+ ggtitle("B.") + theme(axis.text=element_text(size=6),text = element_text(size=6),axis.title=element_text(size=8),plot.title = element_text(hjust = 0)) 
)
dev.off()

