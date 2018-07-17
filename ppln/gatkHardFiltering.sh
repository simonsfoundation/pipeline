#!/bin/bash

include_file=$1
input_vcf=$2
out_vcf=$3

refGenome=`grep "^GENOMEREF =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2`
gatk_jar=`grep "^GATK =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2` 

TOOLSDIR=`grep "^TOOLSDIR =" $include_file | cut -d'=' -f 2 | cut -d' ' -f 2`
BGZIP=${TOOLSDIR}/bin/bgzip
TABIX=${TOOLSDIR}/bin/tabix
BCFTOOLS=${TOOLSDIR}/bin/bcftools


java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T SelectVariants \
    -V $input_vcf \
    -o ${input_vcf}.raw_snps.vcf\
    -R $refGenome \
    -selectType SNP  -nt 4

java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T VariantFiltration \
    -V ${input_vcf}.raw_snps.vcf \
    -R $refGenome \
    --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0"  \
    --filterName "HardSnp"  \
    -o ${input_vcf}.filtered_snps.vcf 
       
java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T SelectVariants \
    -V $input_vcf \
    -o ${input_vcf}.raw_indels.vcf \
    -R $refGenome \
    -selectType INDEL -nt 4


java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T VariantFiltration \
    -V ${input_vcf}.raw_indels.vcf \
    -R $refGenome \
    --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0"  \
    --filterName "HardIndel"  \
    -o ${input_vcf}.filtered_indels.vcf 


#1:option1    
java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T CombineVariants \
    -V ${input_vcf}.filtered_snps.vcf  \
    -V ${input_vcf}.filtered_indels.vcf \
    -o ${out_vcf} \
    -R $refGenome \
    --genotypemergeoption UNSORTED -nt 4

rm ${input_vcf}.raw_snps* ${input_vcf}.raw_indels*

#bgzip and tabix filtered_snps
${BGZIP} -f ${input_vcf}.filtered_snps.vcf 
${TABIX} -f -p vcf ${input_vcf}.filtered_snps.vcf.gz
#bgzip and tabix filtered indels
${BGZIP} -f ${input_vcf}.filtered_indels.vcf
${TABIX} -f -p vcf ${input_vcf}.filtered_indels.vcf.gz

#option 2a
${BCFTOOLS} concat -a ${input_vcf}.filtered_snps.vcf.gz  ${input_vcf}.filtered_indels.vcf.gz > ${input_vcf}.filtered.temp.vcf
${BCFTOOLS} view -h ${input_vcf}.filtered.temp.vcf > ${out_vcf}.bcf1.vcf
${BCFTOOLS} view -H ${input_vcf}.filtered.temp.vcf |sort -V -k1,1 -k2,2 >> ${out_vcf}.bcf1.vcf

${BGZIP} -f ${out_vcf}.bcf1.vcf
${TABIX} -f -p vcf  ${out_vcf}.bcf1.vcf.gz

rm ${input_vcf}.filtered.temp.vcf

#option 2b
${BCFTOOLS} view -h ${input_vcf}.filtered_snps.vcf.gz > ${input_vcf}.filtered_snps.vcf.bcfsorted.vcf
${BCFTOOLS} view -H ${input_vcf}.filtered_snps.vcf.gz |sort -V -k1,1 -k2,2 >> ${input_vcf}.filtered_snps.vcf.bcfsorted.vcf
${BGZIP} -f ${input_vcf}.filtered_snps.vcf.bcfsorted.vcf
${TABIX} -f -p vcf ${input_vcf}.filtered_snps.vcf.bcfsorted.vcf.gz

${BCFTOOLS} view -h ${input_vcf}.filtered_indels.vcf.gz > ${input_vcf}.filtered_indels.vcf.bcfsorted.vcf
${BCFTOOLS} view -H ${input_vcf}.filtered_indels.vcf.gz |sort -V -k1,1 -k2,2 >> ${input_vcf}.filtered_indels.vcf.bcfsorted.vcf
${BGZIP} -f ${input_vcf}.filtered_indels.vcf.bcfsorted.vcf
${TABIX} -f -p vcf ${input_vcf}.filtered_indels.vcf.bcfsorted.vcf.gz


${BCFTOOLS} concat -a ${input_vcf}.filtered_snps.vcf.bcfsorted.vcf.gz  ${input_vcf}.filtered_indels.vcf.bcfsorted.vcf.gz > ${input_vcf}.filtered_bcfsorted.temp.vcf
${BCFTOOLS} view -h ${input_vcf}.filtered_bcfsorted.temp.vcf > ${out_vcf}.bcf2.vcf
${BCFTOOLS} view -H ${input_vcf}.filtered_bcfsorted.temp.vcf |sort -V -k1,1 -k2,2 >> ${out_vcf}.bcf2.vcf

${BGZIP} -f ${out_vcf}.bcf2.vcf
${TABIX} -f -p vcf  ${out_vcf}.bcf2.vcf.gz

rm ${input_vcf}.filtered_snps.vcf* ${input_vcf}.filtered_indels.vcf* ${input_vcf}.filtered_bcfsorted.temp.vcf

