### 
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
INDIR = /mnt/scratch/$(USR)/bioppln/inputs
OUTDIR = /mnt/scratch/$(USR)/bioppln/$(PROJ)/outputs
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)
PAD = 0
###

all: $(OUTDIR)/$(FAMCODE)-uni-mrg.bed

$(OUTDIR)/$(FAMCODE)-uni-mrg.bed: $(INDIR)/$(FAMCODE)-uni.bed
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python ${SRCDIR}/bedPad.py $< $@ $(BEDOPSDIR) $(PAD) $(LOGDIR)
	rm $<
