### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
PREFIX =
SUFFIX =
REGION = 20#1, or 1:1000-2000
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inBam = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-$(REGION).bam,$(notdir $(inBam))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)-$(REGION).bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	samtools view -b -h $< $(REGION) > $@
	samtools index $@
#	sambamba view -t 3 -h $< $(REGION) > $@
