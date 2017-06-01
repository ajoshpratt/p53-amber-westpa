#!/bin/bash

set -x
umask g+r
cd $WEST_SIM_ROOT || exit 1

rm -f seg_logs/*.log

# Copy up every node's tarball, and put them into one large tarball.
# Afterwards, we'll clean up our presence on the node.
#CURR_ITER_TARBALL=$(printf "%06d" $WEST_CURRENT_ITER).tar
#CURR_ITER_DIR=$(printf "%06d" $WEST_CURRENT_ITER)
#export WEST_JOBID=$PBS_JOBID
#export USER=$PBS_O_LOGNAME
#export TMP=/tmp

#for node in $(scontrol show hostname $SLURM_NODELIST); do
#wait
#for node in $(cat $WEST_SIM_ROOT/PBS_NODELIST.tmp); do
#    (CMD=`ssh $node "tar --append --file=$TMP/$USER/$WEST_JOBID/traj_segs.$node.tar $TMP/$USER/$WEST_JOBID/traj_segs/$CURR_ITER_DIR/*"`
#    echo $CMD
#    rsync -avP $node:$TMP/$USER/$WEST_JOBID/traj_segs.$node.tar $WEST_SIM_ROOT/traj_segs_staging/
#    CMD=`ssh $node "rm -v $TMP/$USER/$WEST_JOBID/traj_segs.$node.tar"`
#    echo $CMD
#    CMD=`ssh $node "rm -v $TMP/$USER/$WEST_JOBID/traj_segs"`
#    echo $CMD
#    CMD=`ssh $node "tar cvf $TMP/$USER/$WEST_JOBID/traj_segs.$node.tar --files-from /dev/null"`
#    echo $CMD
#    LAST_NODE=$node) &
#done

#wait

#cd traj_segs_staging/
#mv traj_segs.$LAST_NODE.tar $CURR_ITER_TARBALL
#for node in $(scontrol show hostname $SLURM_NODELIST); do
#for node in $(cat $WEST_SIM_ROOT/PBS_NODELIST.tmp); do
#    tar --concatenate --file=$CURR_ITER_TARBALL traj_segs.$node.tar
#    rm -vr traj_segs.$node.tar
#done

#tar --append --file=$CURR_ITER_TARBALL $CONFIG/$SYSTEM.prmtop
#tar --append --file=$CURR_ITER_TARBALL $CONFIG/prod.in.annotated
#mv $CURR_ITER_TARBALL $WEST_SIM_ROOT/traj_segs/


cd $WEST_SIM_ROOT || exit 1

rm -f seg_logs/*.log

