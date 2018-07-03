import  os, time, datetime, errno

def makeDir(path):
    try:
        os.mkdir(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def logProc(outputfile, outputdir, cmd, descr, stderr_out=None):
    '''
    Creates an empty file. File name contains time stamp, output file name,
    and status.
    '''
    ts = time.time()
    st = datetime.datetime.fromtimestamp(ts).strftime('%Y%m%d__%H_%M_%S')
    outdir = os.path.join(outputdir, 'logs')
    makeDir(outdir)
    outfn = os.path.basename(outputfile)
    logfn = st + '___' + '_'.join(outfn.split('.')) + '___'+descr
    f = open(os.path.join(outdir, logfn), 'w')
    if stderr_out is None:
 #       if descr == 'started':
        for line in cmd:
            f.write(line)
        f.write('\n')
        f.close()
    else:
        for line in stderr_out:
            f.write(line)
        f.write('\n')
        f.close()


