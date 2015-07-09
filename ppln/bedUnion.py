'''
Take a union of supplied bed files.
'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

print '\nsys.args   :', sys.argv
outf, outdir = sys.argv[1:3]
cmd = 'cat '+ ' '.join(sys.argv[3:]) + ' | sort -V -k1,1 -k2,2 | uniq > ' + sys.argv[1] 
#print cmd
logProc.logProc(outf, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outf, outdir, cmd, 'finished')
else:
    logProc.logProc(outf, outdir, cmd, 'failed', stderr)

