#!/bin/bash

source code/custom-bashrc


if [ "$#" -ne 3 ]; then
        printf "\n\n###### Usage\n\n"
        printf "$0 <PATH to params.bash file> <PATH to group_info.txt file> <GROUP_BY>\n\n"
        exit
fi


PARAMS=$1
source $PARAMS
GROUP_FILE=$2
GROUP_FILE_NAME=`basename $GROUP_FILE | sed 's/\.txt//g'`
GROUP_BY=$3


if [ `cat ${GROUP_BY}.out | wc -l` -eq 1 ]; then exec >> $GROUP_BY.out;else exec > $GROUP_BY.out; fi
exec 2>&1

cd summarize
code/DESeq2.bash $GROUP_FILE $GROUP_BY
ln -s $GROUP_FILE_NAME//fpkm_table.txt
ln -s $GROUP_FILE_NAME//norm_count.txt
code/split_table.bash ../coding_potential/lncRNA.bed lncRNA $GROUP_FILE_NAME//fpkm_table.txt
code/split_table.bash ../coding_potential/mRNA.bed mRNA $GROUP_FILE_NAME//fpkm_table.txt
cd ..

cd fpkm_cutoff
code/group_mean.bash $lncRNA_fpkm_cutoff $GROUP_FILE $GROUP_BY ../summarize/lncRNA_fpkm_table.txt
code/group_mean.bash $mRNA_fpkm_cutoff $GROUP_FILE $GROUP_BY ../summarize/mRNA_fpkm_table.txt
cd ..

cd peak_overlap
for HIST_TSS in `echo $HistoneMarks_TSSsShifts`
do
	code/peak_overlap.bash ../ChIP-Seq/bed/ $GROUP_FILE $GROUP_BY ../coding_potential/lncRNA.bed $HIST_TSS
	code/peak_overlap.bash ../ChIP-Seq/bed/ $GROUP_FILE $GROUP_BY ../coding_potential/mRNA.bed $HIST_TSS
done
cd ..

cd integrate_HistoneCombine
code/integrate_fpkm_peak.bash lncRNA HistoneCombine $GROUP_BY $GROUP_FILE ../fpkm_cutoff ../peak_overlap $HistoneMarks
code/integrate_fpkm_peak.bash mRNA HistoneCombine $GROUP_BY $GROUP_FILE ../fpkm_cutoff ../peak_overlap $HistoneMarks
cd ..

cd pie_matrix_peak
code/make_piematrix_peak.bash lncRNA HistoneCombine $GROUP_BY ../integrate_HistoneCombine/$GROUP_BY/*lncRNA*
code/make_piematrix_peak.bash mRNA HistoneCombine $GROUP_BY ../integrate_HistoneCombine/$GROUP_BY/*mRNA*
cd ..

cd integrate_DE
code/integrate_fpkm_DE.bash lncRNA DE ${GROUP_BY} ../fpkm_cutoff ../summarize/$GROUP_FILE_NAME/
code/integrate_fpkm_DE.bash mRNA DE ${GROUP_BY} ../fpkm_cutoff ../summarize/$GROUP_FILE_NAME/
cd ..

cd pie_matrix_DE
code/make_piematrix_DE.bash lncRNA DE ${GROUP_BY} ../integrate_DE/${GROUP_BY}/*lncRNA*.txt
code/make_piematrix_DE.bash mRNA DE ${GROUP_BY} ../integrate_DE/${GROUP_BY}/*mRNA*.txt
cd ..

cd tracks
code/merge_tracks.bash $GROUP_FILE $GROUP_BY
cd ..

cd report
code/group_report.bash lncRNA lncRNA $GROUP_FILE $GROUP_BY
code/lncRNA_report.bash $GROUP_FILE $GROUP_BY
cd ..

echo "###### Done ######"
