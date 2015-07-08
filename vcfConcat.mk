### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = -bin.vcf.gz
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(sort $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX)))
tempFile = $(OUTDIR)/$(FAMCODE)-varstemp.vcf
targ = $(OUTDIR)/$(FAMCODE)-vars.vcf

all: $(targ)

$(OUTDIR)/$(FAMCODE)-vars.vcf: $(inFiles)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(BCFTOOLS) concat -a -D  $(INDIR)/$(FAMCODE)*$(SUFFIX) > $(tempFile)
	$(BCFTOOLS) view -h $(tempFile) > $@
	$(BCFTOOLS) view -H $(tempFile) | sort -V -k1,1 -k2,2 >> $@
	$(BGZIP) -f $@
	$(TABIX) -f -p vcf $@.gz
