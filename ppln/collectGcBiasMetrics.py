'''
Collect metrics for the final BAM.
'''

import sys, os, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/pipeline/ppln')
import logProc

inbam, outf, picard, genomeRef, outdir = sys.argv[1:]
#progr = os.path.join(os.path.abspath(picarddir), 'CollectGcBiasMetrics.jar')
outf_chart = outf + '.chart'
outf_sum = outf + '.sum'

VALIDATION_STRINGENCY = 'SILENT' #SILENT STRICT
ASSUME_SORTED = 'true' 


#cmd = 'java -Xms750m -Xmx4000m -XX:+UseSerialGC -jar '+progr+' INPUT=%(inbam)s OUTPUT=%(outf)s CHART_OUTPUT=%(outf_chart)s SUMMARY_OUTPUT=%(outf_sum)s ASSUME_SORTED=%(ASSUME_SORTED)s R=%(genomeRef)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = '%(picard)s CollectGcBiasMetrics INPUT=%(inbam)s OUTPUT=%(outf)s CHART_OUTPUT=%(outf_chart)s SUMMARY_OUTPUT=%(outf_sum)s ASSUME_SORTED=%(ASSUME_SORTED)s R=%(genomeRef)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outf, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outf, outdir, cmd, 'finished')
else:
    logProc.logProc(outf, outdir, cmd, 'failed', stderr)

