#!/bin/bash

include_file=$1
input_vcf=$2
out_vcf=$3

refGenome=`grep "^GENOMEREF =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2`
gatk_jar=`grep "^GATK =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2`

java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T LeftAlignAndTrimVariants \
    -R $refGenome \
    --variant $input_vcf \
    -o $out_vcf 
