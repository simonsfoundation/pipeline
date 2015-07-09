default: all
SHELL = /bin/bash
USR = $(shell whoami)
### Inputs ################################
FAMCODE = 1 # override this on cl
PROJ = bioppln
INDIR = /mnt/scratch/$(USR)/$(PROJ)/inputs
SRCDIR = /nethome/asalomatov/projects/ppln
GAPS = /mnt/scratch/asalomatov/data/hg19/gap_corr23.bed
PICARDDIR = /bioinfo/software/installs/picard/git 
GENOMEREF = /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
GATK = /bioinfo/software/installs/GATK/3.2-2/GATK/GenomeAnalysisTK.jar
DBSNP = /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf.gz 
BEDTLSDIR = /bioinfo/software/installs/bedtools/bedtools-2.17.0
SAMTOOLS = /bioinfo/software/installs/bcbio/bin/samtools
###########################################
WORKDIR = /tmp/$(USR)
OUTDIR = /mnt/scratch/$(USR)/$(PROJ)/outputs
TMPDIR = /tmp/$(USR)/$(PROJ)
inBam = $(wildcard $(INDIR)/$(FAMCODE)*.bam)
$(info $(inBam))
o0 = $(addprefix $(WORKDIR)/, $(patsubst %.bam,%-re.bam,$(notdir $(inBam))))
$(info $(o0))
o1 = $(patsubst %-re.bam,%-re-fxgr.bam,$(o0))
$(info $(o1))
o2 = $(addsuffix .bai,$(o1))
$(info $(o2))
o3 = $(patsubst %-fxgr.bam,%-fxgr-flr.bam,$(o1))
$(info $(o3))
o4 = $(patsubst %-flr.bam,%-flr-dp.bam,$(o3))
$(info $(o4))
o5 = $(addsuffix .bai,$(o4))
$(info $(o5))
o6 = $(patsubst %-dp.bam,%-dp.bam.met,$(o4))
$(info $(o6))
o7 = $(patsubst %-dp.bam,%-dp.bam.GcBmet,$(o4))
$(info $(o7))
o8 = $(patsubst %-dp.bam,%-dp.bam.FlSt,$(o4))
$(info $(o8))
o9 = $(patsubst %.bam,%.bed,$(o4))
$(info $(o9))
o10 = $(patsubst %.bed,%-ngps.bed,$(o9))
$(info $(o10))
o11 = $(patsubst %-ngps.bed,%-ngps-mrg.bed,$(o10))
$(info $(o11))
#o12 = $(patsubst %-mrg.bed,%-mrg-nchr.bed,$(o11))
#$(info $(o12))
o13 = $(patsubst %-mrg.bed,%-mrg-23.bed,$(o11))
$(info $(o13))
#o14 = $(addprefix $(OUTDIR)/,$(notdir $(o13)))
#$(info $(o14))
o15 = $(addprefix $(OUTDIR)/,$(notdir $(o6)))
$(info $(o15))
o17 = $(patsubst %-dp.bam,%-dp-irr.bam,$(o4))
$(info $(o17))
o18 = $(addprefix $(OUTDIR)/,$(notdir $(o17)))
$(info $(o18))
o19 = $(addsuffix .bai,$(o16))
$(info $(o16))

.PRECIOUS: $(o4) $(o5) $(o6) $(o7) $(o8) $(o9) $(o10) $(o11) $(o13) $(o15) $(o16) $(o18) $(o19)

all: $(o04) $(o05) $(o7) $(o8) $(o13) $(o15) $(o18) $(o19)

$(WORKDIR)/%-dp-23.bam.bai: $(WORKDIR)/%-dp-23.bam
	python $(SRCDIR)/indexBam.py $< $@ $(OUTDIR)

$(OUTDIR)/%-dp-irr.bam: $(WORKDIR)/%-dp-23.bam
	cp -p $(patsubst %-23.bam,%-irr.bam,$<) $@

