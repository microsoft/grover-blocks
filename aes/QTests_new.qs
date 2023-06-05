// // Copyright (c) Microsoft Corporation.
// // Licensed under the MIT license.
// namespace QTests.GF256
// {
//     open Microsoft.Quantum.Intrinsic;
//     open Microsoft.Quantum.Canon;
//     open Microsoft.Quantum.Convert;
//     open QUtilities;

//     operation MeasureDepth() : Unit {
//         use qubits = Qubit[5] {
//             H(qubits[0]);
//             T(qubits[0]);
//             // let m = M(qubits[0]);
//             let m = Measure([PauliZ, size= 5], qubits);
//             // Microsoft.Quantum.Diagnostics.AssertMeasurementProbability([PauliZ], [qubits[0]], Zero, 0.5, "", 1e-10);

//             if m == One {
//                 T(qubits[1]);
//             } else {
//                 T(qubits[2]);
//             }
//         }
//     }

//     operation Inverse(_a: Result[], costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b) = (Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//             }

//             QGF256.Inverse(a, b, costing);

//             for i in 1..8
//             {
//                 set res w/= i-1 <- M(b[i-1]);
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//             }
//             return res;
//         }
//     }

//     operation Mul(_a: Result[], _b: Result[], unrolled : Bool, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b, c) = (Qubit[8], Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//                 Set(_b[i-1], b[i-1]);
//             }

//             if (unrolled)
//             {
//                 QGF256.UnrolledMul(a, b, c, costing);
//             }
//             else
//             {
//                 QGF256.Mul(a, b, c, costing);
//             }

//             for i in 1..8
//             {
//                 set res w/= i-1 <- M(c[i-1]);
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//                 Set(Zero, c[i-1]);
//             }
//         }
//         return res;
//     }

//     operation Square(_a: Result[], in_place: Bool, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b) = (Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//             }

//             if (in_place)
//             {
//                 QGF256.InPlace.Square(a, costing);
//             }
//             else
//             {
//                 QGF256.Square(a, b);
//             }

//             for i in 1..8
//             {
//                 if (in_place)
//                 {
//                     set res w/= i-1 <- M(a[i-1]);
//                 }
//                 else
//                 {
//                     set res w/= i-1 <- M(b[i-1]);
//                 }
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//             }
//         }
//         return res;
//     }

//     operation Fourth(_a: Result[], in_place: Bool, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b) = (Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//             }

//             if (in_place)
//             {
//                 QGF256.InPlace.Fourth(a, costing);
//             }
//             else
//             {
//                 QGF256.Fourth(a, b);
//             }

//             for i in 1..8
//             {
//                 if (in_place)
//                 {
//                     set res w/= i-1 <- M(a[i-1]);
//                 }
//                 else
//                 {
//                     set res w/= i-1 <- M(b[i-1]);
//                 }
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//             }
//         }
//         return res;
//     }

//     operation Sixteenth(_a: Result[], costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b) = (Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//             }

//             QGF256.Sixteenth(a, b, costing);

//             for i in 1..8
//             {
//                 set res w/= i-1 <- M(b[i-1]);
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//             }
//         }
//         return res;
//     }

//     operation SixtyFourth(_a: Result[], in_place: Bool, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b) = (Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//             }

//             if (in_place)
//             {
//                 QGF256.InPlace.SixtyFourth(a, costing);
//             }
//             else
//             {
//                 // not implemented
//                 // QGF256.SixtyFourth(a, b);
//             }

//             for i in 1..8
//             {
//                 if (in_place)
//                 {
//                     set res w/= i-1 <- M(a[i-1]);
//                 }
//                 else
//                 {
//                     set res w/= i-1 <- M(b[i-1]);
//                 }
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//             }
//         }
//         return res;
//     }
// }

// namespace QTests.AES
// {
//     open Microsoft.Quantum.Intrinsic;
//     open Microsoft.Quantum.Canon;
//     open Microsoft.Quantum.Convert;
//     open QUtilities;

//     operation SBox(_a: Result[], tower_field: Bool, LPS19: Bool, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 8];
//         use (a, b) = (Qubit[8], Qubit[8])
//         {
//             for i in 1..8
//             {
//                 Set(_a[i-1], a[i-1]);
//             }

//             if (LPS19)
//             {
//                 LPS19.SBox(a, b, costing);
//             }
//             else
//             {
//                 if (tower_field)
//                 {   
//                     BoyarPeralta11.SBox(a, b, [], costing);
//                 }
//                 else
//                 {
//                     GLRS16.SBox(a, b, costing);
//                 }
//             }

