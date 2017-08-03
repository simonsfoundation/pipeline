'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc


dcov = '-dcov 1000'
consensusDeterminationModel = '--consensusDeterminationModel USE_READS'
compress = '-compress 0' 
read_filter = '--read_filter BadCigar'

print '\nsys.args   :', sys.argv[1:]
inbam, inntrv, outfile, refGenome, knownindels, tmpdir, gatk, outdir = sys.argv[1:]
cmd = 'java -Xms750m -Xmx5g -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T IndelRealigner -I %(inbam)s --known %(knownindels)s -targetIntervals %(inntrv)s -o %(outfile)s -R %(refGenome)s %(dcov)s %(read_filter)s %(consensusDeterminationModel)s %(compress)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)
    sys.exit(1)

