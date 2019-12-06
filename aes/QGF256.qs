// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
namespace QGF256
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    /// <summary>
    /// Set res = a * b.
    /// Assumes output register to be Zeroed.
    /// </summary>
    /// <param name="a">Input register</param>
    /// <param name="b">Input register</param>
    /// <param name="res">Output register</param>
    /// <returns>Unit</returns>
    operation Mul(a : Qubit[], b: Qubit[], res: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            // construct e
            for (i in 0..6)
            {
                for (j in (i+1)..7)
                {
                    ccnot(a[j], b[8+i-j], res[i], costing);
                }
            }

            // do modulo reduction
            // U
            CNOT(res[6], res[2]);

            CNOT(res[6], res[1]);
            CNOT(res[5], res[1]);

            CNOT(res[5], res[0]);
            CNOT(res[4], res[0]);

            // L
            CNOT(res[6], res[7]);
            CNOT(res[4], res[7]);
            CNOT(res[3], res[7]);

            CNOT(res[5], res[6]);
            CNOT(res[3], res[6]);
            CNOT(res[2], res[6]);

            CNOT(res[4], res[5]);
            CNOT(res[2], res[5]);
            CNOT(res[1], res[5]);

            CNOT(res[3], res[4]);
            CNOT(res[1], res[4]);
            CNOT(res[0], res[4]);

            CNOT(res[2], res[3]);
            CNOT(res[0], res[3]);

            CNOT(res[1], res[2]);

            CNOT(res[0], res[1]);

            // compute d
            for (i in 0..7)
            {
                for (j in 0..i)
                {
                    ccnot(a[j], b[i-j], res[i], costing);
                }
            }
        }
        adjoint auto;
    }

    /// <summary>
    /// Set res = a * b.
    /// Assumes output register to be Zeroed.
    /// Unrolled version.
    /// </summary>
    /// <param name="a">Input register</param>
    /// <param name="b">Input register</param>
    /// <param name="res">Output register</param>
    /// <returns>Unit</returns>
    operation UnrolledMul(a : Qubit[], b: Qubit[], res: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            //  construct e

            ccnot(a[1], b[7], res[0], costing);
            ccnot(a[2], b[6], res[0], costing);
            ccnot(a[3], b[5], res[0], costing);
            ccnot(a[4], b[4], res[0], costing);
            ccnot(a[5], b[3], res[0], costing);
            ccnot(a[6], b[2], res[0], costing);
            ccnot(a[7], b[1], res[0], costing);

            ccnot(a[2], b[7], res[1], costing);
            ccnot(a[3], b[6], res[1], costing);
            ccnot(a[4], b[5], res[1], costing);
            ccnot(a[5], b[4], res[1], costing);
            ccnot(a[6], b[3], res[1], costing);
            ccnot(a[7], b[2], res[1], costing);

            ccnot(a[3], b[7], res[2], costing);
            ccnot(a[4], b[6], res[2], costing);
            ccnot(a[5], b[5], res[2], costing);
            ccnot(a[6], b[4], res[2], costing);
            ccnot(a[7], b[3], res[2], costing);

            ccnot(a[4], b[7], res[3], costing);
            ccnot(a[5], b[6], res[3], costing);
            ccnot(a[6], b[5], res[3], costing);
            ccnot(a[7], b[4], res[3], costing);

            ccnot(a[5], b[7], res[4], costing);
            ccnot(a[6], b[6], res[4], costing);
            ccnot(a[7], b[5], res[4], costing);

            ccnot(a[6], b[7], res[5], costing);
            ccnot(a[7], b[6], res[5], costing);

            ccnot(a[7], b[7], res[6], costing);

            // do modulo reduction
            // U
            CNOT(res[6], res[2]);

            CNOT(res[6], res[1]);
            CNOT(res[5], res[1]);

            CNOT(res[5], res[0]);
            CNOT(res[4], res[0]);

            // L
            CNOT(res[6], res[7]);
            CNOT(res[4], res[7]);
            CNOT(res[3], res[7]);

            CNOT(res[5], res[6]);
            CNOT(res[3], res[6]);
            CNOT(res[2], res[6]);

            CNOT(res[4], res[5]);
            CNOT(res[2], res[5]);
            CNOT(res[1], res[5]);

            CNOT(res[3], res[4]);
            CNOT(res[1], res[4]);
            CNOT(res[0], res[4]);

            CNOT(res[2], res[3]);
            CNOT(res[0], res[3]);

            CNOT(res[1], res[2]);

            CNOT(res[0], res[1]);

            // compute d

            ccnot(a[0], b[7], res[7], costing);
            ccnot(a[1], b[6], res[7], costing);
            ccnot(a[2], b[5], res[7], costing);
            ccnot(a[3], b[4], res[7], costing);
            ccnot(a[4], b[3], res[7], costing);
            ccnot(a[5], b[2], res[7], costing);
            ccnot(a[6], b[1], res[7], costing);
            ccnot(a[7], b[0], res[7], costing);

            ccnot(a[0], b[6], res[6], costing);
            ccnot(a[1], b[5], res[6], costing);
            ccnot(a[2], b[4], res[6], costing);
            ccnot(a[3], b[3], res[6], costing);
            ccnot(a[4], b[2], res[6], costing);
            ccnot(a[5], b[1], res[6], costing);
            ccnot(a[6], b[0], res[6], costing);

            ccnot(a[0], b[5], res[5], costing);
            ccnot(a[1], b[4], res[5], costing);
            ccnot(a[2], b[3], res[5], costing);
            ccnot(a[3], b[2], res[5], costing);
            ccnot(a[4], b[1], res[5], costing);
            ccnot(a[5], b[0], res[5], costing);

            ccnot(a[0], b[4], res[4], costing);
            ccnot(a[1], b[3], res[4], costing);
            ccnot(a[2], b[2], res[4], costing);
            ccnot(a[3], b[1], res[4], costing);
            ccnot(a[4], b[0], res[4], costing);

            ccnot(a[0], b[3], res[3], costing);
            ccnot(a[1], b[2], res[3], costing);
            ccnot(a[2], b[1], res[3], costing);
            ccnot(a[3], b[0], res[3], costing);

            ccnot(a[0], b[2], res[2], costing);
            ccnot(a[1], b[1], res[2], costing);
            ccnot(a[2], b[0], res[2], costing);

            ccnot(a[0], b[1], res[1], costing);
            ccnot(a[1], b[0], res[1], costing);

            ccnot(a[0], b[0], res[0], costing);
        }
        adjoint auto;
    }

    /// <summary>
    /// Set b = a^2.
    /// Assumes output register to be Zeroed.
    /// </summary>
    /// <param name="a">Input register</param>
    /// <param name="b">Output register</param>
    /// <returns>Unit</returns>
    operation Square(a: Qubit[], b: Qubit[]) : Unit
    {
        body (...)
        {
            CNOT(a[0], b[0]);
            CNOT(a[4], b[0]);
            CNOT(a[6], b[0]);
            CNOT(a[4], b[1]);
            CNOT(a[6], b[1]);
            CNOT(a[7], b[1]);
            CNOT(a[1], b[2]);
            CNOT(a[5], b[2]);
            CNOT(a[4], b[3]);
            CNOT(a[5], b[3]);
            CNOT(a[6], b[3]);
            CNOT(a[7], b[3]);
            CNOT(a[2], b[4]);
            CNOT(a[4], b[4]);
            CNOT(a[7], b[4]);
            CNOT(a[5], b[5]);
            CNOT(a[6], b[5]);
            CNOT(a[3], b[6]);
            CNOT(a[5], b[6]);
            CNOT(a[6], b[7]);
            CNOT(a[7], b[7]);
        }
        adjoint auto;
    }

    /// <summary>
    /// Computes b = a^4.
    /// Assumes output register to be Zeroed.
    /// </summary>
    /// <param name="a">Input register</param>
    /// <param name="b">Output register</param>
    /// <returns>Unit</returns>
    operation Fourth(a: Qubit[], b: Qubit[]) : Unit
    {
        body (...)
        {
            CNOT(a[0], b[0]);
            CNOT(a[2], b[0]);
            CNOT(a[3], b[0]);
            CNOT(a[5], b[0]);
            CNOT(a[6], b[0]);
            CNOT(a[7], b[0]);
            CNOT(a[2], b[1]);
            CNOT(a[3], b[1]);
            CNOT(a[4], b[1]);
            CNOT(a[5], b[1]);
            CNOT(a[6], b[1]);
            CNOT(a[4], b[2]);
            CNOT(a[5], b[2]);
            CNOT(a[7], b[2]);
            CNOT(a[2], b[3]);
            CNOT(a[3], b[3]);
            CNOT(a[4], b[3]);
            CNOT(a[1], b[4]);
            CNOT(a[2], b[4]);
            CNOT(a[4], b[4]);
            CNOT(a[5], b[4]);
            CNOT(a[6], b[4]);
            CNOT(a[3], b[5]);
            CNOT(a[6], b[5]);
            CNOT(a[4], b[6]);
            CNOT(a[7], b[6]);
            CNOT(a[3], b[7]);
            CNOT(a[5], b[7]);
            CNOT(a[6], b[7]);
            CNOT(a[7], b[7]);
        }
        adjoint auto;
    }

    /// <summary>
    /// Computes b = a^16.
    /// Assumes output register to be Zeroed.
    /// </summary>
    /// <param name="a">Input register</param>
    /// <param name="b">Output register</param>
    /// <returns>Unit</returns>
    operation Sixteenth(a: Qubit[], b: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            // non optimal strategy
            Fourth(a, b);
            QGF256.InPlace.Fourth(b, costing);
        }
        adjoint auto;
    }

    /// <summary>
    /// Computes b = 1/a.
    /// Assumes output register and ancillas to be Zeroed.
    /// </summary>
    /// <param name="a">Input register</param>
    /// <param name="b">Output register</param>
    /// <param name="c">Ancilla qubyte register</param>
    /// <param name="d">Ancilla qubyte register</param>
    /// <param name="e">Ancilla qubyte register</param>
    /// <returns>Unit</returns>
    operation Inverse(a: Qubit[], b: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            using ((c, d, e) = (Qubit[8], Qubit[8], Qubit[8]))
            {
                Square(a, b);                                                   // A^2 --> B
                Mul(a, b, c, costing);                                          // A*B-->C (Gives Beta_2)
                Fourth(c, d);                                                   // C^4 --> D
                Mul(c, d, e, costing);                                          // C*D-->E (Gives Beta_4)
                (Adjoint Mul)(a, b, c, costing);                                // clears line C
                QGF256.InPlace.Fourth(d, costing);                              // D^4--> D
                Mul(e, d, c, costing);
                // Mul(e, [d[0], d[5], d[4], d[2], d[1], d[3], d[6], d[7]], c); // D*E --> C (Gives Beta_6)
                Square(a, b);                                                   // clears line B
                QGF256.InPlace.SixtyFourth(a, costing);                         // A^64 --> A
                Mul(a, c, b, costing);
                QGF256.InPlace.Square(b, costing);                              // B^2 --> B **************Answer***********************************

                // Cleanup
                (Adjoint QGF256.InPlace.SixtyFourth)(a, costing);               // A^4 --> A (Gives Beta_1)
                // (Adjoint Mul)(e, [d[0], d[5], d[4], d[2], d[1], d[3], d[6], d[7]], c);
                (Adjoint Mul)(e, d, c, costing);
                Sixteenth(d, c, costing);                                       // D^16 --> C (Gives Beta_2)
                (Adjoint QGF256.InPlace.Fourth)(d, costing);                    // D^4 -- > D
                (Adjoint Mul)(c, d, e, costing);                                // E --> 0
                Fourth(c, d);                                                   // D --> 0
                Square(a, d);                                                   // A^2 --> D
                (Adjoint Mul)(a, d, c, costing);                                // C --> 0
                Square(a, d);                                                   // D --> 0
            }
        }
        adjoint auto;
    }
}

