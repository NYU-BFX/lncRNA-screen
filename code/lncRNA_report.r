#!/usr/bin/env Rscript

usage = "\
	Rscript lncRNA_report.r [Summary Table]
"
date()

args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=1) { write(usage,stderr()); quit(save='no'); }

suppressPackageStartupMessages(library(hwriter))
suppressPackageStartupMessages(library(ReportingTools))
suppressPackageStartupMessages(library(tools))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
sessionInfo()


my.table=args[1]

# construct imagename and gene name
my.df=data.frame(read.table(my.table,header=T))
imagename=my.df %>% select(.ID_) %>% mutate(.ID_=paste0("figures/",.ID_, ".png"))
imagename=imagename[,1]
linkname=my.df %>% select(.ID_) %>% mutate(.ID_=paste0("figures/",.ID_, ".pdf"))
linkname=linkname[,1]
my.df$Image <- hwriteImage(imagename, link = linkname, table = FALSE, width=100, height=100)
my.df=select(my.df,Image,everything())

# generating report html and it's necessary css and js
if(!file.exists("report.html")){
  cat("\n\nStart Genrating Report......\n")
  cat("  From: ",my.table,"\n")
  htmlRep <- HTMLReport(shortName = "lncRNA_report", title="lncRNA Standard Report", reportDirectory = "./")

publish("lncRNA Feature Table:", htmlRep)
publish(hwrite("Download", link = paste("merged.tsv",sep="")), htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("lncRNA BED file:", htmlRep)
publish(hwrite("Download", link = paste("lncRNA.bed",sep="")), htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)
publish("          ", htmlRep)

  publish(my.df, htmlRep)
  cat("  Sucess: ")
  finish(htmlRep)
}else{cat("\n\nExisting! Skip Generating Report......\n")}


print("Done")
date()
