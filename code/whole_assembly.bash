#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <the reference annotation file you want to use (including coding gene and annnotated lncRNA)> <lncRNA GTF>\n\n"
        exit
fi

ref_annot_gtf=$1
shift

LNC_RNA=$1
LNC_PREFIX=${LNC_RNA%.*}

ref_annot_id2name=`echo $ref_annot_gtf | sed -r 's/\.gtf/\.id2name.txt/g'`

cat $LNC_RNA $ref_annot_gtf > all.gtf
cat <(cut -f4 ${LNC_PREFIX}.bed | awk '{print $0"\t"$0}') $ref_annot_id2name > all.id2name.txt

join -1 1 -2 1 -t $'\t' <(sort -k1,1 all.id2name.txt) <(cat all.gtf | awk '$3~/exon/' | perl -F/\\t/ -lane '$myline="";$description=pop @F;foreach $f (@F){$myline=$myline."$f\t"};@des=split(/ \"|\";\s{0,1}/,$description);for($i=0;$i<@des;$i=$i+2){if($des[$i]=~/gene_id/){printf "$des[$i+1]\t"}else{$myline=$myline."$des[$i] \"$des[$i+1]\"; "}};printf "$myline\n"' | sort -k1,1) | cut -f2- | perl -F/\\t/ -lane 'print "$F[1]\t$F[2]\t$F[3]\t$F[4]\t$F[5]\t$F[6]\t$F[7]\t$F[8]\tgene_id \"$F[0]\"; $F[9]"' > all.id2name.gtf
