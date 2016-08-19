#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 3 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <params.bash path> <BED file> <CATEGORY Name>\n\n"
        exit
fi

PARAMS=$1
shift
source $PARAMS

BED=$1
category=$2
tmp=`mktemp`

echo "running CPAT..."
cpat.py -r $genome_fa -g $BED -d $CPAT_logitModel -x $CPAT_Hexamer -o ${category}_result.txt

echo "formatting result..."
cat <(printf ".ID_\t") ${category}_result.txt > $tmp

cutoff=`cat $CPAT_cutoff | grep "Coding Probability Cutoff" | cut -d ' ' -f4`

cat $tmp | awk -v C=$cutoff '{if($6<C){print $0"\tno"}else if($6=="coding_prob"){print $0"\tCoding_label"}else{print $0"\tyes"}}' > ${category}_result.txt
rm -rf ${category}_result.txt.dat ${category}_result.txt.r $tmp

if [[ $category == *"mRNA"* ]]
then
	join -t $'\t' -1 1 -2 4 <(grep "yes$" ${category}_result.txt | cut -f1 | sort) <(sort -k4,4 $BED) | cols -t 1 2 3 0 4 5 6 7 8 9 10 11 > ${category}.bed
	ln -s $BED mRNA.bed
else
	join -t $'\t' -1 1 -2 4 <(grep "no$" ${category}_result.txt | cut -f1 | sort) <(sort -k4,4 $BED) | cols -t 1 2 3 0 4 5 6 7 8 9 10 11 > ${category}.bed
fi

head -1 ${category}_result.txt | cut -f1,3,6 > ${category}_for_table.txt

tail -n+2 ${category}_result.txt | cut -f1,3,6 | replace_tab '|' | matrix format -n 4 | replace_with_tab '|' >> ${category}_for_table.txt

echo "DONE!"
