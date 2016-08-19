#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 5 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <CATEGORY> <METHOD> <GROUP_BY> <FPKM Cutoff Folder> <DE Folder>\n\n"
        exit
fi

CATEGORY=$1
METHOD=$2
GROUP_BY=$3
FPKM_CUTOFF=$4
DE=$5


if [ ! -d $GROUP_BY ]
then
	mkdir $GROUP_BY
fi

echo
echo
echo "##############################################"
echo "** Integrating FPKM cutoff and Differential Expression Analysis result grouping by $GROUP_BY"

for file in `ls ${DE}/${GROUP_BY}/*_DE.txt`
do
	BASE=`basename $file`
	GROUP1=`echo $BASE | replace_with_tab '_vs_' | replace_with_tab '_'$METHOD'' | cut -f1`
	GROUP2=`echo $BASE | replace_with_tab '_vs_' | replace_with_tab '_'$METHOD'' | cut -f2`

	cat $FPKM_CUTOFF/$GROUP_BY/$GROUP1*${CATEGORY}*_Mean_above*.txt > $GROUP_BY/${GROUP1}_vs_${GROUP1}_${CATEGORY}_${METHOD}_Expressed.txt
	cat $FPKM_CUTOFF/$GROUP_BY/$GROUP2*${CATEGORY}*_Mean_above*.txt > $GROUP_BY/${GROUP2}_vs_${GROUP2}_${CATEGORY}_${METHOD}_Expressed.txt

	join -t $'\t' -1 1 -2 1 \
		<(cat $file | awk '$2>0.5&&$3<0.1' | cut -f1 | sort) \
		<(cut -f1 $GROUP_BY/{$GROUP1,$GROUP2}*$CATEGORY*Expressed.txt | sort | uniq) \
	> $GROUP_BY/${GROUP1}_vs_${GROUP2}_${CATEGORY}_${METHOD}_Down.txt
	
	join -t $'\t' -1 1 -2 1 \
                <(cat $file | awk '$2<-0.5&&$3<0.1' | cut -f1 | sort) \
                <(cut -f1 $GROUP_BY/{$GROUP1,$GROUP2}*$CATEGORY*Expressed.txt | sort | uniq) \
        > $GROUP_BY/${GROUP1}_vs_${GROUP2}_${CATEGORY}_${METHOD}_Up.txt

	
	join -t $'\t' -1 1 -2 1 -v2 \
                <(cat $GROUP_BY/${GROUP1}_vs_${GROUP2}_${CATEGORY}_${METHOD}_Up.txt $GROUP_BY/${GROUP1}_vs_${GROUP2}_${CATEGORY}_${METHOD}_Down.txt | sort | uniq) \
                <(cut -f1 $GROUP_BY/{$GROUP1,$GROUP2}*$CATEGORY*Expressed.txt | sort | uniq) \
        | grep -v '.ID_' > $GROUP_BY/${GROUP1}_vs_${GROUP2}_${CATEGORY}_${METHOD}_NotSignificant.txt
	echo "    "$GROUP_BY/${GROUP1}_vs_${GROUP2}_${CATEGORY}
done
echo
echo

