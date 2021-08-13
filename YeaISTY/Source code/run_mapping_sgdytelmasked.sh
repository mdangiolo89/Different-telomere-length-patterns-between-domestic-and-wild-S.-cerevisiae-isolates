
#bin="/home/jxyue/Programs/"
for a in *\.R1*gz; do
sample=${a/\.R1.fastq.gz/}
run="Run1";
refseq="SGD_ref.ytelmasked3.fa"
echo "$refseq"
read1="$a"
read2=${a/\.R1\./\.R2\.}
echo "$read1 $read2";
echo "sample: $sample";



#trimmomatic-0.36.jar PE -threads 4 -phred33  $read1  $read2  trimmomatic_f_paired.fq.gz trimmomatic_f_unpaired.fq.gz trimmomatic_r_paired.fq.gz trimmomatic_r_unpaired.fq.gz ILLUMINACLIP:adapter.fa:2:30:10  SLIDINGWINDOW:5:20 
#MINLEN:36

#mv trimmomatic_f_paired.fq.gz ${sample}_1_trim.fq.gz
#mv trimmomatic_r_paired.fq.gz ${sample}_2_trim.fq.gz
#rm trimmomatic_f_unpaired.fq.gz
#rm trimmomatic_r_unpaired.fq.gz 



# bwa  mapping
#ln -s $refseq refseq.fa
bwa index $refseq
bwa mem -t 4 -M $refseq $read1 $read2 > ${sample}_${run}.sam



# ## index reference sequence

samtools faidx $refseq

java   -jar picard.jar CreateSequenceDictionary  REFERENCE=$refseq OUTPUT=$refseq.dict



# # # # sort bam file by picard-tools: SortSam
mkdir tmp

#java   -jar picard.jar SortSam  INPUT=${sample}_${run}.sam OUTPUT=${sample}_${run}.sort.bam SORT_ORDER=coordinate TMP_DIR=./tmp
samtools sort ${sample}_${run}.sam > ${sample}_${run}.sort.bam


# # ## fixmate

java   -jar picard.jar FixMateInformation INPUT=${sample}_${run}.sort.bam OUTPUT=${sample}_${run}.fixmate.bam



# # ## add or replace read groups and sort

java   -jar picard.jar AddOrReplaceReadGroups INPUT=${sample}_${run}.fixmate.bam OUTPUT=${sample}_${run}.rdgrp.bam \
 SORT_ORDER=coordinate RGID=${sample}_${run} RGLB=${sample}_${run} RGPL="Illumina" RGPU=${sample}_${run} \
 RGSM=${sample} RGCN="Sanger"


# # # index the rdgrp.bam file
samtools index ${sample}_${run}.rdgrp.bam


# # ## Picard tools remove duplicates
java   -jar picard.jar MarkDuplicates INPUT=${sample}_${run}.rdgrp.bam REMOVE_DUPLICATES=true  \
  METRICS_FILE=${sample}_${run}.dedup.matrics  OUTPUT=${sample}_${run}.dedup.bam 



# # # index the dedup.bam file
samtools index ${sample}_${run}.dedup.bam



## coverage computation

samtools depth -r yelement ${sample}_${run}.dedup.bam  > ${sample}_${run}.ycoverage.txt
samtools depth -b SGD_coordinatestoretain.bed ${sample}_${run}.dedup.bam > ${sample}_${run}.stdcoverage.txt
samtools depth -b GCcontent5080toretain.bed ${sample}_${run}.dedup.bam > ${sample}_${run}.gc5080coverage.txt


## extract mapping information from bam file for the reads specified in readlist

java   -jar picard.jar FilterSamReads I=${sample}_${run}.rdgrp.bam O=${sample}_${run}.rdgrp.bam.filtered.bam READ_LIST_FILE=${sample}.fasta.readlist FILTER=includeReadList

samtools index -b ${sample}_${run}.rdgrp.bam.filtered.bam



## extract only reads mapped outside Y' element and which are both mapped with an insert of reasonable size

samtools view -L xtoendofchr.bed -U ${sample}_${run}.rdgrp.bam.filtered.bam.mappedoutsidetel ${sample}_${run}.rdgrp.bam.filtered.bam

awk '$9 >= 35 || $9 <= -35 { print }' ${sample}_${run}.rdgrp.bam.filtered.bam.mappedoutsidetel > ${sample}_${run}.rdgrp.bam.filtered.bam.mappedoutsidetel.insertsize35

rm ${sample}_${run}.rdgrp.bam.filtered.bam.mappedoutsidetel



## extract only reads mapped on Y' element and which are first in pair

samtools view -f 64 -F 4 ${sample}_${run}.rdgrp.bam.filtered.bam yelement > ${sample}_${run}.rdgrp.bam.filtered.bam.firstinpair



## extract only reads mapped on Y' element and which are second in pair

samtools view -f 128 -F 4 ${sample}_${run}.rdgrp.bam.filtered.bam yelement > ${sample}_${run}.rdgrp.bam.filtered.bam.secondinpair



## classify reads as ITS not associated with Y' element (<sample>.NOTYITS),ITS associated with Y' element (<sample>.YITS), telomeric (<sample>.TEL)  

perl extractitssgd.pl ${sample}.fasta.readscan ${sample}_${run}.rdgrp.bam.filtered.bam.secondinpair ${sample}_${run}.rdgrp.bam.filtered.bam.firstinpair ${sample}_${run}.rdgrp.bam.filtered.bam.mappedoutsidetel.insertsize35



## estimate coverage, non-Y' associated ITS content (nonYITS), Y'-associated ITS content (YITS), telomere length and Y' copy number

perl compute_tel_length.pl ${sample}.fasta.readscan > ${sample}.lengths.txt



## remove old files

rm ${sample}_${run}.sam
rm ${sample}_${run}.sort.bam
rm ${sample}_${run}.fixmate.bam
rm ${sample}_${run}.rdgrp.bam
rm ${sample}_${run}.rdgrp.bam.bai
rm ${sample}_${run}.rdgrp.reads
#rm ${sample}_${run}.dedup.bam
rm ${sample}_${run}.dedup.bam.bai
rm ${sample}_${run}.dedup.matrics
rm ${sample}_${run}.rdgrp.bam.filtered.bam
rm ${sample}_${run}.rdgrp.bam.filtered.bam.bai
rm ${sample}_${run}.rdgrp.bam.filtered.reads
rm ${sample}_${run}.rdgrp.bam.filtered.bam.secondinpair
rm ${sample}_${run}.rdgrp.bam.filtered.bam.firstinpair
rm ${sample}_${run}.rdgrp.bam.filtered.bam.mappedoutsidetel.insertsize35
rm ${sample}_${run}.ycoverage.txt
rm ${sample}_${run}.stdcoverage.txt
rm ${sample}_${run}.gc5080coverage.txt
rm ${sample}.fasta.readscan.YITS
rm ${sample}.fasta.readscan.NOTYITS

rm -r ./tmp

done;

