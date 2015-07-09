'''
In the input BED file replace Chr1 with 1, Chr2 with 2...,
ChrM with MT, ChrX with X, ChrY with Y, remove all other lines,
write results to output file
'''
import sys
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

if len(sys.argv) != 4:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.bed', 'logdir'

inf, outf, outdir = sys.argv[1:]
cmd = ' '
logProc.logProc(outf, outdir, cmd, 'started')

with open(sys.argv[2], 'w') as fout:
    with open(sys.argv[1], 'r') as fin:
        for l in fin:
            ls = l.split()
            if len(ls[0]) <= 5 and ls[0][:3].lower() == 'chr':
                ls[0] = ls[0][3:]
                if ls[0] == 'M': ls[0] = 'MT'
                fout.write('\t'.join(ls)+'\n')

logProc.logProc(outf, outdir, cmd, 'finished')

