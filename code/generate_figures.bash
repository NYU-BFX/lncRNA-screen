#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 1 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <group_info.txt file path>\n\n"
        exit
fi

GROUP_FILE=$1

cut -f1 $GROUP_FILE | skipn 1 | grep -v "^#" | awk '{print "../RNA-Seq/pipeline/alignment/"$1"/STAR.Log.final.out"}' | xargs bash ../code/code.rnaseq/align_summary > align_summary.txt

code/align_barplot.r ./ align_summary.txt

code/coding_potential_statistics.r ../coding_potential/{novel-lncRNA,gencode-lncRNA,gencode-mRNA}_for_table.txt

code/sample_distance.r ../summarize/norm_count.txt

code/featureCounts_summary ../featureCounts/*.out

code/featureCounts_barplot.r ./ featureCounts_summary.txt
