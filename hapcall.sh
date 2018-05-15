# to re-run hapcall in case the job timed out before finishing. But the bam file and markdups worked fine. 

#!/bin/bash
#SBATCH --mem=40000
#SBATCH --time=4:00:00 --qos=1day
#SBATCH --job-name=HC
#SBATCH --cpus-per-task=10   #make sure to modify $cpus too!!!
#SBATCH --output="%A_%a.out"
#SBATCH --error="%A_%a.error"

set -e 
date
cpus=10
refGATK=/Genomics/grid/users/lamaya/genomes/dmel_genome/dmel-all-chromosome-r6.14.fa
inDIR=/scratch/tmp/lamaya/novaseq_gDNA/129_hs
outDIR=/scratch/tmp/lamaya/novaseq_gDNA/129_hs
infile=129-DNA-C2.sorteduniq.markdup.bam
outfile=${infile%.sort*}.g.vcf
logfile=log.${infile%.sort*}.hapcaller

java -Xmx30g -jar ~/bin/GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -nct $cpus -R $refGATK -I $inDIR/$infile -ERC GVCF -o $outDIR/$outfile |& tee $logfile
date

