#!/bin/bash

source code/custom-bashrc

if [ "$#" -ne 7 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <class_code> <Minimal Length> <Extend TSS ?bp> <reference BED file> <reference GTF file> <Excluding Regions BED file> <merged_gtf path>\n\n"
        exit
fi

class_code=$1
min_length=$2
extend_TSS=$3
ref_annot_bed=$4
ref_annot_gtf=$5
excluding_region=$6
merged_gtf=$7


join -1 1 -2 1 -v1 \
	<(cat $merged_gtf | genomic_regions reg | awk -F '"|\t' '{for(i=1;i<NF;i++){if($i~/gene_id /){break}}print $(i+1)}' | sort | uniq) \
	<(cat $merged_gtf | grep "class_code \"[^$class_code]" | genomic_regions reg | awk -F '"|\t' '{for(i=1;i<NF;i++){if($i~/gene_id /){break}}print $(i+1)}' | sort | uniq) \
| grep -F -f - -w $merged_gtf > 1_novel.gtf

cat 1_novel.gtf | genomic_regions reg | awk -F '\t|gene_id "|"; transcript_id "|"; exon_number' '{print $2"\t"$5}' | sort | mergeuniq -merge | genomic_regions split --by-chrstrand | genomic_regions union | genomic_regions bed > 1_novel.bed

cat 1_novel.bed | perl -F/\\t/ -lane '$sum=0;$org=$_;@size=split(/\,/,$F[10]);foreach(@size){$sum+=$_};if($sum>'$min_length'){print $org}' > 2_long200.bed

TMP=$(mktemp)

cat $ref_annot_bed | genomic_regions connect | genomic_regions pos -op 5p | genomic_regions shiftp -5p -${extend_TSS} > $TMP

cat 2_long200.bed | genomic_overlaps subset -inv -gaps $TMP > 3_noTSS.bed

rm -rf $TMP

cat 3_noTSS.bed | genomic_overlaps subset -inv -gaps $excluding_region > 4_novel_nc.bed

bedToGenePred 4_novel_nc.bed stdout | genePredToGtf file stdin 4_novel_nc.gtf

echo -e ".ID_\tMax_NofExon_Transcript" > Max_NofExon_Transcript.txt
cat 1_novel.gtf | awk '$3~/exon/' | perl -F/\\t/ -lane '@des=split(/ \"|\";\s{0,1}/,$F[8]);for($i=0;$i<@des;$i=$i+2){if($des[$i]=~/gene_id/){$gene_id=$des[$i+1]}elsif($des[$i]=~/exon_number/){$exon_number=$des[$i+1]}else{}}print "$gene_id:$exon_number"'  | sort | uniq -c | sed -r 's/^\s+//g' | tr ' :' '\t' | cut -f1,2 | cols -t 1 0 | sort | mergeuniq -merge | vectors max -n 0 | sed 's/ //g' >> Max_NofExon_Transcript.txt

join -t $'\t' -1 1 -2 1 <(cat $ref_annot_gtf | awk '$3~/exon/' | perl -F/\\t/ -lane '@des=split(/ \"|\";\s{0,1}/,$F[8]);for($i=0;$i<@des;$i=$i+2){if($des[$i]=~/gene_id/){$gene_id=$des[$i+1]}elsif($des[$i]=~/exon_id/){$exon_id=$des[$i+1]}else{}}print "$gene_id:$exon_id"' | sort | uniq -c | sed -r 's/^\s+//g' | tr ' :' '\t' | cut -f1,2 | cols -t 1 0 | sort | mergeuniq -merge | vectors max -n 0 | sed 's/ //g') <(sort -k1,1 ${ref_annot_gtf%.*}.id2name.txt) | cut -f2,3 | cols -t 1 0 >> Max_NofExon_Transcript.txt

sort -k1,1 Max_NofExon_Transcript.txt > $TMP
mv $TMP Max_NofExon_Transcript.txt

rm -rf $TMP
