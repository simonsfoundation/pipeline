### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = ~/projects/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 
SUFFIX = .g.vcf.gz
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(sort $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX)))

all: $(OUTDIR)/$(FAMCODE).vcf

$(OUTDIR)/$(FAMCODE).vcf: $(inFiles)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/gatkCombineGVCF.py $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR) $@ $^
	$(BGZIP) -f $@
	$(TABIX) -f -p vcf $@.gz
