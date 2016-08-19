#!/local/apps/R/3.2.0/bin/Rscript

usage = "\
        Rscript DESeq2.r [MATRIX] [Gene & Group Info] [Sample & Group Info]
"

args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=3) { write(usage,stderr()); quit(save='no'); }

library("dplyr")
library("preprocessCore")
library("pheatmap")
my_arg1=args[1]
my_arg2=args[2]
my_arg3=args[3]

ReadAsMatrix<-function(filename){
  myMatrix <-as.matrix(read.table(filename,row.names=1))
  colnames(myMatrix)=myMatrix[1,]
  myMatrix=myMatrix[-1,]
  temp=apply(myMatrix,2,as.numeric)
  rownames(temp)=rownames(myMatrix)
  colnames(temp)=colnames(myMatrix)
  myMatrix=temp
  return(myMatrix)
}


norm_count=ReadAsMatrix(my_arg1)
myMatrix=norm_count
temp=normalize.quantiles(myMatrix)
rownames(temp)=rownames(myMatrix)
colnames(temp)=colnames(myMatrix)
myMatrix=temp



myGenes=read.table(my_arg2)
colnames(myGenes)=c("Gene","Gene_Group")

group_info=read.table(my_arg3,quote="",sep="\t",header=T)
colnames(group_info)=c("sample","Sample_Group")

group_info=group_info[group_info[,2] %in% myGenes$Gene_Group,]
group_info$Sample_Group=factor(group_info$Sample_Group,levels=unique(group_info[,2]))
myGenes$Gene_Group=factor(myGenes$Gene_Group,levels=unique(group_info[,2]))
myGenes=myGenes[order(myGenes$Gene_Group),]
rownames(group_info)=group_info$sample
group_info <- select(group_info,Sample_Group)
mat <- myMatrix[ as.character(myGenes[,1]), rownames(group_info)]

row.names(mat) <- seq(1,dim(mat)[1])
anno_row=data.frame(myGenes[,2])
colnames(anno_row)=c("Gene_Group")
pdf(file=paste0("supervised_heatmap",".pdf"),onefile=FALSE)
pheatmap(mat,breaks=seq(-2,2,0.05),
        annotation_col=group_info, 
        annotation_row = anno_row,
        annotation_names_row = F, 
        annotation_names_col = F, 
        fontsize = 3, 
        show_rownames=F, 
        fontsize_col=2, 
        col=colorRampPalette(c("navy", "white", "firebrick3"))(80), 
        cluster_cols = F, 
        cluster_rows = F, 
        scale="row",
)
dev.off()

mat1=myMatrix[ unique(as.character(myGenes[,1])), rownames(group_info)]
pdf(file=paste0("unsupervised_heatmap",".pdf"),onefile=FALSE)
pheatmap(mat1,breaks=seq(-2,2,0.05),
        annotation_col=group_info,
        annotation_names_row = F,
        annotation_names_col = F,
        fontsize = 3,
        show_rownames=F,
        fontsize_col=2,
        col=colorRampPalette(c("navy", "white", "firebrick3"))(80),
        cluster_cols = T,
        cluster_rows = T,
        scale="row",
)
dev.off()


png(filename=paste0("supervised_heatmap",".png"))
pheatmap(mat,breaks=seq(-2,2,0.05),
        annotation_col=group_info, 
        annotation_row = anno_row,
        annotation_names_row = F, 
        annotation_names_col = F, 
        fontsize = 3, 
        show_rownames=F, 
        fontsize_col=2, 
        col=colorRampPalette(c("navy", "white", "firebrick3"))(80), 
        cluster_cols = F, 
        cluster_rows = F, 
        scale="row",
)
dev.off()

mat1=myMatrix[ unique(as.character(myGenes[,1])), rownames(group_info)]
png(file=paste0("unsupervised_heatmap",".png"))
pheatmap(mat1,breaks=seq(-2,2,0.05),
        annotation_col=group_info,
        annotation_names_row = F,
        annotation_names_col = F,
        fontsize = 3,
        show_rownames=F,
        fontsize_col=2,
        col=colorRampPalette(c("navy", "white", "firebrick3"))(80),
        cluster_cols = T,
        cluster_rows = T,
        scale="row",
)
dev.off()
