#!/bin/bash -l

if [ -n "$SEG_DEBUG" ] ; then
    set -x
    #env | sort
fi


#cd $WEST_SIM_ROOT
#source env.sh
cd $PBS_O_WORKDIR
mkdir -pv $WEST_CURRENT_SEG_DATA_REF || exit 1
cd $WEST_CURRENT_SEG_DATA_REF || exit 1

module() { eval `/opt/sam/Modules/3.2.6/bin/modulecmd bash $*`; }
source /etc/profile.d/sam-modules.sh
export USE_LOCAL_SCRATCH=1
export SCRATCHROOT=/scratch
export SWROOT=""
export TMP=/tmp
module purge
module load amber/14-intel-2015-cuda-7.5
export CPPTRAJ=/opt/sam/rhel6/amber/amber14.T15/bin/cpptraj
export PMEMD="$(which pmemd.cuda) -O"
export WEST_JOBID=$PBS_JOBID
export USER=$PBS_O_LOGNAME
export SYSTEM=P53
export CONFIG=$WEST_SIM_ROOT/CONFIG
export REF=$PBS_O_WORKDIR/bstates/0/P53.MDM2
env | sort


if [[ "$USE_LOCAL_SCRATCH" == "1" ]] ; then
    # make scratch directory
    WORKDIR=$TMP/$USER/$WEST_JOBID/$WEST_CURRENT_SEG_DATA_REF
    SRCDIR=$TMP/$USER/$WEST_JOBID
    mkdir -p $WORKDIR || exit 1

    STAGEIN="$SWROOT/bin/cp -avL "
else
    STAGEIN="$SWROOT/bin/ln -sv "
fi
cd $WORKDIR || exit 1

function cleanup() {
    # Clean up
    if [[ "$USE_LOCAL_SCRATCH" == "1" ]] ; then
        $SWROOT/bin/cp * $WEST_SIM_ROOT/$WEST_CURRENT_SEG_DATA_REF || exit 1
    else
        # Don't care about this for the moment, as we'll always be using the local tmp space.
        $SWROOT/bin/rm -f *.itp *.mdp *.ndx *.top state.cpt
        $SWROOT/bin/rm -f none.xtc whole.xtc
    fi
}

trap cleanup EXIT

# Set up the run

case $WEST_CURRENT_SEG_INITPOINT_TYPE in
    SEG_INITPOINT_CONTINUES)
        # A continuation from a prior segment
        cd $WORKDIR || exit
        cp  $WEST_SIM_ROOT/$WEST_PARENT_DATA_REF/seg.rst ./parent.rst
        cp  $CONFIG/prod.in .
        cp  $CONFIG/$SYSTEM.prmtop .
        mv prod.in seg.in
    ;;

    SEG_INITPOINT_NEWTRAJ)
        # Initiation of a new trajectory; $WEST_PARENT_DATA_REF contains the reference to the
        # appropriate basis state or generated initial state
        cp $WEST_PARENT_DATA_REF.rst ./parent.rst
        cp $CONFIG/prod.in .
        cp $CONFIG/$SYSTEM.prmtop .
        mv prod.in seg.in
    ;;

    *)
        echo "unknown init point type $WEST_CURRENT_SEG_INITPOINT_TYPE"
        exit 2
    ;;
esac
    
# Propagate segment

export CUDA_VISIBLE_DEVICES=$WM_PROCESS_INDEX 

$PMEMD -p $SYSTEM.prmtop    -i   seg.in  -c parent.rst  -o seg.out           -inf seg.nfo -l seg.log -x seg.nc            -r   seg.rst || exit 1

# Get progress coordinate

#COMMAND="         trajin $WEST_CURRENT_SEG_DATA_REF/parent.rst\n"
COMMAND="$COMMAND trajin seg.nc\n"
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
echo -e $COMMAND | $CPPTRAJ $SYSTEM.prmtop

# Okay!  Minimum distance and the binding RMSD.
#paste <(cat min-dist.dat | tail -n +2 | awk '{print $4}') <(cat rmsd-ar.dat | tail -n +2 | awk '{print $2}') > $WEST_PCOORD_RETURN

cat ca-rmsd-p53.dat | tail -n +2 | awk '{print $2}' > $WEST_PCOORD_RETURN

cat heavy-sc-rmsd-p53.dat | tail -n +2 | awk '{print $2}' > $WEST_HEAVY_SC_RMSD_P53_RETURN

# Everything is named DIHEDRAL_X
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $2'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $3'}) > $WEST_DIHEDRAL_2_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $4'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $5'}) > $WEST_DIHEDRAL_3_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $6'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $7'}) > $WEST_DIHEDRAL_4_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $8'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $9'}) > $WEST_DIHEDRAL_5_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $10'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $11'}) > $WEST_DIHEDRAL_6_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $12'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $13'}) > $WEST_DIHEDRAL_7_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $14'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $15'}) > $WEST_DIHEDRAL_8_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $16'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $17'}) > $WEST_DIHEDRAL_9_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $18'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $19'}) > $WEST_DIHEDRAL_10_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $20'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $21'}) > $WEST_DIHEDRAL_11_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $22'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $23'}) > $WEST_DIHEDRAL_12_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $24'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $25'}) > $WEST_DIHEDRAL_13_RETURN
paste <(cat dihedral_p53.dat | tail -n +2 | awk {'print $26'}) <(cat dihedral_p53.dat | tail -n +2 | awk {'print $27'}) > $WEST_DIHEDRAL_14_RETURN

