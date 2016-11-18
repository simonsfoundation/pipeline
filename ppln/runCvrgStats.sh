#!/bin/bash
indir=$1         #directory with bam file(s)
outdir=$2        #will be created, for final output and metrics
famcode=$3       #1, if bams are 1.p1.bam, 1.fa.bam, 1.mo.bam
working_dir='tmp'   #tmp to work in /tmp, else work in outdir
inclmk='~/projects/pipeline/ppln/include.mk'        #makefile with variable definition 
cleanup=1       #if 0 dont delete intermediate files
rm_work_dir=1 #if 1 remove working dir on exit 
srcdir='~/projects/pipeline/ppln/'      #dir with scripts, eg ~/pipeline/ppln
max_cores=12   #max physical cpu cores to utilize

sfx=
inpd=$indir
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


#make -j $P -f ${srcdir}/indexBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$inpd OUTDIR=$inpd LOGDIR=$outdir
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo "indexBam.mk INCLMK=$inclmk finished with errors"
#    exit 1
#fi


#make -j $P -f ${srcdir}/filterBamTarget.mk TARGBED=/mnt/scratch/asalomatov/data/b37/b37.exome-pm50.bed NEWSUFFIX=-exome INCLMK=$in#clmk PREFIX=$famcode INDIR=$inpd OUTDIR=$outdir LOGDIR=$outdir
#ret=$?
#echo $ret
#if [ $ret -ne 0 ]; then
#    echo "filterBamTarget.mk INCLMK=$inclmk finished with errors"
#    exit 1
#fi

make -j $P -f ${srcdir}/filterBamTarget.mk TARGBED=/mnt/scratch/asalomatov/data/b37/ensembl-genes-coding_all_exome.bed NEWSUFFIX=-genes INCLMK=$inclmk PREFIX=$famcode INDIR=$inpd OUTDIR=$outdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "filterBamTarget.mk INCLMK=$inclmk finished with errors"
    exit 1
fi

make -j $P -f ${srcdir}/indexBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$outdir OUTDIR=$outdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "indexBam.mk INCLMK=$inclmk finished with errors"
    exit 1
fi

make -j $P -f ${srcdir}/flStBam.mk SUFFIX=$sfx INCLMK=$inclmk FAMCODE=$famcode INDIR=$outdir OUTDIR=$metricsdir LOGDIR=$outdir
ret=$?
echo $ret
if [ $ret -ne 0 ]; then
    echo "flStBam.mk INCLMK=$inclmk finished with errors"
   exit 1
fi


