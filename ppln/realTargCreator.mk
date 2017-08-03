### 
#default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = -23
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bam.intervals,$(notdir $(inFile))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX).bam.intervals: $(INDIR)/%$(SUFFIX).bam $(INDIR)/%$(SUFFIX).bed
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/gatkRealignerTargCreator.py $^ $@ $(GENOMEREF) $(MILLSINDEL) $(TMPDIR) $(GATK) $(GAPS) $(LOGDIR)
