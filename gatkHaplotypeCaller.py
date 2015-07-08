'''

'''
import sys, subprocess, commands
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

print '\nsys.args   :', sys.argv[1:]
refGenome, tmpdir, gatk, dbsnp, gaps, outdir, outfile, inbed = sys.argv[1:9]

if '3.2-2-gec30cee' in commands.getoutput('java -jar ' + gatk + ' -T HaplotypeCaller --version'):
    options = '''  \
    --downsample_to_coverage 2000  \
    --downsampling_type BY_SAMPLE  \
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
else: #for 15/06/07 install
    options = '''  \
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
for f in sys.argv[9:]:
    inbams += I + f
    
cmd = 'java -Xms750m -Xmx3500m -XX:+UseSerialGC -Djava.io.tmpdir=%(tmpdir)s -jar %(gatk)s -T HaplotypeCaller %(inbams)s -o %(outfile)s -R %(refGenome)s --dbsnp %(dbsnp)s -L %(inbed)s %(options)s'
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

'''
java -Xms1g -Xmx5000m -XX:+UseSerialGC -Djava.io.
      tmpdir=/tmp/asalomatov_bcbng_working_7mwA1RJkiA/tx/tmp0I30hq -jar /
            bioinfo/software/installs/bcbio/share/java/picard/GenomeAnalysisTK.jar
-R /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
-I /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_p1/1/
11480.p1_SSCtest-reorder-fixrgs-gatkfilter-dedup-1_0_1551236-prep.bam
-I /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_mo/1/11480. mo_SSCtest-reorder-fixrgs-gatkfilter-dedup-1_0_1551236-prep.bam
-I /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_fa/1/11480.fa_SSCtest-reorder-fixrgs-gatkfilter-dedup-1_0_1551236-prep.bam
--dbsnp /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf.gz
#-L /tmp/asalomatov_bcbng_working_7mwA1RJkiA/gatk-haplotype/1/11480-1_0_1551236-raw-regions.bed
-T HaplotypeCaller
-o /tmp/asalomatov_bcbng_working_7mwA1RJkiA/gatk-haplotype/1/tx/tmpegKpSt/ 11480-1_0_1551236-raw.vcf.gz
'''
