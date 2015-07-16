'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

options = '''  \
-L 1 \
--interval_padding 100 \
--standard_min_confidence_threshold_for_calling 30.0   \
--standard_min_confidence_threshold_for_emitting 30.0  \
--downsample_to_coverage 2000  \
--downsampling_type BY_SAMPLE  \
--annotation BaseQualityRankSumTest  \
--annotation FisherStrand  \
--annotation GCContent  \
--annotation HaplotypeScore  \
--annotation HomopolymerRun  \
--annotation MappingQualityRankSumTest  \
--annotation MappingQualityZero  \
--annotation QualByDepth  \
--annotation ReadPosRankSumTest  \
--annotation RMSMappingQuality  \
--annotation DepthPerAlleleBySample  \
--annotation Coverage  \
--interval_set_rule INTERSECTION  \
--annotation ClippingRankSumTest  \
--annotation DepthPerSampleHC  \
--pair_hmm_implementation VECTOR_LOGLESS_CACHING  \
-U LENIENT_VCF_PROCESSING  \
--read_filter BadCigar  \
--read_filter NotPrimaryAlignment \
-nct 10 
'''

print '\nsys.args   :', sys.argv[1:]
inbam0, inbam1, inbam2, outfile, refGenome, tmpdir, gatk, dbsnp, bedfile = sys.argv[1:]
cmd = 'java -Xms750m -Xmx2500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T HaplotypeCaller -I %(inbam0)s -I %(inbam1)s -I %(inbam2)s -o %(outfile)s -R %(refGenome)s --dbsnp %(dbsnp)s -L %(bedfile)s %(options)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, cmd, 'finished')
else:
    logProc.logProc(outfile, cmd, 'failed', stderr)

