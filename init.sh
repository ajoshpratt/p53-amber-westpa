#!/bin/bash -l
source env.sh

SFX=.d$$
mv traj_segs{,$SFX}
mv seg_logs{,$SFX}
mv istates{,$SFX}
rm -Rf traj_segs$SFX seg_logs$SFX istates$SFX & disown %1
rm -f system.h5 west.h5 seg_logs.tar
mkdir seg_logs traj_segs istates

BSTATE_ARGS="--bstates-from BASIS_STATES"

$WEST_ROOT/bin/w_init $BSTATE_ARGS --segs-per-state 1 --serial
