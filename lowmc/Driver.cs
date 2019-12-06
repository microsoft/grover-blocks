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

            Estimates.SBox<QLowMC.InPlace.SBox>("in_place = true", true, free_swaps);
            Estimates.SBox<QLowMC.SBox>("in_place = false", false, free_swaps);
            Estimates.SBoxLayer<QLowMC.SBoxLayer>("in_place = false - L0", 32, 10, false, free_swaps);
            Estimates.SBoxLayer<QLowMC.InPlace.SBoxLayer>("in_place = true - L0", 32, 10, true, free_swaps);
            Estimates.SBoxLayer<QLowMC.SBoxLayer>("in_place = false - L1", 128, 10, false, free_swaps);
            Estimates.SBoxLayer<QLowMC.InPlace.SBoxLayer>("in_place = true - L1", 128, 10, true, free_swaps);
            Estimates.SBoxLayer<QLowMC.SBoxLayer>("in_place = false - L3", 192, 10, false, free_swaps);
            Estimates.SBoxLayer<QLowMC.InPlace.SBoxLayer>("in_place = true - L3", 192, 10, true, free_swaps);
            Estimates.SBoxLayer<QLowMC.SBoxLayer>("in_place = false - L5", 256, 10, false, free_swaps);
            Estimates.SBoxLayer<QLowMC.InPlace.SBoxLayer>("in_place = true - L5", 256, 10, true, free_swaps);

            // L0 toy category -- for development only
            for (int round = 0; round <= 10; round++)
            {
                int category = 0;
                int blocksize = 32;
                Estimates.KeyExpansion<QLowMC.InPlace.L0.KeyExpansion>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps, $"_r{round}");
                if (round > 0)
                {
                    Estimates.AffineLayer<QLowMC.InPlace.L0.AffineLayer>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps, $"_r{round}");
                    Estimates.Round<QLowMC.Round>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                }
            }

            // category 1
            for (int round = 0; round <= 20; round++)
            {
                int category = 1;
                int blocksize = 128;
                Estimates.KeyExpansion<QLowMC.InPlace.L1.KeyExpansion>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                if (round > 0)
                {
                    Estimates.AffineLayer<QLowMC.InPlace.L1.AffineLayer>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                    Estimates.Round<QLowMC.Round>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                }
            }

            // category 3
            for (int round = 0; round <= 30; round++)
            {
                int category = 3;
                int blocksize = 192;
                Estimates.KeyExpansion<QLowMC.InPlace.L3.KeyExpansion>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                if (round > 0)
                {
                    Estimates.AffineLayer<QLowMC.InPlace.L3.AffineLayer>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                    Estimates.Round<QLowMC.Round>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                }
            }

            // category 5
            for (int round = 0; round <= 38; round++)
            {
                int category = 5;
                int blocksize = 256;
                Estimates.KeyExpansion<QLowMC.InPlace.L5.KeyExpansion>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                if (round > 0)
                {
                    Estimates.AffineLayer<QLowMC.InPlace.L5.AffineLayer>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                    Estimates.Round<QLowMC.Round>($"in_place = true - L{category} - round {round}", round, blocksize, category, free_swaps);
                }
            }

            Estimates.Encrypt<QLowMC.Encrypt>("L0", 32, 0, free_swaps, "_l0");
            Estimates.Encrypt<QLowMC.Encrypt>("L1", 128, 1, free_swaps, "_l1");
            Estimates.Encrypt<QLowMC.Encrypt>("L3", 192, 3, free_swaps, "_l3");
            Estimates.Encrypt<QLowMC.Encrypt>("L5", 256, 5, free_swaps, "_l5");

            Estimates.GroverOracle<QLowMC.GroverOracle>("L0 - 1 pair", 32, 1, 0, free_swaps, "_l0_r1");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L1 - 1 pair", 128, 1, 1, free_swaps, "_l1_r1");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L3 - 1 pair", 192, 1, 3, free_swaps, "_l3_r1");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L5 - 1 pair", 256, 1, 5, free_swaps, "_l5_r1");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L0 - 2 pairs", 32, 2, 0, free_swaps, "_l0_r2");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L1 - 2 pairs", 128, 2, 1, free_swaps, "_l1_r2");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L3 - 2 pairs", 192, 2, 3, free_swaps, "_l3_r2");
            Estimates.GroverOracle<QLowMC.GroverOracle>("L5 - 2 pairs", 256, 2, 5, free_swaps, "_l5_r2");

            Console.WriteLine();
        }
    }
}