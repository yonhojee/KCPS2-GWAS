#!/bin/bash
#SBATCH -J gctb.koges # A single job name for the array
#SBATCH -c 1 # Number of cores
#SBATCH -p serial_requeue # Partition
#SBATCH --mem 100000 # Memory request (100Gb)
#SBATCH -t 0-10:00 # Maximum execution time (D-HH:MM)
#SBATCH -e /n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_KOGES/sbayesS/kcps2_ldm/gctb.koges_%a.err
#SBATCH -o /n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_KOGES/sbayesS/kcps2_ldm/gctb.koges_%a.out
#SBATCH --array=0-21

cd /n/home03/yjee/GCTB/gctb_2.03beta_Linux

outdir="/n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_KOGES/sbayesS/kcps2_ldm"
ldmdir="/n/holylfs05/LABS/kraft_lab/Lab/KCPS2/ldm/shrunk_unrelated"
gwasdir="/n/holylfs05/LABS/kraft_lab/Lab/yjee/KOGES/ma"

## declare an array variable
declare -a arr=("ALB" "ALCO_AMOUNT" "GPT" "GOT" "BMI" "CREAT" "DBP" "GGT" "FBS" "HB" "HDL" "HEIGHT" "HCT" "LDL" "PLT" "RBC" "SBP" "BIL" "CHO" "TG" "WC" "WBC")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"
echo $trait

mkdir -p ${outdir}/${trait}
#---------------------------------------
# Run GCTB
#---------------------------------------

for chr in {1..22}; do
./gctb --sbayes S --mldm ${ldmdir}/chr$chr/Chr${chr}_Merge_Final_50K_unrelated.mldmlist --gwas-summary ${gwasdir}/${trait}/koges_${trait}.ma --out ${outdir}/${trait}/koges_${trait}_chr$chr
done

