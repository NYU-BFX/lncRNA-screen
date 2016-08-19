#!/bin/bash

source code/custom-bashrc


if [ "$#" -ne 2 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <PATH to params.bash file> <PATH to group_info.txt file>\n\n"
        exit
fi

PARAMS=$1
GROUP_FILE=$2

source $PARAMS

cd pipeline

#cd cuffmerge
#cut -f1 $GROUP_FILE | skipn 1 | grep -v "^#" | awk '{print "../RNA-Seq/pipeline/cufflinks/"$1}' | xargs code/run_cuffmerge "$cuffmerge"

#code/setup_waiting.bash cuffmerge
#code/job_submitter.bash bash run.bash
#code/wait_jobs.bash cuffmerge
#cd ..

#cd identify
#code/identify.bash $class_code $min_length $extend_TSS $ref_annot_bed $ref_annot_gtf ../cuffmerge/merged.gtf
#cd ..

#cd whole_assembly
#code/whole_assembly.bash $ref_annot_gtf ../identify/4_novel_nc.gtf
#cd ..

#cd coding_potential
#code/run_cpat.bash $PARAMS ../identify/4_novel_nc.bed novel-lncRNA
#code/run_cpat.bash $PARAMS $protein_coding_bed $protein_coding_name
#code/run_cpat.bash $PARAMS $annot_lnc_bed $annot_lnc_name
#cat $annot_lnc_bed novel-lncRNA.bed | sortbed > lncRNA.bed
#cat ${annot_lnc_name}_for_table.txt novel-lncRNA_for_table.txt | sort -k1,1 | uniq > lncRNA_for_table.txt
#ln -sf ${protein_coding_name}_for_table.txt mRNA_for_table.txt
#cd ..

#cd featureCounts
#cut -f1 $GROUP_FILE | skipn 1 | grep -v "^#" | xargs code/setup_waiting.bash
#cut -f1 $GROUP_FILE | skipn 1 | grep -v "^#" | xargs -n1 -I {} code/job_submitter.bash 8 code/run_featureCounts.bash ../whole_assembly/all.gtf ../RNA-Seq/pipeline/alignment/{}
#cut -f1 $GROUP_FILE | skipn 1 | grep -v "^#" | xargs code/wait_jobs.bash

#code/summarize_raw_count */counts.txt > raw_count.txt
#cd ..

#cd annotate
#code/annotate_lncRNA.bash ../coding_potential/lncRNA.bed $other_annotations
#cd ..


group_pattern=`echo ${groups[*]} | sed 's/ /\|/g'`
GROUP_BYs=`head -1 $GROUP_FILE | tr '\t' '\n' | grep -P "^\${group_pattern}$"`
GROUP_FILE_NAME=`basename $GROUP_FILE | sed 's/\.txt//g'`
code/setup_waiting.bash ${GROUP_BYs[*]}
echo ${GROUP_BYs[*]} | xargs -n1 code/job_submitter.bash 1 code/by-group.bash $PARAMS $GROUP_FILE
code/wait_jobs.bash ${GROUP_BYs[*]}

cd figures
code/generate_figures.bash $GROUP_FILE
cd ..

cd report
code/general_report.bash $GROUP_FILE "${GROUP_BYs[*]}"
cd ..

cd ..
