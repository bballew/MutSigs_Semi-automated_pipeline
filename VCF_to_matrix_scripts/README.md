# MutSigsPipeline

It take a really long time to load a large VCF into R and generate a motif matrix.  This automates splitting a VCF file up, loading into R, and generating multiple matrices, which are then added together in R.  The motif matrix has 96 x # samples dimensions (or up to ~200 x samples  if you are also looking at indels or strand  bias), so this is a much smaller representation of the data compared to the original VCF.

# Input reqs:

- Standard format VCF file
- Scripts (in addition to this one)
	- bash_to_call_R.sh
	- mutSigsDataPrep2.r
	- mutSigsSumMatrices.r
	- bash_to_call_SumMatrices.sh
- Config file with variables for use in R scripts (mutSigsConfig.r - customize this)
- Phenotype file with cancer types for your samples

# Pipeline summary:

- VCF is split up in mutSigsMatrixPipeline.sh
- VCF parts are converted from VCFs to matrices in mutSigsDataPrep2.r
- Matrices are read back into R and summed for each cancer type in mutSigsSumMatrices.r

# Output:

- Matrices for each VCF part
- One summed matrix for each cancer type
