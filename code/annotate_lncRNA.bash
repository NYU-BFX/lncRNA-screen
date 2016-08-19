#!/bin/bash

source code/custom-bashrc

if [ "$#" -lt 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "bash run.bash <BED File> <all annotation bed files>\n\n"
        exit
fi

LNC_RNA=$1
shift

other_annotations=($@)

for file in ${other_annotations[@]}
do

BASE_NAME=`basename $file`
PREFIX=${BASE_NAME%.*}

echo -e ".ID_\t$PREFIX" > $PREFIX.txt

cat $LNC_RNA | genomic_overlaps overlap -label $file | cut -f4 | replace_with_tab ':' | sort -k1,1 | mergeuniq -merge | tr ' ' '|' >> $PREFIX.txt

done

