'''
Filter BAMs based on criteria defined in --filter switches.
'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc


nctFlag = '-nct 4'

print '\nsys.args   :', sys.argv[1:]
inbam, recalibtbl, outbam, refGenome, tmpdir, gatk, outdir = sys.argv[1:]
cmd = 'java -Xms750m -Xmx2500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s --read_filter BadCigar --read_filter NotPrimaryAlignment -T PrintReads -I %(inbam)s -o %(outbam)s -R %(refGenome)s -BQSR %(recalibtbl)s %(nctFlag)s'
cmd = cmd % locals()
#print cmd
logProc.logProc(outbam, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outbam, outdir, cmd, 'finished')
else:
    logProc.logProc(outbam, outdir, cmd, 'failed', stderr)

