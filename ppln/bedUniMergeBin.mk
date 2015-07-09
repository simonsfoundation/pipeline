### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
PREFIX = 2
SUFFIX = -call
RANGE = 0
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
num_bins = $(shell ls $(INDIR)/*__bin__$(PREFIX)-uni-mrg.bed | wc -l | xargs seq) 
$(info $(num_bins))

define UniAndMerge

$(eval targ0 = $(OUTDIR)/$(PREFIX)-$(1)-bin-evrth.bed)
$(eval targ1 = $(OUTDIR)/$(PREFIX)-$(1)-bin-evrth-mrg.bed)
targs0 += $(targ0)
targs1 += $(targ1)
$(eval dep0 = $(wildcard $(INDIR)/$(1)__bin__*$(SUFFIX).bed))

$(targ1): $(targ0)
	$(BEDOPS)/bedops --range $(RANGE) --merge $$< > $$@

$(targ0): $(dep0)
	$(BEDOPS)/bedops --everything $$^ > $$@

endef      

$(foreach bin,$(num_bins),$(eval $(call UniAndMerge,$(bin)))) 

all: $(targs1)