$(WORKDIR)/%-dp-23.bam: $(WORKDIR)/%-dp.bam $(WORKDIR)/%-dp-ngps-mrg-23.bed
	python $(SRCDIR)/samtoolsFilterInt.py $^ $@ $(SAMTOOLS) $(OUTDIR)

$(OUTDIR)/%.met: $(WORKDIR)/%.met
	cp -p $<.* $(OUTDIR)/
	cp -p $< $@

#$(OUTDIR)/%-23.bed: $(WORKDIR)/%-23.bed
#	cp -p $< $@

$(WORKDIR)/%-mrg-23.bed: $(WORKDIR)/%-mrg.bed
	python $(SRCDIR)/filter23.py $< $@ $(OUTDIR)

#$(WORKDIR)/%-mrg-nchr.bed: $(WORKDIR)/%-mrg.bed
#	python $(SRCDIR)/removeChr.py $< $@ $(OUTDIR)

$(WORKDIR)/%-ngps-mrg.bed: $(WORKDIR)/%-ngps.bed
	python $(SRCDIR)/bedMerge.py $< $@ $(BEDTLSDIR) $(OUTDIR)

$(WORKDIR)/%-dp-ngps.bed: $(WORKDIR)/%-dp.bed
	python $(SRCDIR)/bedSubtract.py $< $(GAPS) $@ $(BEDTLSDIR) $(OUTDIR)

$(WORKDIR)/%-re-fxgr-flr-dp.bed: $(WORKDIR)/%-re-fxgr-flr-dp.bam
	python $(SRCDIR)/bedGenomeCov.py $< $@ $(BEDTLSDIR) $(OUTDIR)

$(WORKDIR)/%-dp.bam.FlSt: $(WORKDIR)/%-dp.bam
	python $(SRCDIR)/gatkFlagStat.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK)  $(OUTDIR)

$(WORKDIR)/%-dp.bam.GcBmet: $(WORKDIR)/%-dp.bam
	python $(SRCDIR)/collectGcBiasMetrics.py $< $@ $(PICARDDIR) $(GENOMEREF) $(OUTDIR)
	cp -p $@* $(OUTDIR)/
	cp -p $<.de* $(OUTDIR)/

$(WORKDIR)/%-dp.bam.met: $(WORKDIR)/%-dp.bam
	python $(SRCDIR)/collectMultMetrics.py $< $@ $(PICARDDIR) $(GENOMEREF) $(OUTDIR)

$(WORKDIR)/%-dp.bam.bai: $(WORKDIR)/%-dp.bam
	python $(SRCDIR)/indexBam.py $< $@ $(OUTDIR)

$(WORKDIR)/%-flr-dp.bam: $(WORKDIR)/%-flr.bam
	python $(SRCDIR)/dedupBam.py $< $@ $(PICARDDIR) $(OUTDIR)

$(WORKDIR)/%-fxgr-flr.bam: $(WORKDIR)/%-fxgr.bam $(WORKDIR)/%-fxgr.bam.bai
	python $(SRCDIR)/gatkPrintReads.py $^ $@ $(GENOMEREF) $(TMPDIR) $(OUTDIR)

$(WORKDIR)/%-re-fxgr.bam.bai: $(WORKDIR)/%-re-fxgr.bam
	python $(SRCDIR)/indexBam.py $< $@ $(OUTDIR)

$(WORKDIR)/%-re-fxgr.bam: $(WORKDIR)/%-re.bam
	python $(SRCDIR)/addOrReplaceReadGroups.py $< $@ $(PICARDDIR) $(TMPDIR) $(OUTDIR)

$(WORKDIR)/%-re.bam: $(INDIR)/%.bam
	mkdir -p $(WORKDIR)
	mkdir -p $(TMPDIR)
	python $(SRCDIR)/reorderBam.py $< $@ $(PICARDDIR) $(GENOMEREF) $(TMPDIR) $(OUTDIR)
