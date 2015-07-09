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
###########################################
WORKDIR = /tmp/$(USR)
OUTDIR = /mnt/scratch/$(USR)/$(PROJ)/outputs
TMPDIR = /tmp/$(USR)/$(PROJ)
#bin_targets = 
inBam = $(wildcard $(WORKDIR)/$(FAMCODE)*-dp-23.bam)
$(info $(inBam))
num_bins = $(shell ls $(WORKDIR)/*__bin__*.bed | wc -l | xargs seq) 
$(info $(num_bins))
define binBams

$(info $(1))
$(info $(2))
$(eval bsnm = $(notdir $(1)))
$(info $(bsnm))
$(eval fname = $(patsubst %-dp-23.bam,%-dp-23-$(2)-bin.bam,$(bsnm)))
$(info $(fname))
$(eval bin_targ = $(addprefix $(WORKDIR)/,$(fname)))
$(eval bin_dep = $(1) $(wildcard $(WORKDIR)/$(2)__bin__*.bed))
$(info $(bin_targ))
$(info $(bin_dep))
o0 += $(bin_targ)

$(WORKDIR)/%-dp-23-$(2)-bin.bam: $(WORKDIR)/%-dp-23.bam $(wildcard $(WORKDIR)/$(2)__bin__*.bed)
	python $(SRCDIR)/splitBam.py $$^ $$@ $(OUTDIR)

$(WORKDIR)/%-$(2)-bin.bam.intervals: $(WORKDIR)/%-$(2)-bin.bam  $(wildcard $(WORKDIR)/$(2)__bin__*.bed) | $(WORKDIR)/%-$(2)-bin.bam.bai
	python $(SRCDIR)/gatkRealignerTargCreator.py $$^ $$@ $(GENOMEREF) $(TMPDIR) $(GATK) $(GAPS) $(OUTDIR)

$(WORKDIR)/%-$(2)-bin-rlgn.bam.table: $(WORKDIR)/%-$(2)-bin-rlgn.bam  $(wildcard $(WORKDIR)/$(2)__bin__*.bed)
	python $(SRCDIR)/gatkBaseRecalibrator.py $$^ $$@ $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP) $(GAPS) $(OUTDIR)

endef      

o0_ind = $(addsuffix .bai,$(o0))
o1 = $(addsuffix .intervals,$(o0))
#$(info $(o1))
o2 = $(patsubst %-bin.bam,%-bin-rlgn.bam,$(o0))
#$(info $(o2))
o3 = $(addsuffix .table,$(o2))
#$(info $(o3))
o4 = $(patsubst %-bin-rlgn.bam,%-bin-rlgn-rclb.bam,$(o2))
#$(info $(o4))
#$(info $(o14))

$(foreach bam,$(inBam),$(foreach bin,$(num_bins),$(eval $(call binBams,$(bam),$(bin))))) 

.PRECIOUS: $(o0) $(o0_ind) $(o1) $(o2) $(o3) $(o4)

all: $(o4)
#$(info $(bin_targets))

$(WORKDIR)/%-bin-rlgn-rclb.bam: $(WORKDIR)/%-bin-rlgn.bam $(WORKDIR)/%-bin-rlgn.bam.table
	python $(SRCDIR)/gatkPrintBqsrReads.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(OUTDIR)

#$(WORKDIR)/%-bin-rlgn.bam.table: $(WORKDIR)/%-bin-rlgn.bam
#	python $(SRCDIR)/gatkBaseRecalibrator.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP) $(OUTDIR)
#
$(WORKDIR)/%-bin-rlgn.bam: $(WORKDIR)/%-bin.bam $(WORKDIR)/%-bin.bam.intervals
	python $(SRCDIR)/gatkIndelRealigner.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(OUTDIR)

#$(WORKDIR)/%-bin.bam.intervals: $(WORKDIR)/%-bin.bam
#	python $(SRCDIR)/gatkRealignerTargCreator.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(OUTDIR)
#
$(WORKDIR)/%-bin.bam.bai: $(WORKDIR)/%-bin.bam
	python $(SRCDIR)/indexBam.py $< $@ $(OUTDIR)

