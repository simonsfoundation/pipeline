### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = -fxgr
PROJ = mktest
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX).bam.bai,$(notdir $(inBam))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX).bam.bai: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(SAMBAMBA) index -t 4 $<
#	python $(SRCDIR)/indexBam.py $< $@ $(SAMBAMBA) $(LOGDIR)
