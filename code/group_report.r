#!/usr/bin/env Rscript

usage = "\
	Rscript general_report.r [\"all pdf files in wildcard\"] [\"Matrix\"]
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
group_list=unique(data.frame(read.table(args[2],header=T,sep="\t"))[,2])

cat("\n\n####  Start Genrating Report......\n")
htmlRep <- HTMLReport(shortName = "report", title="Standard Report", reportDirectory = "./")

dir.create("figures",recursive=T,showWarnings=F)

for(i in 1:length(filelist)){
	system(paste0("mv ",file_path_sans_ext(filelist[i]),"{.png,.pdf} figures/"))
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
publish("      lncRNA Reports", htmlRep)

for(i in 1:length(group_list)){
        cat(paste0(group_list[i],"\n"))
        publish(hwrite(paste0("lncRNA in ",group_list[i]),link=paste0(group_list[i],"/lncRNA_report.html")), htmlRep)
}

cat("Sucess: ")
finish(htmlRep)


cat("####  Done\n")
date()
