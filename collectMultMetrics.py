'''
Collect metrics for the final BAM.
'''

import sys, os, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

inbam, outf, picarddir, genomeRef, outdir = sys.argv[1:]
progr = os.path.join(os.path.abspath(picarddir), 'CollectMultipleMetrics.jar')


VALIDATION_STRINGENCY = 'SILENT' #SILENT STRICT
PROGRAM0 = 'CollectAlignmentSummaryMetrics' 
PROGRAM1 = 'CollectInsertSizeMetrics' 
PROGRAM2 = 'QualityScoreDistribution' 
PROGRAM3 = 'MeanQualityByCycle' 


cmd = 'java -Xms750m -Xmx4000m -XX:+UseSerialGC -jar '+progr+' INPUT=%(inbam)s OUTPUT=%(outf)s PROGRAM=%(PROGRAM0)s PROGRAM=%(PROGRAM1)s PROGRAM=%(PROGRAM2)s PROGRAM=%(PROGRAM3)s R=%(genomeRef)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outf, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outf, outdir, cmd, 'finished')
    mettarg = open(outf, 'w')
    mettarg.write('see '+outf+'.* files for various metrics')
    mettarg.close()
else:
    logProc.logProc(outf, outdir, cmd, 'failed', stderr)

