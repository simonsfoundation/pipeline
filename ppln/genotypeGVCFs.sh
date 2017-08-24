#!/bin/bash

gvcf_dir=$1
refGenome=$2
gatk_jar=$3
dbsnp=$4
outp_dir=$5
outp_file_prefix=$6
srcdir="/mnt/xfs1/home/asalomatov/projects/pipeline/ppln"
inclmk="/mnt/xfs1/home/asalomatov/projects/pipeline/ppln/include.mk"

mkdir -p $outp_dir

gvcf=$(ls $gvcf_dir/*.g.vcf.gz)
for i in $gvcf; do input_gvcf="$input_gvcf --variant $i"; done

java -Xms250g -Xmx500g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T GenotypeGVCFs \
    $input_gvcf \
    -o ${outp_dir}/${outp_file_prefix}-HC-vars.vcf \
    -R $refGenome \
    --dbsnp $dbsnp \
    -nt 25 \
    --standard_min_confidence_threshold_for_calling 10.0 \
    --standard_min_confidence_threshold_for_emitting 10.0

bgzip ${outp_dir}/${outp_file_prefix}-HC-vars.vcf
tabix -f -p vcf ${outp_dir}/${outp_file_prefix}-HC-vars.vcf.gz

make -f ${srcdir}/extractByType.mk \
    INCLMK=$inclmk \
    VARTYPE=indels \
    SUFFIX=-vars \
    PREFIX=${outp_file_prefix}-HC \
    INDIR=$outp_dir \
    OUTDIR=$outp_dir \
    LOGDIR=$outp_dir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
   echo 'extractByType.mk INCLMK=$inclmk VARTYPE=indels finished with errors'
   #exit 1
fi

make -f ${srcdir}/extractByType.mk \
    INCLMK=$inclmk \
    VARTYPE=snps \
    SUFFIX=-vars \
    PREFIX=${outp_file_prefix}-HC \
    INDIR=$outp_dir \
    OUTDIR=$outp_dir \
    LOGDIR=$outp_dir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'extractByType.mk INCLMK=$inclmk VARTYPE=snps finished with errors'
    #exit 1
fi

make -f ${srcdir}/bcftoolsApplyFilter.mk \
    INCLMK=$inclmk \
    VARTYPE=snps \
    PREFIX=${outp_file_prefix}-HC \
    INDIR=$outp_dir \
    OUTDIR=$outp_dir \
    LOGDIR=$outp_dir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=snps finished with errors'
    #exit 1
fi

make -f ${srcdir}/bcftoolsApplyFilter.mk \
    INCLMK=$inclmk \
    VARTYPE=indels \
    PREFIX=${outp_file_prefix}-HC \
    INDIR=$outp_dir \
    OUTDIR=$outp_dir \
    LOGDIR=$outp_dir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=indels finished with errors'
    #exit 1
fi

make -f ${srcdir}/vcfCombineAllTypes.mk \
    INCLMK=$inclmk \
    SUFFIX=-flr \
    PREFIX=${outp_file_prefix}-HC-vars \
    INDIR=$outp_dir \
    OUTDIR=$outp_dir \
    LOGDIR=$outp_dir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'vcfCombineAllTypes.mk INCLMK=$inclmk finished with errors'
    #exit 1
fi

