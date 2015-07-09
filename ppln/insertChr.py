'''
In the input BED file replace 1 with Chr1, 2 with Chr2...,
MT with ChrM, X with ChrX, Y with ChrY, remove all other lines,
write results to output file
'''
import sys
from sets import Set
if len(sys.argv) != 3:
    print 'Usage:'
    print sys.argv[0], 'input.bed', 'output.bed'

chrset = Set([str(x) for x in range(1, 23)])
chrset.add('Y')
chrset.add('X')
chrset.add('MT')
with open(sys.argv[2], 'w') as fout:
    with open(sys.argv[1], 'r') as fin:
        for l in fin:
            ls = l.split()
            if ls[0] in chrset:
                if ls[0] == 'MT': 
                    ls[0] = 'Chr'+ls[0][0]
                else:
                    ls[0] = 'Chr'+ls[0]
                fout.write('\t'.join(ls)+'\n')
