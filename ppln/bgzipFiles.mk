### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
include /nethome/asalomatov/projects/ppln/include.mk
### may override on cl
FAMCODE = 1
SUFFIX = .vcf
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFiles = $(wildcard $(INDIR)/$(FAMCODE)*$(SUFFIX))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX),%$(SUFFIX).gz,$(notdir $(inFiles))))
$(info $(o0))

all: $(o0)

$(OUTDIR)/%$(SUFFIX).gz: $(INDIR)/%$(SUFFIX)
	mkdir -p $(LOGDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	bgzip -f $<
	$(TABIX) -p vcf $@
