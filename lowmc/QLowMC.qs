// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
namespace QLowMC
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    newtype Parameters = (rounds: Int, blocksize: Int, keysize: Int, sboxes: Int, id: Int);

    operation SBox(x: Qubit[], y: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            // // this variant may be slightly wider when having a multiple p-c grover oracle
            // // but it's easier to read
            // // using (xx = Qubit[3])
            // {
            //     CNOT(x[0], xx[0]);
            //     CNOT(x[1], xx[1]);
            //     CNOT(x[2], xx[2]);

            //     ccnot(x[0], x[1], y[2], costing);
            //     ccnot(x[2], xx[0], y[1], costing);
            //     ccnot(xx[1], xx[2], y[0], costing);

            //     CNOT(xx[0], y[0]);
            //     CNOT(xx[1], y[1]);
            //     CNOT(xx[2], y[2]);

            //     CNOT(x[2], xx[2]);
            //     CNOT(x[1], xx[1]);

            //     CNOT(x[0], y[1]);
            //     CNOT(xx[0], y[2]);
            //     CNOT(x[0], xx[0]);
            // }
            // CNOT(x[1], y[2]);

            // This variant may be slightly narrower when running a grover oracle on multiple p-c pairs
            using (aa = Qubit())
            {
                CNOT(x[0], aa);
                using (bb = Qubit())
                {
                    CNOT(x[1], bb);
                    using (cc = Qubit())
                    {
                        CNOT(x[2], cc);

                        ccnot(x[0], x[1], y[2], costing);
                        ccnot(x[2], aa, y[1], costing);
                        ccnot(bb, cc, y[0], costing);

                        CNOT(aa, y[0]);
                        CNOT(bb, y[1]);
                        CNOT(cc, y[2]);

                        CNOT(x[2], cc);
                    }
                    CNOT(x[1], bb);
                }
                CNOT(x[0], y[1]);
                CNOT(aa, y[2]);
                CNOT(x[0], aa);
            }
            CNOT(x[1], y[2]);
        }
        adjoint auto;
    }

    // note that we work only on the rightmost portion of the state
    // and this spares us allocating ancillas for those bits that are just copied over
    operation SBoxLayer(in_state: Qubit[], ancillas: Qubit[], scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            for (i in (scheme::blocksize-1)..(-3)..(scheme::blocksize - 3*scheme::sboxes))
            {
                SBox(in_state[(i-2)..i], ancillas[(i-2-(scheme::blocksize - 3*scheme::sboxes))..(i-(scheme::blocksize - 3*scheme::sboxes))], costing);
            }
        }
        adjoint auto;
    }

    operation KeyAddition(state: Qubit[], round_key: Qubit[], scheme: QLowMC.Parameters) : Unit
    {
        body (...)
        {
            for (j in 0..(scheme::blocksize-1))
            {
                CNOT(round_key[j], state[j]);
            }
        }
        adjoint auto;
    }

    operation Round(in_state: Qubit[], ancillas: Qubit[], round_key: Qubit[], round: Int, scheme: QLowMC.Parameters, costing: Bool): Unit
    {
        body (...)
        {
            SBoxLayer(in_state, ancillas, scheme, costing);
            let out_state = in_state[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + ancillas[0..(3*scheme::sboxes - 1)];
            if (scheme::id == 0)
            {
                QLowMC.InPlace.L0.KeyExpansion(round_key, round, costing);
                QLowMC.InPlace.L0.AffineLayer(out_state, round, costing);
            }
            if (scheme::id == 1)
            {
                QLowMC.InPlace.L1.KeyExpansion(round_key, round, costing);
                QLowMC.InPlace.L1.AffineLayer(out_state, round, costing);
            }
            elif (scheme::id == 3)
            {
                QLowMC.InPlace.L3.KeyExpansion(round_key, round, costing);
                QLowMC.InPlace.L3.AffineLayer(out_state, round, costing);
            }
            elif (scheme::id == 5)
            {
                QLowMC.InPlace.L5.KeyExpansion(round_key, round, costing);
                QLowMC.InPlace.L5.AffineLayer(out_state, round, costing);
            }
            KeyAddition(out_state, round_key, scheme);
        }
        adjoint auto;
    }

    // utility function in order to simplify uncomputation during encryption
    operation AllRounds(key: Qubit[], state: Qubit[], ancillas: Qubit[], scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            Round(state, ancillas[0..(3*scheme::sboxes - 1)], key, 1, scheme, costing);
            for (round in 2..scheme::rounds)
            {
                let out_state = state[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + ancillas[3*scheme::sboxes*(round-2)..(3*scheme::sboxes*(round-1) - 1)];
                Round(out_state, ancillas[3*scheme::sboxes*(round-1)..(3*scheme::sboxes*round - 1)], key, round, scheme, costing);
            }
        }
        adjoint auto;
    }

    operation ForwardEncrypt(key: Qubit[], state: Qubit[], ancillas: Qubit[], scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            // "round 0"
            if (scheme::id == 0)
            {
                QLowMC.InPlace.L0.KeyExpansion(key, 0, costing);
            }
            if (scheme::id == 1)
            {
                QLowMC.InPlace.L1.KeyExpansion(key, 0, costing);
            }
            elif (scheme::id == 3)
            {
                QLowMC.InPlace.L3.KeyExpansion(key, 0, costing);
            }
            elif (scheme::id == 5)
            {
                QLowMC.InPlace.L5.KeyExpansion(key, 0, costing);
            }
            KeyAddition(state, key, scheme);

            // full rounds
            AllRounds(key, state, ancillas, scheme, costing);
        }
        adjoint auto;
    }

    operation Encrypt(key: Qubit[], state: Qubit[], ciphertext: Qubit[], scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            using (ancillas = Qubit[3 * scheme::sboxes * scheme::rounds])
            {
                ForwardEncrypt(key, state, ancillas, scheme, costing);
                let final_state = state[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + ancillas[3*scheme::sboxes*(scheme::rounds-1)..(3*scheme::sboxes*scheme::rounds - 1)];
                CNOTnBits(final_state, ciphertext, scheme::blocksize);
                (Adjoint ForwardEncrypt)(key, state, ancillas, scheme, costing);
            }
        }
        adjoint auto;
    }

    operation ForwardGroverOracle(other_keys: Qubit[], state_ancillas: Qubit[], encryption_ancillas: Qubit[], key_superposition: Qubit[], success: Qubit, plaintext: Qubit[], target_ciphertext: Bool[], pairs: Int, scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            // copy loaded key
            for (i in 0..(pairs-2))
            {
                CNOTnBits(key_superposition, other_keys[(i*scheme::keysize)..((i+1)*scheme::keysize-1)], scheme::keysize);
            }

            // compute encryption of the i-th target message
            for (i in 0..(pairs-1))
            {
                let state = plaintext[(i*scheme::blocksize)..((i+1)*scheme::blocksize-1)] + state_ancillas[(i*3*scheme::sboxes*scheme::rounds)..((i+1)*3*scheme::sboxes*scheme::rounds-1)];
                let key = i == 0 ? key_superposition | other_keys[((i-1)*scheme::keysize)..(i*scheme::keysize-1)];
                ForwardEncrypt(key, state, encryption_ancillas[(i*3*scheme::sboxes*scheme::rounds)..((i+1)*3*scheme::sboxes*scheme::rounds-1)], scheme, costing);
            }
        }
        adjoint auto;
    }

    operation GroverOracle(key_superposition: Qubit[], success: Qubit, plaintext: Qubit[], target_ciphertext: Bool[], pairs: Int, scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            using ((other_keys, state_ancillas, encryption_ancillas) = (Qubit[scheme::keysize*(pairs-1)], Qubit[3*scheme::sboxes*scheme::rounds*pairs], Qubit[3 * scheme::sboxes * scheme::rounds * pairs]))
            {
                ForwardGroverOracle(other_keys, state_ancillas, encryption_ancillas, key_superposition, success, plaintext, target_ciphertext, pairs, scheme, costing);

                // debug output
                // for (i in 0..(Length(target_ciphertext)-1))
                // {
                //     if (i == Length(target_ciphertext)/pairs)
                //     {
                //         Message("----");
                //     }
                //     Message($"{M(ciphertext[i])} = {target_ciphertext[i]}");
                // }

                mutable state = plaintext[0..(scheme::blocksize-1)] + state_ancillas[0..(3*scheme::sboxes*scheme::rounds-1)];
                mutable ciphertext = state[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + encryption_ancillas[3*scheme::sboxes*(scheme::rounds-1)..(3*scheme::sboxes*scheme::rounds - 1)];
                for (i in 1..(pairs-1))
                {
                    set state = plaintext[(i*scheme::blocksize)..((i+1)*scheme::blocksize-1)] + state_ancillas[(i*3*scheme::sboxes*scheme::rounds)..((i+1)*3*scheme::sboxes*scheme::rounds-1)];
                    set ciphertext = ciphertext + state[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + encryption_ancillas[((i*3*scheme::sboxes*scheme::rounds) + 3*scheme::sboxes*(scheme::rounds-1))..((i*3*scheme::sboxes*scheme::rounds) + 3*scheme::sboxes*scheme::rounds - 1)];
                }
                CompareQubitstring(success, ciphertext, target_ciphertext, costing);

                (Adjoint ForwardGroverOracle)(other_keys, state_ancillas, encryption_ancillas, key_superposition, success, plaintext, target_ciphertext, pairs, scheme, costing);
            }
        }
    }
}

namespace QLowMC.InPlace
{
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    operation SBox(x: Qubit[], costing: Bool) : Unit
    {
        body (...)
        {
            ccnot(x[1], x[2], x[0], costing);
            ccnot(x[0], x[2], x[1], costing);
            ccnot(x[0], x[1], x[2], costing);
            CNOT(x[0], x[1]);
            CNOT(x[1], x[2]);
        }
        adjoint auto;
    }

    // can pass either the full state or the latter part that is S-box'd
    operation SBoxLayer(state: Qubit[], scheme: QLowMC.Parameters, costing: Bool) : Unit
    {
        body (...)
        {
            for (i in (scheme::blocksize-1)..(-3)..(scheme::blocksize - 3*scheme::sboxes))
            {
                SBox(state[(i-2)..i], costing);
            }
        }
        adjoint auto;
    }

    operation AddRoundKey(state: Qubit[], round_key: Qubit[], scheme: QLowMC.Parameters) : Unit
    {
        body (...)
        {
            for (i in 0..(scheme::blocksize-1))
            {
                CNOT(round_key[i], state[i]);
            }
        }
        adjoint auto;
    }
}
