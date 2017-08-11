#!/bin/bash

gvcf_dir=$1
refGenome=$2
gatk_jar=$3
dbsnp=$4
outp_file=$5

gvcf=$(ls $gvcf_dir/*.g.vcf.gz)
for i in $gvcf; do input_gvcf="$input_gvcf --variant $i"; done

java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T GenotypeGVCFs \
    $input_gvcf \
    -o $outp_file \
    -R $refGenome \
    --dbsnp $dbsnp \
    --standard_min_confidence_threshold_for_calling 10.0 \
    --standard_min_confidence_threshold_for_emitting 10.0

