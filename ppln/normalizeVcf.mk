### 
#default: all
SHELL = /bin/bash
ifdef SLURMMASTER
	SHELL=srun
	.SHELLFLAGS= -N1 --cpus-per-task=1 bash -c 
endif
$(info $(SHELL))
USR = $(shell whoami)
INCLMK = 
include $(INCLMK)
### may override on cl
GZTAB=1
PREFIX = 
SUFFIX = 
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX))
#$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX),%-norm$(SUFFIX),$(notdir $(inFile))))
#$(info $(o0))
.DELETE_ON_ERROR:

all: $(o0)

ifeq ($(GZTAB),1)
$(OUTDIR)/%-norm$(SUFFIX): $(INDIR)/%$(SUFFIX)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(VT) normalize -r $(GENOMEREF) -q -o - $< | $(BGZIP) > $@ 
	$(TABIX) -p vcf $@
else
$(OUTDIR)/%-norm$(SUFFIX): $(INDIR)/%$(SUFFIX)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(VT) normalize -r $(GENOMEREF) -q -o $@ $<
endif
