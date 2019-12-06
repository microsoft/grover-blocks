// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
// https://www.nist.gov/publications/depth-16-circuit-aes-s-box

namespace BoyarPeralta11
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    operation ForwardSBox(u: Qubit[], s: Qubit[], t: Qubit[], m: Qubit[], l: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            LPXOR(u[0], u[3], t[1-1]);
            LPXOR(u[0], u[5], t[2-1]);
            LPXOR(u[0], u[6], t[3-1]);
            LPXOR(u[3], u[5], t[4-1]);
            LPXOR(u[4], u[6], t[5-1]);
            LPXOR(t[1-1], t[5-1], t[6-1]);
            LPXOR(u[1], u[2], t[7-1]);
            LPXOR(u[7], t[6-1], t[8-1]);
            LPXOR(u[7], t[7-1], t[9-1]);
            LPXOR(t[6-1], t[7-1], t[10-1]);
            LPXOR(u[1], u[5], t[11-1]);
            LPXOR(u[2], u[5], t[12-1]);
            LPXOR(t[3-1], t[4-1], t[13-1]);
            LPXOR(t[6-1], t[11-1], t[14-1]);
            LPXOR(t[5-1], t[11-1], t[15-1]);
            LPXOR(t[5-1], t[12-1], t[16-1]);
            LPXOR(t[9-1], t[16-1], t[17-1]);
            LPXOR(u[3], u[7], t[18-1]);
            LPXOR(t[7-1], t[18-1], t[19-1]);
            LPXOR(t[1-1], t[19-1], t[20-1]);
            LPXOR(u[6], u[7], t[21-1]);
            LPXOR(t[7-1], t[21-1], t[22-1]);
            LPXOR(t[2-1], t[22-1], t[23-1]);
            LPXOR(t[2-1], t[10-1], t[24-1]);
            LPXOR(t[20-1], t[17-1], t[25-1]);
            LPXOR(t[3-1], t[16-1], t[26-1]);
            LPXOR(t[1-1], t[12-1], t[27-1]);

            LPAND(t[13-1], t[6-1], m[1-1], costing);
            LPAND(t[23-1], t[8-1], m[2-1], costing);
            LPXOR(t[14-1], m[1-1], m[3-1]);
            LPAND(t[19-1], u[7], m[4-1], costing);
            LPXOR(m[4-1], m[1-1], m[5-1]);
            LPAND(t[3-1], t[16-1], m[6-1], costing);
            LPAND(t[22-1], t[9-1], m[7-1], costing);
            LPXOR(t[26-1], m[6-1], m[8-1]);
            LPAND(t[20-1], t[17-1], m[9-1], costing);
            LPXOR(m[9-1], m[6-1], m[10-1]);
            LPAND(t[1-1], t[15-1], m[11-1], costing);
            LPAND(t[4-1], t[27-1], m[12-1], costing);
            LPXOR(m[12-1], m[11-1], m[13-1]);
            LPAND(t[2-1], t[10-1], m[14-1], costing);
            LPXOR(m[14-1], m[11-1], m[15-1]);
            LPXOR(m[3-1], m[2-1], m[16-1]);
            LPXOR(m[5-1], t[24-1], m[17-1]);
            LPXOR(m[8-1], m[7-1], m[18-1]);
            LPXOR(m[10-1], m[15-1], m[19-1]);
            LPXOR(m[16-1], m[13-1], m[20-1]);
            LPXOR(m[17-1], m[15-1], m[21-1]);
            LPXOR(m[18-1], m[13-1], m[22-1]);
            LPXOR(m[19-1], t[25-1], m[23-1]);
            LPXOR(m[22-1], m[23-1], m[24-1]);
            LPAND(m[22-1], m[20-1], m[25-1], costing);
            LPXOR(m[21-1], m[25-1], m[26-1]);
            LPXOR(m[20-1], m[21-1], m[27-1]);
            LPXOR(m[23-1], m[25-1], m[28-1]);
            LPAND(m[28-1], m[27-1], m[29-1], costing);
            LPAND(m[26-1], m[24-1], m[30-1], costing);
            LPAND(m[20-1], m[23-1], m[31-1], costing);
            LPAND(m[27-1], m[31-1], m[32-1], costing);
            LPXOR(m[27-1], m[25-1], m[33-1]);
            LPAND(m[21-1], m[22-1], m[34-1], costing);
            LPAND(m[24-1], m[34-1], m[35-1], costing);
            LPXOR(m[24-1], m[25-1], m[36-1]);
            LPXOR(m[21-1], m[29-1], m[37-1]);
            LPXOR(m[32-1], m[33-1], m[38-1]);
            LPXOR(m[23-1], m[30-1], m[39-1]);
            LPXOR(m[35-1], m[36-1], m[40-1]);
            LPXOR(m[38-1], m[40-1], m[41-1]);
            LPXOR(m[37-1], m[39-1], m[42-1]);
            LPXOR(m[37-1], m[38-1], m[43-1]);
            LPXOR(m[39-1], m[40-1], m[44-1]);
            LPXOR(m[42-1], m[41-1], m[45-1]);
            LPAND(m[44-1], t[6-1], m[46-1], costing);
            LPAND(m[40-1], t[8-1], m[47-1], costing);
            LPAND(m[39-1], u[7], m[48-1], costing);
            LPAND(m[43-1], t[16-1], m[49-1], costing);
            LPAND(m[38-1], t[9-1], m[50-1], costing);
            LPAND(m[37-1], t[17-1], m[51-1], costing);
            LPAND(m[42-1], t[15-1], m[52-1], costing);
            LPAND(m[45-1], t[27-1], m[53-1], costing);
            LPAND(m[41-1], t[10-1], m[54-1], costing);
            LPAND(m[44-1], t[13-1], m[55-1], costing);
            LPAND(m[40-1], t[23-1], m[56-1], costing);
            LPAND(m[39-1], t[19-1], m[57-1], costing);
            LPAND(m[43-1], t[3-1], m[58-1], costing);
            LPAND(m[38-1], t[22-1], m[59-1], costing);
            LPAND(m[37-1], t[20-1], m[60-1], costing);
            LPAND(m[42-1], t[1-1], m[61-1], costing);
            LPAND(m[45-1], t[4-1], m[62-1], costing);
            LPAND(m[41-1], t[2-1], m[63-1], costing);

            LPXOR(m[61-1], m[62-1], l[0]);
            LPXOR(m[50-1], m[56-1], l[1]);
            LPXOR(m[46-1], m[48-1], l[2]);
            LPXOR(m[47-1], m[55-1], l[3]);
            LPXOR(m[54-1], m[58-1], l[4]);
            LPXOR(m[49-1], m[61-1], l[5]);
            LPXOR(m[62-1], l[5], l[6]);
            LPXOR(m[46-1], l[3], l[7]);
            LPXOR(m[51-1], m[59-1], l[8]);
            LPXOR(m[52-1], m[53-1], l[9]);
            LPXOR(m[53-1], l[4], l[10]);
            LPXOR(m[60-1], l[2], l[11]);
            LPXOR(m[48-1], m[51-1], l[12]);
            LPXOR(m[50-1], l[0], l[13]);
            LPXOR(m[52-1], m[61-1], l[14]);
            LPXOR(m[55-1], l[1], l[15]);
            LPXOR(m[56-1], l[0], l[16]);
            LPXOR(m[57-1], l[1], l[17]);
            LPXOR(m[58-1], l[8], l[18]);
            LPXOR(m[63-1], l[4], l[19]);
            LPXOR(l[0], l[1], l[20]);
            LPXOR(l[1], l[7], l[21]);
            LPXOR(l[3], l[12], l[22]);
            LPXOR(l[18], l[2], l[23]);
            LPXOR(l[15], l[9], l[24]);
            LPXOR(l[6], l[10], l[25]);
            LPXOR(l[7], l[9], l[26]);
            LPXOR(l[8], l[10], l[27]);
            LPXOR(l[11], l[14], l[28]);
            LPXOR(l[11], l[17], l[29]);
        }
        adjoint auto;
    }

    // test "s-box" used to force T-depth n per round
    operation DummySBox(input: Qubit[], output: Qubit[], n: Int) : Unit
    {
        body (...)
        {
            for (i in 1..n)
            {
                T(input[0]);
                T(input[1]);
                T(input[2]);
                T(input[3]);
                T(input[4]);
                T(input[5]);
                T(input[6]);
                T(input[7]);

                T(output[0]);
                T(output[1]);
                T(output[2]);
                T(output[3]);
                T(output[4]);
                T(output[5]);
                T(output[6]);
                T(output[7]);

                CNOT(input[0], input[1]);
                CNOT(input[1], input[2]);
                CNOT(input[2], input[3]);
                CNOT(input[3], input[4]);
                CNOT(input[4], input[5]);
                CNOT(input[5], input[6]);
                CNOT(input[6], input[7]);
                CNOT(input[7], output[0]);
                CNOT(output[0], output[1]);
                CNOT(output[1], output[2]);
                CNOT(output[2], output[3]);
                CNOT(output[3], output[4]);
                CNOT(output[4], output[5]);
                CNOT(output[5], output[6]);
                CNOT(output[6], output[7]);
            }
        }
        adjoint auto;
    }

    operation SBox (input: Qubit[], output: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            using ((t, m, l) = (Qubit[27], Qubit[63], Qubit[30]))
            {
                let u = input[7..(-1)..0];
                let s = output[7..(-1)..0];

                ForwardSBox(u, s, t, m, l, costing);

                // get out result
                LPXOR(l[6], l[24], s[0]);
                LPXNOR(l[16], l[26], s[1]);
                LPXNOR(l[19], l[28], s[2]);
                LPXOR(l[6], l[21], s[3]);
                LPXOR(l[20], l[22], s[4]);
                LPXOR(l[25], l[29], s[5]);
                LPXNOR(l[13], l[27], s[6]);
                LPXNOR(l[6], l[23], s[7]);

                // uncompute
                (Adjoint ForwardSBox)(u, s, t, m, l, costing);
             
                // // dummy, forced-T-depth 2 s-box
                // DummySBox(input, output, 2);
            }
        }
        adjoint auto;
    }
}
