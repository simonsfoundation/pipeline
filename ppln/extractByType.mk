### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = ~/projects/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX =
SUFFIX =
VARTYPE = snps# snps|indels|mnps|other -  can be multiple comma-separated selection
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).vcf.gz)
$(info $(inFile))
$(info $(notdir $(inFile)))
$(info $(SUFFIX).vcf.gz)
$(info $(SUFFIX)-$(VARTYPE).vcf.gz)
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).vcf.gz,%$(SUFFIX)-$(VARTYPE).vcf.gz,$(notdir $(inFile))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)-$(VARTYPE).vcf.gz: $(INDIR)/%$(SUFFIX).vcf.gz
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/extractVarByType.py $< $@ $(BCFTOOLS) $(VARTYPE) $(LOGDIR)
	$(TABIX) -p vcf $@
