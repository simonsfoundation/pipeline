### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 2
SUFFIX = -rclb
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
num_bins = $(shell ls $(INDIR)/*__bin__$(FAMCODE)-uni-mrg.bed | wc -l | xargs seq) 
$(info $(num_bins))
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))

define runCaller

$(eval bsnm = $(notdir $(2)))
$(eval fname = $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-$(1)-bin.g.vcf,$(bsnm)))
$(info $(fname))
$(eval JHC_targ = $(addprefix $(OUTDIR)/,$(fname)))
JHC_targs += $(JHC_targ)
$(eval JHC_dep1 = $(INDIR)/$(1)__bin__$(FAMCODE)-uni-mrg.bed)
$(eval JHC_dep2 = $(2))

$(JHC_targ): $(JHC_dep1) $(JHC_dep2)
	python $(SRCDIR)/gatkHaplotypeCallerJoint.py $(GENOMEREF) $(TMPDIR) $(GATK) $(DBSNP) $(GAPS) $(LOGDIR) $(DJAVA_LIB) $$@ $$^

endef      
#$(info $(JHC_targ))

#$(foreach bin,$(num_bins),$(eval $(call runCaller,$(bin)))) 
$(foreach bin,$(num_bins),$(foreach bam,$(inBam),$(eval $(call runCaller,$(bin),$(bam))))) 

all: $(JHC_targs)

