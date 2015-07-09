#!/bin/bash
#$ -cwd
#$ -l excl=true
#$ -e ppl_$JOB_ID.err
#$ -o ppl_$JOB_ID.out
#$ -b y

indir=$1
outdir=$2
famcode=$3
binbam_method=$4
wdwWG=1500000
wdwEX=30000
split_chr=${spliy_chr:=False}
workdir=$(mktemp -d /tmp/${USER}_working_XXXXXXXXXX)
#workdir=/tmp/${USER}
#mkdir -p $workdir
srcdir=/nethome/asalomatov/projects/ppln
bedopsdir=/bioinfo/software/installs/bedops/git/bin

function cleanup {
    echo "Should you run 'rm -rf $workdir' on $(hostname)?"
}
trap cleanup EXIT

mkdir -p $outdir
mkdir -p ${outdir}/logs

P=$(/nethome/carriero/bin/nprocNoHT)

echo "Running $famcode on $(hostname) in $workdir using $P cores."
echo "Running $famcode on $(hostname) in $workdir using $P cores." > ${outdir}/logs/hostInfo.txt

make -j $P -f ${srcdir}/prepBam.mk FAMCODE=$famcode INDIR=$indir WORKDIR=$workdir TMPDIR=$workdir OUTDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'prepBam.mk finished with errors'
    exit 1
fi

inpbeds=`ls ${workdir}/*-mrg-23.bed`
echo $inbeds
python ${srcdir}/bedUnion.py ${workdir}/${famcode}-uni.bed $outdir $inpbeds
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "${srcdir}/bedUnion.py finished with an error."
    exit 1
fi
python ${srcdir}/bedPad.py ${workdir}/${famcode}-uni.bed ${workdir}/${famcode}-uni-mrg.bed $bedopsdir 100 $outdir
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

make -j $P -f ${srcdir}/procBam.mk FAMCODE=$famcode WORKDIR=$workdir TMPDIR=$workdir OUTDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'procBam.mk finished with errors'
    exit 1
fi

make -j $P -f ${srcdir}/callHC_FB.mk FAMCODE=$famcode WORKDIR=$workdir TMPDIR=$workdir OUTDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo 'callHC_FB.mk finished with errors'
    exit 1
fi
