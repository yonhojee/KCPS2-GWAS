#!/bin/bash

cd /path/plink2_install

genodir2="/path/data"

phenodir="/path"
outdir="/path/gwas/irnt_remove_related"
phen="YIDBASE_20240421_no_out_irnt.txt"
related="/path/data/relatedness"

## declare an array variable
declare -a arr=("LDL_B" "TG_B" "HDL_B" "CHO_B" "FBS_B" "INSULIN" "GOT_B" "GPT_B" "GGT_B" "BIL_B" "ALB_B" "TSH_B" "CEA_B" "CREAT_B" "ADIPO" "URIC_B" "ALP_B" "HB_B" "HCT_B" "MCH_B" "MCHC_B" "MCV_B" "RBC_B" "RDW_B" "WBC_B" "PLT_B" "EOS_B" "SBP_B" "DBP_B" "WT_B" "HT_B" "BMI_B" "WAIST_B" "SMOKA_MOD_B" "ALCO_AMOUNT_B" "COFFA_MOD")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"

mkdir ${outdir}/${trait}
#---------------------------------------
# Run GWAS using PLNK2
#---------------------------------------
for chr in {1..22};do
./plink2 --allow-no-sex \
  --bfile ${genodir2}/Chr"$chr"_Merge_Final \
  --linear omit-ref hide-covar \
  --covar ${phenodir}/${phen} \
  --covar-name AGE SEX1 array PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9 PC10 \
  --hwe 0.0001 \
  --mac 10 \
  --pheno ${phenodir}/${phen} \
  --pheno-name ${trait} \
  --covar-variance-standardize \
  --remove ${related}/Chrauto_Merge_Final.sampleqcdedup.pruned2.snponly.2nddegree.king.cutoff.out.id \
  --out ${outdir}/${trait}/KCPS2_Chr"$chr"_${trait} \
  --threads 48
done
