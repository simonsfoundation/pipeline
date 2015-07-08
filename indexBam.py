'''
Index BAM file that is the output of AddOrReplaceReadGroups.
'''

import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

inbam, outbambai, sambamba, outdir = sys.argv[1:]


Tflag = '-t 4'


cmd = '%(sambamba)s index %(Tflag)s %(inbam)s %(outbambai)s '
cmd = cmd % locals()
print cmd
logProc.logProc(outbambai, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outbambai, outdir, cmd, 'finished')
else:
    logProc.logProc(outbambai, outdir, cmd, 'failed', stderr)

