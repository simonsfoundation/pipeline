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
infq = $(wildcard $(INDIR)/$(PREFIX)*.read)
$(info $(infq))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %.read,%.bwa.bam,$(notdir $(infq))))
$(info $(o0))
.DELETE_ON_ERROR:

all: $(o0)

$(OUTDIR)/%$(SUFFIX).bwa.bam: $(INDIR)/%$(SUFFIX).read1.fastq $(INDIR)/%$(SUFFIX).read2.fastq 
	mkdir -p $(OUTDIR)
	bwa mem -t $(NCORES) -M -R "@RG\tID:$(basename $(basename $(notdir $@)))\tPL:ILLUMINA\tSM:$(basename $(basename $(notdir $@)))" $(GENOMEREF) $(word 1,$^) $(word 2,$^) | samtools view -bS -  > $@
