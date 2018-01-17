#!/bin/bash
#$ -S /bin/bash
#$ -N mut_sigs_MatSum
#$ -q all.q
#$ -V
WD=$1 # working directory
Rscript $WD/mutSigsSumMatrices.r $WD
#Rscript /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/split_vcf/pipeline_test/mutSigsSumMatrices.r
