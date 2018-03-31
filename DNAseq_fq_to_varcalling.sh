#/bin/bash

#Batch parameters are specified in snpcaller.sh script that calls this script

refbwa=$1
refGATK=$2
dedup=$3
r3=$4
cpus=$5

fqfile=`awk -v file=$SLURM_ARRAY_TASK_ID '{if (NR==file) print $0 }' listfiles`
echo "filename" $fqfile >&2
fqfile2=${fqfile%R1.fq.gz}R2.fq.gz
name=${fqfile%.R1*}
uniqfile=$name\.sorteduniq.bam

date
echo "start mapping"
bwa mem -M -t $cpus -R "@RG\\tID:$name\\tSM:$name\\tPL:ILLUMINA\\tLB:$name" $refbwa $fqfile $fqfile2 | samtools view -u -@ $cpus | samtools sort -@ $cpus -m 3G | samtools view -F 256 -o $uniqfile

date
echo "finish mapping"
if [ $dedup == 'picard' ]
	then
		echo "Start picard deduplication"
		dedupfile=${uniqfile%bam}markdup.bam
		metrics=$name.metricspicard
		java -Xmx30g -jar ~/bin/picard.jar MarkDuplicates I=$uniqfile O=$dedupfile M=$metrics
		echo "Done dedup for" $uniqfile
		java -Xmx30g -jar ~/bin/picard.jar BuildBamIndex I=$dedupfile
		echo "Done with bam index"
elif [ $dedup == 'nudup' ]
	then
		echo "Start nudup deduplication"
		dedupfile=${uniqfile%.sorted*}
		python ~/bin/nudup/nudup.py -2 -f $r3 -o $dedupfile -s 8 -l 8 $uniqfile --rmdup-only
		dedupfile=${dedupfile}.sorted.dedup.bam
		echo "Done dedup for" $dedupfile
		java -Xmx30g -jar ~/bin/picard.jar BuildBamIndex I=$dedupfile
                echo "Done with bam index"
else	dedupfile=${uniqfile}
	echo "no deduplication for" $uniqfile
	java -Xmx30g -jar ~/bin/picard.jar BuildBamIndex I=$dedupfile
                echo "Done with bam index"
fi

if [ -s $dedupfile ]
	then
	rm $uniqfile 
else
	echo "deduplication failed dedup file is empty - original bam file was kept"
fi

date

echo "Start haplotype caller in GATK"
gvcffile=$name.g.vcf
java -Xmx30g -jar ~/bin/GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -nct $cpus -R $refGATK -I $dedupfile -ERC GVCF -o $gvcffile -fixMisencodedQuals
echo "Done with variantcalling"
date
