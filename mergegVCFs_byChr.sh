#!/bin/bash

##SBATCH parameters from core script DNAseq_merge_gVCFs_array.sh

refgenome=$1
gvcfs=$2
vcfout=$3
logfile=$4
inDIR=$5
outDIR=$6
chrlist=$7
gatk=$8

chr=`awk -v file=$SLURM_ARRAY_TASK_ID '{if (NR==file) print $0 }' $chrlist`
date
echo "processing chromosome" $chr >&2

java -Xmx30g -jar $gatk -T GenotypeGVCFs -R $refgenome -V $gvcfs -newQual -L $chr -o $outDIR/${chr}_$vcfout |& tee $outDIR/${logfile}.$chr

echo "done with genotyping gvcfs for chr" $chr >&2 

date
