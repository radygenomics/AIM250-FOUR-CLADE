RunAdmixture <- function(sampleVCF,sampleNames,
                         ref.genome = c("GRCh38","GRCh37"), temp="/set/your/temp/path/",  
                         PopCode_data = "1000G_899_PopCode.txt", Str_Path="/path/to/STRUCTURE/console", 
                         AIM250_pos = TRUE, chr.label = FALSE)
{
  setwd("/set/your/work/path/")
  ##Requirement tools
  #1.VCFtools version 0.1.15
  #2.R version >= 3.5.1
  #3.bcftools version: 1.7
  #4.STRUCTURE version >=2.3.4 (console binary)
  library(vcfR)
  library(doParallel)
  library(ggplot2)
  library(missMDA)
  library(ade4)
  library(SNPlocs.Hsapiens.dbSNP.20120608)
  
  ##Modify VCF files
  Admixture_modifyVCF(inputFiles = sampleVCF,outputName = "AIM250",threads = 1,temp = temp,AIM250_pos = TRUE, ref.genome = "grch37", chr.label = FALSE)
  
  ##Convert to Structure inport format
  Admixture_VCF2Structure(vcf1 = "AIM250_899genome.vcf",vcf2 = "AIM250_complete.recode.vcf",
                          PopCode_data = PopCode_data,GT_mergeTable = TRUE,
                          outputName = "AIM250")
  
  ##Run Structure
  Admixture_InputStr(Input_Str = "AIM250_str.txt", Str_Path = Str_Path, Output_Str ="AIM250_str_output.txt")
  
  ##Structure output modify
  ##distinguish Pop and group
  ##Population Summary Table
  Admixture_StrOut(Output_Str ="AIM250_str_output.txt_f", PopGroup = c("AFR","EUR","EAS","AMR","Other"),
                   K_value = 4,fileName = "AIM250_Summary.txt" )
  
  ##Individuals proportion Table
  Str_frq <- Admixture_StrOut_Frequency(Output_Str = "AIM250_str_output.txt_f", PopGroup = c("AFR","EUR","EAS","AMR","Other"),K_value = 4,PopCluster = "AIM250_Summary.txt",fileName = "AIM250_Frequency.txt")
  
  ##Convert to PCA format
  df <- Admixture_gt2PCAformat(InputFile = "AIM250_genotype.txt",PopCode_data = PopCode_data, genotype_start_column = 6,
                               genotype_seperator = "|",outputName = "AIM250")
  
  #df <- read.table("AIM250_PCAFormat.txt", sep = "\t",stringsAsFactors = FALSE, header = TRUE)
  df_1000G <- df[which(!df$Pop == "Other"),]
  
  sampleList <- read.table(sampleNames, sep = "\t", stringsAsFactors = FALSE)
  cat("if you have only one sample, you will have Warning message!\n")
  if (!ncol(sampleList) == 1) { stop(" Wrong format : sampleNames") }
  
  Str_frq$Label[which(Str_frq$Pop == 10)] <- sampleList$V1
  Str_frq_1000G <- Str_frq[which(!Str_frq$Pop == 10),]
  if(nrow(sampleList) == 1) {

    #creat sub folder
    dirName <- paste(sampleList$V1,"AdmixtureAnalysis", sep = "_")
    dir.create(dirName, showWarnings = FALSE)
    
    outputName <- paste(dirName,sampleList$V1, sep = "/")
    
    ##PCA plot
    df_pca <- rbind(df[which(df$Individuals == sampleList$V1),], df_1000G)
    figFileName <- paste(dirName,sampleList$V1,sep = "/")
    Admixture_PCAplot_MissingValue(PCAformat = df_pca,PopSelect = "all", figFileName = figFileName)
    
    ##Proportion plot
    #Str_frq <- read.table("AIM250_Frequency.txt", sep = "\t", header = TRUE,stringsAsFactors = FALSE)
    # Admixture_TrianglePlot(Str_frq = Str_frq,figFileName = figFileName,PopCode_data = PopCode_data )
    
  } else {
    #create sub folder
    dirName <- "AIM250_AdmixtureAnalysis"
    dir.create(dirName, showWarnings = FALSE)
    
    ##PCA plot
    df_pca <- df
    figFileName <- paste(dirName,"AIM250",sep = "/")
    Admixture_PCAplot_MissingValue(PCAformat = df_pca,PopSelect ="all", figFileName = figFileName)
    
    ##Proportion plot
    #Str_frq <- read.table("AIM250_Frequency.txt", sep = "\t", header = TRUE,stringsAsFactors = FALSE)
    # Admixture_TrianglePlot(Str_frq = Str_frq, figFileName = figFileName,PopCode_data = PopCode_data )
    
  }
} 
