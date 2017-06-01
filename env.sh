# This file defines where WEST and GROMACS can be found
# Modify to taste
case $HOSTNAME in
    login[0][a,b].frank.sam.pitt.edu | n*)
        # Frank.  I suspect

        # Load the modules!
        echo "Running on FRANK"

        source /etc/profile.d/sam-modules.sh
        module purge
        # Use Adam's westpa
        module use /ihome/lchong/ajp105/modules
        module load westpa/split-merge
        module load anaconda

        SCRATCH=/scratch
        export USE_LOCAL_SCRATCH=1
        export SCRATCHROOT=$SCRATCH
        export TMP=/tmp
        export PATH=$(echo $PATH | sed -e 's|//ihome/lchong/$USER:||g')
        # Inform WEST where to find Python and our other scripts where to find WEST
        export WEST_PYTHON=$(which python2.7)

        # Explicitly name our simulation root directory
        if [[ -z "$WEST_SIM_ROOT" ]]; then
            export WEST_SIM_ROOT="$PWD"
        fi
        export SIM_NAME=$(basename $WEST_SIM_ROOT)
        export WEST_ROOT=$WEST_ROOT
        echo "simulation $SIM_NAME root is $WEST_SIM_ROOT"

        export WM_ZMQ_MASTER_HEARTBEAT=100
        export WM_ZMQ_WORKER_HEARTBEAT=100
        export WM_ZMQ_TIMEOUT_FACTOR=100
    ;;
    *)
        # Where are you running this?
        echo "Not sure where we're running this.  Set up AMBER and WESTPA."

esac


# General stuff now

export WEST_ZMQ_DIRECTORY=server_files
export WEST_LOG_DIRECTORY=job_logs
export PMEMD="$(which pmemd.cuda) -O"
export CPPTRAJ=$(which cpptraj)
export CONFIG=$WEST_SIM_ROOT/CONFIG
export SYSTEM=P53
export REF=$WEST_SIM_ROOT/bstates/0/P53.MDM2
umask g+r 
