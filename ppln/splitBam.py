import sys, subprocess
if len(sys.argv) != 6:
    print 'Usage:'
    print sys.argv[0], 'input.bam', 'input.bed', 'path_to_sambamba', 'output.bam', 'logdir'
    sys.exit(1)
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

print '\nsys.args   :', sys.argv[1:]
inbam, inbed, outf, sambamba, outdir = sys.argv[1:]
cmd = '%(sambamba)s view -f bam -h -L %(inbed)s -o %(outf)s %(inbam)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outf, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outf, outdir, cmd, 'finished')
else:
    logProc.logProc(outf, outdir, cmd, 'failed', stderr)
