#/bin/bash

#Batch parameters are specified in snpcaller.sh script that calls this script

refbwa=$1
refGATK=$2
dedup=$3
cpus=$4
inDIR=$5
outDIR=$6
r3=$7

fqfile=`awk -v file=$SLURM_ARRAY_TASK_ID '{if (NR==file) print $0 }' $inDIR/listfiles`
echo "filename" $fqfile >&2
fqfile2=${fqfile/R1/R2}
name=${fqfile%_S*}
uniqfile=$name\.sorteduniq.bam

#merging fq from L003 and L004. The lane info is lost given the way bwa RG
# is set up. Can be fixed if needed, but merging cannot be done here. 
#run bwa for each lane, merge before markduplicates
# needs listfiles2
fqfileL4=`awk -v file=$SLURM_ARRAY_TASK_ID '{if (NR==file) print $0 }' $inDIR/listfiles2`
fqfileL42=${fqfileL4/R1/R2}

echo "mergin fq from L003 and L004"
infq1=${name}_R1.fq.gz
infq2=${name}_R2.fq.gz
cat $inDIR/$fqfile $inDIR/$fqfileL4 > $outDIR/$infq1
cat $inDIR/$fqfile2 $inDIR/$fqfileL42 > $outDIR/$infq2

date
echo "start mapping"
bwa mem -M -t $cpus -R "@RG\\tID:$name\\tSM:$name\\tPL:ILLUMINA\\tLB:$name" $refbwa $outDIR/$infq1 $outDIR/$infq2 | samtools view -u -@ $cpus | samtools sort -@ $cpus -T $outDIR/$name -m 3G | samtools view -F 256 -o $outDIR/$uniqfile

date
echo "finish mapping"
if [ $dedup == 'picard' ]
	then
		echo "Start picard deduplication"
		dedupfile=${uniqfile%bam}markdup.bam
		metrics=$name.metricspicard
		java -Xmx30g -jar ~/bin/picard.jar MarkDuplicates I=$outDIR/$uniqfile O=$outDIR/$dedupfile M=$outDIR/$metrics
		echo "Done dedup for" $uniqfile
		java -Xmx30g -jar ~/bin/picard.jar BuildBamIndex I=$outDIR/$dedupfile
		echo "Done with bam index"
elif [ $dedup == 'nudup' ]
	then
		echo "Start nudup deduplication"
		dedupfile=${uniqfile%.sorted*}
		python ~/bin/nudup/nudup.py -2 -f $r3 -o $outDIR/$dedupfile -s 8 -l 8 $outDIR/$uniqfile --rmdup-only
		dedupfile=${dedupfile}.sorted.dedup.bam
		echo "Done dedup for" $dedupfile
		java -Xmx30g -jar ~/bin/picard.jar BuildBamIndex I=$outDIR/$dedupfile
                echo "Done with bam index"
else	dedupfile=${uniqfile}
	echo "no deduplication for" $uniqfile
	java -Xmx30g -jar ~/bin/picard.jar BuildBamIndex I=$outDIR/$dedupfile
                echo "Done with bam index"
fi

if [ -s $outDIR/$dedupfile ]
	then
	rm $outDIR/$uniqfile 
else
	echo "deduplication failed dedup file is empty - original bam file was kept"
fi

date

echo "Start haplotype caller in GATK"
gvcffile=$name.g.vcf
java -Xmx30g -jar ~/bin/GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -nct $cpus -R $refGATK -I $outDIR/$dedupfile -ERC GVCF -o $outDIR/$gvcffile
echo "Done with variantcalling"
date
