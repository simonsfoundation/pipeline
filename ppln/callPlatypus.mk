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

$(eval targ = $(OUTDIR)/$(FAMCODE)-PL-$(1)-bin.vcf.gz)
targs += $(targ)
$(eval dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval dep2 = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam))

$(targ): $(dep1) $(dep2)
	python $(SRCDIR)/platypus.py $(GENOMEREF) $(PLATYPUS) $(VCFLIBDIR) $(BCFTOOLS) $(BGZIP) $(LOGDIR) $$@ $$^
	(bcftools view -h $$@; bcftools view -H $$@ | sort -V -k1,2) | bgzip -c > $$@-sort.vcf.gz
	mv -f $$@-sort.vcf.gz $$@
	tabix -f -p vcf $$@
	vt uniq -o $$@-u.vcf.gz $$@
	tabix -p vcf $$@-u.vcf.gz
#	vt decompose -o $$@-d.vcf.gz $$@-u.vcf.gz
#	tabix -p vcf $$@-d.vcf.gz
	vt normalize -r $(GENOMEREF) -o $$@-n.vcf.gz $$@-u.vcf.gz
	tabix -p vcf $$@-n.vcf.gz
	vt sort -o $$@-s.vcf.gz $$@-n.vcf.gz
	cp -f $$@-s.vcf.gz $$@
	tabix -f -p vcf $$@
	rm $$@-u.vcf.gz*
#	rm $$@-d.vcf.gz*
	rm $$@-n.vcf.gz*
	rm $$@-s.vcf.gz*

endef      
define runCallerSplitBam

$(eval targ = $(OUTDIR)/$(FAMCODE)-PL-$(1)-bin.vcf.gz)
targs += $(targ)
$(eval dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval dep2 = $(wildcard $(INDIR)/$(FAMCODE)*-$(1)$(SUFFIX).bam))

$(targ): $(dep1) $(dep2)
	python $(SRCDIR)/platypus.py $(GENOMEREF) $(PLATYPUS) $(VCFLIBDIR) $(BCFTOOLS) $(BGZIP) $(LOGDIR) $$@ $$^
	(bcftools view -h $$@; bcftools view -H $$@ | sort -V -k1,2) | bgzip -c > $$@-sort.vcf.gz
	tabix -f -p vcf $$@
	vt uniq -o $$@-u.vcf.gz $$@
	tabix -p vcf $$@-u.vcf.gz
	vt decompose -o $$@-d.vcf.gz $$@-u.vcf.gz
	tabix -p vcf $$@-d.vcf.gz
#	vt normalize -r $(GENOMEREF) -o $$@-n.vcf.gz $$@-d.vcf.gz
#	tabix -p vcf $$@-n.vcf.gz
	vt sort -o $$@-s.vcf.gz $$@-u.vcf.gz
	cp -f $$@-s.vcf.gz $$@
	tabix -f -p vcf $$@
	rm $$@-u.vcf.gz*
#	rm $$@-d.vcf.gz*
	rm $$@-n.vcf.gz*
	rm $$@-s.vcf.gz*


endef      

#$(info $(targ))
#	bgzip -f $$@
#	tabix -f -p vcf $$@.gz

ifeq ($(SUFFIX),-bin)
$(foreach bin,$(num_bins),$(eval $(call runCallerSplitBam,$(bin)))) 
else
$(foreach bin,$(num_bins),$(eval $(call runCaller,$(bin)))) 
endif

all: $(targs)

