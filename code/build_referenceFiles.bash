#!/bin/bash

source code/custom-bashrc

cd referenceFiles
rm gencode.v19.annotation.id2name.txt
gtf_id2name gencode.v19.annotation.gtf

rm gencode.v19.annotation.id2name.bed
gtf_2bed gencode.v19.annotation.gtf gencode.v19.annotation.id2name.txt

rm gencode.v19.protein_coding_RNAs.bed
cat gencode.v19.annotation.gtf | grep "gene_type \"protein_coding\"" | grep "transcript_status \"KNOWN\"" > gencode.v19.protein_coding_RNAs.gtf
gtf_2bed gencode.v19.protein_coding_RNAs.gtf gencode.v19.annotation.id2name.txt

wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_19/gencode.v19.long_noncoding_RNAs.gtf.gz

rm gencode.v19.long_noncoding_RNAs.gtf
gunzip gencode.v19.long_noncoding_RNAs.gtf

rm gencode.v19.long_noncoding_RNAs.bed
gtf_2bed gencode.v19.long_noncoding_RNAs.gtf gencode.v19.annotation.id2name.txt

cd ..
