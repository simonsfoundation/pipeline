'''
Deduplicate BAMs.
'''
import os, sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/pipeline/ppln')
import logProc

inbam, outbam, picard, outdir = sys.argv[1:]

VALIDATION_STRINGENCY = 'SILENT' #SILENT STRICT
REMOVE_DUPLICATES = 'false' 
CREATE_INDEX = 'true'
MAX_RECORDS_IN_RAM = '2000000'
METRICS_FILE = outbam + '.dedupMetrics'

#markDuplicates = os.path.join(os.path.abspath(picarddir), 'MarkDuplicates.jar')
#cmd = 'java -Xms750m -Xmx4000m -XX:+UseSerialGC -jar '+markDuplicates+' INPUT=%(inbam)s OUTPUT=%(outbam)s MAX_RECORDS_IN_RAM=%(MAX_RECORDS_IN_RAM)s CREATE_INDEX=%(CREATE_INDEX)s REMOVE_DUPLICATES=%(REMOVE_DUPLICATES)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s METRICS_FILE=%(METRICS_FILE)s'
cmd = '%(picard)s MarkDuplicates INPUT=%(inbam)s OUTPUT=%(outbam)s MAX_RECORDS_IN_RAM=%(MAX_RECORDS_IN_RAM)s CREATE_INDEX=%(CREATE_INDEX)s REMOVE_DUPLICATES=%(REMOVE_DUPLICATES)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s METRICS_FILE=%(METRICS_FILE)s'
cmd = cmd % locals()
#print cmd
logProc.logProc(outbam, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outbam, outdir, cmd, 'finished')
else:
    logProc.logProc(outbam, outdir, cmd, 'failed', stderr)

