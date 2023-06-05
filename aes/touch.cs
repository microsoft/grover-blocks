// // Functions to run an operation several times and write timing data to a file or console

// using System;
// using System.Collections.Generic;
// using System.Runtime.InteropServices;
// using System.Text;
// using Microsoft.Quantum.Simulation.Simulators;
// using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
// using Microsoft.Quantum.Simulation.Core;
// using Microsoft.Quantum.Canon;
// using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;

// namespace Microsoft.Quantum.Canon
// {
//     public partial class Touch
//     {
//         private QCTraceSimulator simulator;
//         public class Native : Touch
//         {
//             public Native(IOperationFactory m) : base(m)
//             {
//                 simulator = m as QCTraceSimulator;
//             }
//             public override Func<IQArray<Qubit>, QVoid> __Body__ => (__in__) =>
//             {
                
//                 // (__T__ location, ICallable op, __U__ input, Int64 num_tests) = __in__;
//                 // var filename = (location is QVoid) ? "" : location.ToString();
//                 if (simulator != null)
//                 {
//                     (QCTraceSimulatorImpl)simulator.DoPrimitiveOperation((int)PrimitiveOperationsGroups.R, __in__,
//                         0, true);


//                     // ((SparseSimulatorProcessor)simulator.QuantumProcessor).BenchmarkInit(filename, op.FullName);
//                     // for (Int64 i = 0; i < num_tests; i++)
//                     // {
//                     //     ((SparseSimulatorProcessor)simulator.QuantumProcessor).StartOp(op.FullName);
//                     //     op.Apply<__V__>(input);
//                     //     ((SparseSimulatorProcessor)simulator.QuantumProcessor).EndOp();
//                     // }
//                     // ((SparseSimulatorProcessor)simulator.QuantumProcessor).BenchmarkFinalize();
//                     return QVoid.Instance;
//                 }
//                 else
//                 { // If it's another type of simulator: do nothing
                    
                  
//                 }
//             };
//         }
//     }
// }

