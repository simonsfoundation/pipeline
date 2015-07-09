import sys, os, time, commands
from sets import Set

maxNjobs, scheduler, outputdir, delay = sys.argv[1:]
maxNjobs = int(maxNjobs)
delay = int(delay)

def FewerThanMaxJobs(max_jobs, sched):
    time.sleep(delay)
    x = 100
    if sched == 'sge':
        x = commands.getoutput('qstat | grep asalomatov | wc -l') 
        print x
    elif sched == 'slurm':
        x = commands.getoutput('squeue | grep asalomat | wc -l') 
        print x
    else:
        print 'Unknown scheduler'
        sys.exit(1)
    x = int(x)
    print max_jobs, ' - max number of jobs'
    print x, ' jobs are running'
    print 'Should I submit another job?',  x < max_jobs 
    return x < max_jobs 

families = Set(['11190', '11193', '11195', '13835', '11198', '11827', '13415', '12296', '11989', '13733', '11055', '11056', '11545', '13409', '11303', '11788', '12373', '12521', '11660', '11388', '11262', '13169', '11707', '11469', '13008', '12933', '13610', '13844', '11184', 'BK397', '11834', '12437', '12703', '13726', '12430', '13926', '11571', '11109', '12532', '13606', '11023', '11375', '12667', '11029', '13158', '12304', '11472', '12300', '11471', '11773', '13494', '11479', '13857', '12381', '12905', '11569', '11205', '12581', '14201', '13914', '13557', '13757', '12015', '12073', '11364', '12011', '12390', '14292', '13314', '12157', '12152', '12153', '11959', '13863', '13678', '11120', '13530', '13533', '13532', '11124', '12641', '11083', '11895', '11218', '13668', '11753', '11518', '13741', '11696', '12249', '11009', '11510', '13335', '11691', '11928', '12378', '11459', '11610', '12674', '11291', '11599', '13031', '11452', '11096', '11948', '11093', '11947', '11942', '12630', '11346', '11229', '13822', '11224', '13207', '12444', '13048', '11506', '11504', '12565', '12036', '11013', '11587', '12237', '12233', '12335', '11629', '11425', '12238', '14020', '12621', '13222', '13517', '13742', '12185', '12130', '11006', '11069', '12106', '12578', '13593', '11141', '12744', 'BK409', '12741', '11064', '11148', 'BK389', '11734', '11863', '12225', '11638', '13116', '12341', '12346', '13447', '13793', '13798', '14011', '12198', '13274', '11526', '13346', '12810', '11523', '13815', '13188', '11480', '11172', '12114', '13890', '12118', '13812', '11246', '12752', '12086', '11872', '12212', '12358', '11722', '13333', '13102', '14006', '11498', '12285', '11043', '12555', '11556', '11491', '12603', '11396', '11414', '11390', '11257', '13701', '13629', '11398', '11964', '11711', '11659', '12161', '11715', '11653', '11843', '11969', '13177'])
print len(families), ' families to process'

completed = Set(['11006', '11009', '11013', '11023', '11055', '11056', '11064', '11069', '11083', '11093', '11096', '11109', '11120', '11124', '11141', '11148', '11184', '11190', '11193', '11198', '11205', '11218', '11224', '11229', '11246', '11262', '11291', '11303', '11346', '11364', '11375', '11388', '11390', '11425', '11459', '11469', '11471', '11472', '11479', '11480', '11491', '11498', '11504', '11510', '11518', '11523', '11526', '11545', '11569', '11587', '11599', '11610', '11629', '11660', '11691', '11696', '11707', '11711', '11753', '11773', '11788', '11827', '11834', '11863', '11895', '11928', '11942', '11947', '11948', '11959', '11989', '12011', '12015', '12036', '12073', '12086', '12106', '12114', '12118', '12130', '12152', '12153', '12157', '12185', '12198', '12212', '12225', '12233', '12237', '12238', '12249', '12285', '12300', '12304', '12335', '12341', '12346', '12373', '12378', '12381', '12390', '12430', '12437', '12444', '12521', '12532', '12565', '12578', '12581', '12603', '12621', '12630', '12641', '12667', '12674', '12703', '12741', '12744', '12810', '12905', '12933', '13008', '13031', '13048', '13102', '13116', '13158', '13169', '13188', '13207', '13222', '13314', '13333', '13335', '13346', '13415', '13447', '13494', '13517', '13530', '13532', '13533', '13557', '13593', '13606', '13610', '13668', '13678', '13733', '13741', '13742', '13757', '13793', '13798', '13812', '13815', '13835', '13844', '13857', '13863', '13890', '13914', '14011', '14020', '14201', '14292', 'BK389', 'BK397'])
print len(completed), ' families completed'

families = families.difference(completed)
print len(families), ' families left to process'

while families:
    print len(families), ' families left to process'
    if FewerThanMaxJobs(maxNjobs, scheduler):
        f = families.pop()
        job_name = 'ssc'+str(f)
        outdir = os.path.join(outputdir, job_name)
        if os.path.isdir(outdir):
            continue
        if scheduler == 'sge':
            print 'submitting another job...'
            cmd = 'qsub -N '+job_name+' ~/projects/ppln/pipe03.sh /mnt/ceph2/asalomatov/SSC_Eichler/data_S3 '+outdir+' '+ str(f)+' WG 0 tmp /nethome/asalomatov/projects/ppln/include_150607.mk 1 ,Reorder,FixGroups,FilterBam,DedupBam,Metrics,IndelRealign,BQRecalibrate,HaplotypeCaller,Freebayes,Platypus,HaplotypeCallerGVCF, 1' 
            print cmd
            print commands.getoutput(cmd)
        elif scheduler == 'slurm':
            print 'submitting another job...'
            cmd = 'sbatch -J '+ job_name + ' -o '+ job_name + '.out ' + ' -e '+ job_name + '.err -N 1 --exclusive -D ' + outputdir + ' ~/projects/ppln/pipe03.sh /mnt/ceph2/asalomatov/SSC_Eichler/data_S3 '+outdir+' '+ str(f)+' WG 0 tmp /nethome/asalomatov/projects/ppln/include_150607_new_cl.mk 1 ,Reorder,FixGroups,FilterBam,DedupBam,Metrics,IndelRealign,BQRecalibrate,HaplotypeCaller,Freebayes,Platypus,HaplotypeCallerGVCF, 1'
            print cmd
            print commands.getoutput(cmd)
        else:
            print 'Unknown scheduler'
            sys.exit(1)
