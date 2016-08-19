#!/bin/bash

source code/custom-bashrc

if [ "$#" -lt 7 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <CATEGORY> <METHOD> <GROUP_BY> <PATH to group_info.txt file> <FPKM Cutoff Folder> <Peak Overlap Folder> [Histone Mark Names from group_info.txt header]\n\n"
        exit
fi

CATEGORY=$1
shift
METHOD=$1
shift
GROUP_BY=$1
shift
GROUP_FILE=$1
shift
FPKM_CUTOFF=$1
shift
PEAK_OVERLAP=$1
shift

if [ ! -d $GROUP_BY ];then mkdir $GROUP_BY;fi
GROUP_INDEX=`head -1 $GROUP_FILE | tr '\t' '\n' | cat -n | grep -P "\t\${GROUP_BY}$" | cut -c-7 | sed -E 's/\s+//g'`

HISTONE_MARKS=($@)

echo
echo
echo "##############################################"
echo "** Integrating FPKM cutoff and ChIP-Seq peaks overlap grouping by $GROUP_BY"

pattern=`echo ${HISTONE_MARKS[*]} | sed 's/ /\|/g'`

STATUS=`cat <(head -1 $GROUP_FILE | tr '\t' '\n' | cat -n | grep -P "\t\${pattern}$" | sed -E 's/^\s+//g' | cut -f2 | tr '\n' ' ') <(echo "MonoExonic") | tr ' ' '\n' | grep -v "^$" | sort | awk '{printf $1":+,"$1":- "}'`
expand-grid ${STATUS[*]} | while read i; 
do
	HISTONES=($i)
	echo "####  "${HISTONES[*]}" in "$CATEGORY
	printf "\t"

for group in `cat ${GROUP_FILE} | cut -f${GROUP_INDEX} | skipn 1 | sort | uniq` 
do
	printf $group" "
	RNA_FILE="$FPKM_CUTOFF/$GROUP_BY/${group}_${CATEGORY}_fpkm_table_Mean_above*.txt"
	cat $RNA_FILE | cut -f1 | skipn 1 > $GROUP_BY/Temp_Result.txt
	RESULT=""
	for HIST in ${HISTONES[@]}
	do
		MARK=`echo $HIST | cut -d ':' -f1`
		MARK_STATUS=`echo $HIST | cut -d ':' -f2 | awk '{print ($1~/+/?"":"-v1")}'`
		HIST_FILE=`echo -e "$PEAK_OVERLAP/${GROUP_BY}/${group}_${CATEGORY}_$MARK.txt"`
		if [ -f $HIST_FILE ]
		then

			join -1 1 -2 1 $MARK_STATUS <(cut -f1 $GROUP_BY/Temp_Result.txt | sort) <(cat $HIST_FILE | skipn 1 | cut -f1 | sort) > $GROUP_BY/TEMP
			mv $GROUP_BY/TEMP $GROUP_BY/Temp_Result.txt
		else
			HIST=$MARK":na"
		fi
		RESULT=${RESULT}_$HIST
	done
	RESULT=${RESULT#*_}
	cat $GROUP_BY/Temp_Result.txt | awk '{print $0"\t'${RESULT%.*}'"}' >> $GROUP_BY/${group}_${CATEGORY}_${METHOD}.txt
	cat $GROUP_BY/${group}_${CATEGORY}_${METHOD}.txt | sort -k1,1 | mergeuniq -merge | words -sort -u | tr ' ' '\t' | grep -v "\.ID" | awk '{print($2~/:[+-]/?$1"\t"$2:$1"\t"$NF)}' > $GROUP_BY/${group}_${CATEGORY}_${METHOD}_Result.txt 
	echo -e ".ID_\t${group}_${METHOD}" > $GROUP_BY/${group}_${CATEGORY}_${METHOD}.txt
	cat $GROUP_BY/${group}_${CATEGORY}_${METHOD}_Result.txt >> $GROUP_BY/${group}_${CATEGORY}_${METHOD}.txt
	rm -rf $GROUP_BY/Temp_Result*.txt $GROUP_BY/${group}_${CATEGORY}_${METHOD}_Result.txt
done
	echo
done
echo "*** Done ***"

