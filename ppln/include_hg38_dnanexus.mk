### some variables ####################################################
SRCDIR = ~/projects/pipeline/ppln
BCBIODIR = /home/dnanexus/bcbio
JAVA = $(BCBIODIR)/anaconda/jre/bin/java
GAPS = zzz
PICARDDIR = $(BCBIODIR)/bin/
PICARD = $(BCBIODIR)/bin/picard
GENOMEREF = /home/dnanexus/data/inputs/genome.fa
GATK = /home/dnanexus/gatk/GenomeAnalysisTK.jar
DBSNP = /home/dnanexus/data/inputs/dbsnp144.b38.vcf.gz
BEDTLSDIR = $(BCBIODIR)/bin
SAMTOOLS = $(BCBIODIR)/bin/samtools
FREEBAYES = $(BCBIODIR)/bin/freebayes
PLATYPUS = $(BCBIODIR)/bin/platypus
VCFLIBDIR = $(BCBIODIR)/bin
BGZIP = $(BCBIODIR)/bin/bgzip
BCFTOOLS = $(BCBIODIR)/bin/bcftools
BEDOPSDIR = /home/dnanexus/projects/bedops/applications/bed/bedops/bin
SAMBAMBA = $(BCBIODIR)/bin/sambamba
TABIX = $(BCBIODIR)/bin/tabix
HAPMAP = /home/dnanexus/data/inputs/hapmap_3.3.b38.vcf.gz
OMNI = /home/dnanexus/data/inputs/1000G_omni2.5.b38.vcf.gz
SNP1000G = /home/dnanexus/data/inputs/1000G_phase3.snps.high_confidence.b38.vcf.gz
MILLSINDEL = /home/dnanexus/data/inputs/Mills_and_1000G_gold_standard.indels.b38.vcf.gz
#SNPEFFJAR = $(BCBIODIR)/anaconda/share/snpeff-4.3g-0/snpEff.jar 
#SNPSIFTJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/SnpSift.jar
#SNPEFFCONF = $(BCBIODIR)/anaconda/share/snpeff-4.3g-0/snpEff.config
#SNPEFFGENOME = GRCh38.76
#DBNSFP = /home/dnanexus/data/dbNSFP/dbNSFP3.2a.txt.gz
#DBSPIDEX = /home/dnanexus/data/spidex/spidex_public_noncommercial_v1_0.vcf.gz
#BAM2SMPL = /mnt/xfs1/home/asalomatov/projects/VIP/info/bam2smpl.yml
#BAM2SMPL = /mnt/scratch/asalomatov/data/SPARK/info/baylor_bam2sp_descr.yml
BAM2SMPL = /home/dnanexus/info/bam2SPid.yml
#######################################################################
#/mnt/xfs1/bioinfoCentos7/software/installs/bcbio_nextgen/150617/bin
