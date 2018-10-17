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
library(ggplot2)
library(tools)

# load motif matrix into R
mm <- as.matrix(read.table(inFile, header = TRUE, sep = " ", row.names = 1, as.is = TRUE))
dim(mm)  # sanity check
test_sigs <- 2:15  # consider making this a user-defined variable
# note that if test_sigs starts at 1, the nmf version will error out!
test_nmf = assessNumberSignatures(mm, test_sigs, nReplicates = 5) 
plotNumberSignatures(test_nmf)
ggsave(filename=outFile, dpi=300)
