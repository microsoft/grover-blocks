// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
// https://eprint.iacr.org/2019/854.pdf

namespace LPS19
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    operation ForwardSBox (u: Qubit[], t: Qubit[], z: Qubit[], s: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            use andAnc = Qubit[41] {
                CNOT(u[0], u[5]);
                CNOT(u[3], u[5]);
                CNOT(u[6], u[5]);
                CNOT(u[0], u[4]);
                CNOT(u[3], u[4]);
                CNOT(u[6], u[4]);
                LPANDWithAux(u[5], u[4], t[0], andAnc[0], costing);
                CNOT(t[0], t[5]);

                CNOT(u[1], u[3]);
                CNOT(u[2], u[3]);
                CNOT(u[7], u[3]);
                LPANDWithAux(u[3], u[7], t[0], andAnc[1], costing);

                CNOT(u[0], u[6]);
                CNOT(u[0], u[2]);
                CNOT(u[4], u[2]);
                CNOT(u[5], u[2]);
                CNOT(u[6], u[2]);
                LPANDWithAux(u[6], u[2], t[1], andAnc[2], costing);
                CNOT(t[1], t[2]);

                CNOT(u[2], u[1]);
                CNOT(u[4], u[1]);
                CNOT(u[5], u[1]);
                CNOT(u[7], u[1]);
                CNOT(u[1], u[0]);
                CNOT(u[6], u[0]);
                LPANDWithAux(u[1], u[0], t[1], andAnc[3], costing);

                CNOT(u[1], u[6]);
                CNOT(u[0], u[2]);
                LPANDWithAux(u[6], u[2], t[2], andAnc[4], costing);

                CNOT(u[6], u[3]);
                CNOT(u[7], u[2]);
                LPANDWithAux(u[3], u[2], t[3], andAnc[5], costing);
                CNOT(t[3], t[4]);

                CNOT(u[1], u[6]);
                CNOT(u[5], u[6]);
                CNOT(u[2], u[0]);
                CNOT(u[4], u[0]);
                CNOT(u[7], u[0]);
                LPANDWithAux(u[6], u[0], t[3], andAnc[6], costing);

                CNOT(u[6], u[3]);
                CNOT(u[2], u[0]);
                LPANDWithAux(u[3], u[0], t[4], andAnc[7], costing);

                CNOT(t[3], t[1]);

                CNOT(u[1], u[3]);
                CNOT(u[7], u[4]);
                LPANDWithAux(u[3], u[4], t[5], andAnc[8], costing);

                CNOT(t[5], t[3]);

                CNOT(t[4], t[0]);

                CNOT(t[2], t[4]);

                CNOT(u[1], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[3], u[6]);
                CNOT(u[6], t[3]);

                CNOT(u[0], u[1]);
                CNOT(u[3], u[1]);
                CNOT(u[1], t[0]);

                CNOT(u[1], u[5]);
                CNOT(u[4], u[5]);
                CNOT(u[6], u[5]);
                CNOT(u[7], u[5]);
                CNOT(u[5], t[1]);

                CNOT(u[1], u[4]);
                CNOT(u[3], u[4]);
                CNOT(u[5], u[4]);
                CNOT(u[4], t[4]);

                LPANDWithAux(t[3], t[1], t[6], andAnc[9], costing);
                CNOT(t[0], t[3]);

                CNOT(t[4], t[7]);
                CNOT(t[6], t[7]);

                CNOT(t[0], t[6]);
                LPANDWithAux(t[3], t[7], t[0], andAnc[10], costing);

                CNOT(t[1], t[8]);
                CNOT(t[4], t[8]);

                LPANDWithAux(t[6], t[8], t[9], andAnc[11], costing);


                CNOT(t[4], t[8]);
                CNOT(t[1], t[8]);


                CNOT(t[4], t[9]);
                CNOT(t[9], t[1]);

                CNOT(t[7], t[8]);
                CNOT(t[9], t[8]);

                LPANDWithAux(t[4], t[8], t[10], andAnc[12], costing);


                CNOT(t[9], t[8]);
                CNOT(t[7], t[8]);


                CNOT(t[10], t[1]);
                CNOT(t[10], t[7]);
                LPANDWithAux(t[0], t[7], t[3], andAnc[13], costing);

                CNOT(t[3], t[8]);
                CNOT(t[1], t[8]);

                CNOT(t[0], t[11]);
                CNOT(t[9], t[11]);


                CNOT(t[0], t[12]);
                CNOT(t[3], t[12]);

                CNOT(t[9], t[13]);
                CNOT(t[1], t[13]);

                CNOT(t[11], t[14]);
                CNOT(t[8], t[14]);

                CNOT(u[0], u[2]);
                CNOT(u[1], u[2]);
                CNOT(u[6], u[2]);

                CNOT(u[1], u[4]);
                CNOT(u[3], u[4]);
                CNOT(u[5], u[4]);

                CNOT(u[1], u[6]);
                CNOT(u[3], u[6]);
                CNOT(u[4], u[6]);
                CNOT(u[5], u[6]);
                CNOT(u[7], u[6]);

                CNOT(u[1], u[0]);
                CNOT(u[3], u[0]);

                CNOT(u[0], u[3]);
                CNOT(u[2], u[3]);
                CNOT(u[6], u[3]);

                LPANDWithAux(t[0], u[3], s[2], andAnc[14], costing);
                CNOT(s[2], s[5]);

                CNOT(u[0], u[3]);
                LPANDWithAux(t[12], u[3], s[6], andAnc[15], costing);
                CNOT(s[6], s[2]);
                CNOT(s[6], s[5]);
                CNOT(u[0], u[3]);

                LPANDWithAux(t[1], u[4], s[1], andAnc[16], costing);
                CNOT(s[1], s[3]);
                CNOT(s[1], s[4]);
                CNOT(u[7], u[4]);
                LPANDWithAux(t[13], u[4], s[7], andAnc[17], costing);
                CNOT(s[7], s[1]);
                CNOT(s[7], s[2]);
                CNOT(s[7], s[3]);
                CNOT(s[7], s[5]);
                CNOT(u[7], u[4]);

                LPANDWithAux(t[3], u[0], s[6], andAnc[18], costing);
                CNOT(s[6], s[7]);

                CNOT(u[3], u[6]);
                LPANDWithAux(t[11], u[6], s[0], andAnc[19], costing);
                CNOT(s[0], s[2]);
                CNOT(u[3], u[6]);

                LPANDWithAux(t[14], u[2], s[0], andAnc[20], costing);
                CNOT(s[0], s[1]);
                CNOT(s[0], s[3]);
                CNOT(s[0], s[4]);
                CNOT(s[0], s[5]);
                CNOT(s[0], s[6]);
                CNOT(s[0], s[7]);

                LPANDWithAux(t[9], u[7], z[0], andAnc[21], costing);
                CNOT(z[0], s[2]);
                CNOT(z[0], s[4]);
                CNOT(z[0], s[5]);
                CNOT(z[0], s[7]);
                LPANDWithAux(t[9], u[7], z[0], andAnc[22], costing);

                CNOT(u[0], u[5]);
                CNOT(u[3], u[5]);
                LPANDWithAux(t[12], u[5], z[0], andAnc[23], costing);

                CNOT(z[0], s[0]);
                CNOT(z[0], s[3]);
                CNOT(z[0], s[5]);
                CNOT(z[0], s[7]);

                LPANDWithAux(t[12], u[5], z[0], andAnc[24], costing);
                CNOT(u[3], u[5]);
                CNOT(u[0], u[5]);

                CNOT(u[1], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[3], u[6]);
                CNOT(u[4], u[6]);
                LPANDWithAux(t[3], u[6], z[0], andAnc[25], costing);

                CNOT(z[0], s[0]);
                CNOT(z[0], s[3]);
                CNOT(z[0], s[4]);
                CNOT(z[0], s[5]);
                CNOT(z[0], s[6]);

                LPANDWithAux(t[3], u[6], z[0], andAnc[26], costing);
                CNOT(u[4], u[6]);
                CNOT(u[3], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[1], u[6]);

                CNOT(u[0], u[6]);
                CNOT(u[1], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[4], u[6]);
                CNOT(u[5], u[6]);
                LPANDWithAux(t[0], u[6], z[0], andAnc[27], costing);

                CNOT(z[0], s[4]);
                CNOT(z[0], s[6]);
                CNOT(z[0], s[7]);

                LPANDWithAux(t[0], u[6], z[0], andAnc[28], costing);
                CNOT(u[5], u[6]);
                CNOT(u[4], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[1], u[6]);
                CNOT(u[0], u[6]);

                CNOT(u[0], u[7]);
                CNOT(u[1], u[7]);
                CNOT(u[2], u[7]);
                CNOT(u[4], u[7]);
                CNOT(u[5], u[7]);
                CNOT(u[6], u[7]);
                LPANDWithAux(t[11], u[7], z[0], andAnc[29], costing);

                CNOT(z[0], s[0]);
                CNOT(z[0], s[1]);
                CNOT(z[0], s[2]);

                LPANDWithAux(t[11], u[7], z[0], andAnc[30], costing);
                CNOT(u[6], u[7]);
                CNOT(u[5], u[7]);
                CNOT(u[4], u[7]);
                CNOT(u[2], u[7]);
                CNOT(u[1], u[7]);
                CNOT(u[0], u[7]);

                CNOT(u[0], u[7]);
                CNOT(u[3], u[7]);
                CNOT(u[4], u[7]);
                CNOT(u[5], u[7]);
                LPANDWithAux(t[14], u[7], z[0], andAnc[31], costing);

                CNOT(z[0], s[0]);
                CNOT(z[0], s[1]);
                CNOT(z[0], s[5]);
                CNOT(z[0], s[6]);

                LPANDWithAux(t[14], u[7], z[0], andAnc[32], costing);
                CNOT(u[5], u[7]);
                CNOT(u[4], u[7]);
                CNOT(u[3], u[7]);
                CNOT(u[0], u[7]);

                CNOT(u[1], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[3], u[6]);
                LPANDWithAux(t[8], u[6], z[0], andAnc[33], costing);

                CNOT(z[0], s[2]);
                CNOT(z[0], s[5]);
                CNOT(z[0], s[6]);

                LPANDWithAux(t[8], u[6], z[0], andAnc[34], costing);
                CNOT(u[3], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[1], u[6]);

                CNOT(u[0], u[3]);
                CNOT(u[2], u[3]);
                LPANDWithAux(t[13], u[3], z[0], andAnc[35], costing);

                CNOT(z[0], s[0]);
                CNOT(z[0], s[1]);
                CNOT(z[0], s[3]);
                CNOT(z[0], s[4]);

                LPANDWithAux(t[13], u[3], z[0], andAnc[36], costing);
                CNOT(u[2], u[3]);
                CNOT(u[0], u[3]);

                CNOT(u[0], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[3], u[6]);
                LPANDWithAux(t[1], u[6], z[0], andAnc[37], costing);

                CNOT(z[0], s[0]);
                CNOT(z[0], s[1]);
                CNOT(z[0], s[3]);
                CNOT(z[0], s[4]);
                CNOT(z[0], s[5]);

                LPANDWithAux(t[1], u[6], z[0], andAnc[38], costing);
                CNOT(u[3], u[6]);
                CNOT(u[2], u[6]);
                CNOT(u[0], u[6]);

                CNOT(u[2], u[6]);
                CNOT(u[3], u[6]);
                LPANDWithAux(t[8], u[6], s[2], andAnc[39], costing);
                CNOT(u[3], u[6]);
                CNOT(u[2], u[6]);

                LPANDWithAux(t[9], u[6], s[5], andAnc[40], costing);
            }
            X(s[1]);
            X(s[2]);
            X(s[6]);
            X(s[7]);
        }
        adjoint auto;
    }

    operation SBox (input: Qubit[], output: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            use (t, z, s) = (Qubit[15], Qubit[1], Qubit[8])
            {
                let u = input[7..(-1)..0];

                ForwardSBox(u, t, z, s, costing);
                
                for i in 0..7
                {
                    CNOT(s[i], output[7-i]);
                }

                (Adjoint ForwardSBox)(u, t, z, s, costing);
            }
        }
        adjoint auto;
    }
}
