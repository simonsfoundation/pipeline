'''
In the input BED file filter out all but chr 1 - 22, X, Y, MT.
'''
import sys
from sets import Set
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

if len(sys.argv) != 4:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.bed', 'logdir'


chrset = Set([str(x) for x in range(1, 23)])
chrset.add('Y')
chrset.add('X')
chrset.add('MT')

inf, outf, outdir = sys.argv[1:]
cmd = ' '
logProc.logProc(outf, outdir, cmd, 'started')

with open(outf, 'w') as fout:
    with open(inf, 'r') as fin:
        for l in fin:
            ls = l.split()
            if ls[0] in chrset:
                fout.write('\t'.join(ls)+'\n')

logProc.logProc(outf, outdir, cmd, 'finished')
