#! /bin/bash -l

#PBS -N K.CR.05.01
#PBS -S /bin/bash
#PBS -j oe
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=32
#PBS -q dist_amd
#PBS -m ae
#PBS -M ajp105@pitt.edu
#PBS -A lchong

# Script name: run2.sh
# Script created by: ajp105
# Date: Sat Oct 25 12:39:56 EDT 2014
# System: Linux ltc1.chem.pitt.edu 2.6.18-164.6.1.el5 #1 SMP Tue Nov 3 16:12:36 EST 2009 x86_64 x86_64 x86_64 GNU/Linux
#
# environment.sh provides the following variables:
# BASEDIR, APPSDIR, BUILDDIR, SRCDIR, LOGDIR, MODULESDIR, WORKDIR
# SRCDIR and LOGDIR refer to locations where src code is downloaded and where build scripts are logged.  These are purposefully kept seperate from the
# general downloads and logging directories.

#################################################################### DESCRIPTION ####################################################################
# AN EXAMPLE OF SOME AMBER STUFF AWWW YEAH
##################################################################### VARIABLES #####################################################################
source env.sh
module load anaconda
module load scripts/westpa
module load westpa/current
BASEDIR=$PBS_O_WORKDIR/$1
WEST=$BASEDIR/west_subsampl.h5

WESTBIN=$(which west)
JOSHTOOLS=/home/lchong/ajp105/apps/postanalysis_reweighting_tool/analysis_tools

# Not my function; taken from http://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
# Modified somewhat for my purposes, here, however.
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|g" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|g" \
        -e "s|\[|\(|g" \
        -e "s|,|\ |g" \
        -e "s|\]|\)|gp" $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn="export "; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\%s\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
set -x
##################################################################### BEGINNING #####################################################################
cd $BASEDIR
if [ -f parameters.yaml ]; then
    parse_yaml parameters.yaml > parameters
    source parameters
else
    ln -sv ../parameters.yaml
    parse_yaml parameters.yaml > parameters
    source parameters
fi
ln -sv ../BINS* .
ln -sv ../STATES* .

#AVERAGE=('cumulative' 'blocked')
#STEPITER=(1 10 50)

# Standard analysis (direct trace)

#REDOANALYSIS=1
#START_ITER=(125)
rm west_subsampl.h5
if [ -f west_subsampl.h5 ]; then
    WESTITER=(`h5ls west.h5 | grep summary`)
    WESTSUBITER=(`h5ls west_subsampl.h5 | grep summary`)
    echo $WESTITER
    echo $WESTSUBITER
    if [ ${WESTITER[2]} != ${WESTSUBITER[2]} ] || [ $REDOANALYSIS = 1 ]; then
        REDOANALYSIS=1
        python $JOSHTOOLS/subsample_h5file.py -f west.h5 -o west_subsampl.h5 -s ${STRIDE[0]}
        #ln -sv west.h5 west_subsampl.h5
            w_assign --states-from-file STATES.INTERMEDIATE --bins-from-file BINS.MIN -W west_subsampl.h5
            w_kinetics trace
            for ITER in ${START_ITER[@]}; do
                for METHOD in ${AVERAGE[@]}; do
                    for BLOCKSIZE in ${STEPITER[@]}; do
                        w_kinavg trace -e $METHOD --step-iter $BLOCKSIZE  -a assign.h5 -W west_subsampl.h5 -k kintrace.h5 --first-iter $ITER -o kinavg.$ITER.$METHOD.BLOCK.$BLOCKSIZE.h5
                        w_stateprobs -e $METHOD --step-iter $BLOCKSIZE  -a assign.h5 -W west_subsampl.h5 --first-iter $ITER -o stateprobs.$ITER.$METHOD.BLOCK.$BLOCKSIZE.h5
                    done
                done
            done
    fi
else
    REDOANALYSIS=1
        python $JOSHTOOLS/subsample_h5file.py -f west.h5 -o west_subsampl.h5 -s ${STRIDE[0]}
        #ln -sv west.h5 west_subsampl.h5
        w_assign --states-from-file STATES.INTERMEDIATE --bins-from-file BINS.MIN -W west_subsampl.h5
        w_kinetics trace
        for ITER in ${START_ITER[@]}; do
            for METHOD in ${AVERAGE[@]}; do
                for BLOCKSIZE in ${STEPITER[@]}; do
                    w_kinavg trace -e $METHOD --step-iter $BLOCKSIZE  -a assign.h5 -W west_subsampl.h5 -k kintrace.h5 --first-iter $ITER -o kinavg.$ITER.$METHOD.BLOCK.$BLOCKSIZE.h5
                    w_stateprobs -e $METHOD --step-iter $BLOCKSIZE  -a assign.h5 -W west_subsampl.h5 --first-iter $ITER -o stateprobs.$ITER.$METHOD.BLOCK.$BLOCKSIZE.h5
                done
            done
        done
fi

#if [ $REDOANALYSIS = 0 ]; then
#    exit 0
#    tmux kill-window
#fi

#REDOANALYSIS=0

# Sets up multiple runs for the non Markovian analysis procedure.
if [ $REDOANALYSIS = 1 ]; then
    mv     PRODUCTION PRODUCTION.OLD
    mkdir  PRODUCTION
    cd     PRODUCTION
        for BIN in ${BINS[@]}; do
            for ITER in ${START_ITER[@]}; do
                for METHOD in ${AVERAGE[@]}; do
                    for BLOCKSIZE in ${STEPITER[@]}; do
                    mkdir $BIN.$ITER.$METHOD.BLOCK.$BLOCKSIZE
                    cd    $BIN.$ITER.$METHOD.BLOCK.$BLOCKSIZE
                        cp $BASEDIR/STATES.$BIN STATES
                        cp $BASEDIR/BINS.$BIN BINS
                            if [ $ITER = ${START_ITER[0]} ]; then
                                w_assign -W $WEST \
                                    -o assign.h5 --states-from-file STATES --bins-from-file BINS

                                $WESTBIN $JOSHTOOLS/w_postanalysis_matrix.py \
                                    -a assign.h5 --colors-from-macrostates \
                                    -o flux_matrices.h5 -W $WEST
                            else
                                ln -sv ../$BIN.${START_ITER[0]}.$METHOD.BLOCK.$BLOCKSIZE/assign.h5 .
                                ln -sv ../$BIN.${START_ITER[0]}.$METHOD.BLOCK.$BLOCKSIZE/flux_matrices.h5 .
                            fi

                            $WESTBIN $JOSHTOOLS/w_postanalysis_reweight.py \
                                -a assign.h5 -k flux_matrices.h5 \
                                -o kinrw.h5 -e $METHOD --step-iter $BLOCKSIZE --obs-threshold 1 -W $WEST --first-iter $ITER
                        cd ..
                    done
                done
            done
        done
    cd ..
#read -p "Press any key to close pane."
fi
######################################################################## END ########################################################################
