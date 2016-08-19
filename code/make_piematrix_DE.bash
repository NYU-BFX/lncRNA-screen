#!/bin/bash

source code/custom-bashrc

if [ "$#" -lt 4 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <CATEGORY> <METHOD> <GROUP_BY> <INTEGRAGED files>\n\n"
        exit
fi

CATEGORY=$1
shift
METHOD=$1
shift
GROUP_BY=$1
shift
INTEGRATED=$@

echo
echo
echo "##############################################"
echo "** Making Pie-matrix for $CATEGORY $METHOD grouping by $GROUP_BY"

TMP1=$(mktemp)
TMP2=$(mktemp)

ls $INTEGRATED | xargs -n 1 wc -l | sed -r 's/^\s+//g' | sed -r 's/\s+/\t/g' | replace_with_tab ''$GROUP_BY'\/' | replace_with_tab '_vs_' | replace_with_tab '_'${CATEGORY}'_'${METHOD}'_' | sed 's/.txt//g' | cut -f1,3- | cols -t 1 2 3 0 | replace_tab ':' | sort -k1,1 > $TMP1

ls $INTEGRATED | xargs -n 1 wc -l | sed -r 's/^\s+//g' | sed -r 's/\s+/\t/g' | replace_with_tab ''$GROUP_BY'\/' | replace_with_tab '_vs_' | replace_with_tab '_'${CATEGORY}'_'${METHOD}'_' | sed 's/.txt//g' | cut -f1,3- | cols -t 1 2 3 0 | replace_tab ':' | sort -k1,1 | cut -f1,3 | sort | mergeuniq -vec -func add -n 0 | sort -k1,1 > $TMP2

join -t $'\t' -1 1 -2 1 $TMP1 $TMP2 | replace_with_tab ':' > ${GROUP_BY}_${CATEGORY}_${METHOD}.txt

rm -rf $TMP1 $TMP2

Rscript code/piematrix.r ${GROUP_BY}_${CATEGORY}_${METHOD}.txt ${GROUP_BY}_${CATEGORY}_${METHOD}

echo
echo
