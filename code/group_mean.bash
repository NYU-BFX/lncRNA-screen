#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 4 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <FPKM CUTOFF> <PATH to group_info.txt file> <GROUP_BY> <FPKM MATRIX FILE>\n\n"
        exit
fi

cutoff=$1
GROUP_FILE=$2
GROUP_BY=$3
MATRIX=$4
GROUP_INDEX=`head -1 $GROUP_FILE | tr '\t' '\n' | cat -n| grep -P "\t\${GROUP_BY}$" | cut -c-7 | sed -E 's/\s+//g'`
myfile=`basename $MATRIX`
CATEGORY=${myfile%.*}

if [ ! -d $GROUP_BY ]
then
	mkdir $GROUP_BY
fi

echo
echo
echo "##############################################"
echo "** Calculating FPKM Cutoff for $CATEGORY grouping by $GROUP_BY"
printf "\t"

for group in `cat ${GROUP_FILE} | cut -f${GROUP_INDEX} | skipn 1 | sort | uniq` 
do
	printf $group" "

	column=`echo $(cut -f1,$GROUP_INDEX $GROUP_FILE | cat -n| grep -P "\t\${group}$" | cut -c-7 | sed -E 's/\s+//g') | tr ' ' ','`
	total=`cut -f1,$GROUP_INDEX $GROUP_FILE | grep -P "\t\${group}$" | wc -l`

	echo -e ".ID_\t${group}_PCTGofSample_above"$cutoff"" > $GROUP_BY/${group}_${CATEGORY}_PCTGofSample_above"$cutoff".txt
	cat $MATRIX | cut -f1,$column | skipn 1 | sed 's/\t/ /g' | replace_with_tab ' ' | vectors test -g -e -c $cutoff | vectors sum -n 0 | awk '{print $1"\t"$2/'$total'*100}' | awk '$2>0' >> $GROUP_BY/${group}_${CATEGORY}_PCTGofSample_above"$cutoff".txt

	echo -e ".ID_\t${group}_Mean" > $GROUP_BY/${group}_${CATEGORY}_Mean.txt
	cat $MATRIX | cut -f1,$column | skipn 1 | sed 's/\t/ /g' | replace_with_tab ' ' | vectors m -n 4 | awk '$2>0' >> $GROUP_BY/${group}_${CATEGORY}_Mean.txt

# computing the mean fpkm only on samples that pass the cutoff (divide by the number of patient pass the cutoff)
	echo -e ".ID_\t${group}_Mean_above"$cutoff"" > $GROUP_BY/${group}_${CATEGORY}_Mean_above"$cutoff".txt
	join -1 1 -2 1 <(cat $MATRIX | cut -f1,$column | skipn 1 | sed 's/\t/ /g' | replace_with_tab ' ' | vectors cutoff -c $cutoff | vectors sum | sort -k1,1) <(cat $GROUP_BY/${group}_${CATEGORY}_PCTGofSample_above"$cutoff".txt | awk '$2>0{print $1"\t"'$total'*$2/100}' | sort -k1,1) | awk '{print $1"\t"$2/$3}' >> $GROUP_BY/${group}_${CATEGORY}_Mean_above"$cutoff".txt
	rm -rf $GROUP_BY/*{Mean.txt}
done

echo
echo
