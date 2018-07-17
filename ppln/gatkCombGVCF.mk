### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = 
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

all: $(OUTDIR)/$(FAMCODE).g.vcf

$(OUTDIR)/$(FAMCODE).g.vcf: $(inFiles)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/gatkCombineGVCF.py $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR) $@ $^
	$(BGZIP) -f $@
	$(TABIX) -f -p vcf $@.gz
