#!/bin/bash

if [ -n "$SEG_DEBUG" ] ; then
    set -x
    env | sort
fi

cd $WEST_SIM_ROOT
module() { eval `/opt/sam/Modules/3.2.6/bin/modulecmd bash $*`; }
export USE_LOCAL_SCRATCH=1
export SCRATCHROOT=$SCRATCH
export SWROOT=""
export TMP=/tmp
export PATH=$(echo $PATH | sed -e 's|//ihome/lchong/ajp105:||g')
export SIM_NAME=$(basename $WEST_SIM_ROOT)
export WEST_ROOT=$WEST_ROOT
module unload anaconda
module purge
module load amber/14-intel-2013-cuda-7.0
export WEST_PYTHON=$(which python2.7)
export PMEMD="$(which pmemd.cuda) -O"
export CPPTRAJ=$(which cpptraj)
#export CUDA_VISIBLE_DEVICES=0
env | sort

function cleanup() {
    rm -f min-dist.$$.dat
    rm -f trp-min-dist.$$.dat
    rm -f ar-rmsd.$$.dat
    rm -f poar-rmsd.$$.dat
    rm -f ca-rmsd.$$.dat
}

trap cleanup EXIT

# Get progress coordinate
# WEST_STRUCT_DATA_REF

#COMMAND="         parm CONFIG/$SYSTEM.prmtop\n"
COMMAND="$COMMAND trajin $WEST_STRUCT_DATA_REF.rst\n"
COMMAND="$COMMAND reference $REF.rst\n"
# ... but keep in mind, not all residues exist in the reference structure.
# The "nofit" parameter ensures this is the case.
# This is the uh, one magic sort from the P53 paper.  Lemme look that up.  Oh!  Right, the binding RMSD.
# Now, let's get some extra stuff, such as the 'binding' RMSD of each individual residue
# S-Peptide Anchor residue after aligning on itself.  This is the "pre-organized anchor residue RMSD"
# The lack of the nofit command should align it on itself.

# We also want the C-alpha RMSD.  This should be aligned on itself.
COMMAND="$COMMAND rms p53-ca-rmsd :2-14@CA reference out ca-rmsd-p53.dat mass\n"
# Let's get the c-alpha RMSD of SPROT, as well.  Why not?  Could be interesting.
COMMAND="$COMMAND rms p53-heavy-rmsd :2-14&!@N,H,CA,HA,C,O reference out heavy-sc-rmsd-p53.dat mass\n"
 COMMAND="$COMMAND multidihedral dihedralP53 phi psi resrange 2-14 out dihedral_p53.dat \n"
COMMAND="$COMMAND go\n"
echo -e $COMMAND | $CPPTRAJ $CONFIG/$SYSTEM.prmtop

# Okay!  Minimum distance and the binding RMSD.
#paste <(cat min-dist.dat | tail -n +2 | awk '{print $4}') <(cat rmsd-ar.dat | tail -n +2 | awk '{print $2}') > $WEST_PCOORD_RETURN

cat ca-rmsd-p53.dat | tail -n +2 | awk '{print $2}' > $WEST_PCOORD_RETURN


if [ -n "$SEG_DEBUG" ] ; then
    head -v $WEST_PCOORD_RETURN
fi


