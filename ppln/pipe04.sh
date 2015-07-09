#!/bin/bash
#$ -cwd
#$ -l excl=true
#$ -e ppl_$JOB_ID.err
#$ -o ppl_$JOB_ID.out
#$ -b y

### bam cleaning, parallelization, and variant callers
### the same as pipe03 but w/o splitting bam files

indir=$1
outdir=$2
famcode=$3
binbam_method=$4
skip_binbam=$5
working_dir=$6
split_chr=1
wdwWG=1500000
wdwEX=500000
if [ "$working_dir" = "tmp" -o "$working_dir" = "TMP" ] 
then
    workdir=$(mktemp -d /tmp/${USER}_working_${famcode}_XXXXXXXXXX)
else
    workdir=${outdir}/work
fi
#workdir=/tmp/${USER}_working_${famcode}
#mkdir -p $workdir
#workdir=$(pwd)
srcdir=/nethome/asalomatov/projects/ppln
bedopsdir=/bioinfo/software/installs/bedops/git/bin

function cleanup {
    echo "Should you run 'rm -rf $workdir' on $(hostname)?"
    rm -rf $workdir
}
trap cleanup EXIT

metricsdir=${outdir}/metrics
mkdir -p $outdir
mkdir -p ${outdir}/logs
mkdir -p $metricsdir

P=$(/nethome/carriero/bin/nprocNoHT)
### the following is for running locally
if [ "$(hostname)" = "scda000" -o "$(hostname)" = "scda001" -o "$(hostname)" = "scda008" ]; then
    P=12
fi

echo "Running $famcode on $(hostname) in $workdir using $P cores."
echo "Running $famcode on $(hostname) in $workdir using $P cores." > ${outdir}/logs/hostInfo.txt

make -j $P -f ${srcdir}/reordBam.mk FAMCODE=$famcode INDIR=$indir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'reordBam.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/fxgrBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'fxgrBam.mk finished with errors'
    exit 1
