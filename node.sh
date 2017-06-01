#!/bin/bash -l

set -x
umask g+r
cd $PBS_O_WORKDIR
#source env.sh
#cd $WEST_SIM_ROOT
export WEST_ROOT=/ihome/lchong/ajp105/apps/westpa/westpa-wexplore/
export WEST_PYTHON=/ihome/lchong/ajp105/apps/anaconda/bin/python2.7
export CONFIG=$PBS_O_WORKDIR/CONFIG
#IFS=', ' read -r -a CUDANODES <<< "$CUDA_VISIBLE_DEVICES"
export WM_ZMQ_MASTER_HEARTBEAT=100
export WM_ZMQ_WORKER_HEARTBEAT=100
export WM_ZMQ_TIMEOUT_FACTOR=100

#for GPU in ${CUDANODES[@]}; do 
#    export CUDA_VISIBLE_DEVICES=$GPU
    $WEST_ROOT/bin/w_run "$@" &> west-$PBS_NODENUM-node.log
#done
