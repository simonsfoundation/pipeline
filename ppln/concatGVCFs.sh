#!/bin/bash
# this is to merge bin gvcf manually for a few early batches where 
# pipeline have not done that

bam_dir=$1
gvcf_dir=$2
P=$3

bamfiles=$(ls ${bam_dir}/*.bam)
cd $gvcf_dir

ls *bin.g.vcf | xargs -n1 -P $P bgzip
ls *bin.g.vcf.gz | xargs -n1 -P $P tabix -p vcf
for bf in $bamfiles 
do
    echo $bf
    bn="${bf%.*}"
    bn=$(basename $bn)
    echo $bn
    bcftools concat -a -D  ${bn}*bin.g.vcf.gz > ${bn}-temp.g.vcf
    bcftools view -h ${bn}-temp.g.vcf > ${bn}.g.vcf
    bcftools view -H ${bn}-temp.g.vcf | sort -V -k1,1 -k2,2 >> ${bn}.g.vcf
    bgzip -f ${bn}.g.vcf
    tabix -f -p vcf ${bn}.g.vcf.gz
    rm ${bn}*-bin.g.vcf*
done
