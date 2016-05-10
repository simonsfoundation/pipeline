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
FAMCODE = 
SUFFIX = 
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
#$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bam.bai,$(notdir $(inBam))))
#$(info $(o0))
.DELETE_ON_ERROR:

all: $(o0)

$(OUTDIR)/%$(SUFFIX).bam.bai: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(SAMBAMBA) index -t 3 $<
#	python $(SRCDIR)/indexBam.py $< $@ $(SAMBAMBA) $(LOGDIR)
