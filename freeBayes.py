'''

'''
import sys, subprocess
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc


try:
    print '\nsys.args   :', sys.argv[1:]
    N = 8
    refGenome, freebayes, vcflibdir, bgzip, outdir, outfile, inbed = sys.argv[1:N]
    fl = ' -b '
    inbams = ''
    for f in sys.argv[N:]:
        inbams += fl + f
    if 'v0.9.21-7' in subprocess.Popen([freebayes], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0]:
        options = ''' \
        --ploidy 2 \
        --min-repeat-entropy 1'''
    else:
        options = ''' \
        --ploidy 2 \
        --min-repeat-entropy 1 \
        --experimental-gls '''

    cmd = "%(freebayes)s %(inbams)s -f %(refGenome)s --targets %(inbed)s %(options)s "
    cmd += "| %(vcflibdir)s/vcffilter -f 'QUAL > 6' -s | %(vcflibdir)s/vcfallelicprimitives | %(vcflibdir)s/vcfstreamsort | %(bgzip)s -c > %(outfile)s"
    cmd = cmd % locals()
    print cmd
    logProc.logProc(outfile, outdir, cmd, 'started')
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if p.returncode == 0:
        logProc.logProc(outfile, outdir, cmd, 'finished')
    else:
        logProc.logProc(outfile, outdir, cmd, 'failed', stderr)
except Exception as e:
    logProc.logProc(outfile, outdir, ' ', 'failed', stderr_out=e.message)
    raise

'''
[2015-03-03 07:11] /bioinfo/software/installs/bcbio/bin/freebayes
-f /bioinfo/data/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa
-b /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_fa/1/11480.fa_SSCtest-reorder-fixrgs-gatkfilter-dedup-1_0_1551236-prep.bam
-b /tmp/ asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_mo/1/11480.mo_SSCtest-reorder-fixrgs-gatkfilter-dedup-1_0_1551236-prep.bam
-b /tmp/asalomatov_bcbng_working_7mwA1RJkiA/bamprep/11480_p1/1/11480.p1_SSCtest- reorder-fixrgs-gatkfilter-dedup-1_0_1551236-prep.bam
--ploidy 2
--targets /tmp/asalomatov_bcbng_working_7mwA1RJkiA/freebayes/1/11480- 1_0_1551236-raw-regions.bed
--min-repeat-entropy 1 --experimental-gls

| /bioinfo/software/installs/bcbio/bin/vcffilter -f 'QUAL > 5' -s | /bioinfo/software/installs/bcbio/bin/vcfallelicprimitives | /bioinfo/software/installs/bcbio/bin/vcfstreamsort
| bgzip -c > /tmp/asalomatov_bcbng_working_7mwA1RJkiA/freebayes/1/tx/tmp98nePZ/11480-1_0_1551236-raw.vcf.gz
'''
