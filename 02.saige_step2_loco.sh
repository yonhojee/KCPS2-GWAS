#!/bin/bash

cd /path/SAIGE/conda_env
module load python/3.10.13-fasrc01
conda activate RSAIGE
FLAGPATH=`which python | sed 's|/bin/python$||'`
export LDFLAGS="-L${FLAGPATH}/lib"
export CPPFLAGS="-I${FLAGPATH}/include"

genodir1="/path/data/SAIGE_input"
genodir2="/path/data"

phenodir="/path"
outdir="/path/data/SAIGE_output/loco"
phen="YIDBASE_20240315_no_out.txt"

## declare an array variable
declare -a arr=("LDL_B" "TG_B" "HDL_B" "CHO_B" "FBS_B" "INSULIN" "GOT_B" "GPT_B" "GGT_B" "BIL_B" "ALB_B" "TSH_B" "CEA_B" "CREAT_B" "ADIPO" "URIC_B" "ALP_B" "HB_B" "HCT_B" "MCH_B" "MCHC_B" "MCV_B" "RBC_B" "RDW_B" "WBC_B" "PLT_B" "EOS_B" "SBP_B" "DBP_B" "WT_B" "HT_B" "BMI_B" "WAIST_B" "SMOKA_MOD_B" "ALCO_AMOUNT_B" "COFFA_MOD")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"

#---------------------------------------
# 1-3. Step 2: performing single-variant association tests
#---------------------------------------
for chr in {1..22};do
Rscript /path/SAIGE/extdata/step2_SPAtests.R \
        --bedFile=${genodir2}/Chr"$chr"_Merge_Final.bed       \
        --bimFile=${genodir2}/Chr"$chr"_Merge_Final.bim       \
        --famFile=${genodir2}/Chr"$chr"_Merge_Final.fam       \
        --AlleleOrder=alt-first \
        --SAIGEOutputFile=${outdir}/${trait}/KCPS2_${trait}_chr${chr}.SAIGE.plink.txt \
        --chrom=${chr} \
        --minMAF=0 \
        --minMAC=10 \
        --GMMATmodelFile=${outdir}/${trait}/KCPS2_${trait}.rda \
        --varianceRatioFile=${outdir}/${trait}/KCPS2_${trait}.varianceRatio.txt \
        --is_output_moreDetails=TRUE    \
        --LOCO=TRUE --is_imputed_data=TRUE \
        --is_overwrite_output=TRUE
done

