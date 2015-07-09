### 
#default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX = 1
SUFFIX = -dp
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###

inBam = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bam)
$(info $(inBam))
inBed = $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bed,$(inBam))
outBed = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%$(SUFFIX)-cloc.bed,$(notdir $(inBed))))

all: $(outBed)

$(OUTDIR)/%$(SUFFIX)-cloc.bed: $(OUTDIR)/%$(SUFFIX).bam $(OUTDIR)/%$(SUFFIX).bed
	python $(SRCDIR)/gatkCallableLoci.py $^ $@ $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR)

#num_bins = $(shell ls $(INDIR)/*__bin__$(PREFIX)-uni-mrg.bed | wc -l | xargs seq) 
#$(info $(num_bins))

#define callLoci
#$(info $(1))
#$(info $(2))
#$(eval bin_dep_bed = $(wildcard $(INDIR)/$(2)__bin__$(PREFIX)-uni-mrg.bed))
#$(eval bsnm = $(notdir $(1)))
#$(eval fname = $(patsubst %.bam,%-cloc.bed,$(bsnm)))
#$(eval bin_targ = $(addprefix $(OUTDIR)/$(2)__bin__,$(fname)))
#$(eval bin_dep = $(1) $(bin_dep_bed))
#$(info $(bin_targ))
#$(info $(bin_dep))
#bin_targs += $(bin_targ)
#
#$(bin_targ): $(bin_dep)
#	python $(SRCDIR)/gatkCallableLoci.py $$^ $$@ $(GENOMEREF) $(TMPDIR) $(GATK) $(LOGDIR)
#endef      
#
#$(foreach bam,$(inBam),$(foreach bin,$(num_bins),$(eval $(call callLoci,$(bam),$(bin))))) 
#
#all: $(bin_targs)
#
