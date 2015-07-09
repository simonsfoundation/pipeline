'''
BEDtools merge
'''
import sys, subprocess
if len(sys.argv) != 5:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.bed', 'bedtoolsdir', 'logdir'
    sys.exit(1)
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

print '\nsys.args   :', sys.argv[1:]
inbed, outf, bedtlsdir, outdir = sys.argv[1:]
cmd = '%(bedtlsdir)s' + '/mergeBed -i %(inbed)s > %(outf)s'
cmd = cmd % locals()
#print cmd
logProc.logProc(outf, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outf, outdir, cmd, 'finished')
else:
    logProc.logProc(outf, outdir, cmd, 'failed', stderr)
