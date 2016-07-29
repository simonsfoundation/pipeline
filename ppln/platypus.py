'''
filtering is after
https://github.com/chapmanb/bcbio-nextgen/blob/master/bcbio/variation/vfilter.py
'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc


try:
    print '\nsys.args   :', sys.argv[1:]
    NbeforeBams = 9
    refGenome, platypus, vcflibdir, bcftools, bgzip, outdir, outfile, inregions  = sys.argv[1:NbeforeBams]
    inbams = ' --bamFiles=' + ','.join(sys.argv[NbeforeBams:])
    options = '''\
    --logFileName=/dev/null \
    --verbosity=1 \
    --assemble=1 \
    --hapScoreThreshold=10\
    --scThreshold=0.99 \
    --filteredReadsFrac=0.9 \
    --rmsmqThreshold=20 \
    --qdThreshold=0 \
    --abThreshold=0.0001 \
    --minVarFreq=0.0 '''
#    cmd = "%(platypus)s callVariants %(inbams)s --output=%(outfile)s --refFile=%(refGenome)s --regions=%(inregions)s "
#    cmd = "%(platypus)s callVariants %(inbams)s --output=%(outfile)s --refFile=%(refGenome)s --regions=%(inregions)s %(options)s "
#--output=%(outfile)s 
    cmd = "%(platypus)s callVariants %(inbams)s --output=- --refFile=%(refGenome)s --regions=%(inregions)s %(options)s "
    cmd += "| %(bcftools)s filter -O v --soft-filter 'PlatQualDepth' -e '(FR[0] <= 0.5 && TC < 4 && %%QUAL < 20) || (TC < 13 && %%QUAL < 10) ||      (FR[0] > 0.5 && TC < 4 && %%QUAL < 50)' -m '+' | %(vcflibdir)s/vcfallelicprimitives --keep-geno | %(vcflibdir)s/vcfstreamsort | %(bgzip)s -c > %(outfile)s"
    print cmd
    cmd = cmd % locals()
    print cmd
    logProc.logProc(outfile, outdir, cmd, 'started')
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if p.returncode == 0:
        logProc.logProc(outfile, outdir, cmd, 'finished')
    else:
        logProc.logProc(outfile, outdir, cmd, 'failed', stderr)
except Exception as e:
    logProc.logProc(outfile, outdir, ' ', 'failed', stderr_out=e.message)
    raise

'''
/bioinfo/software/installs/bcbio_nextgen/150607/bin/Platypus.py callVariants --bamFiles=/mnt/scratch/asalomatov/bioppln/run11480dsPIPE03_EX_ns/work/11480.mo_SSCtest-20-re-fxgr-flr-dp-23-rlgn-rclb.bam,/mnt/scratch/asalomatov/bioppln/run11480dsPIPE03_EX_ns/work/11480.fa_SSCtest-20-re-fxgr-flr-dp-23-rlgn-rclb.bam, /mnt/scratch/asalomatov/bioppln/run11480dsPIPE03_EX_ns/work/11480.p1_SSCtest-20-re-fxgr-flr-dp-23-rlgn-rclb.bam --output=- --refFile=/bioinfo/data/bcbio_nextgen/150607/genomes/Hsapiens/GRCh37/seq/GRCh37.fa --regions=/mnt/scratch/asalomatov/bioppln/run11480dsPIPE03_EX_ns/work/10__bin__11480-uni-mrg.bed --logF ileName=/dev/null     --verbosity=1     --assemble=1     --hapScoreThreshold=10 --scThreshold=0.99     --filteredReadsFrac=0.9     --rmsmqThreshold=20 --qdThreshold=0     --abThreshold=0.0001     --minVarFreq=0.0 
'''
