library(data.table)
library(dplyr)
library(ggplot2)
library(cowplot)
library(tidyverse)
library(gridExtra)
library(grid)
library(ggrepel)
library(ggpubr)
library(susieR)
library(Rfast)
set.seed(1)

# =======
# SuSiE
# =======
get_gwas_rs671=function(trait){
  
  bim <- fread(paste0("/path/ldm/extract/kcps2_ld_chr12.bim"),data.table = F)
  snp <- bim$V2

  gwas_fn = paste0("/path/gwas/SAIGE/loco/")
  gwas0 <- fread(paste0(gwas_fn,"SAIGE_",trait,"_INFO.txt.gz"), data.table = F) 
  gwas1 <- gwas0 %>%
    dplyr::filter(MarkerID %in% snp)
  print(trait)
  return(gwas1)
}

run_susie <- function(trait){

  # Merge gwas and extracting SNPs
  sumstats <- get_gwas_rs671(trait)
      
  # Z-score
  z_scores <- sumstats$BETA / sumstats$SE
  
  # LD matrix
  R_ref <- fread(paste0("/path/ldm/extract/chr12_kcps2_r.ld.gz"))
  R_ref <- as.matrix(R_ref)
  rownames(R_ref)<-colnames(R_ref)
  
  ## Run SuSiE
  fitted_rss3 <- susieR::susie_rss(z_scores, R_ref, n = sumstats$N[1], L = 10, refine = TRUE)
  print(paste0("SuSiE converged: ",fitted_rss3$converged))
  
  susie_plot(fitted_rss3, y="PIP")

  print(trait)
  return(fitted_rss3)  
}

trait_list=c("LDL","TG","HDL","CHO","FBS","INSULIN","GOT","GPT","GGT","BIL","ALB","TSH","CEA",
             "CREAT","ADIPO","URIC","ALP","HB","HCT","MCH","MCHC","MCV","RBC","RDW","WBC","PLT","EOS",
             "SBP","DBP","WT","HEIGHT","BMI","WAIST","SMOKA_MOD","ALCO_AMOUNT","COFFA")
all_trait_output <- list()               
for(k in 1:length(trait_list)){
  all_trait_output[[trait_list[k]]] <- run_susie(trait_list[k])
}

pip_res <- c()
for(k in 1:length(trait_list)){
  bim <- fread(paste0("/path/ldm/extract/kcps2_ld_chr12.bim"),data.table = F)
  snp <- bim$V2

  mean_pip0 <- mean(all_trait_output[[trait_list[k]]]$pip)
  cs <- all_trait_output[[trait_list[k]]]$sets$cs
  N_cs <- length(cs)
  Total_size_cs <- sum(length(cs$L1),length(cs$L2),length(cs$L3),length(cs$L4),length(cs$L5),length(cs$L6),length(cs$L7),length(cs$L8),length(cs$L9),length(cs$L10), na.rm = TRUE)
  N_cs_1 <- sum(length(cs$L1)==1,length(cs$L2)==1,length(cs$L3)==1,length(cs$L4)==1,length(cs$L5)==1,length(cs$L6)==1,length(cs$L7)==1,length(cs$L8)==1,length(cs$L9)==1,length(cs$L10)==1, na.rm = TRUE)
  size_cs <- paste(c(length(cs$L1),length(cs$L2),length(cs$L3),length(cs$L4),length(cs$L5),length(cs$L6),length(cs$L7),length(cs$L8),length(cs$L9),length(cs$L10)),sep=",",collapse = ",")

  SNP <- paste(snp[c(cs$L1,cs$L2,cs$L3,cs$L4,cs$L5,cs$L6,cs$L7,cs$L8,cs$L9,cs$L10)],sep=",",collapse = ",")
  Is_rs671 <- str_detect(SNP, "rs671")
  snp_index <- which(snp=="rs671")
  PIP_rs671 <- all_trait_output[[trait_list[k]]]$pip[snp_index] #rs671: 622
 
  #mean_pip1 <- cbind(trait_list[k], mean_pip0, count_pip1, nrow(snp), N_cs, size_cs, SNP)
  mean_pip1 <- cbind(trait_list[k], mean_pip0, length(snp), N_cs, N_cs_1, Total_size_cs, size_cs, SNP, Is_rs671, PIP_rs671)
  
  pip_res <- rbind(pip_res, mean_pip1)
}
pip_res <- as.data.frame(pip_res)
colnames(pip_res) <- c("trait","mean_PIP", "Number of SNPs fine-mapped","Number of CS", "Number of CS with 1 variant","Total size of CS (#variants)","Size of each CS","SNPs in cs","Is_rs671","PIP_rs671")