fi
rm ${workdir}/*-re.bam*

make -j $P -f ${srcdir}/indexBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/flrBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'flrBam.mk finished with errors'
    exit 1
fi
rm ${workdir}/*-fxgr.bam*

make -j $P -f ${srcdir}/dedupBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'dedupBam.mk finished with errors'
    exit 1
fi
rm ${workdir}/*-flr.bam*

make -j $P -f ${srcdir}/indexBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk finished with errors'
    exit 1
fi

#cp -p ${workdir}/*.dedupMetrics ${metricsdir}/
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'copying dedupMetrics failed'
#    exit 1
#fi
#
#make -j $P -f ${srcdir}/multMetricsBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$metricsdir LOGDIR=$outdir SUFFIX=-dp
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'multMetricsBam.mk finished with errors'
#    exit 1
#fi
#
#make -j $P -f ${srcdir}/gcBiasMetricsBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$metricsdir LOGDIR=$outdir SUFFIX=-dp
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'gcBiasMetricsBam.mk finished with errors'
#    exit 1
#fi
#

make -j $P -f ${srcdir}/flStBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$metricsdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'flStBam.mk finished with errors'
    exit 1
fi


make -j $P -f ${srcdir}/genomeCvrgBed.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'genomeCvrgBed.mk finished with errors'
    exit 1
fi

#make -j $P -f ${srcdir}/mergeBed.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-mrg
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'mergeBed.mk finished with errors'
#    exit 1
#fi

make -j $P -f ${srcdir}/filter23Bed.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filter23Bed.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/filter23Bam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filter23Bam.mk finished with errors'
    exit 1
fi

cp -p ${workdir}/*-irr.bam ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying *-irr.bam failed'
    exit 1
fi

make -j $P -f ${srcdir}/indexBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk finished with errors'
    exit 1
fi
rm ${workdir}/*-dp.bam*
rm ${workdir}/*-irr.bam*

# callable loci

make -j $P -f ${srcdir}/callableLoci.mk PREFIX=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callableLoci.mk finished with errors'
    exit 1
fi

cp -p ${workdir}/*.summary ${metricsdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying callable loci summary failed'
    exit 1
fi

make -j $P -f ${srcdir}/filterCallNoCall.mk PREFIX=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-cloc 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filterCallNoCall.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/realTargCreator.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'realTargCreator.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/indelRealign.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indelRealign.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/baseRecalibrate.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rlgn 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'baseRecalibrate.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/printBqsrReads.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rlgn 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'printBqsrReads.mk finished with errors'
    exit 1
fi
rm ${workdir}/*-rlgn.bam*

# bin bed files
if [ $skip_binbam -ne 1 ]; then
#    make -j $P -f ${srcdir}/filterBedByCvrg.mk PREFIX=$famcode SUFFIX=-rclb MINCVRG=1 INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
#    ret=$?
#    echo $ret
#    if [ $ret -ne 0 ]; then
#        echo 'filterBedByCvrg.mk finished with errors'
#        exit 1
#    fi
#
#    make -j $P -f ${srcdir}/bedopsIntersect.mk PREFIX=$famcode SUFFIX=-flr INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
#    ret=$?
#    echo $ret
#    if [ $ret -ne 0 ]; then
#        echo 'bedopsIntersect.mk finished with errors'
#        exit 1
#    fi

#    make -j $P -f ${srcdir}/bedopsEvthn.mk PREFIX=$famcode SUFFIX=-flr INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
#    ret=$?
#    echo $ret
#    if [ $ret -ne 0 ]; then
#        echo 'bedopsEvthn.mk finished with errors'
#        exit 1
#    fi

    inpbeds=$(ls ${workdir}/*-call.bed)
    echo $inbeds
    python ${srcdir}/bedUnion.py ${workdir}/${famcode}-uni.bed $outdir $inpbeds
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "${srcdir}/bedUnion.py finished with an error."
        exit 1
    fi
    #make -j $P -f ${srcdir}/mergeBed.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-mrg
    #ret=$?
    #echo $ret
    #if [ $ret -ne 0 ]; then
    #    echo 'mergeBed.mk finished with errors'
    #    exit 1
    #fi

    python ${srcdir}/bedPad.py ${workdir}/${famcode}-uni.bed ${workdir}/${famcode}-uni-mrg.bed $bedopsdir 0 $outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "${srcdir}/bedPad.py finished with an error."
        exit 1
    fi
    if [ "$binbam_method" == "WG" ]; then
        python ${srcdir}/binBamWG.py ${workdir}/${famcode}-uni-mrg.bed \
        ${workdir}/bin__${famcode}-uni-mrg.bed $wdwWG $outdir
        ret=$?
        echo $ret
        if [ $ret -ne 0 ]; then
            echo "${srcdir}/binBamWG.py finished with an error."
            exit 1
        fi
    fi
    if [ "$binbam_method" == "EX" ]; then
        python ${srcdir}/binBamExome.py ${workdir}/${famcode}-uni-mrg.bed \
        ${workdir}/bin__${famcode}-uni-mrg.bed $wdwEX $split_chr $outdir
        ret=$?
        echo $ret
        if [ $ret -ne 0 ]; then
            echo "${srcdir}/binBamExome.py finished with an error."
            exit 1
        fi
    fi
fi

#make -j $P -f ${srcdir}/bedUniMergeBin.mk PREFIX=$famcode RANGE=200 INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-call 
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'bedUniMergeBin.mk finished with errors'
#    exit 1
#fi

#make -j $P -f ${srcdir}/splitBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb 
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'splitBam.mk finished with errors'
#    exit 1
#fi
#
#make -j $P -f ${srcdir}/indexBam.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'indexBam.mk finished with errors'
#    exit 1
#fi

make -j $P -f ${srcdir}/callGATK_HC.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callGATK_HC.mk finished with errors'
    exit 1
fi

#make -j $P -f ${srcdir}/gatkCombVar.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$outdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'gatkCombVar.mk finished with errors'
#    exit 1
#fi

#temp copy all vcf files to output dir.
#mkdir -p ${outdir}/vcf
#cp -p ${workdir}/*-bin.vcf.gz ${outdir}/vcf 
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'vcf copy finished with errors'
#    exit 1
#fi
#
make -j $P -f ${srcdir}/vcfCombine.mk FAMCODE=${famcode}-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'vcfCombine.mk HC finished with errors'
    exit 1
fi

make -f ${srcdir}/extractByType.mk VARTYPE=indels SUFFIX=-vars PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'extractByType.mk VARTYPE=indels finished with errors'
    exit 1
fi

make -f ${srcdir}/extractByType.mk VARTYPE=snps SUFFIX=-vars PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'extractByType.mk VARTYPE=snps finished with errors'
    exit 1
fi

make -f ${srcdir}/bcftoolsApplyFilter.mk VARTYPE=snps PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'bcftoolsApplyFilter.mk VARTYPE=snps finished with errors'
    exit 1
fi

make -f ${srcdir}/bcftoolsApplyFilter.mk VARTYPE=indels PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'bcftoolsApplyFilter.mk VARTYPE=indels finished with errors'
    exit 1
fi

make -f ${srcdir}/vcfCombineAllTypes.mk  SUFFIX=-flr PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$outdir LOGDIR=$outdir 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'vcfCombineAllTypes.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/callFreebayes.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callFreebayes.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/vcfCombine.mk FAMCODE=${famcode}-FB INDIR=$workdir OUTDIR=$outdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'vcfCombine.mk FB finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/callPlatypus.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callPlatypus.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/vcfCombine.mk FAMCODE=${famcode}-PL INDIR=$workdir OUTDIR=$outdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'vcfCombine.mk PL finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/callGATK_HC_JOINT.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callGATK_HC_JOINT.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/genotypeGVCFs.mk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'genotypeGVCFs.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/vcfCombine.mk FAMCODE=${famcode}-JHC INDIR=$workdir OUTDIR=$outdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'vcfCombine.mk JHC finished with errors'
    exit 1
fi

