#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 5 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <Histone BED file folder> <PATH to group_info.txt file> <GROUP_BY> <Annotation BED File> <(HistonMark):(TSS Upstream Shift Dist):(TSS Downstream Shift Dist)>\n\n"
        exit
fi

BED_PATH=$1
GROUP_FILE=$2
GROUP_BY=$3
BED=$4
HIST_TSS=$5
HIST=`echo $HIST_TSS | cut -d ':' -f1`
UP=`echo $HIST_TSS | cut -d ':' -f2`
DOWN=`echo $HIST_TSS | cut -d ':' -f3`
GROUP_INDEX=`head -1 $GROUP_FILE | tr '\t' '\n' | cat -n| grep -P "\t\${GROUP_BY}$" | cut -c-7 | sed -E 's/\s+//g'`
HIST_INDEX=`head -1 $GROUP_FILE | tr '\t' '\n' | cat -n| grep -P "\t\${HIST}$" | cut -c-7 | sed -E 's/\s+//g'`
myfile=`basename $BED`
CATEGORY=${myfile%.*}

if [ ! -d $GROUP_BY ]
then
	mkdir $GROUP_BY
fi

echo
echo
echo "##############################################"
echo "** Overlapping ChIP-Seq peaks grouping by $GROUP_BY"

TMP=`mktemp`

cat $BED | genomic_regions connect | genomic_regions pos -op 5p | genomic_regions shiftp -5p $UP -3p $DOWN > $TMP

echo "####  "$HIST" in "$BED
printf "\t"

for group in `cat ${GROUP_FILE} | cut -f${GROUP_INDEX} | skipn 1 | sort | uniq`
do
	printf $group" "
        peak_files=`cut -f$GROUP_INDEX,$HIST_INDEX $GROUP_FILE | grep -P "^${group}\t" | sort | mergeuniq -merge | cut -f2 | sed -r 's/^\s+//g' | tr ' ,' '\n' | sort | uniq | awk '{print "'${BED_PATH}/'"$0}'`
	if [ ! -d `echo $peak_files | cut -d ' ' -f1` ]
	then
		echo -e ".ID_\t${group}_${HIST}" > $GROUP_BY/${group}_${CATEGORY}_${HIST}.txt
		cat $peak_files | awk '$4>2' | genomic_overlaps overlap -i -label $TMP | replace_with_tab ':' | cut -f4,5 | cols -t 1 0 | sort | mergeuniq -merge | vectors max >> $GROUP_BY/${group}_${CATEGORY}_${HIST}.txt
	fi
	join -t $'\t' -1 1 -2 1 <(cut -f4,10 $BED | sort -k1,1) <(sort -k1,1 ../identify/Max_NofExon_Transcript.txt) | awk '$2==1&&$3==1' | cut -f1 > $GROUP_BY/ALL_${CATEGORY}_MonoExonic.txt
	ln -sf ALL_${CATEGORY}_MonoExonic.txt ${GROUP_BY}/${group}_${CATEGORY}_MonoExonic.txt
done
echo
echo
rm -rf $TMP
