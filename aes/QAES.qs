// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
namespace QAES
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    operation ByteSub(input_state: Qubit[][], ancilla: Qubit[][], costing: Bool) : Unit
    {
        body (...)
        {
            for (i in 0..3)
            {
                for (j in 0..3)
                {
                    // GLRS16.SBox(input_state[j][(i*8)..((i+1)*8-1)], ancilla[j][(i*8)..((i+1)*8-1)], costing);
                    BoyarPeralta11.SBox(input_state[j][(i*8)..((i+1)*8-1)], ancilla[j][(i*8)..((i+1)*8-1)], costing);
                    // BoyarPeralta11.AdjointInverseSBox(input_state[j][(i*8)..((i+1)*8-1)], ancilla[j][(i*8)..((i+1)*8-1)], costing);
                }
            }
        }
        adjoint auto;
    }

    operation SubByte(input_word: Qubit[], ancilla: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            for (i in 0..3)
            {
                // GLRS16.SBox(input_word[(i*8)..((i+1)*8-1)], ancilla[(i*8)..((i+1)*8-1)], costing);
                BoyarPeralta11.SBox(input_word[(i*8)..((i+1)*8-1)], ancilla[(i*8)..((i+1)*8-1)], costing);
                // BoyarPeralta11.AdjointInverseSBox(input_word[(i*8)..((i+1)*8-1)], ancilla[(i*8)..((i+1)*8-1)], costing);
            }
        }
        adjoint auto;
    }
}

