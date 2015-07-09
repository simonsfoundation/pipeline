import sys, os, time, commands
from sets import Set

scheduler, outputdir, inputdir = sys.argv[1:]

def JobIsRunning(sched, jobname):
    if sched == 'sge':
        x = commands.getoutput('qstat | grep '+jobname+' | wc -l') 
        print x
    elif sched == 'slurm':
        x = commands.getoutput('squeue | grep '+jobname+' | wc -l') 
        print x
    else:
        print 'Unknown scheduler'
        sys.exit(1)
    return int(x) > 0

families = ['11190', '11193', '11195', '13835', '11198', '11827', '13415', '12296', '11989', '13733', '11055', '11056', '11545', '13409', '11303', '11788', '12373', '12521', '11660', '11388', '11262', '13169', '11707', '11469', '13008', '12933', '13610', '13844', '11184', 'BK397', '11834', '12437', '12703', '13726', '12430', '13926', '11571', '11109', '12532', '13606', '11023', '11375', '12667', '11029', '13158', '12304', '11472', '12300', '11471', '11773', '13494', '11479', '13857', '12381', '12905', '11569', '11205', '12581', '14201', '13914', '13557', '13757', '12015', '12073', '11364', '12011', '12390', '14292', '13314', '12157', '12152', '12153', '11959', '13863', '13678', '11120', '13530', '13533', '13532', '11124', '12641', '11083', '11895', '11218', '13668', '11753', '11518', '13741', '11696', '12249', '11009', '11510', '13335', '11691', '11928', '12378', '11459', '11610', '12674', '11291', '11599', '13031', '11452', '11096', '11948', '11093', '11947', '11942', '12630', '11346', '11229', '13822', '11224', '13207', '12444', '13048', '11506', '11504', '12565', '12036', '11013', '11587', '12237', '12233', '12335', '11629', '11425', '12238', '14020', '12621', '13222', '13517', '13742', '12185', '12130', '11006', '11069', '12106', '12578', '13593', '11141', '12744', 'BK409', '12741', '11064', '11148', 'BK389', '11734', '11863', '12225', '11638', '13116', '12341', '12346', '13447', '13793', '13798', '14011', '12198', '13274', '11526', '13346', '12810', '11523', '13815', '13188', '11480', '11172', '12114', '13890', '12118', '13812', '11246', '12752', '12086', '11872', '12212', '12358', '11722', '13333', '13102', '14006', '11498', '12285', '11043', '12555', '11556', '11491', '12603', '11396', '11414', '11390', '11257', '13701', '13629', '11398', '11964', '11711', '11659', '12161', '11715', '11653', '11843', '11969', '13177']

sts = ''
read_from = ''
for f in families:
    job_name = 'ssc'+str(f)
    print job_name
    if JobIsRunning(scheduler, job_name):
        continue
    outdir = os.path.join(outputdir, job_name)
    print outdir
    if os.path.isdir(outdir):
        cmd = 'ls -l '+inputdir+'/'+f+'*.bam | wc -l'
        fam_size = int(commands.getstatusoutput(cmd)[1])
        print fam_size
        cmd1 = 'ls -l '+outdir+'/*.vcf.gz | wc -l'
        N_vcfs = commands.getstatusoutput(cmd1)
        cmd2 = 'grep ceph2 '+outdir+'/logs/runInfo.txt | wc -l'
        launch_from = commands.getstatusoutput(cmd2)
        if launch_from[1] == '1':
            read_from = 'ceph2'
        else:
            read_from = 'ceph'
        if N_vcfs[0] == 0:
            if N_vcfs[1] == '4':
                sts = 'completed'
            else:
                sts = 'failed'
        else:
            sts = 'failed'
        print job_name, fam_size, sts, read_from


# below is for date manipulation in python
'''
x = !ls -rtl --time-style=long-iso ssc11006/logs/
st=x[1]
nd=x[-1
        ]
st
nd
import datetime
import datetime as dt
dt.datetime(st[5:7])
dt.datetime.strptime(st[5:7])
dt.datetime.strptime(st[5:7], "%Y-%m-%d %H:%M")
st
st[5:7]
st.split()[5:7]
' '.join(st.split()[5:7])
st =' '.join(st.split()[5:7])
st
nd =' '.join(nd.split()[5:7])
nd
dt.datetime.strptime(st, "%Y-%m-%d %H:%M")
dt.datetime.strptime(nd, "%Y-%m-%d %H:%M") - dt.datetime.strptime(st, "%Y-%m-%d
        %H:%M")
st
nd
'''
