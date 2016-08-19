#!/usr/bin/env Rscript

usage = "\
	Rscript lncRNA_report.r [OUT DIR] [Genome (hg19/mm10/mm9, etc)] [Refernce GTF] [Whole Assembly] [BED file] [\"BIGWIG PATH\"]
"
date()

args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=6) { write(usage,stderr()); quit(save='no'); }

suppressPackageStartupMessages(library(Gviz))
suppressPackageStartupMessages(library(GenomicRanges))
suppressPackageStartupMessages(library(GenomicFeatures))
suppressPackageStartupMessages(library(hwriter))
suppressPackageStartupMessages(library(ReportingTools))
suppressPackageStartupMessages(library(tools))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(animation))
sessionInfo()


outdir=args[1]
my.genome=args[2]
file.reference=args[3]
file.assembly=args[4]
my.table=args[5]
bigwigpath=args[6]

cat("\n\nLoading Ideogram and Genome Axis......\n")
cat("  Genome: ",my.genome,"\n")
# Ideogram Track
itrack <- IdeogramTrack(genome = my.genome)
# Genome Axis Track
gtrack <- GenomeAxisTrack(genome=my.genome)
# bigwig file
cat("\n\nLoading Track Files......\n")
bigwiglist=Sys.glob(bigwigpath)
datatrack=list()
for (i in 1:length(bigwiglist)){
  datatrack[[i]]=DataTrack(range = bigwiglist[i], type = "histogram", name = file_path_sans_ext(basename(bigwiglist[i])),genome=my.genome,showTitle=TRUE)
  cat("  ",bigwiglist[i],"\n")
}


# Reference gtf file
cat("\n\nLoading Reference GTF......\n")
cat("  ",file.reference,"\n")
referencefile <- file.path(file.reference)
reference <- makeTxDbFromGFF(referencefile, format="gtf", circ_seqs=character())
reference <- GeneRegionTrack(reference, genome=my.genome, name="Ref")

# whole assembly gtf file
cat("\n\nLoading Assembly GTF......\n")
cat("  ",file.assembly,"\n")
assemblyfile <- file.path(file.assembly)
assembly <- makeTxDbFromGFF(assemblyfile, format="gtf", circ_seqs=character())
assembly <- GeneRegionTrack(assembly, genome=my.genome, name="Asmbl")

# construct imagename and gene name
my.df=data.frame(read.table(my.table,header=F))

cat("\n\nStart Genrating Plots......\n")
my.bed=my.df %>% select(V1,V2,V3,V4,V5,V6)
colnames(my.bed)=c("chr","start","end","X_ID_","score","strand")
imagename=my.bed %>% select(X_ID_) %>% mutate(X_ID_=paste0("figures/",X_ID_,".png"))
imagename=imagename[,1]
linkname=my.bed %>% select(X_ID_) %>% mutate(X_ID_=paste0("figures/",X_ID_,".pdf"))
linkname=linkname[,1]

# if directory not exist, create one
if(!dir.exists(paste0(outdir,"/figures"))){dir.create(paste0(outdir,"/figures/"))}

# plotting
for (i in 1:nrow(my.bed)){

 tryCatch({
# lncRNA that is plotting
  theone=my.bed[i,]
  theid=as.character(theone[1,4])

# if the pdf and png exist, skipping
if(file.exists(paste0(outdir,"/figures/",theid,".pdf")) & file.exists(paste0(outdir,"/figures/",theid,".png"))){cat("  Skipping ",theid,": Exist!\n");next}

# if not, generate
  thechr=as.character(theone[1,1])
  thestart=as.numeric(theone[1,2])
  theend=as.numeric(theone[1,3])
  thestrand=theone[1,6]
# zoom out 10X
  region.from=ifelse(thestart-abs(theend-thestart)*5>0,thestart-abs(theend-thestart)*5,0)
  region.to=theend+abs(theend-thestart)*5

# if in the zoom out 10X region, there are more than 50 genes in the assembly track, set the assembly track to "dense", then if reference track itself have more than 149 genes, or reference track + assembly track > 150 genes, set reference track to "dense" too, in order to prevent error "Too many stacks to draw". 
  chromosome(assembly)<-thechr
  my.assembly=subset(assembly,from=region.from,to=region.to)
  if(length(unique(gene(my.assembly)))>50){stacking(my.assembly)="dense"}
  chromosome(reference)<-thechr
  my.reference=subset(reference,from=region.from,to=region.to)
  if(length(unique(gene(my.reference)))+length(unique(gene(my.assembly)))>150){stacking(my.reference)="dense"}

# Target track
  atrack <- AnnotationTrack(chromosome=thechr,start=thestart, end=theend,name="This", strand=thestrand, id=paste0(theid," ",thechr,":",thestart,"-",theend),  featureAnnotation = "id", fontcolor.feature = "darkblue", fontsize=7)


# png
#  png(filename = paste0(outdir,"/", imagename[i]))
#  plotTracks(append(list(itrack, gtrack,my.reference,my.assembly,atrack),datatrack), from = region.from, to = region.to, chromosome = thechr, collapseTranscripts = "meta",transcriptAnnotation="gene")
#  dev.off()

# pdf
  pdf(file = paste0(outdir,"/", linkname[i]))
  plotTracks(append(list(itrack, gtrack,my.reference,my.assembly,atrack),datatrack), from = region.from, to = region.to, chromosome = thechr, collapseTranscripts = "meta",transcriptAnnotation="gene")
  dev.off()
  suppressMessages(im.convert(paste0(outdir,"/",linkname[i]), output = paste0(outdir,"/",imagename[i]), extra.opts="-density 150"))
  cat("  Plotting ",theid,": Success!\n")
 },
 error=function(e){
  dev.off()
  cat("  Error!!! ",theid,": ",conditionMessage(e),"\n");
  if(file.exists(paste0(outdir,"/figures/",theid,".png"))){remove.png=file.remove(paste0(outdir,"/figures/",theid,".png"))}
  if(file.exists(paste0(outdir,"/figures/",theid,".pdf"))){remove.pdf=file.remove(paste0(outdir,"/figures/",theid,".pdf"))}
 })
}

print("Done")
date()
