#!/bin/bash
#$ -cwd
#$ -l excl=true
####$ -e ppl_$JOB_ID.err
####$ -o ppl_$JOB_ID.out
#$ -b y

### bam cleaning, parallelization, and variant callers

indir=$1
outdir=$2
famcode=$3
binbam_method=$4
skip_binbam=$5
working_dir=$6
inclmk=$7
cleanup=$8  #if 0 dont delete interm files
split_chr="True"
Nfiles=50
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
#python -c 'import glob;print glob.glob("vcf*")' | wc -w

function cleanup {
    echo "Should you run 'rm -rf $workdir' on $(hostname)?"
    rm -rf $workdir
}
trap cleanup EXIT

metricsdir=${outdir}/metrics
#mkdir -p $outdir
mkdir -p ${outdir}/logs
mkdir -p $metricsdir

P=$(/nethome/carriero/bin/nprocNoHT)
### the following is for running locally
if [ "$(hostname)" = "scda000" -o "$(hostname)" = "scda001" -o "$(hostname)" = "scda008" ]; then
    P=12
fi

echo "Running $famcode on $(hostname) in $workdir using $P cores."
echo "Running $@ on $(hostname) in $workdir using $P cores." > ${outdir}/logs/runInfo.txt

make -j $P -f ${srcdir}/reordBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$indir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'reordBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/fxgrBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'fxgrBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
if [ $cleanup -ne 0 ]; then
    rm ${workdir}/*-re.bam*
fi

make -j $P -f ${srcdir}/indexBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/flrBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'flrBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
if [ $cleanup -ne 0 ]; then
    rm ${workdir}/*-fxgr.bam*
fi

make -j $P -f ${srcdir}/dedupBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'dedupBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
if [ $cleanup -ne 0 ]; then
    rm ${workdir}/*-flr.bam*
fi

make -j $P -f ${srcdir}/indexBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

cp -p ${workdir}/*.dedupMetrics ${metricsdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying dedupMetrics failed'
    exit 1
fi

make -j $P -f ${srcdir}/multMetricsBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$metricsdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'multMetricsBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/gcBiasMetricsBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$metricsdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'gcBiasMetricsBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi


make -j $P -f ${srcdir}/flStBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$metricsdir LOGDIR=$outdir SUFFIX=-dp
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'flStBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi


make -j $P -f ${srcdir}/genomeCvrgBed.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp
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

#make -j $P -f ${srcdir}/mergeBed.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-mrg
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'mergeBed.mk INCLMK=$inclmk finished with errors'
#    exit 1
#fi

make -j $P -f ${srcdir}/filter23Bed.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filter23Bed.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/filter23Bam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-dp 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filter23Bam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

cp -p ${workdir}/*-irr.bam ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying *-irr.bam failed'
    exit 1
fi

make -j $P -f ${srcdir}/indexBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23
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

make -j $P -f ${srcdir}/callableLoci.mk INCLMK=$inclmk PREFIX=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23 
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

make -j $P -f ${srcdir}/filterCallNoCall.mk INCLMK=$inclmk PREFIX=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-cloc
#make -j $P -f ${srcdir}/filterCallNoCall.mk INCLMK=$inclmk PREFIX=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-cloc FILTER2=
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'filterCallNoCall.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
cp -p ${workdir}/*call.bed ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'copying call/nocall bed failed'
    exit 1
fi

make -j $P -f ${srcdir}/realTargCreator.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'realTargCreator.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/indelRealign.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-23 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indelRealign.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/baseRecalibrate.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rlgn 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'baseRecalibrate.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/printBqsrReads.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rlgn 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'printBqsrReads.mk INCLMK=$inclmk finished with errors'
    exit 1
fi
if [ $cleanup -ne 0 ]; then
    rm ${workdir}/*-rlgn.bam*
fi

# bin bed files
if [ $skip_binbam -ne 1 ]; then
#    make -j $P -f ${srcdir}/filterBedByCvrg.mk INCLMK=$inclmk PREFIX=$famcode SUFFIX=-rclb MINCVRG=1 INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
#    ret=$?
#    echo $ret
#    if [ $ret -ne 0 ]; then
#        echo 'filterBedByCvrg.mk INCLMK=$inclmk finished with errors'
#        exit 1
#    fi
#
#    make -j $P -f ${srcdir}/bedopsIntersect.mk INCLMK=$inclmk PREFIX=$famcode SUFFIX=-flr INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
#    ret=$?
#    echo $ret
#    if [ $ret -ne 0 ]; then
#        echo 'bedopsIntersect.mk INCLMK=$inclmk finished with errors'
#        exit 1
#    fi

#    make -j $P -f ${srcdir}/bedopsEvthn.mk INCLMK=$inclmk PREFIX=$famcode SUFFIX=-flr INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
#    ret=$?
#    echo $ret
#    if [ $ret -ne 0 ]; then
#        echo 'bedopsEvthn.mk INCLMK=$inclmk finished with errors'
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
    #make -j $P -f ${srcdir}/mergeBed.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-mrg
    #ret=$?
    #echo $ret
    #if [ $ret -ne 0 ]; then
    #    echo 'mergeBed.mk INCLMK=$inclmk finished with errors'
    #    exit 1
    #fi

    python ${srcdir}/bedPad.py ${workdir}/${famcode}-uni.bed ${workdir}/${famcode}-uni-mrg.bed $bedopsdir 200 $outdir
    ret=$?
    echo $ret
    if [ $ret -ne 0 ]; then
        echo "${srcdir}/bedPad.py finished with an error."
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

#make -j $P -f ${srcdir}/bedUniMergeBin.mk INCLMK=$inclmk PREFIX=$famcode RANGE=200 INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-call 
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'bedUniMergeBin.mk INCLMK=$inclmk finished with errors'
#    exit 1
#fi

#make -j $P -f ${srcdir}/splitBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb 
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'splitBam.mk INCLMK=$inclmk finished with errors'
#    exit 1
#fi

make -j $P -f ${srcdir}/indexBam.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'indexBam.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/callGATK_HC.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callGATK_HC.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/picMergeVcf.mk INCLMK=$inclmk FAMCODE=${famcode}-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "picMergeVcf.mk INCLMK=$inclmk HC finished with errors"
    exit 1
fi
#make -j $P -f ${srcdir}/vcfConcat.mk INCLMK=$inclmk FAMCODE=${famcode}-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'vcfConcat.mk INCLMK=$inclmk HC finished with errors'
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
#make -j $P -f ${srcdir}/vcfCombine.mk INCLMK=$inclmk FAMCODE=${famcode}-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'vcfCombine.mk INCLMK=$inclmk HC finished with errors'
#    exit 1
#fi

make -f ${srcdir}/extractByType.mk INCLMK=$inclmk VARTYPE=indels SUFFIX=-vars PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'extractByType.mk INCLMK=$inclmk VARTYPE=indels finished with errors'
    exit 1
fi

make -f ${srcdir}/extractByType.mk INCLMK=$inclmk VARTYPE=snps SUFFIX=-vars PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'extractByType.mk INCLMK=$inclmk VARTYPE=snps finished with errors'
    exit 1
fi

make -f ${srcdir}/bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=snps PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=snps finished with errors'
    exit 1
fi

make -f ${srcdir}/bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=indels PREFIX=$famcode-HC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'bcftoolsApplyFilter.mk INCLMK=$inclmk VARTYPE=indels finished with errors'
    exit 1
fi

make -f ${srcdir}/vcfCombineAllTypes.mk INCLMK=$inclmk  SUFFIX=-flr PREFIX=$famcode-HC-vars INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir 
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

make -j $P -f ${srcdir}/callFreebayes.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb 
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callFreebayes.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/vcfConcat.mk INCLMK=$inclmk FAMCODE=${famcode}-FB INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "picMergeVcf.mk INCLMK=$inclmk FB finished with errors"
    exit 1
fi

#make -j $P -f ${srcdir}/vcfCombine.mk INCLMK=$inclmk FAMCODE=${famcode}-FB INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'vcfCombine.mk INCLMK=$inclmk FB finished with errors'
#    exit 1
#fi

cp -p ${workdir}/${famcode}-FB-vars.vcf.gz* ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "copying ${famcode}-FB-vars.vcf.gz failed"
    exit 1
fi

make -j $P -f ${srcdir}/callPlatypus.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callPlatypus.mk INCLMK=$inclmk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/vcfConcat.mk INCLMK=$inclmk FAMCODE=${famcode}-PL INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'picMergeVcf.mk INCLMK=$inclmk PL finished with errors'
    exit 1
fi

#make -j $P -f ${srcdir}/vcfCombine.mk INCLMK=$inclmk FAMCODE=${famcode}-PL INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'vcfCombine.mk INCLMK=$inclmk PL finished with errors'
#    exit 1
#fi

cp -p ${workdir}/${famcode}-PL-vars.vcf.gz* ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "copying ${famcode}-PL-vars.vcf.gz failed"
    exit 1
fi

make -j $P -f ${srcdir}/callGATK_HC_JOINT.mk INCLMK=$inclmk FAMCODE=$famcode INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-rclb
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

#make -j $P -f ${srcdir}/vcfCombine.mk INCLMK=$inclmk FAMCODE=${famcode}-JHC INDIR=$workdir OUTDIR=$workdir LOGDIR=$outdir SUFFIX=-bin.vcf.gz
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo 'vcfCombine.mk INCLMK=$inclmk JHC finished with errors'
#    exit 1
#fi

cp -p ${workdir}/${famcode}-JHC-vars.vcf.gz* ${outdir}/
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "copying ${famcode}-JHC-vars.vcf.gz failed"
    exit 1
fi


