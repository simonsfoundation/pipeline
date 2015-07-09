'''
Runs picard's AddOrReplaceReadGroups on a reordered bam file.
'''

import sys, os, subprocess, time, datetime, re
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

inbam, outbam, picarddir, tmpdir, outdir = sys.argv[1:]
addOrReplaceReadGroups = os.path.join(os.path.abspath(picarddir), 'AddOrReplaceReadGroups.jar')
inbam_basename = os.path.basename(inbam)
print 'inbam_basename', inbam_basename
fam_name = re.search('^\w+', inbam_basename).group()
s = re.search (fam_name+'.\w+', inbam_basename)
#if s is None:
#    s = re.search ('\d+\.\w\w', inbam_basename)
#if s is None:
#    sys.exit('Could not find expected pattern in ' + inbam_basename)
sample_id = s.group()
print 'sample_id', sample_id


VALIDATION_STRINGENCY = 'SILENT' #SILENT STRICT
SORT_ORDER = 'coordinate' 
RGID = sample_id #'1' 
RGLB = 'unknown'
RGPL = 'illumina' 
RGPU = sample_id
RGSM = sample_id


cmd = 'java -Xms750m -Xmx4000m -XX:+UseSerialGC -jar '+addOrReplaceReadGroups+' INPUT=%(inbam)s OUTPUT=%(outbam)s SORT_ORDER=%(SORT_ORDER)s RGID=%(RGID)s RGLB=%(RGLB)s RGPL=%(RGPL)s RGPU=%(RGPU)s RGSM=%(RGSM)s TMP_DIR=%(tmpdir)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outbam, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outbam, outdir, cmd, 'finished')
else:
    logProc.logProc(outbam, outdir, cmd, 'failed', stderr)

