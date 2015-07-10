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
   - Amazon EC2 (to come)
   
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
/path/to/pipeline/ppln
```

