default: all
SHELL = /bin/bash
USR = $(shell whoami)
### Inputs ################################
FAMCODE = 1 # override this on cl
PROJ = bioppln
INDIR = /mnt/scratch/$(USR)/$(PROJ)/inputs
SRCDIR = /nethome/asalomatov/projects/ppln
PICARDDIR = /bioinfo/software/installs/picard/git 
GENOMEREF = /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
GAPS = /mnt/scratch/asalomatov/data/hg19/gap_corr23.bed
GATK = /bioinfo/software/installs/GATK/3.2-2/GATK/GenomeAnalysisTK.jar
DBSNP = /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf.gz 
BEDTLSDIR = /bioinfo/software/installs/bedtools/bedtools-2.17.0
FREEBAYES = /bioinfo/software/installs/bcbio/bin/freebayes
VCFLIBDIR = /bioinfo/software/installs/bcbio/bin
BGZIP = /bioinfo/software/installs/bcbio/bin/bgzip
###########################################
WORKDIR = /tmp/$(USR)
OUTDIR = /mnt/scratch/$(USR)/$(PROJ)/outputs
TMPDIR = /tmp/$(USR)/$(PROJ)
num_bins = $(shell ls $(WORKDIR)/*__bin__*.bed | wc -l | xargs seq) 
$(info $(num_bins))

define runCallers

$(eval HC_targ = $(WORKDIR)/$(FAMCODE)-HC-$(1)-bin.vcf.gz)
$(info $(HC_targ))
HC_targs += $(HC_targ)
$(eval HC_dep1 = $(wildcard $(WORKDIR)/$(1)__bin__*.bed))
$(eval HC_dep2 = $(wildcard $(WORKDIR)/$(FAMCODE)*-$(1)-bin-rlgn-rclb.bam))

$(eval FB_targ = $(WORKDIR)/$(FAMCODE)-FB-$(1)-bin.vcf.gz)
$(eval FB_dep1 = $(wildcard $(WORKDIR)/$(1)__bin__*.bed))
$(eval FB_dep2 = $(wildcard $(WORKDIR)/$(FAMCODE)*-$(1)-bin-rlgn-rclb.bam))
FB_targs += $(FB_targ)

$(HC_targ): $(HC_dep1) $(HC_dep2)
	python $(SRCDIR)/gatkHaplotypeCaller.py $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP) $(GAPS) $(OUTDIR) $$@ $$^

$(FB_targ): $(FB_dep1) $(FB_dep2)
	python $(SRCDIR)/freeBayes.py $(GENOMEREF) $(FREEBAYES) $(VCFLIBDIR) $(BGZIP) $(OUTDIR) $$@ $$^

endef      

$(foreach bin,$(num_bins),$(eval $(call runCallers,$(bin)))) 

all: $(OUTDIR)/$(FAMCODE)-gatk-haplotype.vcf.gz $(OUTDIR)/$(FAMCODE)-freebayes.vcf.gz

$(OUTDIR)/$(FAMCODE)-gatk-haplotype.vcf.gz: $(HC_targs)
	cat $^ > $@
$(OUTDIR)/$(FAMCODE)-freebayes.vcf.gz: $(FB_targs)
	cat $^ > $@
