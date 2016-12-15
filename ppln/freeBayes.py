
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
    options = ''' \
    --ploidy 2 \
    --min-repeat-entropy 1'''

    cmd = "%(freebayes)s %(inbams)s -f %(refGenome)s --targets %(inbed)s %(options)s "
    cmd += "| %(vcflibdir)s/vcffilter -f 'QUAL > 5' -F 'QUALlt5' -s | %(vcflibdir)s/vcfallelicprimitives | %(vcflibdir)s/vcfstreamsort | %(bgzip)s -c > %(outfile)s"
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

