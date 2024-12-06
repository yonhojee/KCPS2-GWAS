#!/bin/bash
#SBATCH -J MA_EAS_UKB
#SBATCH -c 1
#SBATCH -t 0-10:00
#SBATCH -p shared
#SBATCH --mem=100000 # 100Gb
#SBATCH -o /n/holylfs05/LABS/kraft_lab/Lab/yjee/Meta_analysis/LMM/MA_EAS_UKB.out
#SBATCH -e /n/holylfs05/LABS/kraft_lab/Lab/yjee/Meta_analysis/LMM/MA_EAS_UKB.err

cd /n/holylfs05/LABS/kraft_lab/Lab/yjee/METAL/METAL/build/bin

# METAL on sumstats on 21 overlapping traits across 4 EAS biobanks and UKB
outdir="/n/holylfs05/LABS/kraft_lab/Lab/yjee/Meta_analysis/LMM"

for trait in ldl tg hdl cho fbs got gpt ggt bil alb creat hb hct rbc wbc plt sbp dbp wt height bmi
#for trait in ldl
do
	echo $trait
  cp /n/holylfs05/LABS/kraft_lab/Lab/KCPS2/gwas/SAIGE/loco/kcps2_${trait}.txt.gz KCPS2data
	cp /n/holylfs05/LABS/kraft_lab/Lab/yjee/BBJ/bbj_${trait}.txt.gz BBJdata
  cp /n/holylfs05/LABS/kraft_lab/Lab/yjee/KOGES/SAIGE_summaries/koges_${trait}.txt.gz KOGESdata
	cp /n/holylfs05/LABS/kraft_lab/Lab/yjee/TWB/REGENIE/twb_${trait}.txt.gz TWBdata
	cp /n/holylfs05/LABS/kraft_lab/Lab/yjee/PUKB/pukb_${trait}.txt.gz UKBdata
	./metal ${outdir}/MA_EAS_UKB.txt
	mv ${outdir}/MA_EAS_UKB1.tbl ${outdir}/MA_EAS_UKB_${trait}.tbl
	mv ${outdir}/MA_EAS_UKB1.tbl.info ${outdir}/MA_EAS_UKB_${trait}.tbl.info
	rm KCPS2data BBJdata KOGESdata TWBdata UKBdata
	echo "done"
done

