// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
using System;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace cs
{
    class Driver
    {
        static void Main(string[] args)
        {
            // estimating costs

            bool free_swaps = true;

            Console.Write("operation, CNOT count, 1-qubit Clifford count, T count, R count, M count, T depth, initial width, extra width, comment, full depth");

            // GF256
            Estimates.Mul<QGF256.Mul>("unrolled = false", false, free_swaps);
            Estimates.Mul<QGF256.UnrolledMul>("unrolled = true", true, free_swaps);
            Estimates.Square<QGF256.Square>("in_place = false", false, free_swaps);
            Estimates.Square<QGF256.InPlace.Square>("in_place = true", true, free_swaps);
            Estimates.Fourth<QGF256.Fourth>("in_place = false", false, free_swaps);
            Estimates.Fourth<QGF256.InPlace.Fourth>("in_place = true", true, free_swaps);
            Estimates.Sixteenth<QGF256.Sixteenth>("in_place = false", free_swaps);
            Estimates.SixtyFourth<QGF256.InPlace.SixtyFourth>("in_place = true", free_swaps);

            // AES
            Estimates.SBox<GLRS16.SBox>("tower_field = false", false, false, free_swaps);
            // Estimates.SBox<NigelsSbox.SBox>("tower_field = true", true, free_swaps);
            Estimates.SBox<LPS19.SBox>("tower_field = true", true, true, free_swaps);
            Estimates.SBox<BoyarPeralta11.SBox>("tower_field = true", true, false, free_swaps);
            Estimates.ByteSub<QAES.ByteSub>("state size is the same for all", free_swaps);
            Estimates.ShiftRow<QAES.InPlace.ShiftRow>("in_place = true - state size is the same for all", free_swaps);
            Estimates.MixWord<QAES.InPlace.MixWord>("in_place = true", true, free_swaps);
            Estimates.MixWord<MaximovMixColumn.MixWord>("in_place = false", false, free_swaps);
            Estimates.MixColumn<QAES.InPlace.MixColumn>("widest = true - state size is the same for all", true, free_swaps);
            Estimates.MixColumn<MaximovMixColumn.MixColumn>("widest = false - state size is the same for all", false, free_swaps);
            Estimates.AddRoundKey<QAES.Widest.AddRoundKey>("widest = true - state size is the same for all", free_swaps);

            // InPlace full KeyExpansion is never run as part of the algorithms, only for tests
            // Estimates.KeyExpansion<QAES.InPlace.KeyExpansion>("in_place = true, Nr = 10, Nk = 4", true, 10, 4, free_swaps);
            // Estimates.KeyExpansion<QAES.InPlace.KeyExpansion>("in_place = true, Nr = 12, Nk = 6", true, 12, 6, free_swaps);
            // Estimates.KeyExpansion<QAES.InPlace.KeyExpansion>("in_place = true, Nr = 14, Nk = 8", true, 14, 8, free_swaps);

            // Partial key expansion is called for different sizes and in different rounds, and may have different values each time
            // AES 128
            for (int round = 1; round <= 10; round++)
            {
                Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_0^(Nk-1)$ - round {round}", 10, 4, round, 0, 3, free_swaps);
            }
            // AES 192
            for (int round = 1; round <= 12; round++)
            {
                if (round % 3 == 1)
                {
                    int key_round = (round/3) * 2 + 1;
                    if (round > 1)
                    {
                        Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_(2*Nk/3)^(Nk-1)$ - round {round}", 12, 6, key_round, 4, 5, free_swaps);
                    }
                    Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_0^(Nk/3-1)$ - round {round}", 12, 6, key_round, 0, 1, free_swaps);
                }
                else if (round % 3 == 2)
                {
                    int key_round = (round/3) * 2 + 1;
                    Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_2^(Nk-1)$ - round {round}", 12, 6, key_round, 2, 5, free_swaps);
                }
                else
                {
                    int key_round = (round/3) * 2;
                    Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_0^(2 Nk/3-1)$ - round {round}", 12, 6, key_round, 0, 3, free_swaps);
                }
            }
            // AES 256
            for (int round = 1; round <= 14; round++)
            {
                if (round % 2 == 0)
                {
                    int key_round = round/2;
                    Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_0^(Nk/2-1)$ - round {round}", 14, 8, key_round, 0, 3, free_swaps);

                }
                else
                {
                    if (round > 2)
                    {
                        int key_round = round/2;
                        Estimates.InPlacePartialKeyExpansion<QAES.InPlace.KeyExpansion>($"$KE_(Nk/2)^(Nk-1)$ - round {round}", 14, 8, key_round, 4, 7, free_swaps);
                    }
                }
            }

            Estimates.KeyExpansion<QAES.Widest.KeyExpansion>("in_place = false - Nr = 10 - Nk = 4 - not currently used", false, 10, 4, free_swaps);
            Estimates.KeyExpansion<QAES.Widest.KeyExpansion>("in_place = false - Nr = 12 - Nk = 6 - not currently used", false, 12, 6, free_swaps);
            Estimates.KeyExpansion<QAES.Widest.KeyExpansion>("in_place = false - Nr = 14 - Nk = 8 - not currently used", false, 14, 8, free_swaps);

            Estimates.Round<QAES.Widest.Round>("state size is the same for all", 0, false, 4, free_swaps);
            for (int round = 1; round <= 10; round++)
            {
                int Nk = 4;
                Estimates.Round<QAES.SmartWide.Round>($"round = {round} - Nk = {Nk} - in_place mixcolumn", round, true, Nk, true, free_swaps);
                Estimates.Round<QAES.SmartWide.Round>($"round = {round} - Nk = {Nk} - Maximov's mixcolumn", round, true, Nk, false, free_swaps);
            }
            for (int round = 1; round <= 12; round++)
            {
                int Nk = 6;
                Estimates.Round<QAES.SmartWide.Round>($"round = {round} - Nk = {Nk} - in_place mixcolumn", round, true, Nk, true, free_swaps);
                Estimates.Round<QAES.SmartWide.Round>($"round = {round} - Nk = {Nk} - Maximov's mixcolumn", round, true, Nk, false, free_swaps);
            }
            for (int round = 1; round <= 14; round++)
            {
                int Nk = 8;
                Estimates.Round<QAES.SmartWide.Round>($"round = {round} - Nk = {Nk} - in_place mixcolumn", round, true, Nk, true, free_swaps);
                Estimates.Round<QAES.SmartWide.Round>($"round = {round} - Nk = {Nk} - Maximov's mixcolumn", round, true, Nk, false, free_swaps);
            }
            Estimates.FinalRound<QAES.Widest.FinalRound>("state size is the same for all", false, 4, free_swaps);
            Estimates.FinalRound<QAES.SmartWide.FinalRound>("Nk = 4 - state size is the same for all but in-place expansion isn't", true, 4, free_swaps);
            Estimates.FinalRound<QAES.SmartWide.FinalRound>("Nk = 6 - state size is the same for all but in-place expansion isn't", true, 6, free_swaps);
            Estimates.FinalRound<QAES.SmartWide.FinalRound>("Nk = 8 - state size is the same for all but in-place expansion isn't", true, 8, free_swaps);
            Estimates.Rijndael<QAES.SmartWide.Rijndael>("smart_wide = true - Nr = 10 - Nk = 4 - in_place mixcolumn", true, 10, 4, true, free_swaps, "_128_in-place-MC");
            Estimates.Rijndael<QAES.SmartWide.Rijndael>("smart_wide = true - Nr = 12 - Nk = 6 - in_place mixcolumn", true, 12, 6, true, free_swaps, "_192_in-place-MC");
            Estimates.Rijndael<QAES.SmartWide.Rijndael>("smart_wide = true - Nr = 14 - Nk = 8 - in_place mixcolumn", true, 14, 8, true, free_swaps, "_256_in-place-MC");
            Estimates.Rijndael<QAES.SmartWide.Rijndael>("smart_wide = true - Nr = 10 - Nk = 4 - Maximov's mixcolumn", true, 10, 4, false, free_swaps, "_128_maximov-MC");
            Estimates.Rijndael<QAES.SmartWide.Rijndael>("smart_wide = true - Nr = 12 - Nk = 6 - Maximov's mixcolumn", true, 12, 6, false, free_swaps, "_192_maximov-MC");
            Estimates.Rijndael<QAES.SmartWide.Rijndael>("smart_wide = true - Nr = 14 - Nk = 8 - Maximov's mixcolumn", true, 14, 8, false, free_swaps, "_256_maximov-MC");
            Estimates.Rijndael<QAES.Widest.Rijndael>("smart_wide = false - Nr = 10 - Nk = 4", false, 10, 4, true, free_swaps, "_128_in-place-MC");
            Estimates.Rijndael<QAES.Widest.Rijndael>("smart_wide = false - Nr = 12 - Nk = 6", false, 12, 6, true, free_swaps, "_192_in-place-MC");
            Estimates.Rijndael<QAES.Widest.Rijndael>("smart_wide = false - Nr = 14 - Nk = 8", false, 14, 8, true, free_swaps, "_256_in-place-MC");

            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 10 - Nk = 4 - in_place mixcolumn - r = 1", true, 1, 10, 4, true, free_swaps, "_128_in-place-MC_r1");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 12 - Nk = 6 - in_place mixcolumn - r = 1", true, 1, 12, 6, true, free_swaps, "_192_in-place-MC_r1");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 14 - Nk = 8 - in_place mixcolumn - r = 1", true, 1, 14, 8, true, free_swaps, "_256_in-place-MC_r1");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 10 - Nk = 4 - in_place mixcolumn - r = 2", true, 2, 10, 4, true, free_swaps, "_128_in-place-MC_r2");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 12 - Nk = 6 - in_place mixcolumn - r = 2", true, 2, 12, 6, true, free_swaps, "_192_in-place-MC_r2");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 14 - Nk = 8 - in_place mixcolumn - r = 2", true, 2, 14, 8, true, free_swaps, "_256_in-place-MC_r2");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 10 - Nk = 4 - in_place mixcolumn - r = 3", true, 3, 10, 4, true, free_swaps, "_128_in-place-MC_r3");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 12 - Nk = 6 - in_place mixcolumn - r = 3", true, 3, 12, 6, true, free_swaps, "_192_in-place-MC_r3");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 14 - Nk = 8 - in_place mixcolumn - r = 3", true, 3, 14, 8, true, free_swaps, "_256_in-place-MC_r3");

            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 10 - Nk = 4 - Maximov's mixcolumn - r = 1", true, 1, 10, 4, false, free_swaps, "_128_maximov-MC_r1");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 12 - Nk = 6 - Maximov's mixcolumn - r = 1", true, 1, 12, 6, false, free_swaps, "_192_maximov-MC_r1");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 14 - Nk = 8 - Maximov's mixcolumn - r = 1", true, 1, 14, 8, false, free_swaps, "_256_maximov-MC_r1");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 10 - Nk = 4 - Maximov's mixcolumn - r = 2", true, 2, 10, 4, false, free_swaps, "_128_maximov-MC_r2");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 12 - Nk = 6 - Maximov's mixcolumn - r = 2", true, 2, 12, 6, false, free_swaps, "_192_maximov-MC_r2");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 14 - Nk = 8 - Maximov's mixcolumn - r = 2", true, 2, 14, 8, false, free_swaps, "_256_maximov-MC_r2");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 10 - Nk = 4 - Maximov's mixcolumn - r = 3", true, 3, 10, 4, false, free_swaps, "_128_maximov-MC_r3");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 12 - Nk = 6 - Maximov's mixcolumn - r = 3", true, 3, 12, 6, false, free_swaps, "_192_maximov-MC_r3");
            Estimates.GroverOracle<QAES.SmartWide.GroverOracle>("smart_wide = true - Nr = 14 - Nk = 8 - Maximov's mixcolumn - r = 3", true, 3, 14, 8, false, free_swaps, "_256_maximov-MC_r3");

            Console.WriteLine();
        }
    }
}