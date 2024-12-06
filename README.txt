Genome-wide association studies in a large Korean cohort identify novel quantitative trait loci for 36 traits and illuminate their genetic architectures

Yon Ho Jee, Ying Wang, Keum Ji Jung, Ji-Young Lee, Heejin Kimm, Rui Duan, Alkes L. Price, Alicia R. Martin, Peter Kraft

#===========================================================
Genome-wide association analysis in KCPS2
#===========================================================
01.saige_step1_loco.sh
02.saige_step2_loco.sh
	- Bash script to run SAIGE in KCPS2
03.run_plink_irnt_remove_related.sh
	- Bash script to run PLINK2 in KCPS2

#===========================================================
Novel loci compared to OTG + EAS biobanks + recent GWAS
#===========================================================
04.kcps2_annotate_loci_dist_EAS_pmid.ipynb
	- Hail script to identify novel loci in KCPS2

#===========================================================
Genetic architecture in KCPS2, KoGES, BBJ, TWB, and UKB
#===========================================================
05.run_sbayesS_lm_unrelated_10132024.sh
	- Bash script to run sbayesS in KCPS2, KoGES, and TWB

#===========================================================
Meta-analysis (METAL)
#===========================================================
06.MA_EAS_UKB.txt
07.MA_EAS_UKB.sh
	- Bash script to run METAL

#===========================================================
Fine-mapping, Colocalization
#===========================================================
08.kcps2_susie_coloc.R
	- R script to run SuSiE, coloc in KCPS2

