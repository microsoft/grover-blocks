// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
using System;
using System.Diagnostics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

static class Utilities
{
    public static int[] Bits(int x)
    {
        Trace.Assert(x < 256);
        Trace.Assert(x >= 0);
        int[] bits = new int[8];

        for (int i = 0; i < 8; i++)
        {
            bits[i] = (x & (1 << i)) > 0 ? 1 : 0;
        }

        return bits;
    }

    public static QArray<bool> nBits(int n, bool val)
    {
        bool[] bits = new bool[n];

        for (int i = 0; i < n; i++)
        {
            bits[i] = val;
        }

        return new QArray<bool>(bits);
    }

    public static QArray<Result> QBits(int x)
    {
        return new QArray<Result>(Bits(x));
    }

    public static QArray<Result> nQBits(int n, bool val)
    {
        int[] bits = new int[n];
        for (int i = 0; i < n; i++)
        {
            bits[i] = val ? 1 : 0;
        }
        return new QArray<Result>(bits);
    }

    public static void PrintBits(bool[] bits)
    {
        for (int i = 8; i > 0; i--)
        {
            Console.Write("{0:d}", bits[i - 1]);
        }
        Console.Write("\n");
    }

    public static void PrintBits(int[] bits)
    {
        for (int i = 8; i > 0; i--)
        {
            Console.Write("{0:d}", bits[i - 1]);
        }
        Console.Write("\n");
    }

    public static void PrintBits(IQArray<long> bits)
    {
        for (int i = 8; i > 0; i--)
        {
            Console.Write("{0:d}", bits[i - 1]);
        }
        Console.Write("\n");
    }

    public static void PrintBits(IQArray<Result> bits)
    {
        for (int i = 8; i > 0; i--)
        {
            Console.Write("{0:d}", bits[i - 1]);
        }
        Console.Write("\n");
    }

    public static void PrintBits(IQArray<Boolean> bits)
    {
        bool t;
        t = bits[0];
        for (int i = 8; i > 0; i--)
        {
            Console.Write("{0:d}", bits[i - 1]);
        }
        Console.Write("\n");
    }
}