SHELL = /bin/bash
USR = $(shell whoami)
### Inputs ################################
FAMCODE = 1 # override this on cl
PROJ = bioppln
INDIR = /mnt/scratch/$(USR)/$(PROJ)/inputs
SRCDIR = /nethome/asalomatov/projects/ppln
PICARDDIR = /bioinfo/software/installs/picard/git 
GENOMEREF = /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
GATK = /bioinfo/software/installs/GATK/3.2-2/GATK/GenomeAnalysisTK.jar
DBSNP = /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf.gz 
BEDTLSDIR = /bioinfo/software/installs/bedtools/bedtools-2.17.0
###########################################
OUTDIR = /mnt/scratch/$(USR)/$(PROJ)/outputs
TMPDIR = /tmp/$(USR)/$(PROJ)
inBam = $(wildcard $(INDIR)/$(FAMCODE)*.bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %.bam,%-re.bam,$(notdir $(inBam))))
$(info $(o0))
o1 = $(patsubst %-re.bam,%-re-fxgr.bam,$(o0))
$(info $(o1))
o2 = $(addsuffix .bai,$(o1))
$(info $(o2))
o3 = $(patsubst %-re-fxgr.bam,%-re-fxgr-flr.bam,$(o1))
$(info $(o3))
o4 = $(patsubst %-re-fxgr-flr.bam,%-re-fxgr-flr-dp.bam,$(o3))
$(info $(o4))
o5 = $(addsuffix .bai,$(o4))
$(info $(o5))
o6 = $(addsuffix .intervals,$(o4))
$(info $(o6))
o7 = $(patsubst %-re-fxgr-flr-dp.bam,%-re-fxgr-flr-dp-rlgn.bam,$(o4))
$(info $(o7))
o8 = $(addsuffix .table,$(o7))
$(info $(o7))
o9 = $(patsubst %-re-fxgr-flr-dp-rlgn.bam,%-re-fxgr-flr-dp-rlgn-rclb.bam,$(o7))
$(info $(o9))
o10 = $(patsubst %-re-fxgr-flr-dp-rlgn-rclb.bam,%-re-fxgr-flr-dp-rlgn-rclb.bam.met,$(o9))
$(info $(o10))
o11 = $(patsubst %-re-fxgr-flr-dp-rlgn-rclb.bam,%-re-fxgr-flr-dp-rlgn-rclb.bam.GcBmet,$(o9))
$(info $(o11))
o12 = $(patsubst %-re-fxgr-flr-dp-rlgn-rclb.bam,%-re-fxgr-flr-dp-rlgn-rclb.bam.FlSt,$(o9))
$(info $(o12))
o13 = $(patsubst %-re-fxgr-flr-dp-rlgn-rclb.bam,%-re-fxgr-flr-dp-rlgn-rclb_bam.bed,$(o9))
$(info $(o13))
o14 = $(addprefix $(OUTDIR)/,$(addsuffix -raw.vcf,$(FAMCODE)))
$(info $(o14))

.PRECIOUS: $(o0) $(o1) $(o2) $(o3) $(o4) $(o5) $(o6) $(o7) $(o8) $(o9) $(o10) $(o11) $(o12) $(o13) $(o14)

all: $(o10) $(o11) $(o12) $(o13) 

#$(OUTDIR)/$(FAMCODE)-raw.vcf: $(OUTDIR)/$(FAMCODE)%-rclb.bam
$(o14): $(o9)
	echo $^ $@ > $@
	python $(SRCDIR)/gatkHaplotypeCaller.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP)

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb_bam.bed: $(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam
	python $(SRCDIR)/bedCoverage.py $< $@ $(BEDTLSDIR) 

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam.FlSt: $(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam
	python $(SRCDIR)/gatkFlagStat.py $< $@ $(GENOMEREF) $(TMPDIR)  $(GATK) 

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam.GcBmet: $(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam
	python $(SRCDIR)/collectGcBiasMetrics.py $< $@ $(PICARDDIR) $(GENOMEREF)

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam.met: $(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam
	python $(SRCDIR)/collectMultMetrics.py $< $@ $(PICARDDIR) $(GENOMEREF)

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn-rclb.bam: $(OUTDIR)/%-re-fxgr-flr-dp-rlgn.bam $(OUTDIR)/%-re-fxgr-flr-dp-rlgn.bam.table
	python $(SRCDIR)/gatkPrintBqsrReads.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK)

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn.bam.table: $(OUTDIR)/%-re-fxgr-flr-dp-rlgn.bam
	python $(SRCDIR)/gatkBaseRecalibrator.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP)

$(OUTDIR)/%-re-fxgr-flr-dp-rlgn.bam: $(OUTDIR)/%-re-fxgr-flr-dp.bam $(OUTDIR)/%-re-fxgr-flr-dp.bam.intervals
	python $(SRCDIR)/gatkIndelRealigner.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK)

$(OUTDIR)/%-re-fxgr-flr-dp.bam.intervals: $(OUTDIR)/%-re-fxgr-flr-dp.bam
	python $(SRCDIR)/gatkRealignerTargCreator.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK)

#$(o5): $(o4)
$(OUTDIR)/%-re-fxgr-flr-dp.bam.bai: $(OUTDIR)/%-re-fxgr-flr-dp.bam
	python $(SRCDIR)/indexBam.py $< $@

#$(o4): $(o3)
$(OUTDIR)/%-re-fxgr-flr-dp.bam: $(OUTDIR)/%-re-fxgr-flr.bam
	python $(SRCDIR)/dedupBam.py $< $@ $(PICARDDIR)

#$(o3): $(o1) $(o2)
$(OUTDIR)/%-re-fxgr-flr.bam: $(OUTDIR)/%-re-fxgr.bam $(OUTDIR)/%-re-fxgr.bam.bai
	python $(SRCDIR)/gatkPrintReads.py $^ $@ $(GENOMEREF) $(TMPDIR)

$(OUTDIR)/%-re-fxgr.bam.bai: $(OUTDIR)/%-re-fxgr.bam
	python $(SRCDIR)/indexBam.py $< $@

$(OUTDIR)/%-re-fxgr.bam: $(OUTDIR)/%-re.bam
	python $(SRCDIR)/addOrReplaceReadGroups.py $< $@ $(PICARDDIR) $(TMPDIR) 

$(OUTDIR)/%-re.bam: $(INDIR)/%.bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	python $(SRCDIR)/reorderBam.py $< $@ $(PICARDDIR) $(GENOMEREF) $(TMPDIR) 
