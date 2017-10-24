### 
#default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = 
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
#inBed = $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bed,$(inBam))
outBed = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-cloc.bed,$(notdir $(inBam))))
$(info $(outBed))

all: $(outBed)

$(OUTDIR)/%$(SUFFIX)-cloc.bed: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	mkdir -p $(LOGDIR)
	python $(SRCDIR)/gatkCallableLoci.py $< $(REGIONSBED) $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR)

#$(OUTDIR)/%$(SUFFIX)-cloc.bed: $(INDIR)/%$(SUFFIX).bam
#	mkdir -p $(OUTDIR)
#	mkdir -p $(LOGDIR)
#	python $(SRCDIR)/gatkCallableLoci.py $< $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR)

