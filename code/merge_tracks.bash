#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <PATH to group_info.txt file> <GROUP_BY>\n\n"
        exit
fi

GROUP_FILE=$1
GROUP_BY=$2

GROUP_INDEX=`head -1 $GROUP_FILE | tr '\t' '\n' | cat -n| grep -P "\t\${GROUP_BY}$" | cut -c-7 | sed -E 's/\s+//g'`

if [ ! -d $GROUP_BY ]
then
        mkdir -p $GROUP_BY
fi

echo
echo
echo "##############################################"
echo "** Merging Tracks grouping by $GROUP_BY"

for sample in `cat ${GROUP_FILE} | cut -f${GROUP_INDEX} | skipn 1 | sort | uniq`
do
	echo
	echo
	echo "################ $sample "
	SAMPLES=`cat $GROUP_FILE | cut -f1,$GROUP_INDEX | grep -P "\t$sample$" | grep -v "^#" | awk '{print "../RNA-Seq/pipeline/alignment/"$1"/"$1".bw"}' | tr '\n' ' '`

	code/track_merge_convert ../referenceFiles/chromInfo.txt $GROUP_BY $sample ${SAMPLES[*]}
done

echo
echo
