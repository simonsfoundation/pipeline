### some variables ####################################################
SRCDIR = ~/projects/pipeline/ppln
JAVA = /mnt/xfs1/home/ifisk/java/jdk1.8.0_11/bin/java
GAPS = /mnt/xfs1/scratch/asalomatov/data/hg19/gap_corr23.bed
BCBIODIR = /mnt/xfs1/bioinfoCentos7/software/installs/bcbio_nextgen/150617
TOOLSDIR = /mnt/xfs1/home/asalomatov/projects/dnanexus/installs
#PICARDDIR = $(BCBIODIR)/share/java/picard-1.96
PICARDDIR = /bioinfo/software/installs/picard/git # $(TOOLSDIR)/bin/picard
PICARD = $(TOOLSDIR)/bin/picard
#GENOMEREF = $(TOOLSDIR)/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
#GENOMEREF = $(TOOLSDIR)/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
GENOMEREF = /mnt/xfs1/bioinfoCentos7/data/bcbio_nextgen/150617/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
#GATK = /mnt/xfs1/bioinfo/software/builds/GATK/fromGitZip150607/gatk-protected-master/target/executable/GenomeAnalysisTK.jar
GATK = /mnt/xfs1/bioinfoCentos7/software/installs/GATK/3.6/GenomeAnalysisTK.jar
DBSNP = /mnt/xfs1/scratch/asalomatov/data/b37/dbsnp_138.b37.vcf
BEDTLSDIR = $(TOOLSDIR)/bin
SAMTOOLS = $(TOOLSDIR)/bin/samtools
#FREEBAYES = $(BCBIODIR)/bin/freebayes
FREEBAYES = /mnt/xfs1/scratch/asalomatov/software/builds/freebayes/bin/freebayes
#PLATYPUS = /mnt/xfs1/scratch/asalomatov/software/installs/bin/Platypus.py
PLATYPUS = $(TOOLSDIR)/bin/platypus
VCFLIBDIR = $(TOOLSDIR)/bin
#VCFLIBDIR = /bioinfo/software/installs/bcbio/bin
BGZIP = $(TOOLSDIR)/bin/bgzip
BCFTOOLS = $(TOOLSDIR)/bin/bcftools
BEDOPSDIR = /mnt/xfs1/bioinfo/software/builds/bedops/git/bedops/bin
SAMBAMBA = $(TOOLSDIR)/bin/sambamba
TABIX = $(TOOLSDIR)/bin/tabix
HAPMAP = /mnt/xfs1/scratch/asalomatov/data/b37/hapmap_3.3.b37.vcf
OMNI = /mnt/xfs1/scratch/asalomatov/data/b37/1000G_omni2.5.b37.vcf
SNP1000G = /mnt/xfs1/scratch/asalomatov/data/b37/1000G_phase1.snps.high_confidence.b37.vcf
MILLSINDEL = /mnt/xfs1/scratch/asalomatov/data/b37/Mills_and_1000G_gold_standard.indels.b37.vcf
#SNPEFFDIR = /mnt/xfs1/scratch/asalomatov/data/snpEff/snpEff_4.3
#SNPEFFJAR = $(SNPEFFDIR)/snpEff.jar
#SNPSIFTJAR = $(SNPEFFDIR)/SnpSift.jar
#SNPEFFCONF = $(SNPEFFDIR)/snpEff.config
SNPEFFDIR = /mnt/xfs1/scratch/asalomatov/data/snpEff
SNPEFFJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/snpEff.jar
SNPSIFTJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/SnpSift.jar
SNPEFFCONF = /mnt/xfs1/scratch/asalomatov/data/snpEff/snpEff.config
SNPEFFGENOME = GRCh37.75
VEPGENBUILD = GRCh37
VEP = /mnt/xfs1/bioinfoCentos7/software/builds/perlbrew/cellar/perls/perl-5.22.1/bin/perl /mnt/xfs1/bioinfoCentos7/software/builds/ensembl/ensembl-tools-release-85/scripts/variant_effect_predictor/variant_effect_predictor.pl --cache --dir=/mnt/ceph/users/carriero/VEPcache/.vep --everything --assembly $(VEPGENBUILD) --offline --force_overwrite --fork 4 --fasta $(GENOMEREF) --no_stats
#DBNSFP = /mnt/xfs1/scratch/asalomatov/data/dbNSFP/hg19/dbNSFP3.0_hg19_sorted.txt.gz
#DBNSFP = /mnt/xfs1/scratch/asalomatov/data/dbNSFP/dbNSFPv3.2a/dbNSFP3.2_hg19_fix.txt.gz
#DBNSFP = /mnt/xfs1/scratch/asalomatov/data/dbNSFP/dbNSFPv3.3a/dbNSFPv3.3a_hg19.txt.gz
DBNSFP = /mnt//xfs1/scratch/asalomatov/data/dbNSFP/dbNSFPv3.4a/dbNSFP3.4a.hg19.txt.gz
DBSPIDEX = /mnt/xfs1/scratch/asalomatov/data/spidex/spidex_public_noncommercial_v1_0.vcf.gz
#BAM2SMPL = /mnt/xfs1/home/asalomatov/projects/VIP/info/bam2smpl.yml
#BAM2SMPL = /mnt/xfs1/scratch/asalomatov/data/SPARK/info/baylor_bam2sp_descr.yml
# BAM2SMPL = /mnt/xfs1/scratch/asalomatov/data/SPARK/info/b6_bam2sp_id.yml
#BAM2SMPL = /mnt/xfs1/scratch/asalomatov/data/SPARK/info/b6_bam2sp_id_byTrio.yml
#BAM2SMPL = /mnt/xfs1/scratch/asalomatov/data/SPARK/info/b7_bam2sp_id.yml
#BAM2SMPL = /mnt/xfs1/scratch/asalomatov/data/SPARK/info/b9_bam2sp.yml
BAM2SMPL = /mnt/xfs1/scratch/asalomatov/data/SPARK/info/b10_bam2sp.yml
#BAM2SMPL = /mnt/ceph/users/asalomatov/regeneron_spark_pilot/info/bam2SPid.yml
#BAM2SMPL = /mnt/xfs1/scratch/asalomatov/bioppln/inputs1/bam2smpl.yml
REGIONSBED = /mnt/xfs1/scratch/asalomatov/data/b37/b37-chrom.bed
#######################################################################
#/mnt/xfs1/bioinfoCentos7/software/installs/bcbio_nextgen/150617/bin
