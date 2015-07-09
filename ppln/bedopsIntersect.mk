### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
PREFIX = 1
SUFFIX = -flr
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bed)

all: $(OUTDIR)/$(PREFIX)-uni.bed

$(OUTDIR)/$(PREFIX)-uni.bed: $(inFiles)
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(BEDOPSDIR)/bedops -i $^ > $@
