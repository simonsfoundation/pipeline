'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc


nct = '-nct 3'

print '\nsys.args   :', sys.argv[1:]
infvcf, outfile, refGenome, tmpdir, gatk, dbsnp, gaps, outdir = sys.argv[1:]
cmd = 'java -Xms750m -Xmx10g -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T BaseRecalibrator -I %(inbam)s -knownSites %(dbsnp)s -o %(outfile)s -R %(refGenome)s %(downsample_to_fraction)s %(read_filter)s %(interval_padding)s %(nct)s -L %(inbed)s'
#cmd = 'java -Xms750m -Xmx2500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T BaseRecalibrator -I %(inbam)s -knownSites %(dbsnp)s -o %(outfile)s -R %(refGenome)s %(downsample_to_fraction)s %(read_filter)s %(interval_padding)s %(nct)s -L %(inbed)s -XL %(gaps)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)

