'''
Runs picard's AddOrReplaceReadGroups on a reordered bam file.
'''
import sys, os, subprocess, time, datetime, re
import yaml
sys.path.insert(0, '~/projects/pipeline/ppln')
import logProc

inbam, outbam, picard, tmpdir, outdir, bam2sample_id_yaml = sys.argv[1:]
#addOrReplaceReadGroups = os.path.join(os.path.abspath(picarddir), 'AddOrReplaceReadGroups.jar')
inbam_basename = os.path.basename(inbam)
print 'inbam_basename', inbam_basename
with open(bam2sample_id_yaml, 'r') as f:
    bam2smpl = yaml.safe_load(f)
sample_id = str(bam2smpl[inbam_basename])
print 'sample_id', sample_id

VALIDATION_STRINGENCY = 'SILENT'  # SILENT STRICT
SORT_ORDER = 'coordinate'
RGID = sample_id
RGLB = 'unknown'
RGPL = 'illumina'
RGPU = sample_id
RGSM = sample_id

#cmd = 'java -Xms750m -Xmx4000m -XX:+UseSerialGC -jar '+addOrReplaceReadGroups+' INPUT=%(inbam)s OUTPUT=%(outbam)s SORT_ORDER=%(SORT_ORDER)s RGID=%(RGID)s RGLB=%(RGLB)s RGPL=%(RGPL)s RGPU=%(RGPU)s RGSM=%(RGSM)s TMP_DIR=%(tmpdir)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = '%(picard)s addOrReplaceReadGroups INPUT=%(inbam)s OUTPUT=%(outbam)s SORT_ORDER=%(SORT_ORDER)s RGID=%(RGID)s RGLB=%(RGLB)s RGPL=%(RGPL)s RGPU=%(RGPU)s RGSM=%(RGSM)s TMP_DIR=%(tmpdir)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outbam, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outbam, outdir, cmd, 'finished')
else:
    logProc.logProc(outbam, outdir, cmd, 'failed', stderr)