namespace QGF256.InPlace {
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    /// <summary>
    /// Computes a^2 in place.
    /// </summary>
    /// <param name="a">Input/Output register</param>
    /// <returns>Unit</returns>
    operation Square(a: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            // U
            CNOT(a[4], a[0]);
            CNOT(a[6], a[0]);
            CNOT(a[5], a[1]);
            CNOT(a[4], a[2]);
            CNOT(a[7], a[2]);
            CNOT(a[5], a[3]);
            CNOT(a[6], a[4]);
            CNOT(a[7], a[4]);
            CNOT(a[6], a[5]);
            CNOT(a[6], a[7]);

            // L
            CNOT(a[5], a[6]);
            CNOT(a[4], a[6]);

            // P
            REWIRE(a[3], a[6], costing);
            REWIRE(a[1], a[4], costing);
            REWIRE(a[2], a[4], costing);
        }
        adjoint auto;
    }

    /// <summary>
    /// Computes a^4 in place.
    /// </summary>
    /// <param name="a">Input/Output register</param>
    /// <returns>Unit</returns>
    operation Fourth(a: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            // TODO: comes straight out of matrix multiplication, may not be optimal
            // U
            CNOT(a[2], a[0]);
            CNOT(a[3], a[0]);
            CNOT(a[5], a[0]);
            CNOT(a[6], a[0]);
            CNOT(a[7], a[0]);
            CNOT(a[2], a[1]);
            CNOT(a[4], a[1]);
            CNOT(a[5], a[1]);
            CNOT(a[6], a[1]);
            CNOT(a[3], a[2]);
            CNOT(a[4], a[2]);
            CNOT(a[6], a[3]);
            CNOT(a[5], a[4]);
            CNOT(a[7], a[4]);
            CNOT(a[6], a[5]);

            // L
            CNOT(a[6], a[7]);
            CNOT(a[5], a[7]);
            CNOT(a[3], a[7]);
            CNOT(a[5], a[6]);
            CNOT(a[4], a[6]);
            CNOT(a[2], a[5]);

            // P
            // TODO: definitely not optimal
            REWIRE(a[1], a[4], costing);
            REWIRE(a[2], a[3], costing);
            REWIRE(a[2], a[5], costing);
            REWIRE(a[1], a[2], costing);
        }
        adjoint auto;
    }

    /// <summary>
    /// Computes a^64 in place.
    /// </summary>
    /// <param name="a">Input/Output register</param>
    /// <returns>Unit</returns>
    operation SixtyFourth(a: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            CNOT(a[1], a[0]);
            CNOT(a[6], a[0]);
            CNOT(a[2], a[1]);
            CNOT(a[3], a[1]);
            CNOT(a[5], a[1]);
            CNOT(a[6], a[1]);
            CNOT(a[3], a[2]);
            CNOT(a[5], a[2]);
            CNOT(a[7], a[2]);
            CNOT(a[6], a[4]);
            CNOT(a[7], a[4]);
            CNOT(a[6], a[5]);
            CNOT(a[7], a[5]);
            CNOT(a[7], a[6]);
            CNOT(a[6], a[7]);
            CNOT(a[3], a[7]);
            CNOT(a[2], a[7]);
            CNOT(a[5], a[6]);
            CNOT(a[1], a[6]);
            CNOT(a[3], a[5]);
            CNOT(a[2], a[5]);
            CNOT(a[2], a[4]);
            CNOT(a[2], a[3]);
            CNOT(a[1], a[2]);

            REWIRE(a[3], a[4], costing);
            REWIRE(a[1], a[3], costing);
        }
        adjoint auto;
    }
}

