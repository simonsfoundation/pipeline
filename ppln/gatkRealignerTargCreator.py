'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

ntFlag = '-nt 10'
#interval_padding = '--interval_padding 0' # bed files padded with 100bp
interval_padding = '--interval_padding 200' 
read_filter = '--read_filter BadCigar'

print '\nsys.args   :', sys.argv[1:]
inbam, inbed, outfile, refGenome, tmpdir, gatk, gaps, outdir = sys.argv[1:]
cmd = 'java -Xms750m -Xmx10g -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T RealignerTargetCreator -I %(inbam)s -o %(outfile)s -R %(refGenome)s %(ntFlag)s %(read_filter)s -L %(inbed)s'
#cmd = 'java -Xms750m -Xmx2500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T RealignerTargetCreator -I %(inbam)s -o %(outfile)s -R %(refGenome)s %(ntFlag)s %(read_filter)s -L %(inbed)s -XL %(gaps)s'
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

