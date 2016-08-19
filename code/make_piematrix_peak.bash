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
INPUT=($@)

#while true; do
    echo
    echo
    echo "##############################################"
    echo "** Making Pie-Matrix for $CATEGORY $METHOD grouping by $GROUP_BY"
    echo
    echo "   Please categorize each histone mark enrichment combination situation into a short name for display in the pie-matrix in the second column of the next file, then save this file. [TAB] is the delimiter."
    echo "     Example:"
    echo
    echo "H3K27ac:-_H3K4me1:-_H3K4me3:+_MonoExonic:-	lncRNA"
    echo "H3K27ac:-_H3K4me1:+_H3K4me3:-_MonoExonic:+	eRNA"
    echo
#    read -p "Are you clear? [Y/N]" yn
#    case $yn in
#        [Yy]* ) if [ ! -f ${CATEGORY}_regroup.txt ]
#                then
#                        cat ${INPUT[*]} | grep -v ".ID_" | cut -f2 | sort | uniq > ${CATEGORY}_regroup.txt
#		else
#			join -t $'\t' -1 1 -2 1 -a1 -a2 <(cat ${INPUT[*]} | grep -v ".ID_" | cut -f2 | sort | uniq) <(sort -k1,1 ${CATEGORY}_regroup.txt) > x
#			mv x ${CATEGORY}_regroup.txt
#                fi
#                vim ${CATEGORY}_regroup.txt; break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer [Y] or [N].";;
#    esac
#done

regroup=${CATEGORY}_regroup.txt

mkdir -p $GROUP_BY

for file in ${INPUT[@]}
do
	temp=`mktemp`
	grep ".ID_" $file > $temp
	while read line; do
		old=`echo $line | cut -d' ' -f1`
		new=`echo $line | cut -d' ' -f2`
		cat $file | grep "$old" | sed "s/$old/$new/g" >> $temp

	done < $regroup
	sort -k1,1 $temp > $GROUP_BY/`basename $file`
	rm -rf $temp
done

tmp1=$(mktemp)
tmp2=$(mktemp)
tmp3=$(mktemp)
tmp4=$(mktemp)
tmp5=$(mktemp)
tmp6=$(mktemp)
grep -v '.ID_' `ls $GROUP_BY/*_${CATEGORY}_${METHOD}*` | replace_with_tab ':' | cut -f1,3 | sort | uniq | replace_with_tab ''$GROUP_BY'\/' | replace_with_tab '_'${CATEGORY}'_'${METHOD}'.txt' | cut -f2,4 | tr '\t' ':' | tr '\n' ' ' | perl -lane 'for($i=0;$i<@F;$i++){for($j=0;$j<@F;$j++){print "$F[$i] $F[$j]"}}' | words -sort -u | sort | uniq | sed 's/ $//g' | perl -F/\\s/ -lane '@x1=split(/:/,$F[0]);@x2=split(/:/,$F[1]);if($x2[0]=~$x1[0]){}else{print $_}' > $tmp1

grep -v '.ID_' `ls $GROUP_BY/*_${CATEGORY}_${METHOD}*` | replace_with_tab ':' | replace_with_tab ''$GROUP_BY'\/' | replace_with_tab '_'${CATEGORY}''_${METHOD}'.txt' | cut -f2,4,5 | cols -t 1 0 2 | sort | sed -r 's/\t/:/2' | mergeuniq -merge | words -sort > $tmp2

cat $tmp1 | perl -F/\\s/ -lane '@x1=split(/:/,$F[0]);@x2=split(/:/,$F[1]);if($x2[0]=~$x1[0]){}else{print $_}' | perl -F/\\s/ -lane 'if($F[1]=~/^$/){$F[1]=$F[0]};printf "$F[0] $F[1]\t";system "echo $F[0] | grep -F -f - -w '"$tmp2"' > '"$tmp3"';echo $F[1] | grep -F -f - -w '"$tmp3"' | wc -l"' | perl -F/\\s/ -lane '$F[0]=~s/:/\t/;$F[1]=~s/:/\t/;print "$F[0]\t$F[1]\t$F[2]"' | cols -t 0 2 1 3 4 | sort -k1,4 | cols -t 0 1 4 2 3 | tr '\t' ' ' | sed 's/ /:/' | sed 's/ /:/' | replace_with_tab ' ' | words -sort -u | replace_with_tab ' ' | awk '{print $3!~/^$/?$1"\tMixed":$0}' | replace_tab ':' | sed 's/:/ /1' | sed 's/:/\t/1' | cols -t 1 0  | words -sort | sed -r 's/\s$//g' | replace_with_tab ':' | tr ' ' '\t' | cols -t 2 3 1 0 | replace_tab ':' | replace_tab ':' | sort -k1,1 | mergeuniq -vec -func add -n 0 | sed 's/:/\t/2' > $tmp5

cat $tmp1 | perl -F/\\s/ -lane '@x1=split(/:/,$F[0]);@x2=split(/:/,$F[1]);if($x2[0]=~$x1[0]){}else{print $_}' | perl -F/\\s/ -lane 'if($F[1]=~/^$/){$F[1]=$F[0]};printf "$F[0] $F[1]\t";system "echo $F[0] | grep -F -f - -w '"$tmp2"' > '"$tmp4"';echo $F[1] | grep -F -f - -w '"$tmp4"' | wc -l"' | perl -F/\\s/ -lane '$F[0]=~s/:/\t/;$F[1]=~s/:/\t/;print "$F[0]\t$F[1]\t$F[2]"' | cut -f1,3,5 | replace_tab ' ' | cols -t 1 0 | words -sort | sed -r 's/\s$//g' | cols -t 1 0 | tr ' ' ':' | sort | mergeuniq -vec -func add -n 0 | sed -r 's/\s$//g' > $tmp6


temp=`mktemp`
join -t $'\t' -1 1 -2 1 <(sort -k1,1 $tmp5) <(sort -k1,1 $tmp6) | replace_with_tab ':' > $temp 

cat $temp | awk '$1!=$2{print $2"\t"$1"\tIntersect\t"$5"\t"$5}' | sort | uniq >> $temp

cat $temp | awk '{if(length($1)>10)print substr($1,1,20)"\t"$2"\t"$3"\t"$4"\t"$5;else print $0}' | awk '{if(length($2)>10)print $1"\t"substr($2,1,20)"\t"$3"\t"$4"\t"$5;else print $0}' > ${GROUP_BY}_${CATEGORY}_${METHOD}.txt

rm -rf $temp
rm -rf $tmp1 $tmp2 $tmp3 $tmp4 $tmp5 $tmp6

#rm -rf x y a b z

Rscript code/piematrix.r ${GROUP_BY}_${CATEGORY}_${METHOD}.txt ${GROUP_BY}_${CATEGORY}_${METHOD}
