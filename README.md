## *pipeline*

### Overview

*pipeline* is a computational engine for genetic variant detection in
a single sample, or in a familial cohort (typically a trio, or a quad). It is a
full-featured, and scalable pipeline that is simple, and modular in its design.
Almost every step in the pipeline is done via a *Makefile* (GNU make). These
makefiles can be used on their own to accomplish common bioinformatics operations, or
they can be stung together in a shell script to compose a pipeline. *pipeline*
is well suited for processing large number of familiar cohorts, and has been deployed on
a 205-family (685 exomes) collection at Simons Foundation.

### Cluster environments
   - Grid Engine
   - Slurm
   - Amazon (to come)
   
### From BAM files to de novo germline mutations

   - BAM file(s) is input
   - Optionally process BAM files according to GATK best practices
   - Compute callable regions, and subdivide genome into bins of approximately
   equal size for parallelization
   - Call variants with a choice of GATK HaplotypeCaller, GATK HaplotypeCaller in GVCF mode, Freebayes, Platypus 
   - Apply GATK variant recalibration
   - Apply hard variant filters
   - Annotate variants
   - Call de novo variants with DNMFilter (in development)
   - Validation against CEUTrio, NA12878

### Getting started

Besides commonly present *Python 2.7, JDK, GNU make*, the following packages are required
   1. [GATK](https://www.broadinstitute.org/gatk/)
   2. [freebayes](https://github.com/ekg/freebayes)
   3. [platypus](http://www.well.ox.ac.uk/platypus)
   4. [piccard](http://broadinstitute.github.io/picard/)
   5. [samtools](http://samtools.sourceforge.net/)
   6. [sambamba](https://github.com/lomereiter/sambamba)
   7. [bedtools](http://bedtools.readthedocs.org/en/latest/content/installation.html)
   8. [bedops](https://github.com/bedops/bedops)
   9. [bgzip, tabix](https://github.com/samtools/htslib)
   10. [bcftools](https://github.com/samtools/bcftools)
   11. [vcflib](https://github.com/ekg/vcflib)
   12. [SnpEff](http://snpeff.sourceforge.net/)
   
All except GATK come with an install of [bcbio-nextgen](https://github.com/chapmanb/bcbio-nextgen), an excellent resource to compare against, and to learn from.

```
cd ~
git clone https://github.com/asalomatov/pipeline.git
```

Next step is to edit *include.mk* defining *Makefile* variables to reflect your setup.

Running it:

```
~/pipeline/ppln/pipe03     \
/path/to/input/bams/       \ #dir with bam file(s)
/path/to/output/dir        \ #will be created, for final output, metrics, log. 
familycode                 \ #124 if bams are 123.p1.bam, 123.fa.bam, 123.mo.bam
WG                         \ #binning method EX, WG(recommended)
0                          \ #if not 1 recompute bins, else use existing ones - for testing
tmp                        \ #if tmp work in /tmp, else work in output dir
~/pipeline/ppln/include.mk \ #makefile with variable definition
1                          \ #if 0 don't delete intermediate files
,Reorder,FixGroups,FilterBam,DedupBam,Metrics,IndelRealign,BQRecalibrate,HaplotypeCaller,Freebayes,Platypus,HaplotypeCallerGVCF, \
1                          \#if 1 remove working dir on exit
/path/to/pipeline/ppln     \
max_cores                  \#max number of physical cpu cores to utilize
```

### Validation

#### NA12878
Let's test this pipeline against CEU sample NA12878. See [this freebayes tutorial](http://clavius.bc.edu/~erik/CSHL-advanced-sequencing/freebayes-tutorial.html), and [this bcbio blog post](http://bcb.io/2014/10/07/joint-calling/) for a good exposition. 

Download chromosome 20 high coverage bam file, Broad Institute's truth set, and NIST Genome in a Bottle target regions.

```
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20130103_high_cov_trio_bams/NA12878/alignment/NA12878.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20130103_high_cov_trio_bams/NA12878/alignment/NA12878.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam.bai
wget http://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/working/20130806_broad_na12878_truth_set/NA12878.wgs.broad_truth_set.20131119.snps_and_indels.genotypes.vcf.gz
wget http://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/working/20130806_broad_na12878_truth_set/NA12878.wgs.broad_truth_set.20131119.snps_and_indels.genotypes.vcf.gz.tbi
wget -O NA12878-callable.bed.gz ftp://ftp-trace.ncbi.nih.gov/giab/ftp/data/NA12878/variant_calls/NIST/union13callableMQonlymerged_addcert_nouncert_excludesimplerep_excludesegdups_excludedecoy_excludeRepSeqSTRs_noCNVs_v2.17.bed.gz
```
Run the pipeline.
```
sbatch -J NA12878 -N 1 --exclusive ~/pipeline/ppln/pipe03.sh ./ ./NA12878 NA12878 WG 0 tmp ~/pipeline/ppln/include.mk 0 ,Reorder,FixGroups,FilterBam,DedupBam,Metrics,IndelRealign,BQRecalibrate,HaplotypeCaller,Freebayes,Platypus,HaplotypeCallerGVCF,RecalibVariants, 1 ~/pipeline/ppln/ 20 all
```

Restrict our consideration to chromosome 20, and to the confidently callable regions.
```
mkdir chr20
tabix -h NA12878.wgs.broad_truth_set.20131119.snps_and_indels.genotypes.vcf.gz 20 | vcfintersect -b NA12878-callable.bed | bgzip -c > chr20/NA12878.wgs.broad_truth_set.20131119-chr20.vcf.gz
tabix -p vcf chr20/NA12878.wgs.broad_truth_set.20131119-chr20.vcf.gz
```
Do the same to our variant calls.

Let use ```vcf-compare``` to gauge the concordance between our calls and the true positives from the truth set.
```
zcat NA12878.wgs.broad_truth_set.20131119-chr20.vcf.gz | grep "^#\|TruthStatus=TRUE_POSITIVE" | bgzip -c > NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz
tabix -p vcf NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz
```
For Haplotype Caller:
```
vcf-compare NA12878-HC-vars-flr-call.vcf.gz ../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz | grep ^VN
VN	1298	NA12878-HC-vars-flr-call.vcf.gz (1.7%)
VN	1740	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (2.3%)
VN	73287	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (97.7%)	NA12878-HC-vars-flr-call.vcf.gz (98.3%)
```
For Haplotype Caller in GVCF mode
```
vcf-compare NA12878-JHC-vars-call.vcf.gz ../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz | grep ^VN
VN	1400	NA12878-JHC-vars-call.vcf.gz (1.9%)
VN	1729	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (2.3%)
VN	73298	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (97.7%)	NA12878-JHC-vars-call.vcf.gz (98.1%)
```
For Freebayes:
```
vcf-compare NA12878-FB-vars-call.vcf.gz ../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz | grep ^VN
VN	445	NA12878-FB-vars-call.vcf.gz (0.6%)
VN	3131	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (4.2%)
VN	71896	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (95.8%)	NA12878-FB-vars-call.vcf.gz (99.4%)
```
For Platypus:
```
vcf-compare NA12878-PL-vars-call.vcf.gz ../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz | grep ^VN
VN	2486	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (3.3%)
VN	3071	NA12878-PL-vars-call.vcf.gz (4.1%)
VN	72541	../NA12878.wgs.broad_truth_set.20131119-chr20-TRUE_POS.vcf.gz (96.7%)	NA12878-PL-vars-call.vcf.gz (95.9%)
```

#### CEU Trio

After downloading chromosome 20 alignments for [NA1278, NA12891, NA12892](ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20130103_high_cov_trio_bams/), and creating symbolic links:
```
ln -s NA12878.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam CEUTrio.NA12878.chr20.20120522.bam
ln -s NA12891.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam CEUTrio.NA12891.chr20.20120522.bam
ln -s NA12892.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam CEUTrio.NA12892.chr20.20120522.bam
ln -s NA12878.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam.bai CEUTrio.NA12878.chr20.20120522.bam.bai
ln -s NA12891.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam.bai CEUTrio.NA12891.chr20.20120522.bam.bai
ln -s NA12892.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam.bai CEUTrio.NA12892.chr20.20120522.bam.bai
```
Download a set of high confidence calls for the trio.
```
wget -O GiaB_NIST_RTG_v0_2.vcf.gz ftp://ftp-trace.ncbi.nih.gov/giab/ftp/data/NA12878/variant_calls/GIAB_integration/NIST_RTG_PlatGen_merged_highconfidence_v0.2_Allannotate.vcf.gz
tabix -f -p vcf GiaB_NIST_RTG_v0_2.vcf.gz
```
Run the pipeline
```
sbatch -J CEUTrio -N 1 --exclusive ~/pipeline/ppln/pipe03.sh ./ ./CEUTrio CEUTrio WG 0 tmp ~/pipeline/ppln/include.mk 0 ,Reorder,FixGroups,FilterBam,DedupBam,Metrics,IndelRealign,BQRecalibrate,HaplotypeCaller,Freebayes,Platypus,HaplotypeCallerGVCF,RecalibVariants, 1 ~/pipeline/ppln/ 20 all
```
Filter out loci where the proband is HomRef, one can use ```SnpSift``` to accomplish this task.
```
java -jar SnpSift.jar filter " GEN[0].GT = '0/0' " CEUTrio-FB-vars.vcf.gz | bgzip -c > CEUTrio-FB-vars-NoHomRef.vcf.gz
```
And, finally, carry out compatisons with *vcf-compare*.

Haplotype Caller:
```
vcf-compare GiaB_NIST_RTG_v0_2-chr20.vcf.gz CEUTrio/CEUTrio-HC-vars-NoHomRef-call.vcf.gz | grep ^VN
VN	112	CEUTrio/CEUTrio-HC-vars-NoHomRef-call.vcf.gz (0.4%)	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (0.2%)
VN	26531	CEUTrio/CEUTrio-HC-vars-NoHomRef-call.vcf.gz (99.6%)
VN	69778	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (99.8%)
```
Haplotype Caller GVCF:
```
vcf-compare GiaB_NIST_RTG_v0_2-chr20.vcf.gz CEUTrio/CEUTrio-JHC-vars-NoHomRef-call.vcf.gz | grep ^VN
VN	137	CEUTrio/CEUTrio-JHC-vars-NoHomRef-call.vcf.gz (0.5%)	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (0.2%)
VN	26701	CEUTrio/CEUTrio-JHC-vars-NoHomRef-call.vcf.gz (99.5%)
VN	69753	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (99.8%)
```
Freebayes:
```
vcf-compare GiaB_NIST_RTG_v0_2-chr20.vcf.gz CEUTrio/CEUTrio-FB-vars-NoHomRef-call.vcf.gz | grep ^VN
VN	9827	CEUTrio/CEUTrio-FB-vars-NoHomRef-call.vcf.gz (44.4%)
VN	12299	CEUTrio/CEUTrio-FB-vars-NoHomRef-call.vcf.gz (55.6%)	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (17.6%)
VN	57591	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (82.4%)
```
Platypus:
```
vcf-compare GiaB_NIST_RTG_v0_2-chr20.vcf.gz CEUTrio/CEUTrio-PL-vars-NoHomRef-call.vcf.gz | grep ^VN
VN	124	CEUTrio/CEUTrio-PL-vars-NoHomRef-call.vcf.gz (0.5%)	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (0.2%)
VN	25110	CEUTrio/CEUTrio-PL-vars-NoHomRef-call.vcf.gz (99.5%)
VN	69766	GiaB_NIST_RTG_v0_2-chr20.vcf.gz (99.8%)
```
