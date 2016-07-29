### some variables ####################################################
SRCDIR = ~/projects/pipeline/ppln
JAVA = /usr/bin/java
GAPS = /mnt/scratch/asalomatov/data/hg19/gap_corr23.bed
BCBIODIR = /mnt/xfs1/bioinfoCentos7/software/installs/bcbio_nextgen/150617
TOOLSDIR = /mnt/xfs1/home/asalomatov/projects/dnanexus/installs
#PICARDDIR = $(BCBIODIR)/share/java/picard-1.96
PICARDDIR = /bioinfo/software/installs/picard/git # $(TOOLSDIR)/bin/picard
#GENOMEREF = $(TOOLSDIR)/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
#GENOMEREF = $(TOOLSDIR)/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
GENOMEREF = /mnt/xfs1/bioinfoCentos7/data/bcbio_nextgen/150617/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
GATK = /mnt/xfs1/bioinfo/software/builds/GATK/fromGitZip150607/gatk-protected-master/target/executable/GenomeAnalysisTK.jar
DBSNP = /mnt/scratch/asalomatov/data/b37/dbsnp_138.b37.vcf
BEDTLSDIR = $(TOOLSDIR)/bin
SAMTOOLS = $(TOOLSDIR)/bin/samtools
FREEBAYES = $(BCBIODIR)/bin/freebayes
#PLATYPUS = /mnt/scratch/asalomatov/software/installs/bin/Platypus.py
PLATYPUS = $(TOOLSDIR)/bin/platypus
VCFLIBDIR = $(TOOLSDIR)/bin
#VCFLIBDIR = /bioinfo/software/installs/bcbio/bin
BGZIP = $(TOOLSDIR)/bin/bgzip
BCFTOOLS = $(TOOLSDIR)/bin/bcftools
BEDOPSDIR = /mnt/xfs1/bioinfo/software/builds/bedops/git/bedops/bin
SAMBAMBA = $(TOOLSDIR)/bin/sambamba
TABIX = $(TOOLSDIR)/bin/tabix
HAPMAP = /mnt/scratch/asalomatov/data/b37/hapmap_3.3.b37.vcf
OMNI = /mnt/scratch/asalomatov/data/b37/1000G_omni2.5.b37.vcf
SNP1000G = /mnt/scratch/asalomatov/data/b37/1000G_phase1.snps.high_confidence.b37.vcf
MILLSINDEL = /mnt/scratch/asalomatov/data/b37/Mills_and_1000G_gold_standard.indels.b37.vcf
SNPEFFJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/snpEff.jar 
SNPSIFTJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/SnpSift.jar
SNPEFFCONF = /mnt/scratch/asalomatov/data/snpEff/snpEff.config
SNPEFFGENOME = GRCh37.75
DBNSFP = /mnt/scratch/asalomatov/data/dbNSFP/hg19/dbNSFP3.0_hg19_sorted.txt.gz
DBSPIDEX = /mnt/scratch/asalomatov/data/spidex/spidex_public_noncommercial_v1_0.vcf.gz
BAM2SMPL = /mnt/scratch/asalomatov/data/SPARK/info/bam2smpl.yml
#######################################################################
#/mnt/xfs1/bioinfoCentos7/software/installs/bcbio_nextgen/150617/bin
