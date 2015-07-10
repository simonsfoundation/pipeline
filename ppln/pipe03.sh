#!/bin/bash                

### bam cleaning, parallelization, and variant callers
# submit to cluster
# sbatch -J ssc11056 -N 1 --exclusive -D ./ ~/projects/ppln/pipe03.sh \
# /mnt/ceph/asalomatov/SSC_Eichler/data_S3/                           \
# /mnt/ceph/asalomatov/SSC_Eichler/rerun/ssc11056 11056 WG 0 tmp      \
# /nethome/asalomatov/projects/ppln/include_150607_new_cl.mk 1        \
# ,Reorder,FixGroups,FilterBam,DedupBam,Metrics,IndelRealign,BQRecalibrate,SplitBam,HaplotypeCaller,Freebayes,Platypus,HaplotypeCallerGVCF, \
# 1        
# /path/to/pipeline/ppln

indir=$1         #directory with bam file(s)
outdir=$2        #will be created, for final output and metrics
famcode=$3       #1, if bams are 1.p1.bam, 1.fa.bam, 1.mo.bam
binbam_method=$4 #EX, WG(recommended)
skip_binbam=$5   #if not 1 recompute bins, else use existing ones - for testing
working_dir=$6   #tmp to work in /tmp, else work in outdir
inclmk=$7        #makefile with variable definition 
cleanup=$8       #if 0 dont delete intermediate files
conf=$9          #comma surrounded list of unordered instructions
rm_work_dir=${10} #if 1 remove working dir on exit 
srcdir=${11}      #dir with scripts, eg ~/pipeline/ppln
max_cores=${12}   #max physical cpu cores to utilize
echo "config is $conf"

sfx=
inpd=$indir
split_chr="True"
Nfiles=50
if [ "$working_dir" = "tmp" -o "$working_dir" = "TMP" ] 
then
    workdir=$(mktemp -d /tmp/${USER}_working_${famcode}_XXXXXXXXXX)
else
    workdir=${outdir}/work
fi

function cleanup {
    echo "Should you run 'rm -rf $workdir' on $(hostname)?"
    if [ $rm_work_dir -eq 1 ]; then
        echo "running 'rm -rf $workdir' on $(hostname)"
        rm -rf $workdir
    fi
}
trap cleanup EXIT

metricsdir=${outdir}/metrics
mkdir -p ${outdir}/logs
mkdir -p $metricsdir

#number of physical cores
P=$(lscpu -p | grep -v '^#' | awk '{split($0,a,","); print a[2]}' | sort | uniq | wc -l)
if [ $max_cores -lt $P ]; then
    P=$max_cores
fi

echo "Running $famcode on $(hostname) in $workdir using $P cores."
echo "Running ${0} $@ on $(hostname) in $workdir using $P cores." > ${outdir}/logs/runInfo.txt

if [[ $conf == *",Reorder,"* ]]; then
    make -j $P -f ${srcdir}/reordBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$indir OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "reordBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    sfx='-re'
    prevsfx=$sfx
    inpd=$workdir
fi

