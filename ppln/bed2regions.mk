### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
PATTERN = __bin
SUFFIX =
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(wildcard $(INDIR)/*$(PATTERN)*$(SUFFIX).bed)
$(info $(inFiles))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%$(SUFFIX).list,$(notdir $(inFiles))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX).list: $(INDIR)/%$(SUFFIX).bed
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/bed2regions.py $< $@ $(LOGDIR)
