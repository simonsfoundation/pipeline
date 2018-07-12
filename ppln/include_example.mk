### some variables ####################################################
SRCDIR = ~/projects/pipeline/ppln
JAVA = /mnt/xfs1/home/ifisk/java/jdk1.8.0_11/bin/java
GAPS = /mnt/xfs1/scratch/asalomatov/data/hg19/gap_corr23.bed
BCBIODIR = /mnt/xfs1/bioinfoCentos7/software/installs/bcbio_nextgen/150617
TOOLSDIR = /mnt/xfs1/home/asalomatov/projects/dnanexus/installs
PICARDDIR = /bioinfo/software/installs/picard/git 
PICARD = $(TOOLSDIR)/bin/picard
GENOMEREF = /mnt/xfs1/bioinfoCentos7/data/bcbio_nextgen/150617/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
DJAVA_LIB = /mnt/xfs1/GATK_3.6/gatk-protected-3.6/public/VectorPairHMM/src/main/c++
GATK = /mnt/xfs1/bioinfoCentos7/software/installs/GATK/3.6/GenomeAnalysisTK.jar
DBSNP = /mnt/xfs1/scratch/asalomatov/data/b37/dbsnp_138.b37.vcf
BEDTLSDIR = $(TOOLSDIR)/bin
SAMTOOLS = $(TOOLSDIR)/bin/samtools
FREEBAYES = /mnt/xfs1/scratch/asalomatov/software/builds/freebayes/bin/freebayes
PLATYPUS = $(TOOLSDIR)/bin/platypus
VCFLIBDIR = $(TOOLSDIR)/bin
BGZIP = $(TOOLSDIR)/bin/bgzip
BCFTOOLS = $(TOOLSDIR)/bin/bcftools
BEDOPSDIR = /mnt/xfs1/bioinfo/software/builds/bedops/git/bedops/bin
SAMBAMBA = $(TOOLSDIR)/bin/sambamba
TABIX = $(TOOLSDIR)/bin/tabix
HAPMAP = /mnt/xfs1/scratch/asalomatov/data/b37/hapmap_3.3.b37.vcf
OMNI = /mnt/xfs1/scratch/asalomatov/data/b37/1000G_omni2.5.b37.vcf
SNP1000G = /mnt/xfs1/scratch/asalomatov/data/b37/1000G_phase1.snps.high_confidence.b37.vcf
MILLSINDEL = /mnt/xfs1/scratch/asalomatov/data/b37/Mills_and_1000G_gold_standard.indels.b37.vcf
SNPEFFDIR = /mnt/xfs1/scratch/asalomatov/data/snpEff
SNPEFFJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/snpEff.jar
SNPSIFTJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/SnpSift.jar
SNPEFFCONF = /mnt/xfs1/scratch/asalomatov/data/snpEff/snpEff.config
SNPEFFGENOME = GRCh37.75
VEPGENBUILD = GRCh37
VEP = /mnt/xfs1/bioinfoCentos7/software/builds/perlbrew/cellar/perls/perl-5.22.1/bin/perl /mnt/xfs1/bioinfoCentos7/software/builds/ensembl/ensembl-tools-release-85/scripts/variant_effect_predictor/variant_effect_predictor.pl --cache --dir=/mnt/ceph/users/carriero/VEPcache/.vep --everything --assembly $(VEPGENBUILD) --offline --force_overwrite --fork 4 --fasta $(GENOMEREF) --no_stats
DBNSFP = /mnt//xfs1/scratch/asalomatov/data/dbNSFP/dbNSFPv3.4a/dbNSFP3.4a.hg19.txt.gz
DBSPIDEX = /mnt/xfs1/scratch/asalomatov/data/spidex/spidex_public_noncommercial_v1_0.vcf.gz
BAM2SMPL = /mnt/ceph/users/asalomatov/regeneron_spark_pilot/info/bam2SPid.yml
REGIONSBED = /mnt/xfs1/scratch/asalomatov/data/b37/b37-chrom.bed

