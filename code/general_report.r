#!/usr/bin/env Rscript

usage = "\
	Rscript general_report.r [\"all pdf files in wildcard\"] [\"all groups in wildcard\"]
"
date()

args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=2) { write(usage,stderr()); quit(save='no'); }

suppressPackageStartupMessages(library(hwriter))
suppressPackageStartupMessages(library(ReportingTools))
suppressPackageStartupMessages(library(tools))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
sessionInfo()


filelist=Sys.glob(args[1])
group_list=data.frame(read.table(args[2],header=T,sep="\t"))

cat("\n\n####  Start Genrating Report......\n")
htmlRep <- HTMLReport(shortName = "lncRNA_report", title="lncRNA Standard Report", reportDirectory = "./")

dir.create("figures",recursive=T,showWarnings=F)

for(i in 1:length(filelist)){
	system(paste0("cp ",file_path_sans_ext(filelist[i]),"{.png,.pdf} figures/"))
	cat(paste0(filelist[i],"\n"))
	himg <- hwriteImage(paste0("figures/",file_path_sans_ext(basename(filelist[i])),".png"),link=paste0("figures/",file_path_sans_ext(basename(filelist[i])),".pdf"))
	publish(toupper(gsub("_"," ",file_path_sans_ext(basename(filelist[i])))), htmlRep)
	publish(hwrite(himg, br=TRUE), htmlRep,name=file_path_sans_ext(basename(filelist[i])))
}

publish("          ", htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("      Report for each grouping level", htmlRep)

for(i in 2:length(colnames(group_list))){
	cat(paste0(colnames(group_list)[i],"\n"))
	publish(hwrite(colnames(group_list)[i],link=paste0(colnames(group_list)[i],"/report.html")), htmlRep)
}

publish(group_list,htmlRep)

cat("Sucess: ")
finish(htmlRep)


cat("####  Done\n")
date()
