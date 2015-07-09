'''
FlagStat
'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc


nctFlag = '-nct 4'

print '\nsys.args   :', sys.argv[1:]
inbam, outf, refGenome, tmpdir, gatk, outdir = sys.argv[1:]
cmd = 'java -Xms750m -Xmx2500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T FlagStat -I %(inbam)s -o %(outf)s -R %(refGenome)s'
cmd = cmd % locals()
#print cmd
logProc.logProc(outf, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outf, outdir, cmd, 'finished')
else:
    logProc.logProc(outf, outdir, cmd, 'failed', stderr)


'''
[2015-03-03 01:51] /bioinfo/software/installs/bcbio/bin/gatk-framework -Xms250m
-Xmx833m -XX:+UseSerialGC -Djava.io.tmpdir=/tmp/
asalomatov_bcbng_working_7mwA1RJkiA/tx/tmpOvVBQk -XX:+UseSerialGC 
-U LENIENT_VCF_PROCESSING 
--read_filter BadCigar 
--read_filter NotPrimaryAlignment 
-T PrintReads 
-L 1:1-1551236 
-R /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa 
-I /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamclean/11480_mo/11480.mo_SSCtest-reorder-fixrgs-gatkfilter-dedup.bam
--downsample_to_coverage 10000 
-BQSR /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamclean/11480_mo/11480.mo_SSCtest-reorder-fixrgs-gatkfilter-dedup.grp 
-o /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_mo/1/tx/tmpBDNN7g/11480.mo_SSCtest-reorder-fixrgs- gatkfilter-dedup-1_0_1551236-prep-prealign.bam
'''


