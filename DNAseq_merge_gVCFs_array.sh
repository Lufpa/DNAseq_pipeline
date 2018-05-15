#!/bin/bash
#SBATCH --mem=100000
#SBATCH --time=24:00:00 --qos=1day
#SBATCH --job-name=Ggvcf
#SBATCH --cpus-per-task=1
#SBATCH --output="%A_%a.out"
#SBATCH --error="%A_%a.error"
#SBATCH --array=1-6

# run from the inDIR folder
# requires a mygvcfiles.list with the gvcf files to merge

set -e 
date >&2

refgenome=/Genomics/grid/users/lamaya/genomes/dmel_genome/dmel-all-chromosome-r6.14.fa
vcfout=bigproject_batch1.vcf
logfile=log.genotypegvcf.${vcfout%.vcf}
inDIR=/scratch/tmp/lamaya/novaseq_gDNA/vcf
outDIR=/scratch/tmp/lamaya/novaseq_gDNA/vcf
gvcfs=$inDIR/mygvcfiles.list
chrlist=/Genomics/grid/users/lamaya/scripts/DNAseq_pipeline/chromosomes.list
gatk=/Genomics/grid/users/lamaya/bin/GATK/GenomeAnalysisTK.jar

source /Genomics/grid/users/lamaya/scripts/DNAseq_pipeline/mergegVCFs_byChr.sh ${refgenome} ${gvcfs} ${vcfout} ${logfile} ${inDIR} ${outDIR} ${chrlist} ${gatk}

date >&2
