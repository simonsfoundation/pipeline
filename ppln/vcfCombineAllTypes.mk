### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX =
SUFFIX = -flr
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).vcf.gz)
$(info $(inFiles))
#outFile := $(addprefix $(OUTDIR)/,$(subst -raw-snps,,$(basename $(notdir $(inFiles)))))
outFile := $(OUTDIR)/$(PREFIX)-flr.vcf
$(info $(outFile))
#inFiles += $(wildcard $(INDIR)/$(PREFIX)*-raw-indels$(SUFFIX).vcf.gz)
$(info $(inFiles))
tempFile = $(OUTDIR)/$(FAMCODE)-varsflrtemp.vcf
targ = $(OUTDIR)/$(FAMCODE)-vars-flr.vcf

all: $(outFile)

$(outFile): $(inFiles)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(BCFTOOLS) concat -a $^ > $(tempFile)
	$(BCFTOOLS) view -h $(tempFile) > $@
	$(BCFTOOLS) view -H $(tempFile) | sort -V -k1,1 -k2,2 >> $@
	$(BGZIP) -f $@
	$(TABIX) -f -p vcf $@.gz
#	$(VCFLIBDIR)/vcfcombine $^ > $@
#	$(BGZIP) -f $@
#	$(TABIX) -f -p vcf $@.gz
