'''

'''
'''

'''
import os, sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

VALIDATION_STRINGENCY = 'SILENT' #SILENT STRICT LENIENT
CREATE_INDEX= 'false'

N = 6
print '\nsys.args   :', sys.argv[1:]
refGenome, tmpdir, picard, outdir, outfile = sys.argv[1:N]
I = ' I='
infiles = ''
for f in sys.argv[N:]:
    infiles += I + f
    
#picard = os.path.join(os.path.abspath(picarddir), 'MergeVcfs.jar')
cmd = picard + ' MergeVcfs -Xms750m -Xmx5000m -XX:+UseSerialGC %(infiles)s O=%(outfile)s TMP_DIR=%(tmpdir)s VALIDATION_STRINGENCY=%(VALIDATION_STRINGENCY)s CREATE_INDEX=%(CREATE_INDEX)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)
