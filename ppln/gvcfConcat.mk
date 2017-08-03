### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX = 1
SUFFIX = -bin.g.vcf
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX))
bn = $(basename $(notdir inFiles))
o0 = $(addprefix $(OUTDIR)/, $(addsuffix .g.vcf,$(bn)))
$(info $(o0))

#tempfile = $(OUTDIR)/$(PREFIX)-temp.g.vcf
#targ = $(OUTDIR)/$(PREFIX).g.vcf

all: $(o0)

$(o0):  
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
#	$(BCFTOOLS) concat -a -D  $(INDIR)/$(SAMPLENAME)*$(SUFFIX) > $(tempFile)
	$(BCFTOOLS) concat -a -D  $^ > $(tempFile)
	$(BCFTOOLS) view -h $(tempFile) > $@
	$(BCFTOOLS) view -H $(tempFile) | sort -V -k1,1 -k2,2 >> $@
	$(BGZIP) -f $@
	$(TABIX) -f -p vcf $@.gz
	rm $^
