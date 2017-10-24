### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = 
include $(INCLMK)
### may override on cl
FAMCODE = 2
SUFFIX = -bin
PROJ = mktest
INDIR = 
OUTDIR = 
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
	($(BCFTOOLS) view -h $$@; $(BCFTOOLS) view -H $$@ | sort -V -k1,2) | $(BGZIP) -c > $$@-sort.vcf.gz
	mv -f $$@-sort.vcf.gz $$@
	$(TABIX) -f -p vcf $$@
	$(VT) uniq -o $$@-u.vcf.gz $$@
	$(TABIX) -p vcf $$@-u.vcf.gz
#	$(VT) decompose -o $$@-d.vcf.gz $$@-u.vcf.gz
#	$(TABIX) -p vcf $$@-d.vcf.gz
	$(VT) normalize -r $(GENOMEREF) -o $$@-n.vcf.gz $$@-u.vcf.gz
	$(TABIX) -p vcf $$@-n.vcf.gz
	$(VT) sort -o $$@-s.vcf.gz $$@-n.vcf.gz
	cp -f $$@-s.vcf.gz $$@
	$(TABIX) -f -p vcf $$@
	rm $$@-u.vcf.gz*
#	rm $$@-d.vcf.gz*
	rm $$@-n.vcf.gz*
	rm $$@-s.vcf.gz*

endef      
define runCallerSplitBam
#IA: decompose should be commented, not normalize
$(eval targ = $(OUTDIR)/$(FAMCODE)-PL-$(1)-bin.vcf.gz)
targs += $(targ)
$(eval dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval dep2 = $(wildcard $(INDIR)/$(FAMCODE)*-$(1)$(SUFFIX).bam))

$(targ): $(dep1) $(dep2)
	python $(SRCDIR)/platypus.py $(GENOMEREF) $(PLATYPUS) $(VCFLIBDIR) $(BCFTOOLS) $(BGZIP) $(LOGDIR) $$@ $$^
	($(BCFTOOLS) view -h $$@; $(BCFTOOLS) view -H $$@ | sort -V -k1,2) | $(BGZIP) -c > $$@-sort.vcf.gz
	$(TABIX) -f -p vcf $$@
	$(VT) uniq -o $$@-u.vcf.gz $$@
	$(TABIX) -p vcf $$@-u.vcf.gz
#	$(VT) decompose -o $$@-d.vcf.gz $$@-u.vcf.gz
#	$(TABIX) -p vcf $$@-d.vcf.gz
	$(VT) normalize -r $(GENOMEREF) -o $$@-n.vcf.gz $$@-d.vcf.gz
	$(TABIX) -p vcf $$@-n.vcf.gz
	$(VT) sort -o $$@-s.vcf.gz $$@-u.vcf.gz
	cp -f $$@-s.vcf.gz $$@
	$(TABIX) -f -p vcf $$@
	rm $$@-u.vcf.gz*
#	rm $$@-d.vcf.gz*
	rm $$@-n.vcf.gz*
	rm $$@-s.vcf.gz*


endef      

#$(info $(targ))
#	$(BGZIP) -f $$@
#	$(TABIX) -f -p vcf $$@.gz

ifeq ($(SUFFIX),-bin)
$(foreach bin,$(num_bins),$(eval $(call runCallerSplitBam,$(bin)))) 
else
$(foreach bin,$(num_bins),$(eval $(call runCaller,$(bin)))) 
endif

all: $(targs)

