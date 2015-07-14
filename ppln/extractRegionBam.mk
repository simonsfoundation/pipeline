### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = ~/projects/pipeline/ppln/include.mk
include $(INCLMK)
### may override on cl
FAMCODE = 1
SUFFIX = 
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)
T = 4
BIN =
###
inBam = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX).bam)
$(info $(inBam))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bam,%$(SUFFIX)-$(BIN).bam,$(notdir $(inBam))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX)-$(BIN).bam: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	$(SAMBAMBA) view -t $(T) -f bam -h -L $(SRCDIR)/data/$(BIN)__bin-WG.bed -o $@ $<
#%(sambamba)s view -f bam -h -L %(inbed)s -o %(outf)s %(inbam)s
