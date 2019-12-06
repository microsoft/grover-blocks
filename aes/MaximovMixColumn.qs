// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
// https://eprint.iacr.org/2019/833.pdf

namespace MaximovMixColumn
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;


    // x: input
    // y: output
    operation MixColumn(in_state: Qubit[][], out_state: Qubit[][], first_word: Int, last_word: Int, costing: Bool) : Unit
    {
        body (...)
        {
            for (j in first_word..last_word)
            {
                MixWord(in_state[j], out_state[j]);
            }
        }
        adjoint auto;
    }

    // x: input
    // y: output
    operation MixWord (x: Qubit[], y: Qubit[]) : Unit
    {
        // can convert from pseudocode with the following regex
        // /([a-z])([0-9]+)\s=\s([a-z])([0-9]+)\s\^\s([a-z])([0-9]+)/gm
        // LPXOR(\3[\4], \5[\6], \1[\2]);
        body (...)
        {
            using (t = Qubit[62])
            {
                LPXOR(x[15], x[23], t[0]);
                LPXOR(x[7], x[31], t[1]);
                LPXOR(x[23], x[31], t[2]);
                LPXOR(x[7], x[15], t[3]);
                LPXOR(x[6], x[14], t[4]);
                LPXOR(x[4], x[12], t[5]);
                LPXOR(x[3], x[11], t[6]);
                LPXOR(x[0], x[8], t[7]);
                LPXOR(x[13], x[21], t[8]);
                LPXOR(x[5], x[29], t[9]);
                LPXOR(x[20], x[28], t[10]);
                LPXOR(x[16], x[24], t[11]);
                LPXOR(x[19], x[27], t[12]);
                LPXOR(x[22], x[30], t[13]);
                LPXOR(x[17], x[25], t[14]);
                LPXOR(x[1], x[9], t[15]);
                LPXOR(x[10], x[18], t[16]);
                LPXOR(x[2], x[26], t[17]);
                LPXOR(x[24], t[7], t[18]);
                LPXOR(t[2], t[18], y[16]);
                LPXOR(t[1], t[18], t[19]);
                LPXOR(t[11], t[19], y[24]);
                LPXOR(x[0], t[11], t[20]);
                LPXOR(t[0], t[20], y[8]);
                LPXOR(t[3], t[7], t[21]);
                LPXOR(t[20], t[21], y[0]);
                LPXOR(x[22], t[4], t[22]);
                LPXOR(t[9], t[22], y[30]);
                LPXOR(x[6], x[7], t[23]);
                LPXOR(x[5], t[13], t[24]);
                LPXOR(x[13], t[10], t[25]);
                LPXOR(t[9], t[25], y[21]);
                LPXOR(x[26], t[16], t[26]);
                LPXOR(t[15], t[26], y[2]);
                LPXOR(x[9], t[17], t[27]);
                LPXOR(x[28], t[8], t[28]);
                LPXOR(x[25], y[2], t[29]);
                LPXOR(t[27], t[29], y[26]);
                LPXOR(t[2], t[26], t[30]);
                LPXOR(x[3], t[0], t[31]);
                LPXOR(x[19], t[6], t[32]);
                LPXOR(t[1], t[32], t[33]);
                LPXOR(t[17], t[33], y[27]);
                LPXOR(t[5], t[12], t[34]);
                LPXOR(x[27], t[30], t[35]);
                LPXOR(x[10], t[35], t[36]);
                LPXOR(t[6], t[36], y[19]);
                LPXOR(t[16], t[31], t[37]);
                LPXOR(t[12], t[37], y[11]);
                LPXOR(t[14], y[8], t[38]);
                LPXOR(t[18], t[38], t[39]);
                LPXOR(x[1], t[39], y[9]);
                LPXOR(t[29], t[30], t[40]);
                LPXOR(t[11], t[40], y[17]);
                LPXOR(x[14], t[24], t[41]);
                LPXOR(x[13], t[41], y[6]);
                LPXOR(x[29], t[8], t[42]);
                LPXOR(t[5], t[42], y[5]);
                LPXOR(x[30], t[23], t[43]);
                LPXOR(t[0], t[43], y[31]);
                LPXOR(t[2], t[4], t[44]);
                LPXOR(x[15], t[44], y[7]);
                LPXOR(x[28], t[34], t[45]);
                LPXOR(t[2], t[45], y[20]);
                LPXOR(t[1], t[13], t[46]);
                LPXOR(x[15], t[46], y[23]);
                LPXOR(y[27], t[37], t[47]);
                LPXOR(t[36], t[47], y[3]);
                LPXOR(t[14], t[17], t[48]);
                LPXOR(x[10], t[48], y[18]);
                LPXOR(x[6], t[8], t[49]);
                LPXOR(t[13], t[49], y[14]);
                LPXOR(x[21], y[30], t[50]);
                LPXOR(t[24], t[50], y[22]);
                LPXOR(x[4], x[5], t[51]);
                LPXOR(t[28], t[51], y[29]);
                LPXOR(x[22], t[23], t[52]);
                LPXOR(t[44], t[52], y[15]);
                LPXOR(t[39], y[17], t[53]);
                LPXOR(t[21], t[53], y[25]);
                LPXOR(x[17], t[27], t[54]);
                LPXOR(x[18], t[54], y[10]);
                LPXOR(x[9], t[21], t[55]);
                LPXOR(t[14], t[55], y[1]);
                LPXOR(x[12], y[21], t[56]);
                LPXOR(t[28], t[56], y[13]);
                LPXOR(t[3], t[10], t[57]);
                LPXOR(t[6], t[57], t[58]);
                LPXOR(x[12], t[58], y[4]);
                LPXOR(t[31], t[32], t[59]);
                LPXOR(x[4], t[10], t[60]);
                LPXOR(t[59], t[60], y[12]);
                LPXOR(y[20], t[58], t[61]);
                LPXOR(t[59], t[61], y[28]);

                // now need to cleanup the t array
                // everything is an XOR, fine not using Adjoint decorator
                LPXOR(y[20], t[58], t[61]);
                LPXOR(x[4], t[10], t[60]);
                LPXOR(t[31], t[32], t[59]);
                LPXOR(t[6], t[57], t[58]);
                LPXOR(t[3], t[10], t[57]);
                LPXOR(x[12], y[21], t[56]);
                LPXOR(x[9], t[21], t[55]);
                LPXOR(x[17], t[27], t[54]);
                LPXOR(t[39], y[17], t[53]);
                LPXOR(x[22], t[23], t[52]);
                LPXOR(x[4], x[5], t[51]);
                LPXOR(x[21], y[30], t[50]);
                LPXOR(x[6], t[8], t[49]);
                LPXOR(t[14], t[17], t[48]);
                LPXOR(y[27], t[37], t[47]);
                LPXOR(t[1], t[13], t[46]);
                LPXOR(x[28], t[34], t[45]);
                LPXOR(t[2], t[4], t[44]);
                LPXOR(x[30], t[23], t[43]);
                LPXOR(x[29], t[8], t[42]);
                LPXOR(x[14], t[24], t[41]);
                LPXOR(t[29], t[30], t[40]);
                LPXOR(t[18], t[38], t[39]);
                LPXOR(t[14], y[8], t[38]);
                LPXOR(t[16], t[31], t[37]);
                LPXOR(x[10], t[35], t[36]);
                LPXOR(x[27], t[30], t[35]);
                LPXOR(t[5], t[12], t[34]);
                LPXOR(t[1], t[32], t[33]);
                LPXOR(x[19], t[6], t[32]);
                LPXOR(x[3], t[0], t[31]);
                LPXOR(t[2], t[26], t[30]);
                LPXOR(x[25], y[2], t[29]);
                LPXOR(x[28], t[8], t[28]);
                LPXOR(x[9], t[17], t[27]);
                LPXOR(x[26], t[16], t[26]);
                LPXOR(x[13], t[10], t[25]);
                LPXOR(x[5], t[13], t[24]);
                LPXOR(x[6], x[7], t[23]);
                LPXOR(x[22], t[4], t[22]);
                LPXOR(t[3], t[7], t[21]);
                LPXOR(x[0], t[11], t[20]);
                LPXOR(t[1], t[18], t[19]);
                LPXOR(x[24], t[7], t[18]);
                LPXOR(x[2], x[26], t[17]);
                LPXOR(x[10], x[18], t[16]);
                LPXOR(x[1], x[9], t[15]);
                LPXOR(x[17], x[25], t[14]);
                LPXOR(x[22], x[30], t[13]);
                LPXOR(x[19], x[27], t[12]);
                LPXOR(x[16], x[24], t[11]);
                LPXOR(x[20], x[28], t[10]);
                LPXOR(x[5], x[29], t[9]);
                LPXOR(x[13], x[21], t[8]);
                LPXOR(x[0], x[8], t[7]);
                LPXOR(x[3], x[11], t[6]);
                LPXOR(x[4], x[12], t[5]);
                LPXOR(x[6], x[14], t[4]);
                LPXOR(x[7], x[15], t[3]);
                LPXOR(x[23], x[31], t[2]);
                LPXOR(x[7], x[31], t[1]);
                LPXOR(x[15], x[23], t[0]);
            }
        }
        adjoint auto;
    }
}
