# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
from sage.all import GF, matrix
from plu_decomposition import PermutationToREWIRE, LowerTriangularToCNOT, UpperTriangularToCNOT
import L1, L3, L5
import L0
import os

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
    km = [matrix(K, L.KM[_]) for _ in range(len(L.KM))]
    km_inv = [kmi.inverse() for kmi in km]
    ikm = [km[0]]

    if single_file:
        if os.path.exists('in_place_key_expansion_%s.qs' % L_name):
            os.remove('in_place_key_expansion_%s.qs' % L_name)

    for i in range(1, L.rounds+1):
        _m = km[i] * km_inv[i-1]
        ikm.append(_m)

    ikm.append(km_inv[-1])

    # python lowmc implementation output

    code = """IKM = [
    """
    for m in ikm:
        code += "["
        code += m.str().replace('\n', ',\n').replace(' ', ', ')
        code += "],"
    code += ']\n'
    with open('in_place_km_%s.py' % L_name, 'w') as f:
        f.write(code)

    # qsharp lowmc implementation output

    for i in range(len(ikm)):
        code = """namespace QLowMC.InPlace.%s
    {
        open Microsoft.Quantum.Intrinsic;
        open Microsoft.Quantum.Canon;
        open QUtilities;
    """ % L_name

        M = ikm[i]
        P, L, U = M.LU()

        # print U

        if use_apply_each:
            # using ApplyToEachA
            code += """
            operation KeyExpansionRound%dU(round_key: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {
                    ApplyToEachA(ApplyToPairOfIndices(CNOT, _, _, round_key), [\n""" % (i)
            code += UpperTriangularToCNOT(U, bufname="round_key", tabs=5)
            code += """                ]);
                }
                adjoint auto;
            }\n"""
        else:
            # listing all cnots
            code += """
            operation KeyExpansionRound%dU(round_key: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {\n""" % (i)
            code += UpperTriangularToCNOT(U, bufname="round_key", tabs=5, use_apply_each=False)
            code += """        }
                adjoint auto;
            }\n"""

        # print L

        if use_apply_each:
            # using ApplyToEachA
            code += """
            operation KeyExpansionRound%dL(round_key: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {
                    ApplyToEachA(ApplyToPairOfIndices(CNOT, _, _, round_key), [\n""" % (i)
            code += LowerTriangularToCNOT(L, bufname="round_key", tabs=5)
            code += """                ]);
                }
                adjoint auto;
            }\n"""
        else:
            # listing all cnots
            code += """
            operation KeyExpansionRound%dL(round_key: Qubit[], costing: Bool) : Unit
            {
                body (...)
                {\n""" % (i)
            code += LowerTriangularToCNOT(L, bufname="round_key", tabs=3, use_apply_each=False)
            code += """        }
                adjoint auto;
            }\n"""

        # print P
        code += """
        operation KeyExpansionRound%dP(round_key: Qubit[], costing: Bool) : Unit
        {
            body (...)
            {\n""" % (i)
        code += PermutationToREWIRE(P, bufname="round_key", tabs=3)
        code += """        }
            adjoint auto;\
        }\n"""

        # full linear operation
        code +="""
        operation KeyExpansionRound%d(round_key: Qubit[], costing: Bool) : Unit
        {
            body (...)
            {
                %sKeyExpansionRound%dU(round_key, costing);
                %sKeyExpansionRound%dL(round_key, costing);
                %sKeyExpansionRound%dP(round_key, costing);
            }
            adjoint auto;
        }\n""" % (
            i,
            "", # "// ", # if i < 3 else "// ",
            i,
            "", # "// ", # if i < 3 else "// ",
            i,
            "", # "// ", # if i < 3 else "// ",
            i,
        )

        code += "}\n"

        if single_file:
            with open('in_place_key_expansion_%s.qs' % (L_name), 'a') as f:
                f.write(code)
        else:
            with open('in_place_key_expansion_%s_Round%d.qs' % (L_name, i), 'w') as f:
                f.write(code)

    # muxer
    code = """namespace QLowMC.InPlace.%s
    {
        open Microsoft.Quantum.Intrinsic;
        open QUtilities;

        operation KeyExpansion(round_key: Qubit[], round: Int, costing: Bool) : Unit
        {
            body (...)
            {
                if""" % L_name

    for i in range(len(ikm)):
        code += "(round == %d)\n" % (i)
        code += "            {\n"
        code += "                %sKeyExpansionRound%d(round_key, costing);\n" % (
            "", # if i < 3 else "// ",
            i
            )
        code += "            }"
        if i < len(ikm) - 1:
            code += "\n            elif "

    code += """
            }
            adjoint auto;
        }
    }
    """

    with open('in_place_key_expansion_%s.qs' % L_name, 'a' if single_file else 'w') as f:
        f.write(code)
