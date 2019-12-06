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
            CNOT(u[0], u[5]);
            CNOT(u[3], u[5]);
            CNOT(u[6], u[5]);
            CNOT(u[0], u[4]);
            CNOT(u[3], u[4]);
            CNOT(u[6], u[4]);
            LPAND(u[5], u[4], t[0], costing);
            CNOT(t[0], t[5]);

            CNOT(u[1], u[3]);
            CNOT(u[2], u[3]);
            CNOT(u[7], u[3]);
            LPAND(u[3], u[7], t[0], costing);

            CNOT(u[0], u[6]);
            CNOT(u[0], u[2]);
            CNOT(u[4], u[2]);
            CNOT(u[5], u[2]);
            CNOT(u[6], u[2]);
            LPAND(u[6], u[2], t[1], costing);
            CNOT(t[1], t[2]);

            CNOT(u[2], u[1]);
            CNOT(u[4], u[1]);
            CNOT(u[5], u[1]);
            CNOT(u[7], u[1]);
            CNOT(u[1], u[0]);
            CNOT(u[6], u[0]);
            LPAND(u[1], u[0], t[1], costing);

            CNOT(u[1], u[6]);
            CNOT(u[0], u[2]);
            LPAND(u[6], u[2], t[2], costing);

            CNOT(u[6], u[3]);
            CNOT(u[7], u[2]);
            LPAND(u[3], u[2], t[3], costing);
            CNOT(t[3], t[4]);

            CNOT(u[1], u[6]);
            CNOT(u[5], u[6]);
            CNOT(u[2], u[0]);
            CNOT(u[4], u[0]);
            CNOT(u[7], u[0]);
            LPAND(u[6], u[0], t[3], costing);

            CNOT(u[6], u[3]);
            CNOT(u[2], u[0]);
            LPAND(u[3], u[0], t[4], costing);

            CNOT(t[3], t[1]);

            CNOT(u[1], u[3]);
            CNOT(u[7], u[4]);
            LPAND(u[3], u[4], t[5], costing);

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

            LPAND(t[3], t[1], t[6], costing);
            CNOT(t[0], t[3]);

            CNOT(t[4], t[7]);
            CNOT(t[6], t[7]);

            CNOT(t[0], t[6]);
            LPAND(t[3], t[7], t[0], costing);

            CNOT(t[1], t[8]);
            CNOT(t[4], t[8]);

            LPAND(t[6], t[8], t[9], costing);


            CNOT(t[4], t[8]);
            CNOT(t[1], t[8]);


            CNOT(t[4], t[9]);
            CNOT(t[9], t[1]);

            CNOT(t[7], t[8]);
            CNOT(t[9], t[8]);

            LPAND(t[4], t[8], t[10], costing);


            CNOT(t[9], t[8]);
            CNOT(t[7], t[8]);


            CNOT(t[10], t[1]);
            CNOT(t[10], t[7]);
            LPAND(t[0], t[7], t[3], costing);

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

            LPAND(t[0], u[3], s[2], costing);
            CNOT(s[2], s[5]);

            CNOT(u[0], u[3]);
            LPAND(t[12], u[3], s[6], costing);
            CNOT(s[6], s[2]);
            CNOT(s[6], s[5]);
            CNOT(u[0], u[3]);

            LPAND(t[1], u[4], s[1], costing);
            CNOT(s[1], s[3]);
            CNOT(s[1], s[4]);
            CNOT(u[7], u[4]);
            LPAND(t[13], u[4], s[7], costing);
            CNOT(s[7], s[1]);
            CNOT(s[7], s[2]);
            CNOT(s[7], s[3]);
            CNOT(s[7], s[5]);
            CNOT(u[7], u[4]);

            LPAND(t[3], u[0], s[6], costing);
            CNOT(s[6], s[7]);

            CNOT(u[3], u[6]);
            LPAND(t[11], u[6], s[0], costing);
            CNOT(s[0], s[2]);
            CNOT(u[3], u[6]);

            LPAND(t[14], u[2], s[0], costing);
            CNOT(s[0], s[1]);
            CNOT(s[0], s[3]);
            CNOT(s[0], s[4]);
            CNOT(s[0], s[5]);
            CNOT(s[0], s[6]);
            CNOT(s[0], s[7]);

            LPAND(t[9], u[7], z[0], costing);
            CNOT(z[0], s[2]);
            CNOT(z[0], s[4]);
            CNOT(z[0], s[5]);
            CNOT(z[0], s[7]);
            LPAND(t[9], u[7], z[0], costing);

            CNOT(u[0], u[5]);
            CNOT(u[3], u[5]);
            LPAND(t[12], u[5], z[0], costing);

            CNOT(z[0], s[0]);
            CNOT(z[0], s[3]);
            CNOT(z[0], s[5]);
            CNOT(z[0], s[7]);

            LPAND(t[12], u[5], z[0], costing);
            CNOT(u[3], u[5]);
            CNOT(u[0], u[5]);

            CNOT(u[1], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[3], u[6]);
            CNOT(u[4], u[6]);
            LPAND(t[3], u[6], z[0], costing);

            CNOT(z[0], s[0]);
            CNOT(z[0], s[3]);
            CNOT(z[0], s[4]);
            CNOT(z[0], s[5]);
            CNOT(z[0], s[6]);

            LPAND(t[3], u[6], z[0], costing);
            CNOT(u[4], u[6]);
            CNOT(u[3], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[1], u[6]);

            CNOT(u[0], u[6]);
            CNOT(u[1], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[4], u[6]);
            CNOT(u[5], u[6]);
            LPAND(t[0], u[6], z[0], costing);

            CNOT(z[0], s[4]);
            CNOT(z[0], s[6]);
            CNOT(z[0], s[7]);

            LPAND(t[0], u[6], z[0], costing);
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
            LPAND(t[11], u[7], z[0], costing);

            CNOT(z[0], s[0]);
            CNOT(z[0], s[1]);
            CNOT(z[0], s[2]);

            LPAND(t[11], u[7], z[0], costing);
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
            LPAND(t[14], u[7], z[0], costing);

            CNOT(z[0], s[0]);
            CNOT(z[0], s[1]);
            CNOT(z[0], s[5]);
            CNOT(z[0], s[6]);

            LPAND(t[14], u[7], z[0], costing);
            CNOT(u[5], u[7]);
            CNOT(u[4], u[7]);
            CNOT(u[3], u[7]);
            CNOT(u[0], u[7]);

            CNOT(u[1], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[3], u[6]);
            LPAND(t[8], u[6], z[0], costing);

            CNOT(z[0], s[2]);
            CNOT(z[0], s[5]);
            CNOT(z[0], s[6]);

            LPAND(t[8], u[6], z[0], costing);
            CNOT(u[3], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[1], u[6]);

            CNOT(u[0], u[3]);
            CNOT(u[2], u[3]);
            LPAND(t[13], u[3], z[0], costing);

            CNOT(z[0], s[0]);
            CNOT(z[0], s[1]);
            CNOT(z[0], s[3]);
            CNOT(z[0], s[4]);

            LPAND(t[13], u[3], z[0], costing);
            CNOT(u[2], u[3]);
            CNOT(u[0], u[3]);

            CNOT(u[0], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[3], u[6]);
            LPAND(t[1], u[6], z[0], costing);

            CNOT(z[0], s[0]);
            CNOT(z[0], s[1]);
            CNOT(z[0], s[3]);
            CNOT(z[0], s[4]);
            CNOT(z[0], s[5]);

            LPAND(t[1], u[6], z[0], costing);
            CNOT(u[3], u[6]);
            CNOT(u[2], u[6]);
            CNOT(u[0], u[6]);

            CNOT(u[2], u[6]);
            CNOT(u[3], u[6]);
            LPAND(t[8], u[6], s[2], costing);
            CNOT(u[3], u[6]);
            CNOT(u[2], u[6]);

            LPAND(t[9], u[6], s[5], costing);

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
            using ((t, z, s) = (Qubit[15], Qubit[1], Qubit[8]))
            {
                let u = input[7..(-1)..0];

                ForwardSBox(u, t, z, s, costing);
                
                for (i in 0..7)
                {
                    CNOT(s[i], output[7-i]);
                }

                (Adjoint ForwardSBox)(u, t, z, s, costing);
            }
        }
        adjoint auto;
    }
}
