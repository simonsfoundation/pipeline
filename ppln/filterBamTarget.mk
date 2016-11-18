### 
#default: all
SHELL = /bin/bash
USR = $(shell whoami)
include $(INCLMK)
### may override on cl
PREFIX =
SUFFIX =
NEWSUFFIX = -targ
TARGBED = 
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX)$(NEWSUFFIX).bam,$(notdir $(inFile))))
$(info $(o0))
$(info $(o1))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)$(NEWSUFFIX).bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	samtools view -hb -L $(TARGBED) -o $@ -U $(@:$(NEWSUFFIX).bam=$(NEWSUFFIX)-extra.bam) $<
	bedtools coverage -sorted -hist -b $@ -a $(TARGBED) > $(@:$(NEWSUFFIX).bam=$(NEWSUFFIX)-cvrg.txt)

#	bedtools coverage -hist -abam $@ -b $(TARGBED) > $(@:$(NEWSUFFIX).bam=$(NEWSUFFIX)-cvrg.txtu
#    samtools view -hb -L $(TARGBED) -o $@ -U $@.extra.bam $<
