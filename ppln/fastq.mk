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
#bName = $(basename $(inBam))
#$(info $(bName))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%read,$(notdir $(inBam))))
$(info $(o0))
#o1 = $(addsuffix 1.fastq, $(o0))
#o2 = $(addsuffix 2.fastq, $(o0))
#$(info $(o1))
#$(info $(o2))
.DELETE_ON_ERROR:

all: $(o0)

$(OUTDIR)/%read: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	samtools fastq -1 $@1.fastq -2 $@2.fastq -t $<
	echo "samtools fstq done!" > $@
