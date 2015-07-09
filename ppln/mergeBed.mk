### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
FAMCODE = 1
SUFFIX = -ngps
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bed)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%$(SUFFIX)-mrg.bed,$(notdir $(inFile))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)-mrg.bed: $(INDIR)/%$(SUFFIX).bed
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/bedMerge.py $< $@ $(BEDTLSDIR) $(LOGDIR)
