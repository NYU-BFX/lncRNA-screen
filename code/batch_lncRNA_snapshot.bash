#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <Num of threads> <lncRNA.bed> <PATH to group_info.txt file>\n\n"
        exit
fi

NSLOTS=$1
BED=$2

total=`cat $BED | wc -l`

Nround=$(($total/$NSLOTS))

Nremain=$(($total%$NSLOTS))

for round in `seq $Nround`
do
	all_elements=""
	for sec_round in `seq $NSLOTS`
	do
		element=$(($round*$NSLOTS-$NSLOTS+$sec_round))
		code/setup_waiting.bash $element
		cat $BED | rows $(($element-1)) > $element.bed
		code/job_submitter.bash 1 code/lncRNA_snapshot.bash ${element}.bed
		all_elements=$all_elements" "$element
	done
	code/wait_jobs.bash $all_elements
done

all_elements=""
for remain in `seq $Nremain`
do
	element=$(($Nround*NSLOTS+$remain))
	code/setup_waiting.bash $element
	cat $BED | rows $(($element-1)) > $element.bed
	code/job_submitter.bash 1 code/lncRNA_snapshot.bash ${element}.bed
	all_elements=$all_elements" "$element
done
code/wait_jobs.bash $all_elements
