### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = ~/projects/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 
SUFFIX = 
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
RMINPUT = NO
###
$(info $(FAMCODE))
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-fxgr.bam,$(notdir $(inBam))))
$(info $(o0))

all: $(o0)

ifeq ($(RMINPUT),YES)
$(OUTDIR)/%$(SUFFIX)-fxgr.bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/addOrReplaceReadGroups.py $< $@ $(PICARD) $(TMPDIR) $(LOGDIR) $(BAM2SMPL)
	rm $<*
else
$(OUTDIR)/%$(SUFFIX)-fxgr.bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/addOrReplaceReadGroups.py $< $@ $(PICARD) $(TMPDIR) $(LOGDIR) $(BAM2SMPL)
endif

