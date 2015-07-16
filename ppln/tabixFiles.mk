### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
FAMCODE = 1
SUFFIX = -bin.vcf.gz
FILETYPE = vcf
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX),%$(SUFFIX).tbi,$(notdir $(inFiles))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX).tbi: $(INDIR)/%$(SUFFIX)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(TABIX) -f -p $(FILETYPE) $<
