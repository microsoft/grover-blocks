# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
from sage.all import GF, matrix
from plu_decomposition import PermutationToREWIRE, LowerTriangularToCNOT, UpperTriangularToCNOT
import L1, L3, L5
import L0
import os
"""
Due to large compile times for long operations, it appears more efficient to break the affine layer
into smaller operations.
"""

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-s", "--single_file", action="store_true", help="combine output into a single Q# file")
parser.add_argument("--cnots", action="store_true", help="list explicitly all cnots for L and U")
parser.add_argument("-c", "--category", type=int, default=-1, help="generate code only a single security category")
args = parser.parse_args()

single_file = args.single_file
categories = {
    0: (L0, "L0"),
    1: (L1, "L1"),
    3: (L3, "L3"),
    5: (L5, "L5"),
}
use_apply_each = not args.cnots

if args.category == -1:
    schemes = categories.values()
else:
    try:
        schemes = [categories[args.category]]
    except:
        print "Security category %d not available" % args.category

K = GF(2)

for params in schemes:
    L, L_name = params
    lm = [matrix(K, L.LM[_]) for _ in range(len(L.LM))]
    b = L.b

    if single_file:
        if os.path.exists('affine_layers_%s.qs' % L_name):
            os.remove('affine_layers_%s.qs' % L_name)

    for i in range(len(lm)):
    # for i in range(3):
        code = """\nnamespace QLowMC.InPlace.%s
    {
        open Microsoft.Quantum.Intrinsic;
        open Microsoft.Quantum.Canon;
        open QUtilities;
    """ % L_name

        M = lm[i]
        P, L, U = M.LU()

        # print U

        if use_apply_each:
            # using ApplyToEachA
            code += """
            operation AffineLayerRound%dU(state: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {
                    ApplyToEachA(ApplyToPairOfIndices(CNOT, _, _, state), [\n""" % (i+1)
            code += UpperTriangularToCNOT(U, tabs=5)
            code += """                ]);
                }
                adjoint auto;
            }\n"""
        else:
            # list all cnots
            code += """
            operation AffineLayerRound%dU(state: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {\n""" % (i + 1)
            code += UpperTriangularToCNOT(U, tabs=3, use_apply_each=False)
            code += """        }
                adjoint auto;
            }\n"""

        # print L
        if use_apply_each:
            # using ApplyToEachA
            code += """
            operation AffineLayerRound%dL(state: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {
                    ApplyToEachA(ApplyToPairOfIndices(CNOT, _, _, state), [\n""" % (i+1)
            code += LowerTriangularToCNOT(L, tabs=5)
            code += """                ]);
                }
                adjoint auto;
            }\n"""
        else:
            # list all cnots
            code += """
            operation AffineLayerRound%dL(state: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {\n""" % (i + 1)
            code += LowerTriangularToCNOT(L, tabs=3, use_apply_each=False)
            code += """        }
                adjoint auto;
            }\n"""


        # print P
        code += """
        operation AffineLayerRound%dP(state: Qubit[], costing: Bool) : Unit
        {
            body (...)
            {\n""" % (i + 1)
        code += PermutationToREWIRE(P, tabs=3)
        code += """        }
            adjoint auto;
        }\n"""

        # print the constant added after multiplication
        code += """
        operation AffineLayerRound%dConstantAddition(state: Qubit[], costing: Bool) : Unit
        {
            body (...)
            {\n""" % (i + 1)
        for j in range(len(b[i])):
            if b[i][j] == 1:
                code += "            X(state[%d]);\n" % (j)
        code += "        }\n"
        code += "        adjoint auto;\n"
        code += "    }"
        code += "\n"


        # full affine operation
        code +="""
        operation AffineLayerRound%d(state: Qubit[], costing: Bool) : Unit
        {
            body (...)
            {
                %sAffineLayerRound%dU(state, costing);
                %sAffineLayerRound%dL(state, costing);
                %sAffineLayerRound%dP(state, costing);
                %sAffineLayerRound%dConstantAddition(state, costing);
            }
            adjoint auto;
        }\n}""" % (
            i+1,
            "", # "// ", # if i < 3 else "// ",
            i+1,
            "", # "// ", # if i < 3 else "// ",
            i+1,
            "", # "// ", # if i < 3 else "// ",
            i+1,
            "", # if i < 3 else "// ",
            i+1
        )

        if single_file:
            with open('affine_layers_%s.qs' % (L_name), 'a') as f:
                f.write(code)
        else:
            with open('affine_layers_%s_Round%d.qs' % (L_name, i+1), 'w') as f:
                f.write(code)

    # muxer
    code = """\nnamespace QLowMC.InPlace.%s
    {
        open Microsoft.Quantum.Intrinsic;
        open QUtilities;

        operation AffineLayer(state: Qubit[], round: Int, costing: Bool) : Unit
        {
            body (...)
            {
                if""" % L_name

    for i in range(len(lm)):
        code += "(round == %d)\n" % (i+1)
        code += "            {\n"
        code += "                %sAffineLayerRound%d(state, costing);\n" % (
            "", # if i < 3 else "// ",
            i+1
            )
        code += "            }"
        if i < len(lm) - 1:
            code += "\n            elif "

    code += """
            }
            adjoint auto;
        }
    }
    """

    with open('affine_layers_%s.qs' % L_name, 'a' if single_file else 'w') as f:
        f.write(code)
