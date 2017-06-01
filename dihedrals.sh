#! /bin/bash

module load westpa
# [[B11, B12, B13, ...], [B21, B22, B23, ...], ...]

# We want to generate a list of ramachandran bins from -180 to 180.

#for i in {2..14}; do
#    w_pdist --construct-dataset pdist.dihedral_$i --output dihedral_$i.h5 -b "[`python -c 'print range(-181,182,1)'`, `python -c 'print range(-181,182,1)'`]"
#    plothist average dihedral_$i.h5 0::'phi' 1::'psi' --output dihedral_$i.pdf --title "Residue $i" --linear
#done

#w_pdist --construct-dataset pdist.dihedral_all --output dihedral_all.h5 -b "[`python -c 'print range(-181,182,1)'`, `python -c 'print range(-181,182,1)'`]"
#plothist average dihedral_all.h5 0::"\u03C6" 1::"\u03C8" --output dihedral_all.pdf --title "P53 Ramachandran Plot"
#plothist average dihedral_all.h5 1:-180,180:"\u03C8" --output dihedral_all_psi.pdf --title "P53 \u03C8 Distribution" --linear

plothist average dihedral_all.h5 0::"$\phi$" 1::"$\psi$" --output dihedral_all.pdf --title "P53 Ramachandran Plot"
plothist average dihedral_all.h5 1:-180,180:"$\psi$" --output dihedral_all_psi.pdf --title "P53 $\psi$ Distribution" --linear
