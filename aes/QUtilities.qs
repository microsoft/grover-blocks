// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
namespace QUtilities
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    operation Set (desired: Result, q1: Qubit) : Unit {
        if (desired != M(q1)) {
            X(q1);
        }
    }

    operation SWAPBytes (x: Qubit[], y: Qubit[]) : Unit {
        body (...)
        {
            for (i in 0..7)
            {
                SWAP(x[i], y[i]);
            }
        }
        adjoint auto;
    }

    operation CNOTBytes (x: Qubit[], y: Qubit[]) : Unit {
        body (...)
        {
            for (i in 0..7)
            {
                CNOT(x[i], y[i]);
            }
        }
        adjoint auto;
    }

    operation CNOTnBits (x: Qubit[], y: Qubit[], n: Int) : Unit {
        body (...)
        {
            for (i in 0..(n-1))
            {
                CNOT(x[i], y[i]);
            }
        }
        adjoint auto;
    }

    operation REWIRE (x: Qubit, y: Qubit, free: Bool) : Unit {
        body (...)
        {
            if (not free)
            {
                SWAP(x, y);
            }
        }
        adjoint auto;
    }

    operation REWIREBytes (x: Qubit[], y: Qubit[], free: Bool) : Unit {
        body (...)
        {
            if (not free)
            {
                SWAPBytes(x, y);
            }
        }
        adjoint auto;
    }

    operation ccnot(x: Qubit, y: Qubit, z: Qubit, costing: Bool) : Unit {
        body (...)
        {
            if (costing)
            {
                ccnot_T_depth_1(x, y, z);
                // ccnot_7_t_depth_4(x, y, z);
            }
            else
            {
                CCNOT(x, y, z);
            }
        }
        adjoint auto;
    }

    // assumes output qubit set to Zero
    // linear-program xor equivalent to
    // bool outp = 0
    // outp = in_1 ^ in_2
    operation LPXOR (in_1: Qubit, in_2: Qubit, outp: Qubit) : Unit
    {
        body (...)
        {
            CNOT(in_1, outp);
            CNOT(in_2, outp);
        }
        adjoint auto;
    }

    // assumes outp = 0
    operation LPXNOR(in_1: Qubit, in_2: Qubit, outp: Qubit) : Unit
    {
        body (...)
        {
            LPXOR(in_1, in_2, outp);
            X(outp);
        }
        adjoint auto;
    }

    operation LPAND (in_1: Qubit, in_2: Qubit, outp: Qubit, costing: Bool) : Unit
    {
        body (...)
        {
            if (costing)
            {
                AND(in_1, in_2, outp);
            }
            else
            {
                // ccnot does not assume output bit to be set to Zero!
                ccnot(in_1, in_2, outp, costing);
            }
        }
        adjoint auto;
    }

    // --------------------------------------------------------------------------

    operation LinearPrepare(a : Qubit, b : Qubit, c : Qubit, d : Qubit) : Unit is Adj {
        CNOT(b, d);
        CNOT(c, a);
        CNOT(c, b);
        CNOT(a, d);
    }

    operation AND(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit {
        body (...) {
            using (anc = Qubit()) {
                H(target);
                LinearPrepare(control1, control2, target, anc);
                Adjoint T(control1);
                Adjoint T(control2);
                T(target);
                T(anc);
                Adjoint LinearPrepare(control1, control2, target, anc);
                H(target);
                S(target);
            }
        }
        adjoint (...) {
            H(target);
            AssertProb([PauliZ], [target], One, 0.5, "Probability of the measurement must be 0.5", 1e-10);
            if (IsResultOne(M(target))) {
                S(control1);
                S(control2);
                CNOT(control1, control2);
                Adjoint S(control2);
                CNOT(control1, control2);
                X(target);
            }
        }
    }

    // ------------------------------------------------------------------------

    // /// #Summary
    // /// Implementation of the 3 qubit Toffoli gate over the Clifford+T gate set
    // /// in T-depth 4, according to Amy et al
    // /// # Remarks
    // /// The circuit corresponding to this implementation uses 7 T gates,
    // /// 7 CNOT gates, 2 Hadamard gates and has T-depth 4.
    // /// # References
    // /// - [ *M. Amy, D. Maslov, M. Mosca, M. Roetteler*,
    // ///     IEEE Trans. CAD, 32(6): 818-830 (2013)](http://doi.org/10.1109/TCAD.2013.2244643)
    // /// # See Also
    // /// - For the circuit diagram see Figure 7 (a) on
    // ///   [Page 15 of arXiv:1206.0758v3](https://arxiv.org/pdf/1206.0758v3.pdf#page=15)
    operation ccnot_7_t_depth_4 (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Ctl {
        body (...) {
            Adjoint T(control1);
            Adjoint T(control2);
            H(target);
            CNOT(target, control1);
            T(control1);
            CNOT(control2, target);
            CNOT(control2, control1);
            T(target);
            Adjoint T(control1);
            CNOT(control2, target);
            CNOT(target, control1);
            Adjoint T(target);
            T(control1);
            H(target);
            CNOT(control2, control1);
        }

        adjoint self;
    }

    // -------------------------------------------------------------------------

    // /// # Summary
    // /// CCNOT gate over the Clifford+T gate set, in T-depth 1, according to Selinger
    // /// # Remarks
    // ///
    // /// # References
    // /// - [ *P. Selinger*,
    // ///        Phys. Rev. A 87: 042302 (2013)](http://doi.org/10.1103/PhysRevA.87.042302)
    // /// # See Also
    // /// - For the circuit diagram see Figure 1 on
    // ///   [ Page 3 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation ccnot_T_depth_1 (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj + Ctl {
        using (auxillaryRegister = Qubit[4]) {

            // apply UVU† where U is outer circuit and V is inner circuit
            ApplyWithCA(TDepthOneCCNOTOuterCircuit, TDepthOneCCNOTInnerCircuit, auxillaryRegister + [target, control1, control2]);
        }
    }


    /// # See Also
    /// - Used as a part of @"Microsoft.Quantum.Samples.UnitTesting.TDepthOneCCNOT"
    /// - For the circuit diagram see Figure 1 on
    ///   [ Page 3 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation TDepthOneCCNOTOuterCircuit (qs : Qubit[]) : Unit is Adj + Ctl {
        EqualityFactI(Length(qs), 7, "7 qubits are expected");
        H(qs[4]);
        CNOT(qs[5], qs[1]);
        CNOT(qs[6], qs[3]);
        CNOT(qs[5], qs[2]);
        CNOT(qs[4], qs[1]);
        CNOT(qs[3], qs[0]);
        CNOT(qs[6], qs[2]);
        CNOT(qs[4], qs[0]);
        CNOT(qs[1], qs[3]);
    }


    /// # See Also
    /// - Used as a part of @"Microsoft.Quantum.Samples.UnitTesting.TDepthOneCCNOT"
    /// - For the circuit diagram see Figure 1 on
    ///   [ Page 3 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation TDepthOneCCNOTInnerCircuit (qs : Qubit[]) : Unit is Adj + Ctl {
        EqualityFactI(Length(qs), 7, "7 qubits are expected");
        ApplyToEachCA(Adjoint T, qs[0 .. 2]);
        ApplyToEachCA(T, qs[3 .. 6]);
    }


	/// # Summary
	/// Flips a blank output qubit if and only if all input
	/// control qubits are in the 1 state. Uses clean ancilla
	/// which are returned dirty.
	///
	/// # Inputs
	/// ## controlQubits
	/// Array of qubits acting like a controlled X on the output
	/// ## blankControlQubits
	/// Qubits initialized to 0 which are used as ancilla.
	/// ## output
	/// A qubit, assumed to be 0, which is flipped if all control
	/// qubits are 1
	///
	/// # Remarks
	/// Identical in function to (Controlled X)(controlQubits, (output))
	/// except the depth is lower, the output must be 0, and it uses
	/// ancilla which are not uncomputed.
	/// If controlQubits has n qubits, then this needs n-2
	/// blankControlQubits.
	operation CompressControls(controlQubits : Qubit[], blankControlQubits : Qubit[], output : Qubit, costing: Bool) : Unit {
		body (...){
			let nControls = Length(controlQubits);
			let nNewControls = Length(blankControlQubits);
			if (nControls == 2){
				LPAND(controlQubits[0], controlQubits[1], output, costing);
			} else {
				Fact(nNewControls >= nControls/2, $"Cannot compress {nControls}
					control qubits to {nNewControls} qubits without more ancilla");
				Fact(nNewControls <= nControls,
					$"Cannot compress {nControls} control qubits into
					{nNewControls} qubits because there are too few controls");
				let compressLength = nControls - nNewControls;
				for (idx in 0.. 2 .. nControls - 2){
					LPAND(controlQubits[idx], controlQubits[idx + 1], blankControlQubits[idx/2], costing);
				}
				if (nControls % 2 == 0){
					CompressControls(blankControlQubits[0.. nControls/2 - 1], blankControlQubits[nControls/2 .. nNewControls - 1], output, costing);
				} else {
					CompressControls([controlQubits[nControls - 1]] + blankControlQubits[0.. nControls/2 - 1], blankControlQubits[nControls/2 .. nNewControls - 1], output, costing);
				}
			}
		}
		adjoint auto;
	}


    /// # Summary
	/// Checks if the input register is all ones, and if so,
	/// flips the output qubit from 0 to 1.
	/// # Inputs
	/// ## xs
	/// Qubit register being checked against all-zeros
	/// ## output
	/// The qubit that will be flipped
	///
	/// # Remarks
	/// This has the same function as (Controlled X)(xs, (output))
	/// but this explicitly forms a binary tree to achieve a logarithmic
	/// depth. This means it borrows n-1 clean qubits.
	operation TestIfAllOnes(xs : Qubit[], output : Qubit, costing: Bool) : Unit {
		body (...){
			let nQubits = Length(xs);
			if (nQubits == 1){
				CNOT(xs[0], output);
			} elif (nQubits == 2){
				ccnot(xs[0], xs[1], output, costing);
			} else {
				using ((spareControls, ancillaOutput) = (Qubit[nQubits - 2], Qubit())){
					CompressControls(xs, spareControls, ancillaOutput, costing);
					CNOT(ancillaOutput, output);
					(Adjoint CompressControls)(xs, spareControls, ancillaOutput, costing);
				}
			}
		}
		controlled (controls, ...){
			TestIfAllOnes(controls + xs, output, costing);
		}
		adjoint controlled auto;
	}


    operation CompareQubitstring(success: Qubit, qubitstring: Qubit[], target: Bool[], costing: Bool) : Unit
    {
        body (...)
        {
            if (Length(target) == Length(qubitstring))
            {
                // flip wires expected to be 0 in the target, to allow comparison
                for (i in 0..(Length(target)-1))
                {
                    if (target[i] == false)
                    {
                        X(qubitstring[i]);
                    }
                }

                // record success
                TestIfAllOnes(qubitstring, success, costing);

                // undo flipping
                for (i in 0..(Length(target)-1))
                {
                    if (target[i] == false)
                    {
                        X(qubitstring[i]);
                    }
                }
            }

            // this can also be done in the following way using the Q# standard library
            // but it's more expensive
            // let controlled_op = ControlledOnBitString(target, X);
            // controlled_op(qubitstring, success);
        }
        adjoint auto;
    }
}