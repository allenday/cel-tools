#!/usr/local/bin/Rscript
library('getopt')

#one time
#https://www.bioconductor.org/install/
#source("https://bioconductor.org/biocLite.R")
#biocLite()
#biocLite('frma')

#one time, but specific to each GEO platform. In this case, we
#pull down the models for platform "hgu133plus2"
#biocLite(paste(my.platform, "frmavecs", sep = ""))
#biocLite(paste(my.platform, "cdf", sep = ""))

spec = matrix(c(
  'help',   'h', 0,  'logical',
  'input',  'i', 1, 'character',
  'output', 'o', 1, 'character'
), byrow=TRUE, ncol=4);
opt = getopt(spec);

if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}

if ( is.null(opt$input) | is.null(opt$output) ) {
  cat("input and output files must be specified\n");
  q(status=1);
}

if ( file.access(opt$input,4) != 0 ) {
  cat("can't read from input file:",opt$input,"\n");
  q(status=1);
}

if (
  #file exists, can't write
  ( file.exists(opt$output) & file.access(opt$output,2) != 0 )
  |
  #can't write to containing directory
  ( file.access(dirname(opt$output),2) != 0 )
) {
  cat("can't write to output file:",opt$output,"\n");
  q(status=1);
}

set.seed(123)
suppressMessages(library('affy'))
suppressMessages(library('frma'))

#process CEL file
my.cel = ReadAffy(filenames=opt$input)
my.platform = annotation(my.cel)

#biocLite(paste(my.platform, "frmavecs", sep = ""))
#biocLite(paste(my.platform, "cdf", sep = ""))

my.frma = frma(my.cel)
my.exprs = exprs(my.frma)

#sanity check
#cbind(my.exprs[1:5,])
#              [,1]
#1007_s_at 7.207965
#1053_at   5.603574
#117_at    8.290412
#121_at    8.965976
#1255_g_at 3.396127

#qualify vector indexes with platform name, as they are not globally unique
rownames(my.exprs) = paste(my.platform,":",rownames(my.exprs),sep="")
write.csv(my.exprs,opt$output)
