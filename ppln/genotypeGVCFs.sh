#!/bin/bash
#IA: $4 is  30, $5 is 10 for SPARK pilot

gvcf_dir=$1
include_file=$2
outp_file=$3
callingThr=$4
emittingThr=$5

refGenome=`grep "^GENOMEREF =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2`
gatk_jar=`grep "^GATK =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2`
dbsnp=`grep "^DBSNP =" $include_file | cut -d'=' -f 2 | cut -d ' ' -f 2`

gvcf=$(ls $gvcf_dir/*.g.vcf.gz)
for i in $gvcf; do input_gvcf="$input_gvcf --variant $i"; done

java -Xms500g -Xmx750g -XX:+UseSerialGC -Djava.io.tmpdir="/tmp" \
    -jar $gatk_jar \
    -T GenotypeGVCFs \
    $input_gvcf \
    -o $outp_file \
    -R $refGenome \
    --dbsnp $dbsnp \
    --standard_min_confidence_threshold_for_calling $callingThr \
    --standard_min_confidence_threshold_for_emitting $emittingThr \
    -nt 16 \
    -A AlleleBalance -A BaseQualityRankSumTest -A Coverage -A HomopolymerRun -A MappingQualityRankSumTest -A MappingQualityZero \
    -A ChromosomeCounts -A GenotypeSummaries -A StrandOddsRatio \
    -A QualByDepth -A RMSMappingQuality -A FisherStrand -A InbreedingCoeff -A ClippingRankSumTest -A DepthPerSampleHC  

