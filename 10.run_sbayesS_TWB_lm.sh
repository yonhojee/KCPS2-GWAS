#!/bin/bash
#SBATCH -J gctb.twb # A single job name for the array
#SBATCH -c 1 # Number of cores
#SBATCH -p serial_requeue # Partition
#SBATCH --mem 100000 # Memory request (100Gb)
#SBATCH -t 0-10:00 # Maximum execution time (D-HH:MM)
#SBATCH -e /n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_TWB/sbayesS/kcps2_ldm/gctb.twb_%a.err
#SBATCH -o /n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_TWB/sbayesS/kcps2_ldm/gctb.twb_%a.out
#SBATCH --array=0-22

cd /n/home03/yjee/GCTB/gctb_2.03beta_Linux

outdir="/n/holylfs05/LABS/kraft_lab/Lab/yjee/GCTB/Output_TWB/sbayesS/kcps2_ldm"
ldmdir="/n/holylfs05/LABS/kraft_lab/Lab/KCPS2/ldm/shrunk_unrelated"
gwasdir="/n/holylfs05/LABS/kraft_lab/Lab/yjee/TWB/ma"

## declare an array variable
declare -a arr=("LDL" "TG" "HDL" "CHO" "FBS" "GOT" "GPT" "GGT" "BIL" "ALB" "CREAT" "URIC" "HB" "HCT" "RBC" "WBC" "PLT" "SBP" "DBP" "WT" "HEIGHT" "BMI" "WAIST")

i=${SLURM_ARRAY_TASK_ID}
trait="${arr[i]}"
echo $trait

mkdir -p ${outdir}/${trait}
#---------------------------------------
# Run GCTB
#---------------------------------------

for chr in {1..22}; do
./gctb --sbayes S --mldm ${ldmdir}/chr$chr/Chr${chr}_Merge_Final_50K_unrelated.mldmlist --gwas-summary ${gwasdir}/${trait}/${trait}.ma --out ${outdir}/${trait}/twb_${trait}_chr$chr
done

