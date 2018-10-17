#!/DCEG/Resources/Tools/R/R-3.3.0/R-3.3.0/bin/Rscript

# run script with trailing argument for input file
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=2) {
  stop("Exactly two arguments must be supplied (in path, out path).", call.=FALSE)
}

inPath = args[1]
outPath = args[2]

# set up environment
setwd(inPath)
source("mutSigsConfig.r") # to get groups list

sumOverGroups <- function(group, outPath) {
    file_list <- list.files(pattern=paste(group, "_mm_*", sep=""))  # list all matrices with the right group in the file name
    matrix_list <- lapply(file_list, readInMatrix)  # read in the matrices listed above
    summed_matrix <- Reduce("+", matrix_list)  # add the matrices read in above
    summed_matrix <- summed_matrix[, colSums(abs(summed_matrix)) != 0]  # remove columns in which all rows sum to zero (instead of doing droplevels on subsetted vcf data, which can lead to discordantly-sized matrices)
    write.table(summed_matrix, file=paste(outPath, group, "_mm_summed", sep=""), row.names=TRUE, col.names=TRUE)
}

readInMatrix <- function(f) {
    as.matrix(read.table(f, header = TRUE, sep = " ", row.names = 1, as.is = TRUE))
}

lapply(groups, sumOverGroups, outPath)  # for each group, do the stuff in the sumOverGroups function
