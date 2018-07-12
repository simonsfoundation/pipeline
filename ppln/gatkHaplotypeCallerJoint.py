'''

'''
import sys, subprocess, commands
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

print '\nsys.args   :', sys.argv[1:]
#refGenome, tmpdir, gatk, dbsnp, gaps, outdir, outfile, inbed = sys.argv[1:9]
refGenome, tmpdir, gatk, dbsnp, gaps, outdir, lib, outfile, inbed = sys.argv[1:10]

if '3.2-2-gec30cee' in commands.getoutput('java -jar ' + gatk + ' -T HaplotypeCaller --version'):
    options = '''  \
    --emitRefConfidence GVCF \
    --variant_index_type LINEAR \
    --variant_index_parameter 128000 \
    --standard_min_confidence_threshold_for_calling 30.0   \
    --standard_min_confidence_threshold_for_emitting 10.0  \
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
    '''
else:
    options = '''  \
    --emitRefConfidence GVCF \
    --standard_min_confidence_threshold_for_calling 30.0   \
    --standard_min_confidence_threshold_for_emitting 10.0  \
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
    '''
#-nct 1  

I = ' -I '
inbams = ''
#for f in sys.argv[9:]:
for f in sys.argv[10:]:
    inbams += I + f
    
cmd = 'java -Xms750m -Xmx3500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -Djava.library.path=%(lib)s -jar %(gatk)s -T HaplotypeCaller %(inbams)s -o %(outfile)s -R %(refGenome)s --dbsnp %(dbsnp)s -L %(inbed)s %(options)s'
#cmd = 'java -Xms750m -Xmx2500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T HaplotypeCaller %(inbams)s -o %(outfile)s -R %(refGenome)s --dbsnp %(dbsnp)s -L %(inbed)s -XL %(gaps)s  %(options)s'
cmd = cmd % locals()
print cmd
logProc.logProc(outfile, outdir, cmd, 'started')
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = p.communicate()
if p.returncode == 0:
    logProc.logProc(outfile, outdir, cmd, 'finished')
else:
    logProc.logProc(outfile, outdir, cmd, 'failed', stderr)

