#!/bin/bash

source code/custom-bashrc
source inputs/params.bash

if [ "$#" -ne 1 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 [BED file]\n\n"
        exit
fi

BED=$1
BED_BASE=`basename $BED`

if [ `cat ${BED_BASE%.*}.out | wc -l` -eq 1 ]; then exec >> ${BED_BASE%.*}.out;else exec > ${BED_BASE%.*}.out; fi
exec 2>&1

code/lncRNA_snapshot.r ../report/ $GENOME $Ref_GTF ../whole_assembly/all.id2name.gtf  $BED "$bigwig_files" > ${BED_BASE%.*}.out

echo "###### Done ######" >> ${BED_BASE%.*}.out
