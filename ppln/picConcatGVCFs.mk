### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /mnt/home/irina/Desktop/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = .g.vcf
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(sort $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX)))

all: $(OUTDIR)/$(FAMCODE)$(SUFFIX)

$(OUTDIR)/$(FAMCODE)$(SUFFIX): $(inFiles)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/picMergeVcf.py $(GENOMEREF) $(TMPDIR) $(PICARD) $(LOGDIR) $@ $^
	$(BGZIP) -f $@
	$(TABIX) -f -p vcf $@.gz
