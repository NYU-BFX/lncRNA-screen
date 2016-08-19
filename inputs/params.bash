
##################
# Global parameters

groups="By_CellType By_Tissue"
ref_annot_gtf="../referenceFiles/gencode.v19.annotation.gtf"
ref_annot_bed="../referenceFiles/gencode.v19.annotation.bed"
ref_annot_name="gencode.v19.annotation"
protein_coding_bed="../referenceFiles/gencode.v19.protein_coding_RNAs.bed"
protein_coding_name="gencode-mRNA"
annot_lnc_bed="../referenceFiles/gencode.v19.long_noncoding_RNAs.bed"
annot_lnc_name="gencode-lncRNA"

##################
# 2. cuffmerge
#    cuffmerge options in double quote
cuffmerge="-p 30 -g $ref_annot_gtf -o ./"


##################
# 3. lnc_identify
#    <class_code> <Minimal Length> <Extend TSS ?bp> <mRNA BED file>
class_code="iusx"
min_length="200"
extend_TSS="1500"
ref_annot_bed=$protein_coding_bed

##################
# 4. whole_assembly
#    <the reference annotation file you want to use (including coding gene and annnotated lncRNA)>
ref_annot_gtf=$ref_annot_gtf

##################
# 5. coding_potential
#    <genome.fa> <CPAT_logitModel.RData> <CPAT_Hexamer.tsv> <CPAT_cutoff.txt>
genome_fa="../referenceFiles/genome.fa"
CPAT_logitModel="../referenceFiles/CPAT_Reference/Human_logitModel.RData"
CPAT_Hexamer="../referenceFiles/CPAT_Reference/Human_Hexamer.tsv"
CPAT_cutoff="../referenceFiles/CPAT_Reference/Human_cutoff.txt"

##################
# 5. featureCounts
#    none

##################
# 6. annotate
#    <all annotation bed files in double quote>
other_annotations="../referenceFiles/RefSeqRefFlat.bed ../referenceFiles/Homo_sapiens.GRCh37.79.bed"

##################
# 6. summarize + split_table
#    none

##################
# 7. fpkm_cutoff
#    <fpkm_cutoff>
lncRNA_fpkm_cutoff=0.5
mRNA_fpkm_cutoff=2

##################
# 7. peak_overlap
#    <(HistonMark):(TSS Upstream Shift Dist):(TSS Downstream Shift Dist)>
#    Use single space to seperate different histone marks, put them all in double quote
HistoneMarks_TSSsShifts="H3K4me3:-2500:2500 H3K4me1:-2500:2500 H3K27ac:-2500:2500"

##################
# 8. integrate_HistoneCombine
#    <HistonMarks seperated by space and all in double quote>
HistoneMarks="H3K4me3 H3K4me1 H3K27ac"

##################
# 8. integrate_DE
#    none

##################
# 9. pie_matrix_peak
#    none

##################
# 9. pie_matrix_DE
#    none

##################
# 10. pie_matrix_DE
#    <Genome(eg: hg19/mm9)> <Reference GTF> <merged track files wild card in double quote>
GENOME="hg19"
Ref_GTF="../referenceFiles/RefSeqRefFlat.gtf"
bigwig_files="../tracks/By_CellType/*.bw"
lncRNA_BED="../coding_potential/lncRNA.bed"
