#!/bin/bash

##SBATCH parameters from core script DNAseq_GenomicImportDB.sh

gvcfs=$1
logfile=$2
inDIR=$3
dbpath=$4
chrlist=$5
gatk=$6

chr=`awk -v file=$SLURM_ARRAY_TASK_ID '{if (NR==file) print $0 }' $chrlist`
date
echo "processing chromosome" $chr >&2

$gatk --java-options "-Xmx100g" GenomicsDBImport --sample-name-map $gvcfs --batch-size 50 -L $chr --genomicsdb-workspace-path ${dbpath}.$chr |& tee $inDIR/${logfile}.$chr

echo "done with Importing gvcfs into DB for chr" $chr >&2 

date
