#!/usr/bin/env Rscript

usage = "\
        Rscript align_barplot.r [OUT DIR] [align_summary.txt]
"

align_reads <- function(x){
  x = x %>% filter(V2!="Uniquely_Mapped") %>% mutate(V4=ifelse(grepl("NonDuplicated|Duplicated",V2, ignore.case=T),"Uniquely_Mapped",as.character(V2))) %>% arrange(desc(V1)) %>% mutate(V3=V3/1000000)
  x$V2 <- factor(x$V2, levels = c("NonDuplicated","Duplicated","Multi_Mapped","Unmapped"))
  x$V4 <- factor(x$V4, levels = c("Uniquely_Mapped","Multi_Mapped","Unmapped"))
  x=x[order(x$V1,x$V2),]
  myplot <- 
    ggplot(x,aes(x=V1,y=V3,fill=V2)) +
    geom_bar(stat="identity",position="stack") +
    scale_fill_manual(values=c("limegreen","forestgreen","orchid","indianred1")) +
    ggtitle("B. Alignment Category Reads") +
    xlab("") + ylab("Number of Reads in Millions") +
    theme(axis.title = element_text(size=8),axis.text.y = element_blank(),axis.text.x = element_text(size=5),plot.title = element_text(size=8),legend.title=element_blank(),legend.text=element_text(size=8),axis.ticks.y=element_blank(), axis.line.y=element_blank()) + 
    coord_flip()
    return(myplot)
}

align_PCT <- function(x){
  x = x %>% filter(V2!="Uniquely_Mapped") %>% group_by(V1,add=F) %>% mutate(V3=V3/sum(V3)) %>% mutate(V4=ifelse(grepl("NonDuplicated|Duplicated",V2, ignore.case=T),"Uniquely_Mapped",as.character(V2))) %>% arrange(desc(V1)) %>% mutate(V3=V3*100)
  x$V2 <- factor(x$V2, levels = c("NonDuplicated","Duplicated","Multi_Mapped","Unmapped"))
  x$V4 <- factor(x$V4, levels = c("Uniquely_Mapped","Multi_Mapped","Unmapped"))
  x=x[order(x$V1,x$V2),]
    myplot <- ggplot(x,aes(x=V1,y=V3,fill=V2)) +
    geom_bar(stat="identity",position="stack") +
    ggtitle("A. Alignment Category Percentage") +
    scale_fill_manual(values=c("limegreen","forestgreen","orchid","indianred1")) +
    xlab("") + ylab("Percentage of Reads") +
    theme(axis.title = element_text(size=5),axis.text.y = element_text(size=2.8,angle=0),axis.text.x = element_text(size=5),plot.title = element_text(size=8)) +
    guides(fill=FALSE) +
    coord_flip()
    return(myplot)
}

for (p in c("dplyr","ggplot2","cowplot")){
  if (!require(p,character.only=TRUE,quietly=TRUE,warn.conflicts=FALSE)) {
    if(!file.exists(Sys.getenv("R_LIBS_USER"))){system(paste0("mkdir",Sys.getenv("R_LIBS_USER")))}
    install.packages(p,lib=Sys.getenv("R_LIBS_USER"),repos="http://cran.rstudio.com/",verbose=F)
  }
    suppressPackageStartupMessages(library(p,character.only=TRUE,verbose=FALSE))
}
args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=2) { write(usage,stderr()); quit(save='no'); }

dir.create(args[1],recursive=T,showWarnings=F)
pdf(paste0(args[1],"/",gsub("\\.[^\\.]+$","",basename(args[2])),".pdf"),width = 7,height=6,onefile = F)
plot_grid(align_PCT(read.table(args[2])),align_reads(read.table(args[2])))
dev.off()
png(filename=paste0(args[1],"/",gsub("\\.[^\\.]+$","",basename(args[2])),".png"),width = 7,height=6,units = "in",res=300)
plot_grid(align_PCT(read.table(args[2])),align_reads(read.table(args[2])))
dev.off()