namespace QAES.Widest
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;
    operation AddRoundKey(state: Qubit[][], round_key: Qubit[]) : Unit
    {
        body (...)
        {
            for (j in 0..3)
            {
                for (i in 0..31)
                {
                    CNOT(round_key[j*32 + i], state[j][i]);
                }
            }
        }
        adjoint auto;
    }

    // WIDE version, does expand the whole key at the beginning
    // assumes the key is set to Zero, except for the first 4 * Nk bytes
    operation KeyExpansion(key: Qubit[], Nr: Int, Nk: Int, costing: Bool) : Unit
    {
        body (...)
        {
            // First stage of exapnsion is copying the AES key into the expanded key
            // this is unneded, we just allocate qubits for the whole expanded key
            // and load the block key in the first registers.

            // For a wide implementation, we don't care about precisely
            // tracking changes. on the other hand, we want W[i-1] and W[i-Nk]
            // to be conserved, hence can't Rot/Sub W[i] without CNOTting it into
            // a temp qubyte since the Rot operation happens in-place

            for (i in Nk..(4 * (Nr+1) - 1))
            {
                // since we can't operate SubByte in place on temp, we do it giving W[i] as output register
                // this would later be set to W[i] = W[i - Nk] ^ temp, so we can first set it to = temp, and then
                // CNOT it with W[i - Nk]

                if (i % Nk != 0 and (i % Nk != 4 or Nk <= 6))
                {
                    // W[i] = W[i-1]
                    CNOTBytes(key[((i-1)*32 + 0)..((i-1)*32 + 7)], key[(i*32 + 0)..((i)*32 + 7)]);
                    CNOTBytes(key[((i-1)*32 + 8)..((i-1)*32 + 15)], key[(i*32 + 8)..((i)*32 + 15)]);
                    CNOTBytes(key[((i-1)*32 + 16)..((i-1)*32 + 23)], key[(i*32 + 16)..((i)*32 + 23)]);
                    CNOTBytes(key[((i-1)*32 + 24)..((i-1)*32 + 31)], key[(i*32 + 24)..((i)*32 + 31)]);
                }
                else
                {
                    if (i % Nk == 0) // note this branch is executed less often when Nk = 6 than when Nk = 4, lowering the overal cost
                    {

                        // W[i] = SubByte(RotByte(W[i-1]))
                        QAES.InPlace.RotByte(key[((i-1)*32 + 0)..((i-1)*32 + 31)], costing);
                        QAES.SubByte(key[((i-1)*32 + 0)..((i-1)*32 + 31)], key[(i*32)..((i+1)*32-1)], costing);
                        (Adjoint QAES.InPlace.RotByte)(key[((i-1)*32 + 0)..((i-1)*32 + 31)], costing);

                        // W[i] ^^^= Rcon[i/Nk]; where uint8_t Rcon[11] = { 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 };
                        if (i / Nk > 0 and i / Nk < 9)
                        {
                            // flip the ((i/Nk)-1)-th bit
                            X(key[i*32 + i/Nk - 1]);
                        }
                        elif (i / Nk == 9)
                        {
                            // >>> bin(0x1b) == '0b00011011'
                            X(key[i*32 + 0]);
                            X(key[i*32 + 1]);
                            X(key[i*32 + 3]);
                            X(key[i*32 + 4]);
                        }
                        elif (i / Nk == 10)
                        {
                            // >>> bin(0x36) == '0b00110110'
                            X(key[i*32 + 1]);
                            X(key[i*32 + 2]);
                            X(key[i*32 + 4]);
                            X(key[i*32 + 5]);
                        }
                    }
                    elif (Nk > 6 and i % Nk == 4)
                    {
                        // W[i] = SubByte(W[i-1]);
                        QAES.SubByte(key[(i-1)*32..((i)*32-1)], key[i*32..((i+1)*32-1)], costing);
                    }
                }

                // W[i] ^^^= W[i - Nk]
                CNOTBytes(key[((i-Nk) * 32 + 0)..((i-Nk) * 32 + 7)], key[(i*32 + 0)..(i*32 + 7)]);
                CNOTBytes(key[((i-Nk) * 32 + 8)..((i-Nk) * 32 + 15)], key[(i*32 + 8)..(i*32 + 15)]);
                CNOTBytes(key[((i-Nk) * 32 + 16)..((i-Nk) * 32 + 23)], key[(i*32 + 16)..(i*32 + 23)]);
                CNOTBytes(key[((i-Nk) * 32 + 24)..((i-Nk) * 32 + 31)], key[(i*32 + 24)..(i*32 + 31)]);
            }
        }
        adjoint auto;
    }

    // round values start from 1 to Nr-1, since the final round Nr has a different shape
    operation Round(in_state: Qubit[][], out_state: Qubit[][], key: Qubit[], round: Int, costing: Bool) : Unit
    {
        body (...)
        {
            QAES.ByteSub(in_state, out_state, costing);
            QAES.InPlace.ShiftRow(out_state, costing);
            QAES.InPlace.MixColumn(out_state, costing);
            AddRoundKey(out_state, key[(4*(round)*32)..(4*(round+1)*32-1)]);
        }
        adjoint auto;
    }

    operation FinalRound(in_state: Qubit[][], out_state: Qubit[][], key: Qubit[], Nr: Int, costing: Bool) : Unit
    {
        body (...)
        {
            QAES.ByteSub(in_state, out_state, costing);
            QAES.InPlace.ShiftRow(out_state, costing);
            AddRoundKey(out_state, key[(4*(Nr)*32)..(4*(Nr+1)*32-1)]);
        }
        adjoint auto;
    }


    // WIDE version
    // assumes the expanded_key is set to Zero, except for the first 4 * Nk bytes
    // assumes the state is set to Zero, except for the first 4 words containing the message
    operation ForwardRijndael(expanded_key: Qubit[], state: Qubit[], ciphertext: Qubit[], Nr: Int, Nk: Int, costing: Bool) : Unit
    {
        body (...)
        {
            KeyExpansion(expanded_key, Nr, Nk, costing);

            // "round 0"
            AddRoundKey([
                    state[(0*32)..(1*32-1)],
                    state[(1*32)..(2*32-1)],
                    state[(2*32)..(3*32-1)],
                    state[(3*32)..(4*32-1)]
                ], expanded_key[0..(4*32)]);

            for (i in 1..(Nr-1))
            {
                // round i \in [1..Nr-1]
                Round([
                    state[(4*32*(i-1) + 0*32)..(4*32*(i-1) + 1*32 - 1)],
                    state[(4*32*(i-1) + 1*32)..(4*32*(i-1) + 2*32 - 1)],
                    state[(4*32*(i-1) + 2*32)..(4*32*(i-1) + 3*32 - 1)],
                    state[(4*32*(i-1) + 3*32)..(4*32*(i-1) + 4*32 - 1)]
                ], [
                    state[(4*32*i + 0*32)..(4*32*i + 1*32 - 1)],
                    state[(4*32*i + 1*32)..(4*32*i + 2*32 - 1)],
                    state[(4*32*i + 2*32)..(4*32*i + 3*32 - 1)],
                    state[(4*32*i + 3*32)..(4*32*i + 4*32 - 1)]
                ], expanded_key, i, costing);
            }

            // final round
            FinalRound([
                    state[(4*32*(Nr-1) + 0*32)..(4*32*(Nr-1) + 1*32 - 1)],
                    state[(4*32*(Nr-1) + 1*32)..(4*32*(Nr-1) + 2*32 - 1)],
                    state[(4*32*(Nr-1) + 2*32)..(4*32*(Nr-1) + 3*32 - 1)],
                    state[(4*32*(Nr-1) + 3*32)..(4*32*(Nr-1) + 4*32 - 1)]
                ], [
                    state[(4*32*Nr + 0*32)..(4*32*Nr + 1*32 - 1)],
                    state[(4*32*Nr + 1*32)..(4*32*Nr + 2*32 - 1)],
                    state[(4*32*Nr + 2*32)..(4*32*Nr + 3*32 - 1)],
                    state[(4*32*Nr + 3*32)..(4*32*Nr + 4*32 - 1)]
                ], expanded_key, Nr, costing);
        }
        adjoint auto;
    }

    operation Rijndael(expanded_key: Qubit[], state: Qubit[], ciphertext: Qubit[], Nr: Int, Nk: Int, costing: Bool) : Unit
    {
        body (...)
        {
            ForwardRijndael(expanded_key, state, ciphertext, Nr, Nk, costing);

            // copy resulting ciphertext out
            for (j in 0..3)
            {
                CNOTBytes(state[(4*32*Nr + j*32)..(4*32*Nr + j*32 + 7)], ciphertext[(j*32 + 0)..(j*32 + 7)]);
                CNOTBytes(state[(4*32*Nr + j*32 + 8)..(4*32*Nr + j*32 + 15)], ciphertext[(j*32 + 8)..(j*32 + 15)]);
                CNOTBytes(state[(4*32*Nr + j*32 + 16)..(4*32*Nr + j*32 + 23)], ciphertext[(j*32 + 16)..(j*32 + 23)]);
                CNOTBytes(state[(4*32*Nr + j*32 + 24)..(4*32*Nr + j*32 + 31)], ciphertext[(j*32 + 24)..(j*32 + 31)]);
            }

            (Adjoint ForwardRijndael)(expanded_key, state, ciphertext, Nr, Nk, costing);
        }
        adjoint auto;
    }
}

