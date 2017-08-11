'''

'''
'''

'''
import sys, subprocess
sys.path.insert(0, '~/asalomatov/projects/ppln')
import logProc

options = '''  \
--suppressCommandLineHeader \
'''
#-genotypeMergeOptions UNIQUIFY \

print '\nsys.args   :', sys.argv[1:]
refGenome, tmpdir, gatk, outdir, outfile = sys.argv[1:6]
I = ' --variant '
infiles = ''
for f in sys.argv[6:]:
    infiles += I + f
    
cmd = 'java -Xms750m -Xmx5000m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T CombineGVCFs %(infiles)s -o %(outfile)s -R %(refGenome)s %(options)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)
