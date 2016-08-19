#!/bin/bash

source code/custom-bashrc

# run featureCounts


if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]
then
	echo "ERROR! NO ARGUMENT SUPPLIED."
	exit 1
fi

if [[ $1 =~ ^[[:digit:]]{1,2}$ ]];
then
        NSLOTS=$1
        shift
elif [[ $NSLOTS == "" ]]
then
	NSLOTS=6
fi

# input
PARAMS=$1
INPUT_DIR=$2
OUT_DIR=`basename ${INPUT_DIR}`

if [ `cat ${OUT_DIR}.out | wc -l` -eq 1 ]; then exec >> $OUT_DIR.out;else exec > $OUT_DIR.out; fi
exec 2>&1

date

CWD=`pwd`
FLAG=0

ck_tmp=`qstat -j $JOB_ID | grep "tmp_free" | sed 's/ +//g' | cut -d ' ' -f1`

if [ ! -z $ck_tmp ]
then
	cd $TMP
	mkdir featureCounts
	ln -s $CWD/`dirname $PARAMS` .
	ln -s $CWD/code
	cd featureCounts
	ln -s ../code
	mkdir -p `dirname $INPUT_DIR`
	ln -s $CWD/$INPUT_DIR `dirname $INPUT_DIR`
	FLAG=1
else
	TMP=$CWD
fi


echo "#########################"
echo "###### Starting: $OUT_DIR on $HOSTNAME in $TMP"
echo

date


BAM=${INPUT_DIR}/STAR.Aligned.sortedByCoord.out.bam

STRAND=`cat $INPUT_DIR/sequencing_info.txt | rows 0 | awk '{if($0=="unstranded"){print 0}else if($0=="secondstrand"){print 1}else{print 2}}'`
RUN_TYPE_FLAG=`cat $INPUT_DIR/sequencing_info.txt | rows 1 | awk '{print ($1~/single-end/?"":"-p")}'`

#STRAND=`basename $(ls $INPUT_DIR/*.tag | cut -d ' ' -f1) | cut -d'.' -f1 | awk '{if($0=="unstranded"){print 0}else if($0=="secondstrand"){print 1}else{print 2}}'`
#RUN_TYPE_FLAG=`head -8 $INPUT_DIR/remove_duplicates.txt | tail -1 | awk '{print ($3>$4?"":"-p")}'`


#########################


#########################


# exit if output exits already

if [ -s $OUT_DIR/original.txt ]
then
	printf "\n\n SKIP FEATURECOUNTS \n\n"
	exit
fi


#########################


# check inputs and references

if [ ! -d $OUT_DIR ] || [ ! $OUT_DIR ]
then
	mkdir -p $OUT_DIR
fi

if [ ! -s $BAM ] || [ ! $BAM ]
then
	printf "\n\n ERROR! BAM $BAM DOES NOT EXIST \n\n"
	exit 1
fi

if [ ! -s $PARAMS ] || [ ! $PARAMS ]
then
	printf "\n\n ERROR! GTF $PARAMS DOES NOT EXIST \n\n"
	exit 1
fi

if [ ! -s $INPUT_DIR/sequencing_info.txt ] || [ ! $INPUT_DIR/sequencing_info.txt ]
then
        printf "\n\n CAN'T DETERMINE SE/PE or LIBRARY STRAND, Missing sequencing_info.txt\n\n"
        exit 1
fi


#########################



# featureCounts generates temp files in the current directory

# Summarize a single-end read dataset using 5 threads:
# featureCounts -T 5 -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_SE.sam
# Summarize a BAM format dataset:
# featureCounts -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_SE.bam
# Summarize multiple datasets at the same time:
# featureCounts -t exon -g gene_id -a annotation.gtf -o counts.txt library1.bam library2.bam library3.bam
# Perform strand-specific read counting (use '-s 2' if reversely stranded):
# featureCounts -s 1 -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_SE.bam
# Summarize paired-end reads and count fragments (instead of reads):
# featureCounts -p -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_PE.bam
# Summarize multiple paired-end datasets:
# featureCounts -p -t exon -g gene_id -a annotation.gtf -o counts.txt library1.bam library2.bam library3.bam
# Count the fragments that have fragment length between 50bp and 600bp only:
# featureCounts -p -P -d 50 -D 600 -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_PE.bam
# Count those fragments that have both ends mapped only:
# featureCounts -p -B -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_PE.bam
# Exclude chimeric fragments from fragment counting:
# featureCounts -p -C -t exon -g gene_id -a annotation.gtf -o counts.txt mapping_results_PE.bam

featureCounts_path=`which featureCounts`

CMD="
cd $OUT_DIR/;
$featureCounts_path \
-T $NSLOTS \
$RUN_TYPE_FLAG \
-g gene_id \
-s $STRAND \
-a ../$PARAMS \
-o featureCounts.txt \
../$BAM;
cd ../;
"
printf "\n\n#!/bin/bash\n\n" > $OUT_DIR/run.bash
printf "\n\n $CMD \n\n" >> $OUT_DIR/run.bash
eval $CMD

CMD="echo -e \"Gene\t${OUT_DIR}\" > $OUT_DIR/counts.txt;cat $OUT_DIR/featureCounts.txt | grep -v '#' | grep -v 'Geneid' | cut -f 1,7 >> $OUT_DIR/counts.txt"
printf "\n\n $CMD \n\n" >> $OUT_DIR/run.bash
eval $CMD

#########################


# check that output generated

if [ ! -s $OUT_DIR/featureCounts.txt ] || [ ! $OUT_DIR/featureCounts.txt ]
then
	printf "\n\n ERROR! COUNTS $OUT_DIR/featureCounts.txt NOT GENERATED \n\n"
	exit 1
fi

date


if [ $FLAG -eq 1 ]; then rsync -rl $OUT_DIR $CWD/; fi

echo "###### Done ######"

# end
