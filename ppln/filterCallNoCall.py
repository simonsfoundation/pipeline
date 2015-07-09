'''

'''
import sys
from sets import Set
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

if len(sys.argv) == 1:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.bed', 'logdir', 'filter1', 'filter2', 'filter3'

N = 4
inf, outf, outdir = sys.argv[1:N]
fltrs = sys.argv[N:]
print fltrs
cmd = ' '
logProc.logProc(outf, outdir, cmd, 'started')

with open(outf, 'w') as fout:
    with open(inf, 'r') as fin:
        for l in fin:
            ls = l.split()
            if ls[3] in fltrs:
                fout.write('\t'.join(ls)+'\n')

logProc.logProc(outf, outdir, cmd, 'finished')
