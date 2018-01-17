#!/bin/bash
#$ -S /bin/bash
#$ -N mut_sigs_prep
#$ -q all.q
#$ -V
F=$1 # name of input file
WD=$2 # working directory
Rscript $WD/mutSigsDataPrep2.r $F $WD
#Rscript /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/split_vcf/pipeline_test/mutSigsDataPrep2.r $F $WD
