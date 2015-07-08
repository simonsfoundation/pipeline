'''
Runs picard's ReorderSam on a bam file from input directory. 
Output goes to temp directory, and upon successful completion is copied 
(or symlinked to the output dir.
'''


ALLOW_INCOMPLETE_DICT_CONCORDANCE = 'true' #true false
VALIDATION_STRINGENCY = 'SILENT' #SILENT STRICT


import sys, os, subprocess, time, datetime
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

inbam, outbam, picarddir, refGenome, tmpdir, outdir = sys.argv[1:]
reorderSam = os.path.join(os.path.abspath(picarddir), 'ReorderSam.jar')
cmd = 'java -Xms750m -Xmx4000m -XX:+UseSerialGC -jar '+reorderSam+' INPUT=%(inbam)s OUTPUT=%(outbam)s REFERENCE=%(refGenome)s ALLOW_INCOMPLETE_DICT_CONCORDANCE=%(ALLOW_INCOMPLETE_DICT_CONCORDANCE)s TMP_DIR=%(tmpdir)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = cmd % locals()
#print cmd
logProc.logProc(outbam, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outbam, outdir, cmd, 'finished')
else:
    logProc.logProc(outbam, outdir, cmd, 'failed', stderr)

