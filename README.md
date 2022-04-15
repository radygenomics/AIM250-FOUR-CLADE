
Simple instructions for setting up:

1. Use R version >= 3.5.1, >= 3.6.3 recommended
   	might need system libgfortran.so libs and other R core prerequisites
   library(vcfR)
   library(ggplot2)
   library(missMDA)
   library(ade4)
   library(reshape)
   library(dplyr)
   library(ggtern)
   library(doParallel)
   library(SNPlocs.Hsapiens.dbSNP.20120608)
   structure binary >=2.3.4 : get console binary from
	https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html
	https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/release/structure_linux_console.tar.gz
      	set in its "mainparams" file:     #define USEPOPINFO  1 

2. R source is patched in multiple places
   1000G_1652_PopCode.txt file is prepared (was not included in UT-AIM250) from 1000G ftp sources
   Appropriate AMR 1000G reference sets are added and retrained (many were more EUR than AMR, especially all PUR samples), some of the larger cohorts are downsampled
   Total number of reference samples is now 899

3. There is a script to prepare genotype digests from (e.g. DRAGEN-produced) hard-filtered.vcf[.gz] files
   it is in scripts/_prepare_GT_vcf.pl
   output is $file.GT.vcf.gz (need to be bgzipped and tabix'd)
   Then use 
   vcf-merge [a lot of *.GT.vcf.gz] > input.vcf
   and prepare all sample names one per line in
   "sampleNames.txt"
   Prerequisites: bgzip tabix vcf-merge

4. Then run
   R
   source("Admixture_Functions_fourclade.r")
   source("RunAIM250four.r")
   RunAdmixture(sampleVCF="input.vcf",sampleNames="sampleNames.txt")
 
