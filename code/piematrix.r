#!/usr/bin/env Rscript

usage = "\
        Rscript piematrix.r <Input Melted Long Format File> <Output Prefix>
	#################### Column Infor:
		side1	side2	group	value	weight
"

Sys.time()
library(dplyr)
library(ggplot2)
sessionInfo()

piematrix <- function (dat) {
  dat <- dat %>% group_by(side1,side2) %>% mutate(pos = (cumsum(value)- value/2)/weight)
  dat$weight=sqrt(dat$weight)
  ggplot(dat, aes(x=weight/2, y = value, fill = group, width = weight)) +
    geom_bar(position="fill", stat="identity") +
    geom_text(aes(x= weight/2, y=pos, label = value, width = weight),size=2 ,angle=45) +
    facet_grid(side1 ~ side2) +
    coord_polar("y") +
    ggtitle("Pie-Matrix") + 
    theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks=element_blank(),  # the axis ticks
      axis.title=element_blank()  # the axis labels
    )
    ggsave(file=paste(args[2],".pdf",sep=""),width=10,height=6,unit="in")
    ggsave(file=paste(args[2],".png",sep=""),width=10,height=6,unit="in")
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=2) { write(usage,stderr()); quit(save='no'); }
mymelt=read.table(args[1],header=F)
colnames(mymelt)=c("side1","side2","group","value","weight")
piematrix(mymelt)

