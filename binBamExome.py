'''
Unite callable regions provided in bed files. Arrange in bins of roughly
equal size
'''
import sys, os
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

class Bed:
    '''bed file'''
    def __init__(self, maxl, fname, split_chr):
        self.bed = []
        self.bin_num = 0
        self.length = 0
        self.max_length = maxl
        self.fname = fname
        self.split_chr = split_chr
        self.chrom = ''
    def clear(self):
        self.bed = []
        self.length = 0
        self.chrom = ''
    def addInterval(self, x):
        '''x is a list of 3 elements
        '''
        if (not type(x) is list) or len(x) != 3:
            sys.exit('Bed: must be a list of 3 elements')
        if self.bed and self.chrom != x[0] and not self.split_chr:
            self.printToFile()
        else:
            self.bed.append('\t'.join(x))
            self.length += int(x[2]) - int(x[1])
            self.chrom = x[0]
            if self.length > self.max_length:
                self.printToFile()
    def printToFile(self):
        self.bin_num += 1
        fout_name = os.path.join(os.path.dirname(self.fname),
                str(self.bin_num)+'__'+os.path.basename(self.fname))
        with open(fout_name, 'w') as fout:
            fout.write('\n'.join(self.bed))
            self.clear()

if __name__ == '__main__':
    if len(sys.argv) != 6:
        print 'Five arguments expected: '
        print sys.argv[0], 'inputbed outputbed Nfiles  split_chr logdir'
        sys.exit(1)
    inf, outf, Nfiles, split_chr, outdir = sys.argv[1:]
    Nfiles = int(Nfiles)
    split_chr = split_chr.lower() in ['true', 't', 'yes']

    try:
        logProc.logProc(outf, outdir, sys.argv[0], 'started')
        bp_covered = 0.0
        with open(inf, 'r') as fin:
            for l in fin:
                ls = l.split()
                bp_covered += float(ls[2]) - float(ls[1])
        wdw = int(bp_covered/Nfiles)
        mybed = Bed(wdw, outf, split_chr)
        with open(inf, 'r') as fin:
            for l in fin:
                ls = l.split()
                mybed.addInterval(ls)
            if mybed.bed:
                mybed.printToFile()
        logProc.logProc(outf, outdir, str(mybed.bin_num)+' intervals created', 'finished')
        sys.exit(0)
    except Exception as e:
        logProc.logProc(outf, outdir, ' ', 'failed', stderr_out=e.message)
        raise
