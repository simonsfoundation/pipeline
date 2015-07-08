### 
default: all
SHELL = /bin/bash
USR = $(shell whoami)
INCLMK = /nethome/asalomatov/projects/ppln/include.mk
include $(INCLMK)
### may override on cl
PREFIX = 1
SUFFIX = -cloc
FILTER1 = CALLABLE
FILTER2 = LOW_COVERAGE
FILTER3 =
PROJ = mktest
INDIR = .
OUTDIR = .
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)/$(PROJ)
###
inFile = $(wildcard $(INDIR)/*$(SUFFIX).bed)
callBed = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%-call.bed,$(notdir $(inFile))))
#nocallBed = $(addprefix $(OUTDIR)/, $(patsubst %$(SUFFIX).bed,%-nocall.bed,$(notdir $(inFile))))

all: $(callBed)

$(OUTDIR)/%-call.bed: $(INDIR)/%$(SUFFIX).bed
	mkdir -p $(OUTDIR)
	mkdir -p $(TMPDIR)
	mkdir -p $(OUTDIR)
	python $(SRCDIR)/filterCallNoCall.py $< $@ $(LOGDIR) $(FILTER1) $(FILTER2) $(FILTER3)
