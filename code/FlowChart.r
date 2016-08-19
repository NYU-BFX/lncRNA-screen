#!/local/apps/R/3.2.0/bin/Rscript

usage = "\
Rscript FlowChart.r [flowchart.txt]"

filter_step_oneside_toright <- function(x,y,a,b,c){
row=x;col=y;criteria=a;accepted=b;unaccepted=c;
straightarrow (from = c(elpos[(row-1)*nrow+col,1],elpos[(row-1)*nrow+col,2]-0.1/nsteps), to = elpos[row*nrow+col,],lwd = 2, arr.pos = 0.72, arr.length = 0.6/nsteps)
splitarrow(from = elpos[row*nrow+col, ], to = elpos[((row+1)*nrow+col):((row+1)*nrow+col+1), ], lwd = 2, centre = c(elpos[row*nrow+col,1], elpos[(row+1)*nrow+col,2] + 0.25/nsteps), arr.side = 2, arr.length = 0.6/nsteps)
text(elpos[(row+1)*nrow+col, 1] - 0.1/nsteps, elpos[(row+1)*nrow+col+1, 2] + 0.2/nsteps, "yes", cex = 4/nsteps)
text(elpos[(row+1)*nrow+col+1, 1] - 0.9/nsteps, elpos[(row+1)*nrow+col+1, 2] + 0.2/nsteps, "no", cex = 4/nsteps)
texthexa(elpos[row*nrow+col,],radx=0.032*nchar(as.character(criteria))/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = criteria, box.col = "lightblue",shadow.col = "cadetblue4", shadow.size = 0.0025, cex = 4/nsteps)
textellipse(elpos[(row+1)*nrow+col,],radx=0.6/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = accepted, box.col = "green",shadow.col = "darkgreen",lcol="black",lwd=1, shadow.size = 0.0025, cex = 4/nsteps)
textrect(elpos[(row+1)*nrow+col+1,], 0.2/nsteps, 0.1/nsteps, lab = unaccepted, box.col = "indianred1",shadow.col = "indianred3", shadow.size = 0.0025, cex = 4/nsteps)
}

filter_step_oneside_toleft <- function(x,y,a,b,c){
  row=x;col=y;criteria=a;accepted=b;unaccepted=c;
  straightarrow (from = c(elpos[(row-1)*nrow+col,1],elpos[(row-1)*nrow+col,2]-0.1/nsteps), to = elpos[row*nrow+col,],lwd = 2, arr.pos = 0.72, arr.length = 0.6/nsteps)
  splitarrow(from = elpos[row*nrow+col, ], to = elpos[((row+1)*nrow+col):((row+1)*nrow+col-1), ], lwd = 2, centre = c(elpos[row*nrow+col,1], elpos[(row+1)*nrow+col,2] + 0.25/nsteps), arr.side = 2, arr.length = 0.6/nsteps)
  text(elpos[(row+1)*nrow+col, 1] + 0.1/nsteps, elpos[(row+1)*nrow+col+1, 2] + 0.2/nsteps, "yes", cex = 4/nsteps)
  text(elpos[(row+1)*nrow+col, 1] - 0.9/nsteps, elpos[(row+1)*nrow+col+1, 2] + 0.2/nsteps, "no", cex = 4/nsteps)
  texthexa(elpos[row*nrow+col,],radx=0.032*nchar(as.character(criteria))/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = criteria, box.col = "lightblue",shadow.col = "cadetblue4", shadow.size = 0.0025, cex = 4/nsteps)
  textellipse(elpos[(row+1)*nrow+col,],radx=0.6/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = accepted, box.col = "green",shadow.col = "darkgreen",lcol="black",lwd=1, shadow.size = 0.0025, cex = 4/nsteps)
  textrect(elpos[(row+1)*nrow+col-1,], 0.2/nsteps, 0.1/nsteps, lab = unaccepted, box.col = "indianred1",shadow.col = "indianred3", shadow.size = 0.0025, cex = 4/nsteps)
}

