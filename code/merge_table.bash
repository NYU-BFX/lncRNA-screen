#!/bin/bash

source code/custom-bashrc

if [ "$#" -lt 3 ]; then
        printf "\n\n###### Usage\n\n"
        printf "bash run.bash <OUT DIR> <BED File> [--inner-join (the file you want to do inner join)] <INPUT(left join)>\n\n"
        exit
fi


OUT_DIR=$1
shift

BED=$1
shift

if [ ! -f $OUT_DIR/merged.tsv ]; 
then
	# Print header
	echo | awk '{print ".ID_\tLocus\tNum_of_Exons\tGene_Body_Size\tSpliced_Transcript_Size"}' > $OUT_DIR/merged.tsv
	# Print annotation table
	cat $BED | perl -lane '$exonsize=0;$org=$_;@a=split(/\t/,$org);$gene_size=$a[2]-$a[1];@exon=split(/,/,$a[10]);foreach(@exon){$exonsize=$exonsize+$_;};if($a[1]-$gene_size<=0){$left=1}else{$left=$a[1]-$gene_size};$right=$a[2]+$gene_size;print "$a[3]\t$a[0]:$a[1]-$a[2]:$a[5]\t$a[9]\t$gene_size\t$exonsize";' >> $OUT_DIR/merged.tsv
fi

TEMP=`mktemp`

if [ $1 == "--inner-join" ]
then
	shift
	inner_list=$1
	echo $inner_list
	shift
	sort -k1,1 $OUT_DIR/merged.tsv | join -1 1 -2 1 - <(cat $inner_list | sort -k1,1 | uniq) | tr " " "\t" | tr "," "|" | perl -lane '$org=$_;@a=split(/\t/,$org);if($a[0]=~/^.ID_$/){$abs_size=@a;};$count_new=@a;if($abs_size!=$count_new){for($i=1;$i<=($abs_size-$count_new);$i++){$org="$org\t0";}}else{};print $org' > $TEMP
	mv -f $TEMP $OUT_DIR/merged.tsv
	wc -l $OUT_DIR/merged.tsv
	join -t $'\t' -1 4 -2 1 <(sort -k4,4 $BED) <(sort $inner_list | sort -k1,1 | uniq) | cols -t 1 2 3 0 4 5 6 7 8 9 10 11 > $OUT_DIR/lncRNA.bed
else
	cp $BED $OUT_DIR/
fi

INPUT=($@)

for file in ${INPUT[@]}
do
	file=`echo $file | tr ',' ' '`
	sort -k1,1 $OUT_DIR/merged.tsv | join -1 1 -2 1 -a1 - <(cat $file | sort -k1,1 | uniq) | tr " " "\t" | tr "," "|" | perl -lane '$org=$_;@a=split(/\t/,$org);if($a[0]=~/^.ID_$/){$abs_size=@a;};$count_new=@a;if($abs_size!=$count_new){for($i=1;$i<=($abs_size-$count_new);$i++){$org="$org\t0";}}else{};print $org' > $TEMP
	mv -f $TEMP $OUT_DIR/merged.tsv
	echo $file;
done


wc -l $OUT_DIR/merged.tsv
