// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Microsoft.Quantum.Simulation.Core;
using static Utilities;
using FileHelpers; // csv parsing

namespace cswrapper
{
    class Estimates
    {
        static QCTraceSimulator getTraceSimulator(bool full_depth)
        {
            var config = new QCTraceSimulatorConfiguration();
            config.UseDepthCounter = true;
            config.UseWidthCounter = true;
            config.UsePrimitiveOperationsCounter = true;
            config.ThrowOnUnconstrainedMeasurement = false;
            config.OptimizeDepth = false;
            if (full_depth)
            {
                config.TraceGateTimes[PrimitiveOperationsGroups.CNOT] = 1;
                config.TraceGateTimes[PrimitiveOperationsGroups.Measure] = 1; // count all one and 2 qubit measurements as depth 1
                config.TraceGateTimes[PrimitiveOperationsGroups.QubitClifford] = 1; // qubit Clifford depth 1
                config.TraceGateTimes[PrimitiveOperationsGroups.R] = 1; // rotations also get depth 1
            }
            return new ResourcesEstimator(config);
            // return new QCTraceSimulator(config);
        }



        public static void ProcessSim<Qop>(QCTraceSimulator sim, string comment = "", bool full_depth = false, string suffix="")
        {
            if (!full_depth)
            {
                DisplayCSV.CSV(sim.ToCSV(), typeof(Qop).FullName, false, comment, false, suffix);
            }
            else
            {
                // full depth only
                var depthEngine = new FileHelperAsyncEngine<DepthCounterCSV>();
                using (depthEngine.BeginReadString(sim.ToCSV()[MetricsCountersNames.depthCounter]))
                {
                    // The engine is IEnumerable
                    foreach (DepthCounterCSV cust in depthEngine)
                    {
                        if (cust.Name == typeof(Qop).FullName)
                        {
                            Console.Write($"{cust.DepthAverage}");
                        }
                    }
                }
            }
        }

