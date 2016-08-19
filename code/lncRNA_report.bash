#!/bin/bash

source code/custom-bashrc

if [ "$#" -lt 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <group_info.txt file path> <GROUP_BY>\n\n"
        exit
fi


group_info=$1
group_info_base=`basename $group_info`
GROUP_BYs=($2)


echo
echo
echo "##############################################"
echo "** Generating lncRNA report"

for GROUP_BY in ${GROUP_BYs[@]}
do
	mkdir -p $GROUP_BY
	group_index=`head -1 $group_info | tr '\t' '\n' | cat -n | sed -E 's/^\s+//g' | grep -P "\t${GROUP_BY}$" | cut -f1`
	for sample in `cat $group_info | cut -f$group_index | skipn 1 | sort | uniq`
	do
		echo
		echo
		echo "##  For " $sample
		mkdir -p $GROUP_BY/$sample
		code/merge_table.bash $GROUP_BY/$sample ../coding_potential/lncRNA.bed --inner-join ../fpkm_cutoff/$GROUP_BY/*$sample*lncRNA*.txt ../coding_potential/lncRNA_for_table.txt  ../integrate_HistoneCombine/$GROUP_BY/*$sample*lncRNA*.txt ../peak_overlap/$GROUP_BY/$sample*lncRNA*.txt ../summarize/${group_info_base%.*}/$GROUP_BY/*$sample*.txt ../annotate/*.txt
		cd $GROUP_BY/$sample
		../../code/lncRNA_report.r merged.tsv
		ln -s ../../figures/
		cd ../../
		echo
		echo
	done
done