namespace GLRS16
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    operation SBox(a: Qubit[], b: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            QGF256.Inverse(a, b, costing);

            // U
            CNOT(b[4], b[0]);
            CNOT(b[5], b[0]);
            CNOT(b[6], b[0]);
            CNOT(b[7], b[0]);
            CNOT(b[4], b[1]);
            CNOT(b[5], b[2]);
            CNOT(b[6], b[3]);
            CNOT(b[7], b[4]);

            // L
            CNOT(b[2], b[7]);
            CNOT(b[3], b[7]);
            CNOT(b[4], b[7]);
            CNOT(b[1], b[6]);
            CNOT(b[2], b[6]);
            CNOT(b[3], b[6]);
            CNOT(b[3], b[5]);
            CNOT(b[4], b[5]);
            CNOT(b[0], b[4]);
            CNOT(b[1], b[4]);
            CNOT(b[2], b[4]);
            CNOT(b[3], b[4]);
            CNOT(b[0], b[3]);
            CNOT(b[1], b[3]);
            CNOT(b[2], b[3]);
            CNOT(b[0], b[2]);
            CNOT(b[1], b[2]);
            CNOT(b[0], b[1]);

            // P
            REWIRE(b[5], b[6], costing);
            REWIRE(b[6], b[7], costing);

            // Affine part
            X(b[0]);
            X(b[1]);
            X(b[5]);
            X(b[6]);
        }
        adjoint auto;
    }
}