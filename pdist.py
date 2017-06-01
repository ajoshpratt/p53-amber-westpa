import numpy as np

def function(n_iter, iter_group, field_name):
    # We want to return the appropriate dataset.
    # Datasets are named dihedral_{2..14}

    return iter_group['auxdata'][field_name]


def dihedral_2(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_2')

def dihedral_3(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_3')

def dihedral_4(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_4')

def dihedral_5(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_5')

def dihedral_6(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_6')

def dihedral_7(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_7')

def dihedral_8(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_8')

def dihedral_9(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_9')

def dihedral_10(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_10')

def dihedral_11(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_11')

def dihedral_12(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_12')

def dihedral_13(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_13')

def dihedral_14(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_14')

def dihedral_14(n_iter, iter_group):
    return function(n_iter, iter_group, 'dihedral_14')

def dihedral_all(n_iter, iter_group):
    data = {}
    for i in range(2,15):
        data[i] = function(n_iter, iter_group, 'dihedral_{}'.format(i))
    # Now we need to add them all together.
    return_arr = data[2]
    for i in range(3,15):
        return_arr = np.concatenate((return_arr, data[i]), axis=1)
    return return_arr