namespace QAES.SmartWide
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open QUtilities;

    // round values start from 1 to Nr-1, since the final round Nr has a different shape
    operation Round(in_state: Qubit[][], out_state: Qubit[][], key: Qubit[], round: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Unit
    {
        body (...)
        {
            QAES.ByteSub(in_state, out_state[0..3], costing);
            QAES.InPlace.ShiftRow(out_state, costing);
            if (in_place_mixcolumn)
            {
                QAES.InPlace.MixColumn(out_state, costing);
            }
            else
            {
                MaximovMixColumn.MixColumn(out_state[0..3], out_state[4..7], 0, 3, costing);
            }

            if (Nk == 4)
            {
                // AES128
                QAES.InPlace.KeyExpansion(key, round, Nk, 0, Nk-1, costing);
                QAES.Widest.AddRoundKey(out_state[(0 + (in_place_mixcolumn ? 0 | 4))..(3 + (in_place_mixcolumn ? 0 | 4))], key);
            }
            elif (Nk == 6)
            {
                // AES192
                if (round % 3 == 1)
                {
                    // shallowest variant found so far (if used in combination with others key_round varinats)
                    let key_round = (round/3) * 2 + 1;
                    if (round > 1)
                    {
                        QAES.InPlace.KeyExpansion(key, key_round, Nk, 2*Nk/3, Nk-1, costing);
                    }
                    QAES.InPlace.KeyExpansion(key, key_round, Nk, 0, 1, costing);
                    CNOTnBits(key[4*32..(5*32-1)], out_state[0 + (in_place_mixcolumn ? 0 | 4)], 32);
                    CNOTnBits(key[5*32..(6*32-1)], out_state[1 + (in_place_mixcolumn ? 0 | 4)], 32);
                    CNOTnBits(key[0*32..(1*32-1)], out_state[2 + (in_place_mixcolumn ? 0 | 4)], 32);
                    CNOTnBits(key[1*32..(2*32-1)], out_state[3 + (in_place_mixcolumn ? 0 | 4)], 32);
                }
                elif (round % 3 == 2)
                {
                    let key_round = (round/3) * 2 + 1;
                    QAES.InPlace.KeyExpansion(key, key_round, Nk, 2, Nk-1, costing);
                    QAES.Widest.AddRoundKey(out_state[(0 + (in_place_mixcolumn ? 0 | 4))..(3 + (in_place_mixcolumn ? 0 | 4))], key[2*32..(6*32-1)]);
                }
                else
                {
                    let key_round = (round/3) * 2;
                    QAES.InPlace.KeyExpansion(key, key_round, Nk, 0, 2*Nk/3-1, costing);
                    QAES.Widest.AddRoundKey(out_state[(0 + (in_place_mixcolumn ? 0 | 4))..(3 + (in_place_mixcolumn ? 0 | 4))], key[0*32..(4*32-1)]);
                }
            }
            elif (Nk == 8)
            {
                // AES256
                if (round % 2 == 0)
                {
                    let key_round = round/2;
                    QAES.InPlace.KeyExpansion(key, key_round, Nk, 0, Nk/2-1, costing);
                    QAES.Widest.AddRoundKey(out_state[(0 + (in_place_mixcolumn ? 0 | 4))..(3 + (in_place_mixcolumn ? 0 | 4))], key[0*32..(4*32-1)]);
                }
                else
                {
                    if (round > 2)
                    {
                        let key_round = round/2;
                        QAES.InPlace.KeyExpansion(key, key_round, Nk, Nk/2, Nk-1, costing);
                    }
                    QAES.Widest.AddRoundKey(out_state[(0 + (in_place_mixcolumn ? 0 | 4))..(3 + (in_place_mixcolumn ? 0 | 4))], key[4*32..(8*32-1)]);
                }
            }
        }
        adjoint auto;
    }

    operation FinalRound(in_state: Qubit[][], out_state: Qubit[][], key: Qubit[], round: Int, Nk: Int, costing: Bool) : Unit
    {
        body (...)
        {
            QAES.ByteSub(in_state, out_state, costing);
            QAES.InPlace.ShiftRow(out_state, costing);
            if (Nk == 4)
            {
                // AES128
                // Nk == Nb, so can simply run a round of key expansion
                // for every round of AES
                QAES.InPlace.KeyExpansion(key, round, Nk, 0, Nk-1, costing);
                QAES.Widest.AddRoundKey(out_state, key);
            }
            elif (Nk == 6)
            {
                // AES192
                let key_round = (round/3) * 2;
                // note, need only first 4 words of last key round
                QAES.InPlace.KeyExpansion(key, key_round, Nk, 0, Nk-3, costing);
                QAES.Widest.AddRoundKey(out_state, key[0*32..(4*32-1)]);
            }
            elif (Nk == 8)
            {
                // AES256
                // note, need only first 4 words of last key round
                let key_round = round/2;
                QAES.InPlace.KeyExpansion(key, key_round, Nk, 0, Nk/2-1, costing);
                QAES.Widest.AddRoundKey(out_state, key[0*32..(4*32-1)]);
            }
        }
        adjoint auto;
    }

    operation ForwardRijndael(key: Qubit[], state: Qubit[], Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Unit
    {
        body (...)
        {
            // "round 0"
            QAES.Widest.AddRoundKey([
                state[(0*32)..(1*32-1)],
                state[(1*32)..(2*32-1)],
                state[(2*32)..(3*32-1)],
                state[(3*32)..(4*32-1)]
            ], key);

            for (i in 1..(Nr-1))
            {
                // round i \in [1..Nr-1]
                Round(in_place_mixcolumn ? [
                    state[(4*32*(i-1) + 0*32)..(4*32*(i-1) + 1*32 - 1)],
                    state[(4*32*(i-1) + 1*32)..(4*32*(i-1) + 2*32 - 1)],
                    state[(4*32*(i-1) + 2*32)..(4*32*(i-1) + 3*32 - 1)],
                    state[(4*32*(i-1) + 3*32)..(4*32*(i-1) + 4*32 - 1)]
                ] | [
                    state[(8*32*(i-1) + 0*32)..(8*32*(i-1) + 1*32 - 1)],
                    state[(8*32*(i-1) + 1*32)..(8*32*(i-1) + 2*32 - 1)],
                    state[(8*32*(i-1) + 2*32)..(8*32*(i-1) + 3*32 - 1)],
                    state[(8*32*(i-1) + 3*32)..(8*32*(i-1) + 4*32 - 1)]
                ], in_place_mixcolumn ? [
                    state[(4*32*i + 0*32)..(4*32*i + 1*32 - 1)],
                    state[(4*32*i + 1*32)..(4*32*i + 2*32 - 1)],
                    state[(4*32*i + 2*32)..(4*32*i + 3*32 - 1)],
                    state[(4*32*i + 3*32)..(4*32*i + 4*32 - 1)]
                ] | [
                    state[(8*32*(i-1) +  4*32)..(8*32*(i-1) +  5*32 - 1)],
                    state[(8*32*(i-1) +  5*32)..(8*32*(i-1) +  6*32 - 1)],
                    state[(8*32*(i-1) +  6*32)..(8*32*(i-1) +  7*32 - 1)],
                    state[(8*32*(i-1) +  7*32)..(8*32*(i-1) +  8*32 - 1)],
                    state[(8*32*(i-1) +  8*32)..(8*32*(i-1) +  9*32 - 1)],
                    state[(8*32*(i-1) +  9*32)..(8*32*(i-1) + 10*32 - 1)],
                    state[(8*32*(i-1) + 10*32)..(8*32*(i-1) + 11*32 - 1)],
                    state[(8*32*(i-1) + 11*32)..(8*32*(i-1) + 12*32 - 1)]
                ], key, i, Nk, in_place_mixcolumn, costing);
            }

            // final round
            FinalRound(in_place_mixcolumn ? [
                    state[(4*32*(Nr-1) + 0*32)..(4*32*(Nr-1) + 1*32 - 1)],
                    state[(4*32*(Nr-1) + 1*32)..(4*32*(Nr-1) + 2*32 - 1)],
                    state[(4*32*(Nr-1) + 2*32)..(4*32*(Nr-1) + 3*32 - 1)],
                    state[(4*32*(Nr-1) + 3*32)..(4*32*(Nr-1) + 4*32 - 1)]
                ] | [
                    state[(8*32*(Nr-1) + 0*32)..(8*32*(Nr-1) + 1*32 - 1)],
                    state[(8*32*(Nr-1) + 1*32)..(8*32*(Nr-1) + 2*32 - 1)],
                    state[(8*32*(Nr-1) + 2*32)..(8*32*(Nr-1) + 3*32 - 1)],
                    state[(8*32*(Nr-1) + 3*32)..(8*32*(Nr-1) + 4*32 - 1)]
                ], in_place_mixcolumn ? [
                    state[(4*32*Nr + 0*32)..(4*32*Nr + 1*32 - 1)],
                    state[(4*32*Nr + 1*32)..(4*32*Nr + 2*32 - 1)],
                    state[(4*32*Nr + 2*32)..(4*32*Nr + 3*32 - 1)],
                    state[(4*32*Nr + 3*32)..(4*32*Nr + 4*32 - 1)]
                ] | [
                    state[(8*32*(Nr-1) + 4*32)..(8*32*(Nr-1) + 5*32 - 1)],
                    state[(8*32*(Nr-1) + 5*32)..(8*32*(Nr-1) + 6*32 - 1)],
                    state[(8*32*(Nr-1) + 6*32)..(8*32*(Nr-1) + 7*32 - 1)],
                    state[(8*32*(Nr-1) + 7*32)..(8*32*(Nr-1) + 8*32 - 1)]
                ],
                key, Nr, Nk, costing
            );
        }
        adjoint auto;
    }

    operation Rijndael(key: Qubit[], state: Qubit[], ciphertext: Qubit[], Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Unit
    {
        body (...)
        {
            ForwardRijndael(key, state, Nr, Nk, in_place_mixcolumn, costing);

            // copy resulting ciphertext out
            CNOTnBits(in_place_mixcolumn ? state[(4*32*Nr + 0*32)..(4*32*Nr + 1*32 - 1)] | state[(8*32*(Nr-1) + 4*32)..(8*32*(Nr-1) + 5*32 - 1)], ciphertext[0..31], 32);
            CNOTnBits(in_place_mixcolumn ? state[(4*32*Nr + 1*32)..(4*32*Nr + 2*32 - 1)] | state[(8*32*(Nr-1) + 5*32)..(8*32*(Nr-1) + 6*32 - 1)], ciphertext[32..63], 32);
            CNOTnBits(in_place_mixcolumn ? state[(4*32*Nr + 2*32)..(4*32*Nr + 3*32 - 1)] | state[(8*32*(Nr-1) + 6*32)..(8*32*(Nr-1) + 7*32 - 1)], ciphertext[64..95], 32);
            CNOTnBits(in_place_mixcolumn ? state[(4*32*Nr + 3*32)..(4*32*Nr + 4*32 - 1)] | state[(8*32*(Nr-1) + 7*32)..(8*32*(Nr-1) + 8*32 - 1)], ciphertext[96..127], 32);

            (Adjoint ForwardRijndael)(key, state, Nr, Nk, in_place_mixcolumn, costing);
        }
        adjoint auto;
    }

    operation ForwardGroverOracle(other_keys: Qubit[], state_ancillas: Qubit[], key_superposition: Qubit[], success: Qubit, plaintext: Qubit[], target_ciphertext: Bool[], pairs: Int, Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Unit
    {
        body (...)
        {
            // copy loaded key
            for (i in 0..(pairs-2))
            {
                CNOTnBits(key_superposition, other_keys[(i*32*Nk)..((i+1)*32*Nk-1)], 32*Nk);
            }

            // compute AES encryption of the i-th target message
            for (i in 0..(pairs-1))
            {
                let state = plaintext[(i*128)..((i+1)*128-1)] + (in_place_mixcolumn ? state_ancillas[(i*128*Nr)..((i+1)*128*Nr-1)] | state_ancillas[(i*128*(2*Nr-1))..((i+1)*128*(2*Nr-1)-1)]);
                let key = i == 0 ? key_superposition | other_keys[((i-1)*Nk*32)..(i*Nk*32-1)];
                ForwardRijndael(key, state, Nr, Nk, in_place_mixcolumn, costing);
            }
        }
        adjoint auto;
    }

    operation GroverOracle(key_superposition: Qubit[], success: Qubit, plaintext: Qubit[], target_ciphertext: Bool[], pairs: Int, Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Unit
    {
        body (...)
        {
            using ((other_keys, state_ancillas) = (Qubit[32*Nk*(pairs-1)], Qubit[128*(in_place_mixcolumn ? Nr | (2*Nr-1))*pairs]))
            {
                ForwardGroverOracle(other_keys, state_ancillas, key_superposition, success, plaintext, target_ciphertext, pairs, Nr, Nk, in_place_mixcolumn, costing);

                // debug output
                // for (i in 0..(Length(target_ciphertext)-1))
                // {
                //     if (i == Length(target_ciphertext)/pairs)
                //     {
                //         Message("----");
                //     }
                //     Message($"{M(ciphertext[i])} = {target_ciphertext[i]}");
                // }

                mutable ciphertext = in_place_mixcolumn ? state_ancillas[(128*Nr-128)..(128*Nr-1)] | state_ancillas[128*(2*Nr-2)..(128*(2*Nr-1)-1)];
                for (i in 1..(pairs-1))
                {
                    set ciphertext = ciphertext + (in_place_mixcolumn ? state_ancillas[((i+1)*128*Nr-128)..((i+1)*128*Nr-1)] | state_ancillas[((i+1)*128*(2*Nr-1)-128)..((i+1)*128*(2*Nr-1)-1)]);
                }

                CompareQubitstring(success, ciphertext, target_ciphertext, costing);

                (Adjoint ForwardGroverOracle)(other_keys, state_ancillas, key_superposition, success, plaintext, target_ciphertext, pairs, Nr, Nk, in_place_mixcolumn, costing);
            }
        }
    }
}

namespace QAES.InPlace
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    operation ShiftRow(state: Qubit[][], costing: Bool) : Unit
    {
        body (...)
        {
            // state is an array of four columns wide one qbit
            // and long 32 qbits. each stretch of 8 qubits makes
            // one of the four qubytes of the word

            // first row stays where it is

            // second is rotated left by 1
            REWIREBytes(state[0][(8*1)..(8*2-1)], state[1][(8*1)..(8*2-1)], costing);
            REWIREBytes(state[1][(8*1)..(8*2-1)], state[2][(8*1)..(8*2-1)], costing);
            REWIREBytes(state[2][(8*1)..(8*2-1)], state[3][(8*1)..(8*2-1)], costing);

            // third is rotated left by 2
            REWIREBytes(state[0][(8*2)..(8*3-1)], state[2][(8*2)..(8*3-1)], costing);
            REWIREBytes(state[1][(8*2)..(8*3-1)], state[3][(8*2)..(8*3-1)], costing);

            // fourth is rotated left by 3
            REWIREBytes(state[2][(8*3)..(8*4-1)], state[3][(8*3)..(8*4-1)], costing);
            REWIREBytes(state[1][(8*3)..(8*4-1)], state[2][(8*3)..(8*4-1)], costing);
            REWIREBytes(state[0][(8*3)..(8*4-1)], state[1][(8*3)..(8*4-1)], costing);
        }
        adjoint auto;
    }

    operation MixWord(word: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            // U
            CNOT(word[7], word[0]);
            CNOT(word[8], word[0]);
            CNOT(word[9], word[0]);
            CNOT(word[15], word[0]);
            CNOT(word[17], word[0]);
            CNOT(word[25], word[0]);
            CNOT(word[9], word[1]);
            CNOT(word[10], word[1]);
            CNOT(word[18], word[1]);
            CNOT(word[26], word[1]);
            CNOT(word[7], word[2]);
            CNOT(word[10], word[2]);
            CNOT(word[11], word[2]);
            CNOT(word[15], word[2]);
            CNOT(word[19], word[2]);
            CNOT(word[27], word[2]);
            CNOT(word[7], word[3]);
            CNOT(word[11], word[3]);
            CNOT(word[12], word[3]);
            CNOT(word[15], word[3]);
            CNOT(word[20], word[3]);
            CNOT(word[28], word[3]);
            CNOT(word[12], word[4]);
            CNOT(word[13], word[4]);
            CNOT(word[21], word[4]);
            CNOT(word[29], word[4]);
            CNOT(word[13], word[5]);
            CNOT(word[14], word[5]);
            CNOT(word[22], word[5]);
            CNOT(word[30], word[5]);
            CNOT(word[14], word[6]);
            CNOT(word[15], word[6]);
            CNOT(word[23], word[6]);
            CNOT(word[31], word[6]);
            CNOT(word[8], word[7]);
            CNOT(word[15], word[7]);
            CNOT(word[16], word[7]);
            CNOT(word[24], word[7]);
            CNOT(word[9], word[8]);
            CNOT(word[10], word[8]);
            CNOT(word[15], word[8]);
            CNOT(word[16], word[8]);
            CNOT(word[17], word[8]);
            CNOT(word[18], word[8]);
            CNOT(word[23], word[8]);
            CNOT(word[25], word[8]);
            CNOT(word[26], word[8]);
            CNOT(word[15], word[9]);
            CNOT(word[17], word[9]);
            CNOT(word[23], word[9]);
            CNOT(word[25], word[9]);
            CNOT(word[14], word[10]);
            CNOT(word[15], word[10]);
            CNOT(word[18], word[10]);
            CNOT(word[22], word[10]);
            CNOT(word[23], word[10]);
            CNOT(word[24], word[10]);
            CNOT(word[26], word[10]);
            CNOT(word[31], word[10]);
            CNOT(word[12], word[11]);
            CNOT(word[15], word[11]);
            CNOT(word[19], word[11]);
            CNOT(word[20], word[11]);
            CNOT(word[23], word[11]);
            CNOT(word[24], word[11]);
            CNOT(word[26], word[11]);
            CNOT(word[27], word[11]);
            CNOT(word[28], word[11]);
            CNOT(word[13], word[12]);
            CNOT(word[14], word[12]);
            CNOT(word[20], word[12]);
            CNOT(word[21], word[12]);
            CNOT(word[22], word[12]);
            CNOT(word[29], word[12]);
            CNOT(word[30], word[12]);
            CNOT(word[21], word[13]);
            CNOT(word[24], word[13]);
            CNOT(word[26], word[13]);
            CNOT(word[27], word[13]);
            CNOT(word[29], word[13]);
            CNOT(word[15], word[14]);
            CNOT(word[22], word[14]);
            CNOT(word[23], word[14]);
            CNOT(word[24], word[14]);
            CNOT(word[26], word[14]);
            CNOT(word[27], word[14]);
            CNOT(word[29], word[14]);
            CNOT(word[30], word[14]);
            CNOT(word[31], word[14]);
            CNOT(word[23], word[15]);
            CNOT(word[25], word[15]);
            CNOT(word[26], word[15]);
            CNOT(word[28], word[15]);
            CNOT(word[29], word[15]);
            CNOT(word[31], word[15]);
            CNOT(word[23], word[16]);
            CNOT(word[24], word[16]);
            CNOT(word[25], word[16]);
            CNOT(word[26], word[16]);
            CNOT(word[27], word[16]);
            CNOT(word[29], word[16]);
            CNOT(word[30], word[16]);
            CNOT(word[31], word[16]);
            CNOT(word[25], word[17]);
            CNOT(word[26], word[17]);
            CNOT(word[27], word[17]);
            CNOT(word[28], word[17]);
            CNOT(word[30], word[17]);
            CNOT(word[31], word[17]);
            CNOT(word[23], word[18]);
            CNOT(word[24], word[18]);
            CNOT(word[25], word[18]);
            CNOT(word[26], word[18]);
            CNOT(word[29], word[18]);
            CNOT(word[30], word[18]);
            CNOT(word[31], word[18]);
            CNOT(word[23], word[19]);
            CNOT(word[24], word[19]);
            CNOT(word[26], word[19]);
            CNOT(word[28], word[19]);
            CNOT(word[31], word[19]);
            CNOT(word[24], word[20]);
            CNOT(word[25], word[20]);
            CNOT(word[27], word[20]);
            CNOT(word[29], word[20]);
            CNOT(word[25], word[21]);
            CNOT(word[26], word[21]);
            CNOT(word[28], word[21]);
            CNOT(word[30], word[21]);
            CNOT(word[24], word[22]);
            CNOT(word[26], word[22]);
            CNOT(word[27], word[22]);
            CNOT(word[29], word[22]);
            CNOT(word[31], word[22]);
            CNOT(word[25], word[23]);
            CNOT(word[27], word[23]);
            CNOT(word[28], word[23]);
            CNOT(word[30], word[23]);
            CNOT(word[25], word[24]);
            CNOT(word[26], word[24]);
            CNOT(word[27], word[24]);
            CNOT(word[29], word[24]);
            CNOT(word[30], word[24]);
            CNOT(word[26], word[25]);
            CNOT(word[27], word[25]);
            CNOT(word[27], word[26]);
            CNOT(word[29], word[26]);
            CNOT(word[31], word[26]);
            CNOT(word[28], word[27]);
            CNOT(word[29], word[27]);
            CNOT(word[29], word[28]);
            CNOT(word[31], word[28]);
            CNOT(word[31], word[29]);

            // L
            CNOT(word[5], word[31]);
            CNOT(word[6], word[31]);
            CNOT(word[13], word[31]);
            CNOT(word[14], word[31]);
            CNOT(word[21], word[31]);
            CNOT(word[22], word[31]);
            CNOT(word[24], word[31]);
            CNOT(word[26], word[31]);
            CNOT(word[27], word[31]);
            CNOT(word[29], word[31]);
            CNOT(word[6], word[30]);
            CNOT(word[7], word[30]);
            CNOT(word[8], word[30]);
            CNOT(word[9], word[30]);
            CNOT(word[10], word[30]);
            CNOT(word[22], word[30]);
            CNOT(word[23], word[30]);
            CNOT(word[24], word[30]);
            CNOT(word[27], word[30]);
            CNOT(word[29], word[30]);
            CNOT(word[4], word[29]);
            CNOT(word[5], word[29]);
            CNOT(word[12], word[29]);
            CNOT(word[20], word[29]);
            CNOT(word[21], word[29]);
            CNOT(word[24], word[29]);
            CNOT(word[25], word[29]);
            CNOT(word[26], word[29]);
            CNOT(word[0], word[28]);
            CNOT(word[1], word[28]);
            CNOT(word[8], word[28]);
            CNOT(word[16], word[28]);
            CNOT(word[17], word[28]);
            CNOT(word[3], word[27]);
            CNOT(word[4], word[27]);
            CNOT(word[11], word[27]);
            CNOT(word[13], word[27]);
            CNOT(word[19], word[27]);
            CNOT(word[20], word[27]);
            CNOT(word[25], word[27]);
            CNOT(word[2], word[26]);
            CNOT(word[3], word[26]);
            CNOT(word[7], word[26]);
            CNOT(word[8], word[26]);
            CNOT(word[9], word[26]);
            CNOT(word[11], word[26]);
            CNOT(word[18], word[26]);
            CNOT(word[19], word[26]);
            CNOT(word[23], word[26]);
            CNOT(word[1], word[25]);
            CNOT(word[2], word[25]);
            CNOT(word[7], word[25]);
            CNOT(word[8], word[25]);
            CNOT(word[11], word[25]);
            CNOT(word[12], word[25]);
            CNOT(word[13], word[25]);
            CNOT(word[14], word[25]);
            CNOT(word[15], word[25]);
            CNOT(word[17], word[25]);
            CNOT(word[18], word[25]);
            CNOT(word[23], word[25]);
            CNOT(word[24], word[25]);
            CNOT(word[0], word[24]);
            CNOT(word[9], word[24]);
            CNOT(word[16], word[24]);
            CNOT(word[0], word[23]);
            CNOT(word[7], word[23]);
            CNOT(word[8], word[23]);
            CNOT(word[10], word[23]);
            CNOT(word[14], word[23]);
            CNOT(word[15], word[23]);
            CNOT(word[7], word[22]);
            CNOT(word[8], word[22]);
            CNOT(word[9], word[22]);
            CNOT(word[10], word[22]);
            CNOT(word[14], word[22]);
            CNOT(word[6], word[21]);
            CNOT(word[15], word[21]);
            CNOT(word[5], word[20]);
            CNOT(word[14], word[20]);
            CNOT(word[15], word[20]);
            CNOT(word[4], word[19]);
            CNOT(word[13], word[19]);
            CNOT(word[3], word[18]);
            CNOT(word[7], word[18]);
            CNOT(word[8], word[18]);
            CNOT(word[9], word[18]);
            CNOT(word[10], word[18]);
            CNOT(word[12], word[18]);
            CNOT(word[13], word[18]);
            CNOT(word[15], word[18]);
            CNOT(word[2], word[17]);
            CNOT(word[7], word[17]);
            CNOT(word[8], word[17]);
            CNOT(word[9], word[17]);
            CNOT(word[10], word[17]);
            CNOT(word[11], word[17]);
            CNOT(word[12], word[17]);
            CNOT(word[13], word[17]);
            CNOT(word[1], word[16]);
            CNOT(word[10], word[16]);
            CNOT(word[14], word[16]);
            CNOT(word[2], word[15]);
            CNOT(word[7], word[15]);
            CNOT(word[8], word[15]);
            CNOT(word[11], word[15]);
            CNOT(word[12], word[15]);
            CNOT(word[13], word[15]);
            CNOT(word[14], word[15]);
            CNOT(word[6], word[14]);
            CNOT(word[13], word[14]);
            CNOT(word[4], word[13]);
            CNOT(word[11], word[13]);
            CNOT(word[5], word[12]);
            CNOT(word[3], word[11]);
            CNOT(word[7], word[11]);
            CNOT(word[8], word[11]);
            CNOT(word[9], word[11]);
            CNOT(word[7], word[10]);
            CNOT(word[8], word[10]);
            CNOT(word[9], word[10]);
            CNOT(word[0], word[9]);
            CNOT(word[7], word[9]);
            CNOT(word[1], word[8]);

            // P
            REWIRE(word[30], word[31], costing);
            REWIRE(word[27], word[28], costing);
            REWIRE(word[26], word[27], costing);
            REWIRE(word[25], word[26], costing);
            REWIRE(word[22], word[23], costing);
            REWIRE(word[21], word[22], costing);
            REWIRE(word[20], word[21], costing);
            REWIRE(word[19], word[20], costing);
            REWIRE(word[18], word[19], costing);
            REWIRE(word[17], word[18], costing);
            REWIRE(word[16], word[17], costing);
            REWIRE(word[12], word[13], costing);
            REWIRE(word[10], word[15], costing);
            REWIRE(word[8], word[9], costing);
            REWIRE(word[6], word[7], costing);
            REWIRE(word[5], word[6], costing);
            REWIRE(word[4], word[5], costing);
            REWIRE(word[3], word[4], costing);
            REWIRE(word[2], word[3], costing);
            REWIRE(word[1], word[2], costing);
            REWIRE(word[0], word[1], costing);
        }
        adjoint auto;
    }

    operation MixColumn(state: Qubit[][], costing: Bool) : Unit
    {
        body (...)
        {
            for (j in 0..3)
            {
                MixWord(state[j], costing);
            }
        }
        adjoint auto;
    }

    operation RotByte(word: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            for (i in 0..2)
            {
                REWIREBytes(word[(i*8)..((i+1)*8-1)], word[((i+1)*8)..((i+2)*8-1)], costing);
            }
        }
        adjoint auto;
    }

    operation KeyExpansion(key: Qubit[], kexp_round: Int, Nk: Int, first_word: Int, last_word: Int, costing: Bool) : Unit
    {
        body (...)
        {
            for (i in first_word..last_word)
            {
                if (i == 0)
                {
                    RotByte(key[(32*(Nk-1))..(32*(Nk)-1)], costing);
                    QAES.SubByte(key[(32*(Nk-1))..(32*(Nk)-1)], key[(32*(0))..(32*(1)-1)], costing);
                    (Adjoint RotByte)(key[(32*(Nk-1))..(32*(Nk)-1)], costing);

                    // W[i] ^^^= Rcon[i/Nk]; where uint8_t Rcon[11] = { 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 };
                    if (kexp_round > 0 and kexp_round < 9)
                    {
                        // flip the ((i/Nk)-1)-th bit
                        X(key[kexp_round - 1]);
                    }
                    elif (kexp_round == 9)
                    {
                        // >>> bin(0x1b) == '0b00011011'
                        X(key[0]);
                        X(key[1]);
                        X(key[3]);
                        X(key[4]);
                    }
                    elif (kexp_round == 10)
                    {
                        // >>> bin(0x36) == '0b00110110'
                        X(key[1]);
                        X(key[2]);
                        X(key[4]);
                        X(key[5]);
                    }
                }
                else
                {
                    if (Nk == 8 and i == 4)
                    {
                        QAES.SubByte(key[(32*(i-1))..(32*(i)-1)], key[(32*(i))..(32*(i+1)-1)], costing);
                    }
                    else
                    {
                        CNOTnBits(key[(32*(i-1))..(32*(i)-1)], key[(32*(i))..(32*(i+1)-1)], 32);
                    }
                }
            }
        }
        adjoint auto;
    }
}
