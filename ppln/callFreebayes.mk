### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 2
SUFFIX = -bin
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
num_bins = $(shell ls $(INDIR)/*__bin__$(FAMCODE)-uni-mrg.bed | wc -l | xargs seq) 
$(info $(num_bins))

define runCaller

$(eval targ = $(OUTDIR)/$(FAMCODE)-FB-$(1)-bin.vcf.gz)
targs += $(targ)
$(eval dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval dep2 = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam))

$(targ): $(dep1) $(dep2)
	python $(SRCDIR)/freeBayes.py $(GENOMEREF) $(FREEBAYES) $(VCFLIBDIR) $(BGZIP) $(LOGDIR) $$@ $$^
	$(TABIX) -f -p vcf $$@

endef      
#$(info $(targ))

define runCallerSplitBam

$(eval targ = $(OUTDIR)/$(FAMCODE)-FB-$(1)-bin.vcf.gz)
targs += $(targ)
$(eval dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval dep2 = $(wildcard $(INDIR)/$(FAMCODE)*-$(1)$(SUFFIX).bam))

$(targ): $(dep1) $(dep2)
	python $(SRCDIR)/freeBayes.py $(GENOMEREF) $(FREEBAYES) $(VCFLIBDIR) $(BGZIP) $(LOGDIR) $$@ $$^
	$(TABIX) -f -p vcf $$@

endef      
#$(info $(targ))

ifeq ($(SUFFIX),-bin)
$(foreach bin,$(num_bins),$(eval $(call runCallerSplitBam,$(bin)))) 
else
$(foreach bin,$(num_bins),$(eval $(call runCaller,$(bin)))) 
endif

all: $(targs)

