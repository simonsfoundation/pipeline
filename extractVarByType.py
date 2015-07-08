'''

'''

import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

infile, outfile, bcftools, vartype, outdir = sys.argv[1:]


cmd = '%(bcftools)s view -v %(vartype)s -o %(outfile)s -O z %(infile)s '
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)


