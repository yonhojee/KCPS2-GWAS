#!/bin/bash

cd /path/METAL/METAL/build/bin

# METAL on sumstats on 21 overlapping traits across 4 EAS biobanks and UKB
outdir="/path/Meta_analysis/LMM"

for trait in ldl tg hdl cho fbs got gpt ggt bil alb creat hb hct rbc wbc plt sbp dbp wt height bmi
#for trait in ldl
do
	echo $trait
  cp /path/KCPS2/gwas/SAIGE/loco/kcps2_${trait}.txt.gz KCPS2data
	cp /path/BBJ/bbj_${trait}.txt.gz BBJdata
  cp /path/KOGES/SAIGE_summaries/koges_${trait}.txt.gz KOGESdata
	cp /path/TWB/REGENIE/twb_${trait}.txt.gz TWBdata
	cp /path/PUKB/pukb_${trait}.txt.gz UKBdata
	./metal ${outdir}/MA_EAS_UKB.txt
	mv ${outdir}/MA_EAS_UKB1.tbl ${outdir}/MA_EAS_UKB_${trait}.tbl
	mv ${outdir}/MA_EAS_UKB1.tbl.info ${outdir}/MA_EAS_UKB_${trait}.tbl.info
	rm KCPS2data BBJdata KOGESdata TWBdata UKBdata
	echo "done"
done

