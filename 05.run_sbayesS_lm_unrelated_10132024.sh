#!/bin/bash
#SBATCH -J gctb.unrl # A single job name for the array
#SBATCH -c 1 # Number of cores
#SBATCH -p serial_requeue # Partition
#SBATCH --mem 100000 # Memory request (100Gb)
#SBATCH -t 0-10:00 # Maximum execution time (D-HH:MM)
#SBATCH -e /path/Output_KCPS2/sbayesS/SAIGE/lm_remove_related_ldm/gctb.unrl_%a.err
#SBATCH -o /path/Output_KCPS2/sbayesS/SAIGE/lm_remove_related_ldm/gctb.unrl_%a.out
#SBATCH --array=0-35

cd /gctb_2.03beta_Linux

#---------------------------------------
# Run GCTB for KCPS2
#---------------------------------------

outdir="/path/Output_KCPS2/sbayesS/SAIGE/lm_remove_related_ldm"
gwasdir="/path/ma/irnt_remove_related"
ldmdir="/path/ldm/shrunk_unrelated"

declare -a arr=("LDL" "TG" "HDL" "CHO" "FBS" "INSULIN" "GOT" "GPT" "GGT" "BIL" "ALB" "TSH" "CEA" "CREAT" "ADIPO" "URIC" "ALP" "HB" "HCT" "MCH" "MCHC" "MCV" "RBC" "RDW" "WBC" "PLT" "EOS" "SBP" "DBP" "WT" "HEIGHT" "BMI" "WAIST" "SMOKA_MOD" "ALCO_AMOUNT" "COFFA")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"
echo $trait

mkdir -p ${outdir}/${trait}

for chr in {1..22}; do
./gctb --sbayes S --mldm ${ldmdir}/chr$chr/Chr${chr}_Merge_Final_50K_unrelated.mldmlist --gwas-summary ${gwasdir}/PLINK_${trait}_irnt.ma --out ${outdir}/${trait}/PLINK_kcps2_50K_${trait}_chr$chr
done

#---------------------------------------
# Run GCTB for KoGES
#---------------------------------------

outdir="/path/Output_KOGES/sbayesS/kcps2_ldm"
ldmdir="/path/ldm/shrunk_unrelated"
gwasdir="/path/KOGES/ma"

declare -a arr=("ALB" "ALCO_AMOUNT" "GPT" "GOT" "BMI" "CREAT" "DBP" "GGT" "FBS" "HB" "HDL" "HEIGHT" "HCT" "LDL" "PLT" "RBC" "SBP" "BIL" "CHO" "TG" "WC" "WBC")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"
echo $trait

mkdir -p ${outdir}/${trait}

for chr in {1..22}; do
./gctb --sbayes S --mldm ${ldmdir}/chr$chr/Chr${chr}_Merge_Final_50K_unrelated.mldmlist --gwas-summary ${gwasdir}/${trait}/koges_${trait}.ma --out ${outdir}/${trait}/koges_${trait}_chr$chr
done

#---------------------------------------
# Run GCTB for TWB
#---------------------------------------

outdir="/path/Output_TWB/sbayesS/kcps2_ldm"
ldmdir="/path/ldm/shrunk_unrelated"
gwasdir="/path/TWB/ma"

declare -a arr=("LDL" "TG" "HDL" "CHO" "FBS" "GOT" "GPT" "GGT" "BIL" "ALB" "CREAT" "URIC" "HB" "HCT" "RBC" "WBC" "PLT" "SBP" "DBP" "WT" "HEIGHT" "BMI" "WAIST")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"
echo $trait

mkdir -p ${outdir}/${trait}

for chr in {1..22}; do
./gctb --sbayes S --mldm ${ldmdir}/chr$chr/Chr${chr}_Merge_Final_50K_unrelated.mldmlist --gwas-summary ${gwasdir}/${trait}/${trait}.ma --out ${outdir}/${trait}/twb_${trait}_chr$chr
done

