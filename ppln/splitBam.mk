### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = -rclb
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###

inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
num_bins = $(shell ls $(INDIR)/*__bin__$(FAMCODE)*-mrg.bed | wc -l | xargs seq) 
define binBams

$(info $(1))
$(info $(2))
$(eval bsnm = $(notdir $(1)))
$(info $(bsnm))
$(eval fname = $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-$(2)-bin.bam,$(bsnm)))
$(info $(fname))
$(eval bin_targ = $(addprefix $(OUTDIR)/,$(fname)))
$(eval bin_dep = $(1) $(INDIR)/$(2)__bin__$(FAMCODE)-uni-mrg.bed)
$(info $(bin_targ))
$(info $(bin_dep))
bin_targs += $(bin_targ)

$(bin_targ): $(bin_dep)
	python $(SRCDIR)/splitBam.py $$^ $$@ $(SAMBAMBA) $(LOGDIR)

endef      
#$(WORKDIR)/%-dp-23-$(2)-bin.bam: $(WORKDIR)/%-dp-23.bam $(wildcard $(WORKDIR)/$(2)__bin__*.bed)
#	python $(SRCDIR)/splitBam.py $$^ $$@ $(OUTDIR)

$(foreach bam,$(inBam),$(foreach bin,$(num_bins),$(eval $(call binBams,$(bam),$(bin))))) 

all: $(bin_targs)

