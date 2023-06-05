// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
using System;
using System.Collections.Generic;
using System.Globalization;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

using FileHelpers; // csv parsing

// Library that deals with making human-friendly the CSV tracer's output

namespace cswrapper
{

    public class QDecimalConverter : ConverterBase
    {
        public override object StringToField(string from)
        {
            if (from == "NaN")
            {
                return Convert.ToDecimal(-1);
            }
            else
            {
                return Decimal.Parse(from, NumberStyles.AllowExponent | NumberStyles.AllowDecimalPoint);
            }
        }
        public override string FieldToString(object fieldValue)
        {
            if (Convert.ToDecimal(fieldValue) == Convert.ToDecimal(-1))
            {
                return "NaN";
            }
            else
            {
                return ((decimal)fieldValue).ToString();
            }
        }
    }
    class DisplayCSV
    {
        public static void Depth(string csv, string line_name, bool all = false)
        {
            var engine = new FileHelperAsyncEngine<DepthCounterCSV>();
            using (engine.BeginReadString(csv))
            {
                // This wont display anything, we have dropped it
                foreach (var err in engine.ErrorManager.Errors)
                {
                    Console.WriteLine();
                    Console.WriteLine("Error on Line number: {0}", err.LineNumber);
                    Console.WriteLine("Record causing the problem: {0}", err.RecordString);
                    Console.WriteLine("Complete exception information: {0}", err.ExceptionInfo.ToString());
                }

                // The engine is IEnumerable
                foreach (DepthCounterCSV cust in engine)
                {
                    if (cust.Name == line_name || all)
                    {
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") depth avg " + cust.DepthAverage + " (variance " + cust.DepthVariance + ")");
                    }
                }
            }
        }

        public static void Width(string csv, string line_name, bool all = false)
        {
            var engine = new FileHelperAsyncEngine<WidthCounterCSV>();
            using (engine.BeginReadString(csv))
            {
                // This wont display anything, we have dropped it
                foreach (var err in engine.ErrorManager.Errors)
                {
                    Console.WriteLine();
                    Console.WriteLine("Error on Line number: {0}", err.LineNumber);
                    Console.WriteLine("Record causing the problem: {0}", err.RecordString);
                    Console.WriteLine("Complete exception information: {0}", err.ExceptionInfo.ToString());
                }

                // The engine is IEnumerable
                foreach (WidthCounterCSV cust in engine)
                {
                    if (cust.Name == line_name || all)
                    {
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") initial width avg " + cust.InputWidthAverage + " (variance " + cust.InputWidthVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") extra width avg " + cust.ExtraWidthAverage + " (variance " + cust.ExtraWidthVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") return width avg " + cust.ReturnWidthAverage + " (variance " + cust.ReturnWidthVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") borrowed width avg " + cust.BorrowedWidthAverage + " (variance " + cust.BorrowedWidthVariance + ")");
                    }
                }
            }
        }

        public static void Operations(string csv, string line_name, bool all = false)
        {
            var engine = new FileHelperAsyncEngine<OperationCounterCSV>();
            using (engine.BeginReadString(csv))
            {
                // This wont display anything, we have dropped it
                foreach (var err in engine.ErrorManager.Errors)
                {
                    Console.WriteLine();
                    Console.WriteLine("Error on Line number: {0}", err.LineNumber);
                    Console.WriteLine("Record causing the problem: {0}", err.RecordString);
                    Console.WriteLine("Complete exception information: {0}", err.ExceptionInfo.ToString());
                }

                // The engine is IEnumerable
                foreach (OperationCounterCSV cust in engine)
                {
                    if (cust.Name == line_name || all)
                    {
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") CNOT count avg " + cust.CNOTAverage + " (variance " + cust.CNOTVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") Clifford count avg " + cust.QubitCliffordAverage + " (variance " + cust.QubitCliffordVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") T count avg " + cust.TAverage + " (variance " + cust.TVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") R count avg " + cust.RAverage + " (variance " + cust.RVariance + ")");
                        Console.WriteLine(cust.Name + " (<- " + cust.Caller + ") Measure count avg " + cust.MeasureAverage + " (variance " + cust.MeasureVariance + ")");
                    }
                }
            }
        }

        public static void All(Dictionary<String, String> csv, string line_name, bool all = false)
        {
            // print results
            Depth(csv[MetricsCountersNames.depthCounter], line_name, all);
            Console.WriteLine();
            Width(csv[MetricsCountersNames.widthCounter], line_name, all);
            Console.WriteLine();
            Operations(csv[MetricsCountersNames.primitiveOperationsCounter], line_name, all);
            Console.WriteLine();
        }

        public static void CSV(Dictionary<String, String> csv, string line_name, bool display_header = false, string comment = "", bool all = false, string suffix = "")
        {
            // print results
            if (display_header)
            {
                Console.WriteLine("operation, CNOT count, 1-qubit Clifford count, T count, R count, M count, T depth, initial width, extra width, comment, ");
            }
            Console.Write($"{Environment.NewLine}{line_name}{suffix}, ");
            var countEngine = new FileHelperAsyncEngine<OperationCounterCSV>();
            using (countEngine.BeginReadString(csv[MetricsCountersNames.primitiveOperationsCounter]))
            {
                // The engine is IEnumerable
                foreach (OperationCounterCSV cust in countEngine)
                {
                    if (cust.Name == line_name || all)
                    {
                        Console.Write($"{cust.CNOTAverage}, {cust.QubitCliffordAverage}, {cust.TAverage}, {cust.RAverage}, {cust.MeasureAverage}, ");
                    }
                }
            }
            var depthEngine = new FileHelperAsyncEngine<DepthCounterCSV>();
            using (depthEngine.BeginReadString(csv[MetricsCountersNames.depthCounter]))
            {
                // The engine is IEnumerable
                foreach (DepthCounterCSV cust in depthEngine)
                {
                    if (cust.Name == line_name || all)
                    {
                        Console.Write($"{cust.DepthAverage}, ");
                    }
                }
            }
            var widthEngine = new FileHelperAsyncEngine<WidthCounterCSV>();
            using (widthEngine.BeginReadString(csv[MetricsCountersNames.widthCounter]))
            {
                // The engine is IEnumerable
                foreach (WidthCounterCSV cust in widthEngine)
                {
                    if (cust.Name == line_name || all)
                    {
                        Console.Write($"{cust.InputWidthAverage}, {cust.ExtraWidthAverage}, ");
                    }
                }
            }
            Console.Write($"{comment}, ");
        }
    }
}