//             for i in 1..8
//             {
//                 set res w/= i-1 <- M(b[i-1]);
//             }

//             // cleanup
//             for i in 1..8
//             {
//                 Set(Zero, a[i-1]);
//                 Set(Zero, b[i-1]);
//             }
//         }
//         return res;
//     }

//     operation ShiftRow(_state: Result[], costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (state_1, state_2, state_3, state_4) = (Qubit[32], Qubit[32], Qubit[32], Qubit[32])
//         {
//             let state = [state_1, state_2, state_3, state_4];
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_state[j * 32 + i], state[j][i]);
//                 }
//             }

//             QAES.InPlace.ShiftRow(state, costing);

//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(state[0][i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(state[1][i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(state[2][i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(state[3][i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, state[j][i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     operation MixWord(_word: Result[], in_place: Bool, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 32];

//         use word = Qubit[32]
//         {
//             for i in 0..31
//             {
//                 Set(_word[i], word[i]);
//             }

//             if (in_place)
//             {
//                 QAES.InPlace.MixWord(word, costing);
//                 for i in 0..31
//                 {
//                     set res w/= i <- M(word[i]);
//                 }
//             }
//             else
//             {
//                 use output = Qubit[32]
//                 {
//                     MaximovMixColumn.MixWord(word, output);
//                     for i in 0..31
//                     {
//                         set res w/= i <- M(output[i]);
//                         Set(Zero, output[i]);
//                     }
//                 }
//             }

//             // cleanup
//             for i in 0..31
//             {
//                 Set(Zero, word[i]);
//             }
//         }
//         return res;
//     }

//     operation MixColumn(_state: Result[], in_place: Bool, costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (state_1, state_2, state_3, state_4) = (Qubit[32], Qubit[32], Qubit[32], Qubit[32])
//         {
//             let state = [state_1, state_2, state_3, state_4];
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_state[j * 32 + i], state[j][i]);
//                 }
//             }

//             if (in_place)
//             {
//                 QAES.InPlace.MixColumn(state, costing);
//                 for i in 0..31
//                 {
//                     set res_1 w/= i <- M(state[0][i]);
//                 }

//                 for i in 0..31
//                 {
//                     set res_2 w/= i <- M(state[1][i]);
//                 }

//                 for i in 0..31
//                 {
//                     set res_3 w/= i <- M(state[2][i]);
//                 }

//                 for i in 0..31
//                 {
//                     set res_4 w/= i <- M(state[3][i]);
//                 }
//             }
//             else
//             {
//                 use (out_1, out_2, out_3, out_4) = (Qubit[32], Qubit[32], Qubit[32], Qubit[32])
//                 {
//                     MaximovMixColumn.MixColumn(state, [out_1, out_2, out_3, out_4], 0, 3, costing);
//                     for i in 0..31
//                     {
//                         set res_1 w/= i <- M(out_1[i]);
//                         Set(Zero, out_1[i]);
//                     }
//                     for i in 0..31
//                     {
//                         set res_2 w/= i <- M(out_2[i]);
//                         Set(Zero, out_2[i]);
//                     }
//                     for i in 0..31
//                     {
//                         set res_3 w/= i <- M(out_3[i]);
//                         Set(Zero, out_3[i]);
//                     }
//                     for i in 0..31
//                     {
//                         set res_4 w/= i <- M(out_4[i]);
//                         Set(Zero, out_4[i]);
//                     }
//                 }
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, state[j][i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     operation ByteSub(_input_state: Result[], costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (
//                 input_state_1, input_state_2, input_state_3, input_state_4,
//                 output_state_1, output_state_2, output_state_3, output_state_4
//             ) = (
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32]
//             )
//         {
//             let input_state = [input_state_1, input_state_2, input_state_3, input_state_4];
//             let output_state = [output_state_1, output_state_2, output_state_3, output_state_4];
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_input_state[j * 32 + i], input_state[j][i]);
//                 }
//             }
//             use sBAnc = Qubit[4*4*BoyarPeralta11.SBoxAncCount()]{
//                 QAES.ByteSub(input_state, output_state, sBAnc, costing);
//             }
//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(output_state[0][i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(output_state[1][i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(output_state[2][i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(output_state[3][i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, input_state[j][i]);
//                     Set(Zero, output_state[j][i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     operation AddRoundKey(_state: Result[], _round_key: Result[]) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (
//                 state_1, state_2, state_3, state_4,
//                 round_key
//             ) = (
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[4*32]
//             )
//         {
//             let state = [state_1, state_2, state_3, state_4];
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_state[j * 32 + i], state[j][i]);
//                     Set(_round_key[j * 32 + i], round_key[32*j + i]);
//                 }
//             }

