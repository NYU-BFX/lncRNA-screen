#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 3 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <BED File> <CATEGORY> <Matrix File>\n\n"
        exit
fi

BED=$1
CATEGORY=$2
MATRIX=$3

bn=`basename $MATRIX`

head -1 $MATRIX > ${CATEGORY}_$bn
join -t $'\t' -1 1 -2 1 <(cut -f4 $BED | sort) <(sort -k1,1 $MATRIX) >> ${CATEGORY}_$bn

