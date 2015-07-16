### 
#default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX = 1
SUFFIX = -dp
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###

inBam = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bam)
$(info $(inBam))
inBed = $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bed,$(inBam))
outBed = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%$(SUFFIX)-cloc.bed,$(notdir $(inBed))))

all: $(outBed)

$(OUTDIR)/%$(SUFFIX)-cloc.bed: $(OUTDIR)/%$(SUFFIX).bam $(OUTDIR)/%$(SUFFIX).bed
	python $(SRCDIR)/gatkCallableLoci.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR)