//             QAES.Widest.AddRoundKey(state, round_key);

//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(state[0][i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(state[1][i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(state[2][i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(state[3][i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, state[j][i]);
//                     Set(Zero, round_key[j*32 + i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     operation KeyExpansion(_key: Result[], Nr: Int, Nk: Int, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 32*4*(Nr+1)];

//         use key = Qubit[32*4*(Nr+1)]
//         {
//             for i in 0..(32*Nk - 1)
//             {
//                 Set(_key[i], key[i]);
//             }
//             use sbAnc = Qubit[QAES.Widest.NumberOfKeyExpansionSubBytes(Nr, Nk)*4*BoyarPeralta11.SBoxAncCount()]{
//                 QAES.Widest.KeyExpansion(key, Nr, Nk, sbAnc, costing);
//             }
//             for i in 0..(32*4*(Nr+1)-1)
//             {
//                 set res w/= i <- M(key[i]);
//             }

//             // cleanup
//             for i in 0..(32*4*(Nr+1)-1)
//             {
//                 Set(Zero, key[i]);
//             }
//         }
//         return res;
//     }

//     operation InPlacePartialKeyExpansion(_key: Result[], Nr: Int, Nk: Int, kexp_round: Int, low: Int, high: Int, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 32*4*(Nr+1)];

//         use key = Qubit[32*4*(Nr+1)]
//         {
//             for i in 0..(32*Nk - 1)
//             {
//                 Set(_key[i], key[i]);
//             }

//             QAES.InPlace.KeyExpansion(key, kexp_round, Nk, low, high, costing);

//             for i in 0..(32*4*(Nr+1)-1)
//             {
//                 set res w/= i <- M(key[i]);
//             }

//             // cleanup
//             for i in 0..(32*4*(Nr+1)-1)
//             {
//                 Set(Zero, key[i]);
//             }
//         }
//         return res;
//     }

//     operation InPlaceKeyExpansion(_key: Result[], Nr: Int, Nk: Int, costing: Bool) : Result[]
//     {
//         mutable res = [Zero, size = 32*4*(Nr+1)];

//         use (key, temp) = (Qubit[32*4*(Nr+1)], Qubit[32*Nk])
//         {
//             for i in 0..(32*Nk - 1)
//             {
//                 Set(_key[i], key[i]);
//                 Set(_key[i], temp[i]);
//             }

//             let key_rounds = (Nr+1)*4/Nk;
//             for round in 1..key_rounds
//             {
//                 QAES.InPlace.KeyExpansion(temp, round, Nk, 0, Nk/2, costing);
//                 QAES.InPlace.KeyExpansion(temp, round, Nk, Nk/2+1, Nk-1, costing);
//                 if (round < key_rounds)
//                 {
//                     CNOTnBits(temp, key[round*Nk*32..((round+1)*Nk*32-1)], Nk*32);
//                 }
//                 else
//                 {
//                     CNOTnBits(temp, key[round*Nk*32..(round*Nk*32 + 32*(4*(Nr + 1) - key_rounds * Nk)-1)], 32*(4*(Nr + 1) - key_rounds * Nk));
//                 }
//             }

//             for i in 0..(32*4*(Nr+1)-1)
//             {
//                 set res w/= i <- M(key[i]);
//             }

//             // cleanup
//             for i in 0..(32*4*(Nr+1)-1)
//             {
//                 Set(Zero, key[i]);
//             }
//             for i in 0..(32*Nk-1)
//             {
//                 Set(Zero, temp[i]);
//             }
//         }
//         return res;
//     }

//     operation Round(_state: Result[], _round_key: Result[], round: Int, smart_wide: Bool, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (
//                 in_state_1, in_state_2, in_state_3, in_state_4,
//                 out_state_1, out_state_2, out_state_3, out_state_4,
//                 out_state_5, out_state_6, out_state_7, out_state_8,
//                 round_key
//             ) = (
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[Nk*32]
//             )
//         {
//             let in_state = [in_state_1, in_state_2, in_state_3, in_state_4];
//             let out_state = [out_state_1, out_state_2, out_state_3, out_state_4, out_state_5, out_state_6, out_state_7, out_state_8];
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_state[j * 32 + i], in_state[j][i]);
//                     Set(_round_key[j * 32 + i], round_key[32*j + i]);
//                 }
//             }
//             use sBAnc = Qubit[4*4*BoyarPeralta11.SBoxAncCount()]{

