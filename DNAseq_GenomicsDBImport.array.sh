#!/bin/bash
#SBATCH --mem=100000
#SBATCH --time=5-00:00 --qos=1wk
#SBATCH --job-name=ImportDB
#SBATCH --cpus-per-task=1
#SBATCH --output="%A_%a.out"
#SBATCH --error="%A_%a.error"
#SBATCH --array=1-6

# run from the inDIR folder where the .list file is located
# requires a mygvcfiles.forImportDB.list with the sample ID of the gvcf files TAB path to the gvcfs

set -e 
date >&2

#refgenome=/Genomics/grid/users/lamaya/genomes/dmel_genome/dmel-all-chromosome-r6.14.fa
#vcfout=bigproject_batch1.vcf

logfile=log.importDB.bigproject_batch1
inDIR=/scratch/tmp/lamaya/novaseq_gDNA
gvcfs=$inDIR/mygvcfiles.forImportDB.list
dbpath=/scratch/tmp/lamaya/novaseq_gDNA/testDB
chrlist=/Genomics/grid/users/lamaya/scripts/DNAseq_pipeline/chromosomes.list
gatk=/Genomics/grid/users/lamaya/bin/gatk-4.0.5.2/gatk

source /Genomics/grid/users/lamaya/scripts/DNAseq_pipeline/GenomicsDBImport.sh ${gvcfs} ${logfile} ${inDIR} ${dbpath} ${chrlist} ${gatk}

date >&2
