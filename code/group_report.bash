#!/bin/bash

source code/custom-bashrc

if [ "$#" -lt 4 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <Re-defined category in pie-matrix> <\"lncRNA\" or \"mRNA\"> <group_info.txt file path> <GROUP_BY>\n\n"
        exit
fi


TEMP=$(mktemp)

redefine=$1
shift
CATEGORY=$1
shift
group_info=$1
shift
group_info_base=`basename $group_info`
GROUP_BYs=($@)

rm -rf $TEMP


for GROUP_BY in ${GROUP_BYs[@]}
do
echo
echo
echo "##############################################"
echo "** Generating group level report grouping by $GROUP_BY"
	mkdir -p $GROUP_BY
	group_index=`head -1 $group_info | tr '\t' '\n' | cat -n | sed -E 's/^\s+//g' | grep -P "\t${GROUP_BY}$" | cut -f1`
	cut -f1,$group_index $group_info > $TEMP
	grep "$redefine" ../pie_matrix_peak/$GROUP_BY/*_${CATEGORY}_HistoneCombine.txt | replace_with_tab "$GROUP_BY\/" | replace_with_tab "_${CATEGORY}_" | replace_with_tab ':' | cut -f2,4 | sort | cols -t 1 0 > $GROUP_BY/list.txt
	cd $GROUP_BY
	../code/supervised_pheatmap.r ../../summarize/${CATEGORY}_fpkm_table.txt list.txt $TEMP
	cp ../../pie_matrix_peak/${GROUP_BY}_${CATEGORY}_HistoneCombine.{png,pdf} .
	cp ../../pie_matrix_DE/${GROUP_BY}_${CATEGORY}_DE.{png,pdf} .
	Rscript ../code/group_report.r "*.pdf" $TEMP
	cd ../
	rm -rf $TEMP
echo
echo
done

