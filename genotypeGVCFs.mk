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
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
num_bins = $(shell ls $(INDIR)/*__bin__$(FAMCODE)-uni-mrg.bed | wc -l | xargs seq) 
$(info $(num_bins))

define runCaller

$(eval targ = $(OUTDIR)/$(FAMCODE)-JHC-$(1)-bin.vcf)
targs += $(targ)
$(eval dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval dep2 = $(wildcard $(INDIR)/$(FAMCODE)*-$(1)$(SUFFIX).g.vcf))

$(targ): $(dep1) $(dep2)
	python $(SRCDIR)/gatkGenotypeGVCFs.py $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP) $(GAPS) $(LOGDIR) $$@ $$^
	$(BGZIP) $$@
	$(TABIX) -p vcf $$@.gz

endef      
#$(info $(targ))

$(foreach bin,$(num_bins),$(eval $(call runCaller,$(bin)))) 

all: $(targs)

