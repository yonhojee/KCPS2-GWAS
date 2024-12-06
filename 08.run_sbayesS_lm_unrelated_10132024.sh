#!/bin/bash
#SBATCH -J gctb.unrl # A single job name for the array
#SBATCH -c 1 # Number of cores
#SBATCH -p serial_requeue # Partition
#SBATCH --mem 100000 # Memory request (100Gb)
#SBATCH -t 0-10:00 # Maximum execution time (D-HH:MM)
#SBATCH -e /n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_KCPS2/sbayesS/SAIGE/lm_remove_related_ldm/gctb.unrl_%a.err
#SBATCH -o /n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_KCPS2/sbayesS/SAIGE/lm_remove_related_ldm/gctb.unrl_%a.out
#SBATCH --array=0-35

cd /n/home03/yjee/GCTB/gctb_2.03beta_Linux

outdir="/n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_KCPS2/sbayesS/SAIGE/lm_remove_related_ldm"
gwasdir="/n/holylfs05/LABS/kraft_lab/Lab/KCPS2/ma/irnt_remove_related"
ldmdir="/n/holylfs05/LABS/kraft_lab/Lab/KCPS2/ldm/shrunk_unrelated"

## declare an array variable
declare -a arr=("LDL" "TG" "HDL" "CHO" "FBS" "INSULIN" "GOT" "GPT" "GGT" "BIL" "ALB" "TSH" "CEA" "CREAT" "ADIPO" "URIC" "ALP" "HB" "HCT" "MCH" "MCHC" "MCV" "RBC" "RDW" "WBC" "PLT" "EOS" "SBP" "DBP" "WT" "HEIGHT" "BMI" "WAIST" "SMOKA_MOD" "ALCO_AMOUNT" "COFFA")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"
echo $trait

mkdir -p ${outdir}/${trait}
#---------------------------------------
# Run GCTB
#---------------------------------------

for chr in {1..22}; do
./gctb --sbayes S --mldm ${ldmdir}/chr$chr/Chr${chr}_Merge_Final_50K_unrelated.mldmlist --gwas-summary ${gwasdir}/PLINK_${trait}_irnt.ma --out ${outdir}/${trait}/PLINK_kcps2_50K_${trait}_chr$chr
done

