// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Microsoft.Quantum.Simulation.Core;
using static Utilities;
using FileHelpers; // csv parsing

namespace cs
{
    class Estimates
    {
        static QCTraceSimulator getTraceSimulator(bool full_depth)
        {
            var config = new QCTraceSimulatorConfiguration();
            config.useDepthCounter = true;
            config.useWidthCounter = true;
            config.usePrimitiveOperationsCounter = true;
            config.throwOnUnconstraintMeasurement = false;

            if (full_depth)
            {
                config.gateTimes[PrimitiveOperationsGroups.CNOT] = 1;
                config.gateTimes[PrimitiveOperationsGroups.Measure] = 1; // count all one and 2 qubit measurements as depth 1
                config.gateTimes[PrimitiveOperationsGroups.QubitClifford] = 1; // qubit Clifford depth 1
            }
            return new QCTraceSimulator(config);
        }

        public static void ProcessSim<Qop>(QCTraceSimulator sim, string comment = "", bool full_depth = false, string suffix = "")
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

        public static void SBox<Qop>(string comment = "", bool in_place = false, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.SBox.Run(sim, nQBits(3, false), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.SBox.Run(sim, nQBits(3, false), in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void SBoxLayer<Qop>(string comment = "", int blocksize = 128, int sboxes = 10, bool in_place = false, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.SBoxLayer.Run(sim, nQBits(blocksize, false), blocksize, sboxes, in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.SBoxLayer.Run(sim, nQBits(blocksize, false), blocksize, sboxes, in_place, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void AffineLayer<Qop>(string comment = "", int round = 1, int blocksize = 128, int category = 1, bool free_swaps = true, string suffix = "")
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.AffineLayer.Run(sim, nQBits(blocksize, false), round, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, false, suffix);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.AffineLayer.Run(sim, nQBits(blocksize, false), round, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void KeyExpansion<Qop>(string comment = "", int round = 1, int blocksize = 128, int category = 1, bool free_swaps = true, string suffix = "")
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.KeyExpansion.Run(sim, nQBits(blocksize, false), round, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, false, suffix);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.KeyExpansion.Run(sim, nQBits(blocksize, false), round, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Round<Qop>(string comment = "", int round = 1, int blocksize = 128, int category = 1, bool free_swaps = true)
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.Round.Run(sim, nQBits(blocksize, false), nQBits(blocksize, false), round, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.Round.Run(sim, nQBits(blocksize, false), nQBits(blocksize, false), round, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void Encrypt<Qop>(string comment = "", int blocksize = 128, int category = 1, bool free_swaps = true, string suffix = "")
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.Encrypt.Run(sim, nQBits(blocksize, false), nQBits(blocksize, false), category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, false, suffix);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.Encrypt.Run(sim, nQBits(blocksize, false), nQBits(blocksize, false), category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }

        public static void GroverOracle<Qop>(string comment = "", int blocksize = 128, int pairs = 1, int category = 1, bool free_swaps = true, string suffix = "")
        {
            var sim = getTraceSimulator(false);
            var res = QTests.LowMC.GroverOracle.Run(sim, nQBits(blocksize, false), nQBits(blocksize*pairs, false), nBits(blocksize*pairs, false), pairs, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, false, suffix);
            sim = getTraceSimulator(true);
            res = QTests.LowMC.GroverOracle.Run(sim, nQBits(blocksize, false), nQBits(blocksize*pairs, false), nBits(blocksize*pairs, false), pairs, category, free_swaps).Result;
            ProcessSim<Qop>(sim, comment, true);
        }
    }
}
