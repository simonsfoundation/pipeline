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

   - BAM file(s) is input(tested for whole exome, whole genome to come)
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
   
All except GATK come with an install of [bcbio-nextgen](https://github.com/chapmanb/bcbio-nextgen).

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

Let's test this pipeline against CEU sample NA12878. Download chromosome 20 high
coverage bam file, Broad Institute's truth set, and NIST Genome in a Bottle target regions.

```
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20130103_high_cov_trio_bams/NA12878/alignment/NA12878.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20130103_high_cov_trio_bams/NA12878/alignment/NA12878.chrom20.ILLUMINA.bwa.CEU.high_coverage.20120522.bam.bai
wget http://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/working/20130806_broad_na12878_truth_set/NA12878.wgs.broad_truth_set.20131119.snps_and_indels.genotypes.vcf.gz
wget http://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/working/20130806_broad_na12878_truth_set/NA12878.wgs.broad_truth_set.20131119.snps_and_indels.genotypes.vcf.gz.tbi
wget -O NA12878-callable.bed.gz ftp://ftp-trace.ncbi.nih.gov/giab/ftp/data/NA12878/variant_calls/NIST/union13callableMQonlymerged_addcert_nouncert_excludesimplerep_excludesegdups_excludedecoy_excludeRepSeqSTRs_noCNVs_v2.17.bed.gz
```

Extract chr20, and restrict out consideration to the confidently callable regions.

```
mkdir chr20
tabix -h NA12878.wgs.broad_truth_set.20131119.snps_and_indels.genotypes.vcf.gz 20 | vcfintersect -b NA12878-callable.bed > chr20/NA12878.wgs.broad_truth_set.20131119-chr20.vcf
bgzip chr20/NA12878.wgs.broad_truth_set.20131119-chr20.vcf
tabix -p vcf chr20/NA12878.wgs.broad_truth_set.20131119-chr20.vcf.gz
```

