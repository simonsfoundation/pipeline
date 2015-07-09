'''
In the input BED file produced by betools genomecoverage filter out all features with coverage below minCvrg
'''
import sys
from sets import Set
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

if len(sys.argv) != 5:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.bed', 'minCvrg', 'logdir'


inf, outf, min_cvrg, outdir = sys.argv[1:]
min_cvrg = int(min_cvrg)
cmd = ' '
logProc.logProc(outf, outdir, cmd, 'started')

with open(outf, 'w') as fout:
    with open(inf, 'r') as fin:
        for l in fin:
            ls = l.split()
            if int(ls[3]) >= min_cvrg:
                fout.write('\t'.join(ls)+'\n')

logProc.logProc(outf, outdir, cmd, 'finished')
