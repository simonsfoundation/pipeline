### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
MINCVRG = 5
PREFIX =
SUFFIX = -mrg
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bed)
$(info $(inFile))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%$(SUFFIX)-flr.bed,$(notdir $(inFile))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)-flr.bed: $(INDIR)/%$(SUFFIX).bed
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/filterBedByCvrg.py $< $@ $(MINCVRG) $(LOGDIR)
