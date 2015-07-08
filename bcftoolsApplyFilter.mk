### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
VARTYPE = snps# snps|indels|mnps|other -  can be multiple comma-separated selection
ifeq ($(VARTYPE),snps)
	FILTER = QD < 2.0 || MQ < 40.0 || FS > 60.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0
	FILTID = HardSnp
else
	FILTER = QD < 2.0 || ReadPosRankSum < -20.0 || FS > 200.0
	FILTID = HardIndel
endif
$(info $(FILTER))
PREFIX =
SUFFIX = -vars-$(VARTYPE)
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).vcf.gz)
$(info $(inFile))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).vcf.gz,%$(SUFFIX)-flr.vcf.gz,$(notdir $(inFile))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)-flr.vcf.gz: $(INDIR)/%$(SUFFIX).vcf.gz
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	bcftools filter -O z --soft-filter $(FILTID) -e '$(FILTER)' -m + -o $@ $<
	tabix -p vcf $@
