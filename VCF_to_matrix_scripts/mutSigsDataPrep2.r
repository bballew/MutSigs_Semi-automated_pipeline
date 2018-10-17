#!/DCEG/Resources/Tools/R/R-3.3.0/R-3.3.0/bin/Rscript

# run script with trailing argument for input file
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=2) {
  stop("Exactly two arguments must be supplied (input file, output path).", call.=FALSE)
}

# input parameters
inFile = args[1]
myPath = args[2]

# set up environment
library(tools)
library(SomaticSignatures)
setwd(myPath)

source("mutSigsConfig.r") # config file with:
	# myRef
	# phenoFile
	# subjectCol
	# phenoCol
	# groups

if (myRef == "hg19") {
	library(BSgenome.Hsapiens.UCSC.hg19)
} else if (myRef == "hs37d5") {
	library(BSgenome.Hsapiens.1000genomes.hs37d5) 
}

# function to retrieve motifs, convert to matrix, and export matrix
buildMotifMatrix <- function(groupName, vr_filtered, inFile, myRef) {
	print(paste(groupName, "_mm_", file_path_sans_ext(basename(inFile)), sep=""))
	vr_group <- vr_filtered[which(vr_filtered$cancerType==groupName)]								# separate into groups
	#sampleNames(vr_group) <- droplevels(sampleNames(vr_group))										# remove subjects that have no data in the group subset
		# note that if there's no data for a sample but the sample IS in the group, this may cause inconsistencies when adding matrices over a group
	if (myRef == "hg19") {
		group_motifs <- mutationContext(vr_group, BSgenome.Hsapiens.UCSC.hg19)						# retrieve somatic motifs from the reference sequence
	} else if (myRef == "hs37d5") {
		group_motifs <- mutationContext(vr_group, BSgenome.Hsapiens.1000genomes.hs37d5)
	}
	group_mm <- motifMatrix(group_motifs, normalize = FALSE)										# convert to matrix representation
	write.table(group_mm, file=paste(groupName, "_mm_", file_path_sans_ext(basename(inFile)), sep=""), row.names=TRUE, col.names=TRUE)	# export matrices for use in next steps
}

# use ScanVcfParam to define only one (or a few) INFO field(s) to import, to limit file size and memory requirement
print("scanning")
svp <- ScanVcfParam(info="DB")
vr <- readVcfAsVRanges(inFile, myRef, param = svp)

# remove any weird contigs
print("removing contigs")
vr <- keepStandardChromosomes(vr)

# remove all "." and homozygous ref genotypes from your VRanges object
print("removing ref gts")
vr_filtered <- vr[which(vr$GT!=".")]
vr_filtered <- vr_filtered[which(vr_filtered$GT!="0/0")]

# import phenotype (cancer type) data
print("importing pheno")
pheno <- read.table(phenoFile, header = TRUE)

# slice dataframe to get just the data of interest
cancerTypes <- pheno[c(subjectCol,phenoCol)]
names(cancerTypes) <- c("subjects", "cancerType")

# add the sample names to the metadata, so they're accessible inside that dataframe to merge on
mcols(vr_filtered)$subjects = sampleNames(vr_filtered)

# merge the metadata dataframe with the cancer types dataframe and assign back to the VRanges metadata dataframe
mcols(vr_filtered) <- merge(mcols(vr_filtered), cancerTypes, by = "subjects")

# # get unique listing of phenotype groups - no, get from config file so it can be reused in next r script
# groups <- unique(cancerTypes["cancerType"])

# loop over entries in "groups" list for each of the steps in the buildMotifMatrix function
print("lapplying")
lapply(groups, buildMotifMatrix, vr_filtered, inFile, myRef)
