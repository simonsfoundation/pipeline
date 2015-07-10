## *pipeline*

### Overview

*pipeline* is a computational pipeline for genetic variant detection in
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

Besides commonly present Python 2.7, JDK, GNU make the following packages are required
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


