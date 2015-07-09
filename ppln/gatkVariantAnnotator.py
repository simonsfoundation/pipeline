'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

options = '''  \
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
'''
#-nct 1  

print '\nsys.args   :', sys.argv[1:]
refGenome, tmpdir, gatk, dbsnp, gaps, outdir, outfile, inbed = sys.argv[1:9]
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
[2015-04-16 19:17] INFO  19:17:02,452 HelpFormatter - Program Args: -T
VariantAnnotator -R /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
--variant
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/freebayes/1/11480-1_0_1560353-raw.vcf.gz
--out
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/freebayes/1/tx/tmpkrZdGu/11480-1_0_1560353-raw-
gatkann.vcf.gz -L
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/freebayes/1/11480-1_0_1560353-raw.vcf.gz
--dbsnp /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf.gz
-I
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/bamprep/11480_fa/1/11480.fa_dnsmpl-reorder-fixrgs-gatkfilter-dedup-1_0_1560353-prep.bam
-I /tmp/
asalomatov_bcbng_working_Zn0mVGaJNs/bamprep/11480_mo/1/11480.mo_dnsmpl-reorder-fixrgs-gatkfilter-dedup-1_0_1560353-prep.bam
-I
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/bamprep/11480_p1/1/11480.p1_dnsmpl-reorder-fixrgs-gatkfilter-dedup-1_0_1560353-prep.bam
-A BaseQualityRankSumTest -A FisherStrand -A GCContent -A HaplotypeScore -A
HomopolymerRun -A MappingQualityRankSumTest -A MappingQualityZero -A QualByDepth
-A ReadPosRankSumTest -A RMSMappingQuality -A DepthPerAlleleBySample -A Coverage
--allow_potentially_misencoded_quality_scores -U ALL --read_filter BadCigar
--read_filter NotPrimaryAlignment
470589 [2015-04-16 19:17] INFO  19:17:02,454 HelpFormatter - Program Args: -T
VariantAnnotator -R /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
--variant
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/freebayes/1/11480-1_1563029_3188608-raw.vcf.gz
--out /tmp/asalomatov_bcbng_working_Zn0mVGaJNs/freebayes/1/tx/tmpI_vQn4/11480-
1_1563029_3188608-raw-gatkann.vcf.gz -L
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/freebayes/1/11480-1_1563029_3188608-raw.vcf.gz
--dbsnp /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf.gz
-I
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/bamprep/11480_fa/1/11480.fa_dnsmpl-reorder-fixrgs-gatkfilter-dedup-
1_1563029_3188608-prep.bam -I
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/bamprep/11480_mo/1/11480.mo_dnsmpl-reorder-fixrgs-gatkfilter-dedup-1_1563029_3188608-prep.bam
-I
/tmp/asalomatov_bcbng_working_Zn0mVGaJNs/bamprep/11480_p1/1/11480.p1_dnsmpl-reorder-fixrgs-gatkfilter-dedup-1_1563029_3188608-prep.bam
-A BaseQualityRankSumTest -A           FisherStrand -A GCContent -A
HaplotypeScore -A HomopolymerRun -A MappingQualityRankSumTest -A
MappingQualityZero -A QualByDepth -A ReadPosRankSumTest -A RMSMappingQuality -A
DepthPerAlleleBySample -A Coverage --allow_potentially_misencoded_quality_scores
-U ALL --read_filter BadCigar --read_filter NotPrimaryAlignment

'''
