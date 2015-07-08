'''
Unite callable regions provided in bed files. Arrange in bins of roughly
equal size -  a la bcbio - subdivide the whole genome in ~1.5mbp intervals using end points from callable regions.
'''
import sys, os
sys.path.insert(0, '/nethome/asalomatov/projects/ppln')
import logProc

def checkNtvl(ci, ni):
    '''Check is intervals withing the same chromosome are non overlapping
    sorted increasingly by starting coordinate
    '''
#    print 'curr:',  ci
#    print 'next:',  ni
    if not ci:
        return 0
    if ci[0] == ni[0]:
        if int(ci[2]) > int(ni[1]) or int(ci[1]) > int(ni[2]):
            logProc.logProc(outf, outdir, ' ', 'failed', stderr_out=inf+' contains overlapping intervals or not sorted by starting coordinate '+' '.join(ci))
            return 1
    return 0

def accumNtvl(ci, ni, w, fname):
    '''A la bcbio-nextgen genome subdivision logic.
    '''
    if not ci:
        for i in ni: ci.append(i)
        if int(ci[2]) - int(ci[1]) > w:
            with open(fname, 'w') as fout:
                fout.write('\t'.join(ci)+'\n')
            del ci[:]
            return True
        else:
            return False
    else:
        if int(ni[2]) - int(ci[1]) > w or ci[0] != ni[0]:
            with open(fname, 'w') as fout:
                fout.write('\t'.join(ci)+'\n')
            ci[0] = ni[0]
            ci[1] = ni[1]
            ci[2] = ni[2]
            return True
        else:
            ci[2] = ni[2]
            return False
    

inf, outf, wdw, outdir = sys.argv[1:]

try:
    logProc.logProc(outf, outdir, sys.argv[0], 'started')
    curr_ntvl = []
    written = True
    bin_num = 0
    fname = os.path.join(os.path.dirname(outf), str(bin_num)+'__'+os.path.basename(outf))
    with open(inf, 'r') as fin:
        for l in fin:
            ls = l.split()
            if checkNtvl(curr_ntvl, ls): sys.exit(1)
            written = accumNtvl(curr_ntvl, ls, int(wdw), fname)
            if written:
                bin_num += 1
                fname = os.path.join(os.path.dirname(outf), str(bin_num)+'__'+os.path.basename(outf))
    if not written:
        with open(fname, 'w') as fout:
            fout.write('\t'.join(curr_ntvl)+'\n')
    logProc.logProc(outf, outdir, str(bin_num+1)+' intervals created', 'finished')
    sys.exit(0)
except Exception as e:
    logProc.logProc(outf, outdir, ' ', 'failed', stderr_out=e.message)
    raise