#=============
# coloc
#=============
library(coloc)
bim <- fread("/path/ldm/extract/kcps2_ld_chr12.bim")
snp <- bim$V2

R_ref <- fread(paste0("/path/ldm/extract/chr12_kcps2_r.ld.gz"))
R_ref <- as.matrix(R_ref)
rownames(R_ref) <- snp
colnames(R_ref) <- rownames(R_ref)

trait_list_coloc <- c("ALCO_AMOUNT","GOT","GPT","GGT","SBP","DBP","COFFA","TG")

coloc_susie_output <- list()               
all_pp4_rs671 <- c()
run_coloc_susie <- function(trait2){
  trait1="ALCO_AMOUNT"
  #trait2="GGT"
  
  gwas1 <- get_gwas_rs671(trait=trait1) %>%
    dplyr::rename(rsid=MarkerID, maf=AF_Allele2)
  colnames(gwas1) <- tolower(names(gwas1))
  
  gwas2 <- get_gwas_rs671(trait=trait2) %>%
    dplyr::rename(rsid=MarkerID, maf=AF_Allele2)
  colnames(gwas2) <- tolower(names(gwas2))
  
  input <- merge(gwas1, gwas2, by="rsid", all=FALSE, suffixes=c("_gwas1","_gwas2")) #5596831

  #reform
  coloc_list <- list()
  temp <- subset(input, select=c("beta_gwas1","se_gwas1","rsid","pos_gwas1","maf_gwas1"))
  temp <- temp[!duplicated(temp),]
  temp$se_gwas1 <- temp$se_gwas1**2
  colnames(temp) <- c("beta","varbeta","snp","position","MAF")
  coloc_list[["gwas1"]] <- as.list(temp)
  coloc_list[["gwas1"]]["type"] <- "quant"
  coloc_list[["gwas1"]]["N"] <- gwas1$n[1]
  coloc_list[["gwas1"]]["LD"] <- list(R_ref)
  
  #temp <- merge_dat[merge_dat$tissue==loop_tissue,]
  temp <- subset(input, select=c("beta_gwas2","se_gwas2","rsid","pos_gwas2","maf_gwas2"))
  temp <- temp[!duplicated(temp$rsid),]
  temp$se_gwas2 <- temp$se_gwas2**2
  temp <- temp[!is.na(temp$se_gwas2),]
  colnames(temp) <- c("beta","varbeta","snp","position","MAF")
  coloc_list[["gwas2"]] <- as.list(temp)
  coloc_list[["gwas2"]]["type"] <- "quant"
  coloc_list[["gwas2"]]["N"] <- gwas2$n[1]
  coloc_list[["gwas2"]]["LD"] <- list(R_ref)
  
  D3=coloc_list$gwas1
  D4=coloc_list$gwas2

  my.res <- coloc.abf(dataset1=D3,dataset2=D4)
  
  S3=coloc::runsusie(D3,n=gwas1$n[1])
  S4=coloc::runsusie(D4,n=gwas2$n[1])
  
  if(requireNamespace("susieR",quietly=TRUE)) {
    susie.res=coloc.susie(S3,S4)
    print(susie.res$summary)
    print(susie.res$results)
  }
  
  pp4_rs671 <- susie.res$results$SNP.PP.H4.row1[which(susie.res$results$snp=="rs671")]
  
  return(list(my.res,pp4_rs671))

}

for(k in 2:length(trait_list_coloc)){
  coloc_susie_output[[trait_list_coloc[k]]] <- run_coloc_susie(trait_list_coloc[k])[[1]]
  all_pp4_rs671 <- c(all_pp4_rs671, run_coloc_susie(trait_list_coloc[k])[[2]])
}
