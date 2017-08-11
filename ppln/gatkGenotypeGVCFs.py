'''

'''
import sys, subprocess
# sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

options = '''  \
--standard_min_confidence_threshold_for_calling 10.0   \
--standard_min_confidence_threshold_for_emitting 10.0  \
'''

print '\nsys.args   :', sys.argv[1:]
N = 9
refGenome, tmpdir, gatk, dbsnp, gaps, outdir, outfile, bedfile = sys.argv[1:N]

#if '3.2-2-g323f22f' in commands.getoutput('java -jar ' + gatk + ' -T HaplotypeCaller --version'):
I = ' --variant '
inbams = ''
for f in sys.argv[N:]:
    inbams += I + f
    
cmd = 'java -Xms750m -Xmx3500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T GenotypeGVCFs %(inbams)s -L %(bedfile)s -o %(outfile)s -R %(refGenome)s --dbsnp %(dbsnp)s %(options)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)

'''
java -jar GenomeAnalysisTK.jar \
  -T GenotypeGVCFs \
  -R reference.fasta \
  --variant sample1.g.vcf \
  --variant sample2.g.vcf \
  -o output.vcf
'''