filter_step_twoside_toright <- function(x,y,a,b,c){
  row=x;col=y;criteria=a;meet1=unlist(strsplit(as.character(b),":"))[1];accepted1=unlist(strsplit(as.character(b),":"))[2];meet2=unlist(strsplit(as.character(c),":"))[1];accepted2=unlist(strsplit(as.character(c),":"))[2]
  straightarrow (from = c(elpos[(row-1)*nrow+col,1],elpos[(row-1)*nrow+col,2]-0.1/nsteps), to = elpos[row*nrow+col,],lwd = 2, arr.pos = 0.72, arr.length = 0.6/nsteps)
  splitarrow(from = elpos[row*nrow+col, ], to = elpos[((row+1)*nrow+col):((row+1)*nrow+col+1), ], lwd = 2, centre = c(elpos[row*nrow+col,1], elpos[(row+1)*nrow+col,2] + 0.25/nsteps), arr.side = 2, arr.length = 0.6/nsteps)
  text(elpos[(row+1)*nrow+col, 1] - 0.3/nsteps, elpos[(row+1)*nrow+col+1, 2] + 0.2/nsteps, meet1, cex = 4/nsteps)
  text(elpos[(row+1)*nrow+col+1, 1] - 0.9/nsteps, elpos[(row+1)*nrow+col+1, 2] + 0.2/nsteps, meet2, cex = 4/nsteps)
  texthexa(elpos[row*nrow+col,],radx=0.032*nchar(as.character(criteria))/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = criteria, box.col = "lightblue",shadow.col = "cadetblue4", shadow.size = 0.0025, cex = 4/nsteps)
  textellipse(elpos[(row+1)*nrow+col,],radx=0.6/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = accepted1, box.col = "green",shadow.col = "darkgreen",lcol="black",lwd=1, shadow.size = 0.0025, cex = 4/nsteps)
  textellipse(elpos[(row+1)*nrow+col+1,],radx=0.6/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = accepted2, box.col = "green",shadow.col = "darkgreen",lcol="black",lwd=1, shadow.size = 0.0025, cex = 4/nsteps)
}

library(diagram)
args <- commandArgs(trailingOnly = TRUE)
if (length(args)!=1) { write(usage,stderr()); quit(save='no'); }
mydata=read.table(args[1],header = F,sep = "\t")

pdf(paste0(gsub("\\.[^\\.]+$","",basename(args[1])),".pdf"),onefile = F)
par(mar = c(0, 0, 0, 0))
openplotmat()
nsteps=8
nrow=4
elpos <- coordinates (rep(nrow,(nsteps*2+1)))

row=1;col=2;
textellipse(elpos[(row-1)*nrow+col,],radx=0.6/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = as.numeric(as.character(mydata[1,2]))+as.numeric(as.character(mydata[1,3])), box.col = "green",shadow.col = "darkgreen",lcol="black",lwd=1, shadow.size = 0.0025, cex = 4/nsteps)

filter_step_oneside_toright(1,2,mydata[1,1],mydata[1,2],mydata[1,3])
filter_step_oneside_toright(3,2,mydata[2,1],mydata[2,2],mydata[2,3])
filter_step_oneside_toright(5,2,mydata[3,1],mydata[3,2],mydata[3,3])
filter_step_oneside_toright(7,2,mydata[4,1],mydata[4,2],mydata[4,3])
filter_step_twoside_toright(9,2,mydata[5,1],mydata[5,2],mydata[5,3])
filter_step_oneside_toleft(11,2,mydata[6,1],mydata[6,2],mydata[6,3])
filter_step_oneside_toright(11,3,mydata[7,1],mydata[7,2],mydata[7,3])
filter_step_oneside_toleft(13,2,mydata[8,1],mydata[8,2],mydata[8,3])
filter_step_oneside_toright(13,3,mydata[9,1],mydata[9,2],mydata[9,3])
filter_step_oneside_toleft(15,2,mydata[10,1],mydata[10,2],mydata[10,3])
filter_step_oneside_toright(15,3,mydata[11,1],mydata[11,2],mydata[11,3])

dev.off()


png(paste0(gsub("\\.[^\\.]+$","",basename(args[1])),".png"))
par(mar = c(0, 0, 0, 0))
openplotmat()
nsteps=8
nrow=4
elpos <- coordinates (rep(nrow,(nsteps*2+1)))

row=1;col=2;
textellipse(elpos[(row-1)*nrow+col,],radx=0.6/nsteps,rady=0.1/nsteps,adj=c(0.5,0.5), lab = as.numeric(as.character(mydata[1,2]))+as.numeric(as.character(mydata[1,3])), box.col = "green",shadow.col = "darkgreen",lcol="black",lwd=1, shadow.size = 0.0025, cex = 4/nsteps)

filter_step_oneside_toright(1,2,mydata[1,1],mydata[1,2],mydata[1,3])
filter_step_oneside_toright(3,2,mydata[2,1],mydata[2,2],mydata[2,3])
filter_step_oneside_toright(5,2,mydata[3,1],mydata[3,2],mydata[3,3])
filter_step_oneside_toright(7,2,mydata[4,1],mydata[4,2],mydata[4,3])
filter_step_twoside_toright(9,2,mydata[5,1],mydata[5,2],mydata[5,3])
filter_step_oneside_toleft(11,2,mydata[6,1],mydata[6,2],mydata[6,3])
filter_step_oneside_toright(11,3,mydata[7,1],mydata[7,2],mydata[7,3])
filter_step_oneside_toleft(13,2,mydata[8,1],mydata[8,2],mydata[8,3])
filter_step_oneside_toright(13,3,mydata[9,1],mydata[9,2],mydata[9,3])
filter_step_oneside_toleft(15,2,mydata[10,1],mydata[10,2],mydata[10,3])
filter_step_oneside_toright(15,3,mydata[11,1],mydata[11,2],mydata[11,3])

dev.off()
