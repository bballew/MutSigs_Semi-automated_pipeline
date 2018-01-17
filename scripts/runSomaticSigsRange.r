#!/DCEG/Resources/Tools/R/R-3.3.0/R-3.3.0/bin/Rscript

# run script with trailing argument for input file
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=2) {
  stop("Exactly two arguments must be supplied (input file, output path).", call.=FALSE)
}

# input parameters
inFile = args[1]
outFile = args[2]
# myPath = args[2]

#setwd(myPath)
library(SomaticSignatures)
library(tools)

# load motif matrix into R
mm <- as.matrix(read.table(inFile, header = TRUE, sep = " ", row.names = 1, as.is = TRUE))
dim(mm)  # sanity check
test_sigs <- 1:15  # consider making this a user-defined variable
#test_nmf = assessNumberSignatures(mm, test_sigs, nReplicates = 5) 
test_pca <- assessNumberSignatures(mm, test_sigs, pcaDecomposition)
# png(paste(file_path_sans_ext(basename(inFile)), "_nmf_scree.png", sep="")
# 	plotNumberSignatures(test_nmf)
# dev.off()
png(outFile)
# png(paste(file_path_sans_ext(basename(inFile)), "_pca_scree.png", sep="")
	plotNumberSignatures(test_pca)
dev.off()

