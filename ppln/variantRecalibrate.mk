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
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).vcf.gz)
$(info $(inFile))
#o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).vcf.,%$(SUFFIX).bam.table,$(notdir $(inFile))))
#$(info $(o0))
recallFile = $(OUTDIR)/$(PREFIX)-recalib-$(VARTYPE).recall
tranchesFile = $(OUTDIR)/$(PREFIX)-recalib-$(VARTYPE).tranches
rplotFile = $(OUTDIR)/$(PREFIX)-recalib-$(VARTYPE).plots.R

all: $(recallFile)

$(OUTDIR)/$(PREFIX)-recalib-$(VARTYPE).recall: $(inFile)
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
			-mode SNP \
			-maxGaussians 4 \
			-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
			-recalFile $@ \
			-tranchesFile $(tranchesFile) \
			-rscriptFile $(rplotFile)
