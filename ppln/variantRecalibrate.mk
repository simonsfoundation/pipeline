### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = ~/projects/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX = 1
SUFFIX = 
VARTYPE = SNP
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)
T = 20
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX))
$(info $(inFile))
recalFile = $(OUTDIR)/$(PREFIX)-recal-$(VARTYPE).recal
tranchesFile = $(OUTDIR)/$(PREFIX)-recal-$(VARTYPE).tranches
rplotFile = $(OUTDIR)/$(PREFIX)-recal-$(VARTYPE).plots.R

all: $(recalFile)

ifeq ($(VARTYPE),SNP)
$(recalFile): $(inFile)
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(JAVA) -Xmx256G -jar $(GATK) \
		    -T VariantRecalibrator \
			-R $(GENOMEREF) \
			-input $< \
			-resource:hapmap,known=false,training=true,truth=true,prior=15.0 $(HAPMAP) \
			-resource:omni,known=false,training=true,truth=true,prior=12.0 $(OMNI) \
			-resource:1000G,known=false,training=true,truth=false,prior=10.0 $(SNP1000G) \
			-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $(DBSNP) \
			-an DP \
			-an QD \
			-an FS \
			-an SOR \
			-an MQ \
			-an MQRankSum \
			-an ReadPosRankSum \
			-mode $(VARTYPE) \
			-mG 4  \
			-nt $(T) \
			-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
			-recalFile $@ \
			-tranchesFile $(tranchesFile) \
			-rscriptFile $(rplotFile)
else
$(recalFile): $(inFile)
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(JAVA) -Xmx256G -jar $(GATK) \
		    -T VariantRecalibrator \
			-R $(GENOMEREF) \
			-input $< \
			-resource:mills,known=true,training=true,truth=true,prior=12.0 $(MILLSINDEL) \
			-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $(DBSNP) \
			-an QD \
			-an DP \
			-an FS \
			-an SOR \
			-an MQRankSum \
			-an ReadPosRankSum \
			-mode $(VARTYPE) \
			-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
			-mG 4 \
			-nt $(T) \
			-recalFile $@ \
			-tranchesFile $(tranchesFile) \
			-rscriptFile $(rplotFile)
endif
