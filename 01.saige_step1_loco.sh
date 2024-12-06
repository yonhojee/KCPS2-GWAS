#!/bin/bash
#SBATCH -J saige1.loco # A single job name for the array
#SBATCH -c 8 # Number of cores
#SBATCH -p serial_requeue # Partition
#SBATCH --mem 100000 # Memory request (100Gb)
#SBATCH -t 1-00:00 # Maximum execution time (D-HH:MM)
#SBATCH -e /path/data/SAIGE_output/loco/step1.loco_%A_%a.err
#SBATCH -o /path/data/SAIGE_output/loco/step1.loco_%A_%a.out
#SBATCH --array=0-35

cd /path/SAIGE/conda_env
module load python/3.10.13-fasrc01
conda activate RSAIGE
FLAGPATH=`which python | sed 's|/bin/python$||'`
export LDFLAGS="-L${FLAGPATH}/lib"
export CPPFLAGS="-I${FLAGPATH}/include"

genodir1="/path/data/SAIGE_input"
genodir2="/path/data"

phenodir="/path"
outdir="/path"
phen="YIDBASE_20240315_no_out.txt"

## declare an array variable
declare -a arr=("LDL_B" "TG_B" "HDL_B" "CHO_B" "FBS_B" "INSULIN" "GOT_B" "GPT_B" "GGT_B" "BIL_B" "ALB_B" "TSH_B" "CEA_B" "CREAT_B" "ADIPO" "URIC_B" "ALP_B" "HB_B" "HCT_B" "MCH_B" "MCHC_B" "MCV_B" "RBC_B" "RDW_B" "WBC_B" "PLT_B" "EOS_B" "SBP_B" "DBP_B" "WT_B" "HT_B" "BMI_B" "WAIST_B" "SMOKA_MOD_B" "ALCO_AMOUNT_B" "COFFA_MOD")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"

mkdir ${outdir}/${trait}
#---------------------------------------
# 1-2. Step 1: fitting the null logistic/linear mixed model
#---------------------------------------

Rscript /path/extdata/step1_fitNULLGLMM.R     \
      --plinkFile=${genodir1}/Chrauto_Merge_Final.sampleqcdedup.pruned2.snponly \
      --useSparseGRMtoFitNULL=FALSE    \
      --phenoFile=${phenodir}/${phen} \
      --phenoCol=${trait} \
      --covarColList=AGE,SEX1,array,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
      --qCovarColList=SEX1,array \
      --sampleIDColinphenoFile=IID \
      --invNormalize=TRUE     \
      --traitType=quantitative        \
      --outputPrefix=${outdir}/${trait}/KCPS2_${trait} \
      --nThreads=8 \
      --LOCO=TRUE \
      --IsOverwriteVarianceRatioFile=TRUE

