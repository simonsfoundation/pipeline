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
PREFIX = 
SUFFIX = 
INDIR = .
OUTDIR = .
NCORES = 4
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)
###
inBam = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bam)
$(info $(inBam))
bName = $(basename $(inBam))
$(info $(bName))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%coll.bam,$(notdir $(inBam))))
$(info $(o0))
.DELETE_ON_ERROR:

all: $(o0)

$(OUTDIR)/%coll.bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	samtools collate -l 5 $< $(basename $@)
