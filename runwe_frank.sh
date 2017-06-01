#!/bin/bash
#PBS -N P53
#PBS -S /bin/bash
#PBS -j oe
#PBS -l walltime=24:00:00
#PBS -l nodes=n384+n383:ppn=1:gpus=4,feature=titan
#PBS -q gpu
#PBS -m ae
#PBS -A lchong

# -l advres=n381_badgpu.22658
# -l nodes=n381:ppn=1:gpus=3,feature=titan

set -x
umask g+r
cd $PBS_O_WORKDIR
source env.sh || exit 1
# -l advres=n381_badgpu.22658

cd $WEST_SIM_ROOT

export USER=$LOGNAME

# Copy over everything to each individual node that is needed...
# ... and it's really best to do this BEFORE we start the server; otherwise, if this step takes a while, we run the risk of
# having the master server die due to 'no clients' before they've even started.
rm PBS_NODELIST.tmp
awk 'NR == 1 || NR % 1 == 0' $PBS_NODEFILE > PBS_NODELIST.tmp
for node in $(cat $WEST_SIM_ROOT/PBS_NODELIST.tmp); do
    CMD=`ssh $node "rm -vr $TMP/$USER"`
    echo $CMD
    CMD=`ssh $node "mkdir -p $TMP/$USER/$PBS_JOBID && tar cvf $TMP/$USER/$PBS_JOBID/traj_segs.$node.tar --files-from /dev/null"`
    echo $CMD
done

SERVER_INFO=$WEST_SIM_ROOT/west_zmq_info-$PBS_JOBID.json
# start server
$WEST_ROOT/bin/w_run --work-manager=zmq --n-workers=0 --zmq-mode=master --zmq-write-host-info=$SERVER_INFO --zmq-comm-mode=tcp &> west-$PBS_JOBID.log &

# wait on host info file up to one minute
for ((n=0; n<60; n++)); do
    if [ -e $SERVER_INFO ] ; then
        echo "== server info file $SERVER_INFO =="
        cat $SERVER_INFO
        break
    fi
    sleep 1
done

# exit if host info file doesn't appear in one minute
if ! [ -e $SERVER_INFO ] ; then
    echo 'server failed to start'
    exit 1
fi

export WEST_JOBID=$PBS_JOBID

# start clients, with the proper number of cores on each
pbsdsh -v -u $WEST_SIM_ROOT/node.sh --work-manager=zmq --zmq-mode=client --n-workers=4 --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &

wait
