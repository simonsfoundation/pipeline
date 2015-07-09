'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

print '\nsys.args   :', sys.argv[1:]
inbam, inbed, outfile, samtools, outdir  = sys.argv[1:6]
otherbam = outfile.replace('-23.bam', '-irr.bam')
cmd = "%(samtools)s view -hb -L %(inbed)s -o %(outfile)s -U %(otherbam)s %(inbam)s"
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)