if [[ $conf == *",FixGroups,"* ]]; then
    make -j $P -f ${srcdir}/fxgrBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "fxgrBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    if [ $cleanup -ne 0 ]; then
        rm ${workdir}/*-re.bam*
    fi
    sfx='-fxgr'
    prevsfx=$sfx
    inpd=$workdir
    make -j $P -f ${srcdir}/indexBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "indexBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
fi


if [[ $conf == *",FilterBam,"* ]]; then
    make -j $P -f ${srcdir}/flrBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "flrBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    if [ $cleanup -ne 0 ]; then
        rm ${workdir}/*-fxgr.bam*
    fi
    sfx='-flr'
    prevsfx=$sfx
    inpd=$workdir
fi

if [[ $conf == *",DedupBam,"* ]]; then
    make -j $P -f ${srcdir}/dedupBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "dedupBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    sfx='-dp'
    prevsfx=$sfx
    inpd=$workdir
    cp -p ${workdir}/*.dedupMetrics ${metricsdir}/
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'copying dedupMetrics failed'
        exit 1
    fi
    if [ $cleanup -ne 0 ]; then
        rm ${workdir}/*-flr.bam*
    fi

    make -j $P -f ${srcdir}/indexBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "indexBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
fi

if [[ $conf == *",Metrics,"* ]]; then
    make -j $P -f ${srcdir}/multMetricsBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$metricsdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "multMetricsBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/gcBiasMetricsBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$metricsdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "gcBiasMetricsBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/flStBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$metricsdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "flStBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
fi


make -j $P -f ${srcdir}/genomeCvrgBed.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'genomeCvrgBed.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
cp -p ${workdir}/*.bed ${metricsdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying copying genome coverage bed failed'
    exit 1
fi

make -j $P -f ${srcdir}/filter23Bed.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filter23Bed.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/filter23Bam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filter23Bam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
sfx='-23'
prevsfx=$sfx

cp -p ${workdir}/*-irr.bam ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying *-irr.bam failed'
    exit 1
fi

make -j $P -f ${srcdir}/indexBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
if [ $cleanup -ne 0 ]; then
    rm ${workdir}/*-dp.bam*
    rm ${workdir}/*-irr.bam*
fi

# callable loci

make -j $P -f ${srcdir}/callableLoci.mk SUFFIX=$sfx INCLMK=$inclmk PREFIX=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callableLoci.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

cp -p ${workdir}/*.summary ${metricsdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying callable loci summary failed'
    exit 1
fi

make -j $P -f ${srcdir}/filterCallNoCall.mk INCLMK=$inclmk PREFIX=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-cloc
#make -j $P -f ${srcdir}/filterCallNoCall.mk INCLMK=$inclmk PREFIX=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-cloc FILTER2=
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "filterCallNoCall.mk INCLMK=$inclmk finished with errors"
    exit 1
fi
cp -p ${workdir}/*call.bed ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying call/nocall bed failed'
    exit 1
fi

if [[ $conf == *",IndelRealign,"* ]]; then
    make -j $P -f ${srcdir}/realTargCreator.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "realTargCreator.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/indelRealign.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "indelRealign.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    sfx='-rlgn'
    prevsfx=$sfx
    inpd=$workdir
fi

if [[ $conf == *",BQRecalibrate,"* ]]; then
    make -j $P -f ${srcdir}/baseRecalibrate.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "baseRecalibrate.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/printBqsrReads.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "printBqsrReads.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    if [ $cleanup -ne 0 ]; then
        rm ${workdir}/*-rlgn.bam*
    fi
    sfx='-rclb'
    prevsfx=$sfx
    inpd=$workdir
fi

# bin bed files
if [[ $skip_binbam -ne 1 ]]; then

    inpbeds=$(ls ${workdir}/*-call.bed)
    echo $inbeds
    python ${srcdir}/bedUnion.py ${workdir}/${famcode}-uni.bed $outdir $inpbeds
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "${srcdir}/bedUnion.py finished with an error."
        exit 1
    fi
    make -j $P -f ${srcdir}/bedPad.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "${srcdir}/bedPad.mk finished with an error."
        exit 1
    fi
    if [ "$binbam_method" == "WG" ]; then
        python ${srcdir}/binBamWG.py ${workdir}/${famcode}-uni-mrg.bed \
        ${workdir}/bin__${famcode}-uni-mrg.bed $Nfiles $outdir
        ret=$?
        echo $ret
        if [ $ret -ne 0 ]; then
            echo "${srcdir}/binBamWG.py finished with an error."
            exit 1
        fi
    fi
    if [ "$binbam_method" == "EX" ]; then
        python ${srcdir}/binBamExome.py ${workdir}/${famcode}-uni-mrg.bed \
        ${workdir}/bin__${famcode}-uni-mrg.bed $Nfiles $split_chr $outdir
        ret=$?
        echo $ret
        if [ $ret -ne 0 ]; then
            echo "${srcdir}/binBamExome.py finished with an error."
            exit 1
        fi
    fi
    mkdir -p ${outdir}/bed
    cp -p ${workdir}/*-uni-mrg.bed ${outdir}/bed
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'copying *-uni-mrg.bed failed'
        exit 1
    fi
fi

if [[ $conf == *",SplitBam,"* ]]; then
    make -j $P -f ${srcdir}/splitBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "splitBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/indexBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "indexBam.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi
    prevsfx=$sfx
    sfx='-bin'
fi

if [[ $conf == *",HaplotypeCaller,"* ]]; then
    make -j $P -f ${srcdir}/callGATK_HC.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'callGATK_HC.mk INCLMK=$inclmk finished with errors'
        exit 1
    fi

    make -j $P -f ${srcdir}/picMergeVcf.mk INCLMK=$inclmk FAMCODE=${famcode}-HC INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "picMergeVcf.mk INCLMK=$inclmk HC finished with errors"
        exit 1
    fi

    make -f ${srcdir}/extractByType.mk INCLMK=$inclmk VARTYPE=indels SUFFIX=-vars PREFIX=$famcode-HC INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'extractByType.mk INCLMK=$inclmk VARTYPE=indels finished with errors'
        exit 1
    fi

    make -f ${srcdir}/extractByType.mk INCLMK=$inclmk VARTYPE=snps SUFFIX=-vars PREFIX=$famcode-HC INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'extractByType.mk INCLMK=$inclmk VARTYPE=snps finished with errors'
        exit 1
    fi

    make -f ${srcdir}/bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=snps PREFIX=$famcode-HC INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir 
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=snps finished with errors'
        exit 1
    fi

    make -f ${srcdir}/bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=indels PREFIX=$famcode-HC INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir 
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=indels finished with errors'
        exit 1
    fi

    make -f ${srcdir}/vcfCombineAllTypes.mk INCLMK=$inclmk SUFFIX=-flr PREFIX=$famcode-HC-vars INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir 
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'vcfCombineAllTypes.mk INCLMK=$inclmk finished with errors'
        exit 1
    fi

    cp -p ${workdir}/${famcode}-HC-vars-flr.vcf.gz* ${outdir}/
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "copying ${famcode}-HC-vars-flr.vcf.gz failed"
        exit 1
    fi
fi

if [[ $conf == *",Freebayes,"* ]]; then
    make -j $P -f ${srcdir}/callFreebayes.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo 'callFreebayes.mk INCLMK=$inclmk finished with errors'
        exit 1
    fi

    make -j $P -f ${srcdir}/vcfConcat.mk INCLMK=$inclmk FAMCODE=${famcode}-FB INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "picMergeVcf.mk INCLMK=$inclmk FB finished with errors"
        exit 1
    fi

    cp -p ${workdir}/${famcode}-FB-vars.vcf.gz* ${outdir}/
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "copying ${famcode}-FB-vars.vcf.gz failed"
        exit 1
    fi
fi

if [[ $conf == *",Platypus,"* ]]; then
    make -j $P -f ${srcdir}/callPlatypus.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "callPlatypus.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/vcfConcat.mk INCLMK=$inclmk FAMCODE=${famcode}-PL INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "picMergeVcf.mk INCLMK=$inclmk PL finished with errors"
        exit 1
    fi

    cp -p ${workdir}/${famcode}-PL-vars.vcf.gz* ${outdir}/
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "copying ${famcode}-PL-vars.vcf.gz failed"
        exit 1
    fi
fi

if [[ $conf == *",HaplotypeCallerGVCF,"* ]]; then
    make -j $P -f ${srcdir}/callGATK_HC_JOINT.mk SUFFIX=$prevsfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$workdir LOGDIR=$outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "callGATK_HC_JOINT.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/genotypeGVCFs.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "genotypeGVCFs.mk INCLMK=$inclmk finished with errors"
        exit 1
    fi

    make -j $P -f ${srcdir}/picMergeVcf.mk INCLMK=$inclmk FAMCODE=${famcode}-JHC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "picMergeVcf.mk INCLMK=$inclmk JHC finished with errors"
        exit 1
    fi

    cp -p ${workdir}/${famcode}-JHC-vars.vcf.gz* ${outdir}/
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "copying ${famcode}-JHC-vars.vcf.gz failed"
        exit 1
    fi
fi

echo 'Run completed'
echo 'Run completed' > ${outdir}/logs/runCompleted.txt
