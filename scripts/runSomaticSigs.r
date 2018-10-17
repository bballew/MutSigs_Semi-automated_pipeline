#!/DCEG/Resources/Tools/R/R-3.3.0/R-3.3.0/bin/Rscript

# run script with trailing argument for input file
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=4) {
  stop("Exactly four arguments must be supplied (# sigs, group name, input file, output basename with path).", call.=FALSE)
}

# input parameters
numSigs = as.integer(args[1])
group = args[2]
inFile = args[3]
outBase = args[4]

library(ggplot2)
library(SomaticSignatures)
library(ggdendro)

mm <- as.matrix(read.table(inFile, header = TRUE, sep = " ", row.names = 1, as.is = TRUE))
nmf <- identifySignatures(mm, numSigs, nmfDecomposition)
write.table(signatures(nmf), file=paste(outBase, "_sigs.txt", sep=""), row.names=TRUE, col.names=TRUE)
write.table(samples(nmf), file=paste(outBase, "_samples.txt", sep=""), row.names=TRUE, col.names=TRUE)

plotSignatures(nmf, normalize = TRUE) + ggtitle(paste(group, numSigs, "Signatures by NMF", sep=" "))
ggsave(filename=paste(outBase, "_sigs.png", sep=""), dpi=300)

plotSamples(nmf) #+ geom_bar()
ggsave(filename=paste(outBase, "_sigs_by_sample.png", sep=""), width=20, dpi=300)

clu = clusterSpectrum(mm, "motif")
ggdendrogram(clu, rotate = TRUE)
ggsave(filename=paste(outBase, "_cluster.png", sep=""), dpi=300)

# png(filename=paste(outBase, "_sigs.png", sep=""), width=400, height=600, res=300)
# 	plotSignatures(nmf, normalize = TRUE) + ggtitle(paste(group, numSigs, "Signatures by NMF", sep=" "))
# dev.off()

# png(filename=paste(outBase, "_sigs_by_sample.png", sep=""), width=400, height=600, res=300)
# 	plotSamples(nmf) 
# dev.off()