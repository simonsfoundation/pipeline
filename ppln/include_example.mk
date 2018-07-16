###	DIRECTORIES	 ####################################################
SRCDIR = <absolute path to directory with pipeline\'s code> 
BCBIODIR = <absolute path to directory with installed bcbio-nextgen>
TOOLSDIR = <absolute path to directory that has links to all necessary tools in subdirectory bin>
BEDTLSDIR = $(TOOLSDIR)/bin   
VCFLIBDIR = $(TOOLSDIR)/bin
BEDOPSDIR = <absolute path to subdirectory bin of directory for bedops>

###	 BAM2SMPL	 ####################################################
BAM2SMPL = <absolute path to the corresponding BAM2SMPL file>

###		 ####################################################
JAVA = <java directory>

###	REFERENCES/DBs	   ####################################################
GAPS = <absolute path to bed with gaps in assembly of reference genome>
GENOMEREF = <absolute path to reference genome>
DBNSFP = <absolute path to gzipped dbNSFP>
DBSPIDEX = <absolute path to gzipped spidex DB>
DBSNP = <absolute path to DBSNP vcf>
HAPMAP = <absolute path to HAPMAP vcf>
MILLSINDEL = <absolute path to Mills_and_1000G_gold_standard.indels.b37.vcf>
REGIONSBED = <absolute path to bed with chromosomes starting and ending positions>
OMNI = <absolute path to vcf with OMNI db> 
SNP1000G = <absolute path to vcf with high confidence SNPs from 1000 Genome project>
SNPEFFDIR = <absolute path to snpEff directory>
SNPEFFJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/snpEff.jar
SNPSIFTJAR = $(BCBIODIR)/Cellar/snpeff/4.1g/libexec/SnpSift.jar
SNPEFFCONF = <absolute path to snpEff.config>
SNPEFFGENOME = <snpEff reference genome> #for example, GRCh37.75
VEPGENBUILD = <VEP genome build> #for example, GRCh37
VEP = <command line to execute variant_effect_predictor.pl>

###	 TOOLS	       ####################################################
GATK = <absolute path to  GATK GenomeAnalysisTK.jar>
DJAVA_LIB = <absolute path to java native libraries for GATK>
FREEBAYES = <absolute path to freebayes excutable>
BCFTOOLS = $(TOOLSDIR)/bin/bcftools
BGZIP = $(TOOLSDIR)/bin/bgzip
PICARD = $(TOOLSDIR)/bin/picard
PLATYPUS = $(TOOLSDIR)/bin/platypus
SAMBAMBA = $(TOOLSDIR)/bin/sambamba
SAMTOOLS = $(TOOLSDIR)/bin/samtools
TABIX = $(TOOLSDIR)/bin/tabix
VT = $(TOOLSDIR)/bin/vt

