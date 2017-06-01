#!/bin/bash -l

set -x
umask g+r 
cd $WEST_SIM_ROOT || exit 1

# Stage in the tarball to every node.

PREV_ITER=(`expr $WEST_CURRENT_ITER - 1`)
PREV_ITER_TARBALL=$(printf "%06d" $PREV_ITER).tar
CURR_ITER_TARBALL=$(printf "%06d" $WEST_CURRENT_ITER).tar
export WEST_JOBID=$PBS_JOBID
export USER=$PBS_O_LOGNAME
export TMP=/tmp
#for node in $(scontrol show hostname $SLURM_NODELIST); do
for node in $(cat $WEST_SIM_ROOT/PBS_NODELIST.tmp); do
    (CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && rsync -avP $WEST_SIM_ROOT/traj_segs/$PREV_ITER_TARBALL ."`
    echo $CMD
    CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && rsync -avP $WEST_SIM_ROOT/traj_segs/$CURR_ITER_TARBALL ."`
    echo $CMD
    CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && tar xvf $PREV_ITER_TARBALL"`
    echo $CMD
    CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && tar xvf $CURR_ITER_TARBALL"`
    echo $CMD
    CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && rm -vr traj_segs"`
    echo $CMD
    CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && mkdir traj_segs"`
    echo $CMD
    CMD=`ssh $node "cd $TMP/$USER/$WEST_JOBID && cp -avP $WEST_SIM_ROOT/CONFIG/PM.prmtop ."`
    echo $CMD
    CMD=`ssh $node "mv $TMP/$USER/$WEST_JOBID/$TMP/$USER/*/traj_segs/* $TMP/$USER/$WEST_JOBID/traj_segs/"`
    echo $CMD
    CMD=`ssh $node "mv $TMP/$USER/$WEST_JOBID/$WEST_SIM_ROOT/CONFIG/* $TMP/$USER/$WEST_JOBID/"`
    echo $CMD
    CMD=`ssh $node "rm -vr $TMP/$USER/$WEST_JOBID/$TMP/"`
    echo $CMD
    CMD=`ssh $node "ls $TMP/$USER/$WEST_JOBID/traj_segs/"`
    echo $CMD) &
done

wait
