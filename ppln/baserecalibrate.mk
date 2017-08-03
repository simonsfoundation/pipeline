### 
#default: all
SHELL = /bin/bash
ifdef SLURMMASTER
	SHELL=srun
	.SHELLFLAGS= -N1 --cpus-per-task=1 bash -c 
endif
$(info $(SHELL))
USR = $(shell whoami)
INCLMK = 
include $(INCLMK)
### may override on cl
PREFIX = 
SUFFIX = 
INDIR = .
OUTDIR = .
NCORES = 4
LOGDIR = $(OUTDIR)
TMPDIR = /tmp/$(USR)
###
infiles = $(wildcard $(INDIR)/$(PREFIX)*$(SUFFIX).bam)
$(info $(infiles))
o0 = $(addprefix $(OUTDIR)/, $(patsubst %.bam,%.rclb.bam,$(notdir $(infiles))))
$(info $(o0))
.DELETE_ON_ERROR:

all: $(o0)

$(OUTDIR)/%$(SUFFIX).rclb.bam: $(INDIR)/%$(SUFFIX).bam $(INDIR)/%$(SUFFIX).bam.table 
	java -Xms750m -Xmx2500m -XX:+UseSerialGC  -jar $(GATK) --read_filter BadCigar --read_filter NotPrimaryAlignment -T PrintReads -I $(word 1,$^) -o $@ -R $(GENOMEREF) -BQSR $(word 2,$^) -nct $(NCORES) -compress 5 --disable_bam_indexing

$(OUTDIR)/%$(SUFFIX).bam.table: $(INDIR)/%$(SUFFIX).bam
	mkdir -p $(OUTDIR)
	java -Xms750m -Xmx10g -XX:+UseSerialGC -jar $(GATK) -T BaseRecalibrator -I $< -knownSites $(DBSNP) -knownSites $(MILLSINDEL) -knownSites $(INDEL1000G) -o $@ -R $(GENOMEREF) --downsample_to_fraction 0.1 --read_filter BadCigar --interval_padding 200  -nct $(NCORES)