//                 if (smart_wide)
//                 {
//                     QAES.SmartWide.Round(in_state, out_state, round_key, sBAnc, round, Nk, in_place_mixcolumn, costing);
//                 }
//                 else
//                 {
//                     // note in the test we use "round 0", but in practice
//                     // "round 0" consists only in copying the initial 4 words
//                     // of the expanded key onto the message, before starting rounds
//                     QAES.Widest.Round(in_state, out_state[4..7], round_key, sBAnc, 0, costing);
//                 }
//             }

//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(out_state[4][i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(out_state[5][i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(out_state[6][i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(out_state[7][i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, in_state[j][i]);
//                     Set(Zero, out_state[j][i]);
//                     Set(Zero, out_state[j+4][i]);
//                     Set(Zero, round_key[j*32 + i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     operation FinalRound(_state: Result[], _round_key: Result[], smart_wide: Bool, Nr: Int, costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (
//                 in_state_1, in_state_2, in_state_3, in_state_4,
//                 out_state_1, out_state_2, out_state_3, out_state_4,
//                 round_key
//             ) = (
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[32], Qubit[32], Qubit[32], Qubit[32],
//                 Qubit[4*32*(Nr+1)]
//             )
//         {
//             let in_state = [in_state_1, in_state_2, in_state_3, in_state_4];
//             let out_state = [out_state_1, out_state_2, out_state_3, out_state_4];
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_state[j * 32 + i], in_state[j][i]);
//                     Set(_round_key[j * 32 + i], round_key[4*32*Nr + 32*j + i]);
//                 }
//             }
//             use sBAnc = Qubit[4*4*BoyarPeralta11.SBoxAncCount()]{
//                 if (smart_wide)
//                 {
//                     QAES.SmartWide.FinalRound(in_state, out_state, round_key, sBAnc, Nr, Nr - 6, costing);
//                 }
//                 else
//                 {
//                     QAES.Widest.FinalRound(in_state, out_state, round_key, sBAnc, Nr, costing);
//                 }
//             }

//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(out_state[0][i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(out_state[1][i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(out_state[2][i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(out_state[3][i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, in_state[j][i]);
//                     Set(Zero, out_state[j][i]);
//                     Set(Zero, round_key[4*32*Nr + j*32 + i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     // WIDE
//     operation WideRijndael(_message: Result[], _key: Result[], Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (state, expanded_key, ciphertext) = ( Qubit[4*32*(Nr+1)], Qubit[4*32*(Nr+1)], Qubit[4*32])
//         {
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_message[j * 32 + i], state[j*32 + i]);
//                 }
//             }
//             for j in 0..(Nk-1)
//             {
//                 for i in 0..31
//                 {
//                     Set(_key[j * 32 + i], expanded_key[j*32 + i]);
//                 }
//             }


//             QAES.Widest.Rijndael(expanded_key, state, ciphertext, Nr, Nk, costing);

//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(ciphertext[0*32 + i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(ciphertext[1*32 + i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(ciphertext[2*32 + i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(ciphertext[3*32 + i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, state[j*32 + i]);
//                     Set(Zero, ciphertext[j*32 + i]);
//                 }
//             }
//             for j in 0..(Nk-1)
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, expanded_key[j*32 + i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }

//     // narrower
//     operation SmartWideRijndael(_message: Result[], _key: Result[], Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Result[][]
//     {
//         mutable res_1 = [Zero, size = 32];
//         mutable res_2 = [Zero, size = 32];
//         mutable res_3 = [Zero, size = 32];
//         mutable res_4 = [Zero, size = 32];

//         use (state, key, ciphertext) = ( Qubit[4*32*(in_place_mixcolumn ? Nr+1 | 2*Nr)], Qubit[Nk*32], Qubit[4*32])
//         {
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(_message[j*32 + i], state[j*32 + i]);
//                 }
//             }
//             for j in 0..(Nk-1)
//             {
//                 for i in 0..31
//                 {
//                     Set(_key[j * 32 + i], key[j*32 + i]);
//                 }
//             }

//             QAES.SmartWide.Rijndael(key, state, ciphertext, Nr, Nk, in_place_mixcolumn, costing);

//             for i in 0..31
//             {
//                 set res_1 w/= i <- M(ciphertext[0*32 + i]);
//             }

