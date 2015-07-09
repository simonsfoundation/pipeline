'''
from '1  0   100' to  '1:0-100' to use with platypus 
'''
import sys
from sets import Set
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

if len(sys.argv) != 4:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.list', 'logdir'


inf, outf, outdir = sys.argv[1:]
cmd = ' '
logProc.logProc(outf, outdir, cmd, 'started')

with open(outf, 'w') as fout:
    with open(inf, 'r') as fin:
        for l in fin:
            ls = l.split()
            fout.write(ls[0]+':'+ls[1]+'-'+ls[2]+'\n')

logProc.logProc(outf, outdir, cmd, 'finished')
