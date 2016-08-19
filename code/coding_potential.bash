#!/bin/bash

if [ "$#" -ne 1 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <BED file>\n\n"
        exit
fi

BED=$1

grep "no$" result.txt | cut -f2 | grep -F -f - -w $BED > lncRNA.bed


head -1 result.txt | cut -f2,4,7 | tr ' ' '_' | sed 's/Sequence_Name/_ID_/' > for_table.txt

tail -n+2 result.txt | cut -f2,4,7 | replace_tab 'XXXX' | matrix format -n 4 | replace_with_tab 'XXXX' >> for_table.txt
