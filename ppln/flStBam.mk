### 
#default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = -dp
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bam.FlSt,$(notdir $(inBam))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX).bam.FlSt: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/gatkFlagStat.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR)
