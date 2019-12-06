# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
from sage.all import GF, matrix, vector, Permutation

"""
Utilities for compiling constant matrix multiplications into no-ancilla Q# code
by going through a PLU decomposition.

NOTE:
    The permutation component is decomposed into 'REWIRE' function calls.
    These are just a wrapper of the SWAP Q# standard library operation, that can be
    disabled when running the estimator (since supposedly SWAP operations are
    free).
"""

def MatrixToPermutation(P):
    n = P.dimensions()[1]
    ei = lambda i: vector([int(i == j) for j in range(n)])
    def ie(v):
        for _ in range(n):
            if v[_] == 1: return _
    for i in range(n): assert(ie(ei(i)) == i) # check
    p = [ie(P * ei(i)) + 1 for i in range(n)] # need to shift up by one

    return Permutation(p)


def CycleToTranspositions(C):
    if len(C) <= 2:
        return [C]
    res = []
    for i in range(len(C) - 1):
        res.append((C[i], C[i+1]))
    return res


def PermutationToREWIRE(P, bufname="state", tabs=0, spaces=4):
    code = ""
    tab = (" " * spaces) if spaces > 0 else "\t"
    perm = MatrixToPermutation(P)
    cycles = map(CycleToTranspositions, perm.to_cycles(singletons=False))
    cycles = [e for sub in cycles for e in sub]

    for c in cycles[::-1]: # apply cycles right to left
        l, r = c[0]-1, c[1]-1 # sage Permutations work on {1..n}, so had to shift up indices
        code += '%sREWIRE(%s[%d], %s[%d], costing);\n' % (tab * tabs, bufname, l, bufname, r)
    return code


def UpperTriangularToCNOT(U, bufname="state", tabs=0, spaces=4, use_apply_each=True):
    code = ""
    tab = (" " * spaces) if spaces > 0 else "\t"
    for row in range(U.dimensions()[0]):
        for col in range(row + 1, U.dimensions()[1]):
            if U[row][col] == 1:
                if use_apply_each:
                    code += "%s(%d, %d)," % (tab * tabs * 0, col, row)
                else:
                    code += "%sCNOT(%s[%d], %s[%d]);\n" % (tab * tabs, bufname, col, bufname, row)
    return code


def LowerTriangularToCNOT(L, bufname="state", tabs=0, spaces=4, use_apply_each=True):
    code = ""
    tab = (" " * spaces) if spaces > 0 else "\t"
    for row in range(L.dimensions()[0])[::-1]:
        for col in range(row):
            if L[row][col] == 1:
                if use_apply_each:
                    code += "%s(%d, %d)," % (tab * tabs * 0, col, row)
                else:
                    code += "%sCNOT(%s[%d], %s[%d]);\n" % (tab * tabs, bufname, col, bufname, row)
    return code
