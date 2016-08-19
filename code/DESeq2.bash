#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <PATH to group_info.txt file> <GROUP_BY>\n\n"
        exit
fi

GROUP_FILE=$1
GROUP_BY=$2
code/DESeq2.r ../whole_assembly/all.gtf ../whole_assembly/all.id2name.txt $GROUP_FILE $GROUP_BY ../featureCounts/raw_count.txt
