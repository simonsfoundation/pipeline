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
#o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).vcf.,%$(SUFFIX).bam.table,$(notdir $(inFile))))
#$(info $(o0))
recalFile = $(OUTDIR)/$(PREFIX)-recal-$(VARTYPE).recal
tranchesFile = $(OUTDIR)/$(PREFIX)-recal-$(VARTYPE).tranches
outFile = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX),%-recal-$(VARTYPE)$(SUFFIX),$(notdir $(inFile))))
$(info $(outFile))
outFile1 = $(patsubst %-recal-INDEL-recal-SNP-vars.vcf.gz,%-recal-vars.vcf.gz,$(outFile))
$(info $(outFile1))
#outFile = $(OUTDIR)/$(PREFIX)-recalib-$(VARTYPE).vcf

all: $(outFile1)

$(outFile1): $(inFile)
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(JAVA) -Xmx5G -jar $(GATK) \
		    -T ApplyRecalibration \
			-R $(GENOMEREF) \
			-input $< \
			-nt $(T) \
			-mode $(VARTYPE) \
			--ts_filter_level 99.0 \
			-recalFile $(recalFile) \
			-tranchesFile $(tranchesFile) \
			-o $@
	$(TABIX) -f -p vcf $@
