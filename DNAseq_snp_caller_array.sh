#!/bin/bash
#SBATCH --mem=40000
#SBATCH --time=3:00:00 --qos=1day
#SBATCH --job-name=DNAseq
#SBATCH --cpus-per-task=4   #make sure to modify $cpus too!!!
#SBATCH --output="%A_%a.out"
#SBATCH --error="%A_%a.error"
#SBATCH --array=1-96

##Requires:
# Demultiplexed files (*R1.fq.gz, *R2.fq.gz)
# "listfiles" with the sample id R1 L003 
# "listfiles2" with sample id R1 L004 

set -e

date
inDIR=/Genomics/ayroleslab/lamaya/bigProject/march_2018/novaseq_gDNA
outDIR=/scratch/tmp/lamaya/novaseq_gDNA

# set up the number of cpus to match --cpus-per-task, this value will be use for bwa, samtools, and hapcaller
cpus=4
# specify if 'nudup' or 'picard' should be use for deduplication. If no deduplication, then leave empty ''
dedup='picard'
# if nudup is gonna be used for demultiplexing, load Read 3
r3=*Read_3*

refbwa=/Genomics/grid/users/lamaya/genomes/dmel_genome/dmel-all-chromosome-r6.14
refGATK=/Genomics/grid/users/lamaya/genomes/dmel_genome/dmel-all-chromosome-r6.14.fa

source /Genomics/grid/users/lamaya/scripts/DNAseq_pipeline/DNAseq_fq_to_varcalling.sh ${refbwa} ${refGATK} ${dedup} ${cpus} ${inDIR} ${outDIR} ${r3}

date
