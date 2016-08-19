#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <group_info.txt file path> <GROUP_BY>\n\n"
        exit
fi

TEMP=$(mktemp)

group_info=$1
shift
group_info_base=`basename $group_info`
GROUP_BYs=($@)

group_pattern=`echo ${GROUP_BYs[*]} | sed 's/ /\|/g'`
cat $group_info | cut -f1,`head -1 $group_info | tr '\t' '\n' | cat -n | sed -E 's/^\s+//g' | grep -P "\t${group_pattern}$" | cut -f1 | tr '\n' ',' | sed 's/,$//g'` > $TEMP

Rscript code/general_report.r "../figures/*.pdf" $TEMP

rm -rf $TEMP