//             for i in 0..31
//             {
//                 set res_2 w/= i <- M(ciphertext[1*32 + i]);
//             }

//             for i in 0..31
//             {
//                 set res_3 w/= i <- M(ciphertext[2*32 + i]);
//             }

//             for i in 0..31
//             {
//                 set res_4 w/= i <- M(ciphertext[3*32 + i]);
//             }

//             // cleanup
//             for j in 0..3
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, ciphertext[j*32 + i]);
//                 }
//             }
//             for j in 0..(4*32*(in_place_mixcolumn ? Nr+1 | 2*Nr)-1)
//             {
//                 Set(Zero, state[j]);
//             }
//             for j in 0..(Nk-1)
//             {
//                 for i in 0..31
//                 {
//                     Set(Zero, key[j*32 + i]);
//                 }
//             }
//         }
//         return [res_1, res_2, res_3, res_4];
//     }
//     // operation WideGroverOracle (_key: Result[], _plaintexts: Result[], target_ciphertext: Bool[], Nr: Int, Nk: Int, costing: Bool) : Result
//     // {
//     //     mutable res = Zero;

//     //     use (key, success, plaintext) = (Qubit[Nk*32], Qubit(), Qubit[128])
//     //     {
//     //         for i in 0..(Nk*32-1)
//     //         {
//     //             Set(_key[i], key[i]);
//     //         }
//     //         for i in 0..127
//     //         {
//     //             Set(_plaintexts[i], plaintext[i]);
//     //         }

//     //         // in actual use, we'd initialise set Success to |-), but not in this case
//     //         QAES.Widest.GroverOracle(key, success, plaintext, target_ciphertext, Nr, Nk, costing);

//     //         set res = M(success);

//     //         Set(Zero, success);
//     //         for i in 0..(Nk*32-1)
//     //         {
//     //             Set(Zero, key[i]);
//     //         }
//     //         for i in 0..127
//     //         {
//     //             Set(Zero, plaintext[i]);
//     //         }
//     //     }
//     //     return res;
//     // }

//     operation SmartWideGroverOracle (_key: Result[], _plaintexts: Result[], target_ciphertext: Bool[], pairs: Int, Nr: Int, Nk: Int, in_place_mixcolumn: Bool, costing: Bool) : Result
//     {
//         mutable res = Zero;

//         use (key, success, plaintext) = (Qubit[Nk*32], Qubit(), Qubit[128*pairs])
//         {
//             for i in 0..(Nk*32-1)
//             {
//                 Set(_key[i], key[i]);
//             }
//             for j in 0..(pairs-1)
//             {
//                 for i in 0..127
//                 {
//                     Set(_plaintexts[128*j + i], plaintext[128*j + i]);
//                 }
//             }

//             // in actual use, we'd initialise set Success to |-), but not in this case
//             QAES.SmartWide.GroverOracle(key, success, plaintext, target_ciphertext, pairs, Nr, Nk, in_place_mixcolumn, costing);

//             set res = M(success);

//             Set(Zero, success);
//             for i in 0..(Nk*32-1)
//             {
//                 Set(Zero, key[i]);
//             }
//             for j in 0..(pairs-1)
//             {
//                 for i in 0..127
//                 {
//                     Set(Zero, plaintext[128*j + i]);
//                 }
//             }
//         }
//         return res;
//     }
// }

// namespace QTests.Utilities
// {
//     open Microsoft.Quantum.Intrinsic;
//     open Microsoft.Quantum.Canon;
//     open Microsoft.Quantum.Convert;
//     open QUtilities;

//     operation AND(x: Result, y: Result) : Result
//     {
//         mutable res = Zero;
//         use (a, b, c) = (Qubit(), Qubit(), Qubit())
//         {
//             Set(x, a);
//             Set(y, b);

//             QUtilities.AND(a, b, c);

//             set res = M(c);

//             // cleanup
//             Set(Zero, a);
//             Set(Zero, b);
//             Set(Zero, c);
//         }
//         return res;
//     }

//     operation ANDadj(x: Result, y: Result) : Result
//     {
//         mutable res = Zero;
//         use (a, b, c) = (Qubit(), Qubit(), Qubit())
//         {
//             Set(x, a);
//             Set(y, b);
//             Set(BoolAsResult(ResultAsBool(x) and ResultAsBool(y)), c);

//             (Adjoint QUtilities.AND)(a, b, c);

//             set res = M(c);

//             // cleanup
//             Set(Zero, a);
//             Set(Zero, b);
//             Set(Zero, c);
//         }
//         return res;
//     }
// }