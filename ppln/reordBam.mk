### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = ~/projects/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = 
PROJ = mktest
INDIR = 
OUTDIR = 
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
RMINPUT = NO
###
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-re.bam,$(notdir $(inBam))))
$(info $(o0))

all: $(o0)

ifeq ($(RMINPUT),YES)
$(OUTDIR)/%$(SUFFIX)-re.bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/reorderBam.py $< $@ $(PICARD) $(GENOMEREF) $(TMPDIR) $(LOGDIR)
	rm $<*
else
$(OUTDIR)/%$(SUFFIX)-re.bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/reorderBam.py $< $@ $(PICARD) $(GENOMEREF) $(TMPDIR) $(LOGDIR)
endif