        public static void DepthTest<Qop>()
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.MeasureDepth.Run(sim).Result;
            ProcessSim<Qop>(sim, "");
            sim = getTraceSimulator(true);
            res = QTests.GF256.MeasureDepth.Run(sim).Result;
            ProcessSim<Qop>(sim, "", true);
        }
         public static void AllOnesTest<Qop>()
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.TestAllOnes.Run(sim, 128, true).Result;
            ProcessSim<Qop>(sim, "");
            sim = getTraceSimulator(true);
            res = QTests.GF256.TestAllOnes.Run(sim, 128, true).Result;
            ProcessSim<Qop>(sim, "", true);
        }

        public static void Mul<Qop>(string comment = "", bool unrolled = false, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.Mul.Run(sim, QBits(0), QBits(0), unrolled, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.GF256.Mul.Run(sim, QBits(0), QBits(0), unrolled, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Square<Qop>(string comment = "", bool in_place = false, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.Square.Run(sim, QBits(0), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.GF256.Square.Run(sim, QBits(0), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Fourth<Qop>(string comment = "", bool in_place = false, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.Fourth.Run(sim, QBits(0), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.GF256.Fourth.Run(sim, QBits(0), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Sixteenth<Qop>(string comment = "", bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.Sixteenth.Run(sim, QBits(0), free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.GF256.Sixteenth.Run(sim, QBits(0), free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void SixtyFourth<Qop>(string comment = "", bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.SixtyFourth.Run(sim, QBits(0), true, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.GF256.SixtyFourth.Run(sim, QBits(0), true, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Inverse<Qop>(string comment = "", bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.GF256.Inverse.Run(sim, QBits(0), free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.GF256.Inverse.Run(sim, QBits(0), free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void SBox<Qop>(string comment = "", bool tower_field = true, bool LPS19 = false, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.SBox.Run(sim, QBits(0), tower_field, LPS19, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.SBox.Run(sim, QBits(0), tower_field, LPS19, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void ByteSub<Qop>(string comment = "", bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.ByteSub.Run(sim, nQBits(128, false), free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.ByteSub.Run(sim, nQBits(128, false), free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void ShiftRow<Qop>(string comment = "", bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.ShiftRow.Run(sim, nQBits(128, false), free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.ShiftRow.Run(sim, nQBits(128, false), free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void MixWord<Qop>(string comment = "", bool in_place = true, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.MixWord.Run(sim, nQBits(32, false), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.MixWord.Run(sim, nQBits(32, false), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void MixColumn<Qop>(string comment = "", bool in_place = true, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.MixColumn.Run(sim, nQBits(128, false), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.MixColumn.Run(sim, nQBits(128, false), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void AddRoundKey<Qop>(string comment = "", bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.AddRoundKey.Run(sim, nQBits(128, false), nQBits(128, false)).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.AddRoundKey.Run(sim, nQBits(128, false), nQBits(128, false)).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void KeyExpansion<Qop>(string comment = "", bool in_place = false, int Nr = 10, int Nk = 4, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            if (in_place)
            {
                var res = QTests.AES.InPlaceKeyExpansion.Run(sim, nQBits(32 * Nk, false), Nr, Nk, free_swaps).Result;
            }
            else
            {
                var res = QTests.AES.KeyExpansion.Run(sim, nQBits(32 * Nk, false), Nr, Nk, free_swaps).Result;
            }
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            if (in_place)
            {
                var res = QTests.AES.InPlaceKeyExpansion.Run(sim, nQBits(32 * Nk, false), Nr, Nk, free_swaps).Result;
            }
            else
            {
                var res = QTests.AES.KeyExpansion.Run(sim, nQBits(32 * Nk, false), Nr, Nk, free_swaps).Result;
            }
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void InPlacePartialKeyExpansion<Qop>(string comment = "", int Nr = 10, int Nk = 4, int kexp_round = 1, int low = 0, int high = 4, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.InPlacePartialKeyExpansion.Run(sim, nQBits(32 * Nk, false), Nr, Nk, kexp_round, low, high, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.InPlacePartialKeyExpansion.Run(sim, nQBits(32 * Nk, false), Nr, Nk, kexp_round, low, high, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Round<Qop>(string comment = "", int round = 0, bool smart_wide = false, int Nk = 4, bool in_place_mixcolumn = true, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.Round.Run(sim, nQBits(128, false), nQBits(128, false), round, smart_wide, Nk, in_place_mixcolumn, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.Round.Run(sim, nQBits(128, false), nQBits(128, false), round, smart_wide, Nk, in_place_mixcolumn, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void FinalRound<Qop>(string comment = "", bool smart_wide = false, int Nk = 4, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.AES.FinalRound.Run(sim, nQBits(128, false), nQBits(128, false), smart_wide, Nk + 6, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.AES.FinalRound.Run(sim, nQBits(128, false), nQBits(128, false), smart_wide, Nk + 6, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Rijndael<Qop>(string comment = "", bool widest = false, int Nr = 10, int Nk = 4, bool in_place_mixcolumn = true, bool free_swaps = true, string suffix = "")
        {
            // var sparseSim = new ToffoliSimulator();
            // Random rand = new Random();
            // bool[] randomValues = new bool[128];

            // for (int i = 0; i < 128; i++)
            // {
            //     randomValues[i] = rand.Next(2) == 1;
            // }
            // QTests.AES.SmartWideRijndael.Run(sparseSim, BitsToQubits(randomValues), nQBits(32 * Nk, true), Nr, Nk, in_place_mixcolumn, widest, false);

            var sim = getTraceSimulator(false);
            var res = QTests.AES.SmartWideRijndael.Run(sim, nQBits(128, false), nQBits(32 * Nk, false), Nr, Nk, in_place_mixcolumn, widest, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, false, suffix);
            sim = getTraceSimulator(true);
            res = QTests.AES.SmartWideRijndael.Run(sim, nQBits(128, false), nQBits(32 * Nk, false), Nr, Nk, in_place_mixcolumn, widest, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void GroverOracle<Qop>(string comment = "", bool widest = false, int pairs = 1, int Nr = 10, int Nk = 4, bool in_place_mixcolumn = true, bool free_swaps = true, string suffix = "")
        {
            // var sparseSim = new ToffoliSimulator();
            // Random rand = new Random();
            // bool[] randomValues = new bool[32*Nk];

            // for (int i = 0; i < 32*Nk; i++)
            // {
            //     randomValues[i] = true;//rand.Next(2) == 1;
            // }
            // var res = QTests.AES.SmartWideGroverOracle.Run(sparseSim, BitsToQubits(randomValues), nQBits(128*pairs, false), nBits(128*pairs, false), pairs, Nr, Nk, in_place_mixcolumn, widest, false).Result;

            var sim = getTraceSimulator(false);
            var res = QTests.AES.SmartWideGroverOracle.Run(sim, nQBits(32*Nk, false), nQBits(128*pairs, false), nBits(128*pairs, false), pairs, Nr, Nk, in_place_mixcolumn, widest, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, false, suffix);
            sim = getTraceSimulator(true);
            res = QTests.AES.SmartWideGroverOracle.Run(sim, nQBits(32*Nk, false), nQBits(128*pairs, false), nBits(128*pairs, false), pairs, Nr, Nk, in_place_mixcolumn, widest, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }
        // public static void WideGroverOracle<Qop>(string comment = "", int Nr = 10, int Nk = 4, bool free_swaps = true, string suffix = "")
        // {
        //     var sim = getTraceSimulator(false);
        //     var res = QTests.AES.WideGroverOracle.Run(sim, nQBits(32*Nk, false), nQBits(128, false), nBits(128, false), Nr, Nk, free_swaps).Result;
        //     ProcessSim<Qop>(sim, comment, false, suffix);
        //     sim = getTraceSimulator(true);
        //     res = QTests.AES.WideGroverOracle.Run(sim, nQBits(32*Nk, false), nQBits(128, false), nBits(128, false), Nr, Nk, free_swaps).Result;
        //     ProcessSim<Qop>(sim, comment, true);
        // }
    }
}
