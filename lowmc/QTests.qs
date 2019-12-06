// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
namespace QTests.LowMC
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open QUtilities;

    operation SBox(_a: Result[], in_place: Bool, costing: Bool) : Result[]
    {
        mutable res = new Result[3];
        using ((a, b) = (Qubit[3], Qubit[3]))
        {
            for (i in 1..3)
            {
                Set(_a[i-1], a[i-1]);
            }

            if (in_place)
            {
                QLowMC.InPlace.SBox(a, costing);
            }
            else
            {
                QLowMC.SBox(a, b, costing);
            }

            for (i in 1..3)
            {
                if (in_place)
                {
                    set res w/= i-1 <- M(a[i-1]);
                }
                else
                {
                    set res w/= i-1 <- M(b[i-1]);
                }
            }

            // cleanup
            for (i in 1..3)
            {
                Set(Zero, a[i-1]);
                Set(Zero, b[i-1]);
            }
        }
        return res;
    }

    operation SBoxLayer(_a: Result[], blocksize: Int, sboxes: Int, in_place: Bool, costing: Bool) : Result[]
    {
        mutable res = new Result[blocksize];
        using ((a, ancillas) = (Qubit[blocksize], Qubit[3*sboxes]))
        {
            for (i in 1..blocksize)
            {
                Set(_a[i-1], a[i-1]);
            }

            let scheme = QLowMC.Parameters(0, blocksize, 0, sboxes, 0);

            if (in_place)
            {
                QLowMC.InPlace.SBoxLayer(a, scheme, costing);
                for (i in 1..blocksize)
                {
                    set res w/= i-1 <- M(a[i-1]);
                }
            }
            else
            {
                QLowMC.SBoxLayer(a, ancillas, scheme, costing);
                let out_state = a[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + ancillas;
                for (i in 1..blocksize)
                {
                    set res w/= i-1 <- M(out_state[i-1]);
                }
            }
            // cleanup
            for (i in 1..blocksize)
            {
                Set(Zero, a[i-1]);
            }
            for (i in 1..(3*sboxes))
            {
                Set(Zero, ancillas[i-1]);
            }
        }
        return res;
    }

    operation AffineLayer(_a: Result[], round: Int, id: Int, costing: Bool) : Result[]
    {
        mutable blocksize = 0;
        if (id == 0)
        {
            set blocksize = 32;
        }
        if (id == 1)
        {
            set blocksize = 128;
        }
        elif (id == 3)
        {
            set blocksize = 192;
        }
        elif (id == 5)
        {
            set blocksize = 256;
        }
        mutable res = new Result[blocksize];
        using (a = Qubit[blocksize])
        {
            for (i in 1..blocksize)
            {
                Set(_a[i-1], a[i-1]);
            }
            if (id == 0)
            {
                QLowMC.InPlace.L0.AffineLayer(a, round, costing);
            }
            if (id == 1)
            {
                QLowMC.InPlace.L1.AffineLayer(a, round, costing);
            }
            elif (id == 3)
            {
                QLowMC.InPlace.L3.AffineLayer(a, round, costing);
            }
            elif (id == 5)
            {
                QLowMC.InPlace.L5.AffineLayer(a, round, costing);
            }

            for (i in 1..blocksize)
            {
                set res w/= i-1 <- M(a[i-1]);
            }

            // cleanup
            for (i in 1..blocksize)
            {
                Set(Zero, a[i-1]);
            }
        }
        return res;
    }

    operation KeyExpansion(_a: Result[], round: Int, id: Int, costing: Bool) : Result[]
    {
        mutable blocksize = 0;
        if (id == 0)
        {
            set blocksize = 32;
        }
        if (id == 1)
        {
            set blocksize = 128;
        }
        elif (id == 3)
        {
            set blocksize = 192;
        }
        elif (id == 5)
        {
            set blocksize = 256;
        }
        mutable res = new Result[blocksize];
        using (a = Qubit[blocksize])
        {
            for (i in 1..blocksize)
            {
                Set(_a[i-1], a[i-1]);
            }

            if (id == 0)
            {
                if (costing)
                {
                    QLowMC.InPlace.L0.KeyExpansion(a, round, costing);
                }
                else
                {
                    for (i in 0..round)
                    {
                        QLowMC.InPlace.L0.KeyExpansion(a, i, costing);
                    }
                }
            }
            if (id == 1)
            {
                if (costing)
                {
                    QLowMC.InPlace.L1.KeyExpansion(a, round, costing);
                }
                else
                {
                    for (i in 0..round)
                    {
                        QLowMC.InPlace.L1.KeyExpansion(a, i, costing);
                    }
                }
            }
            elif (id == 3)
            {
                if (costing)
                {
                    QLowMC.InPlace.L3.KeyExpansion(a, round, costing);
                }
                else
                {
                    for (i in 0..round)
                    {
                        QLowMC.InPlace.L3.KeyExpansion(a, i, costing);
                    }
                }
            }
            elif (id == 5)
            {
                if (costing)
                {
                    QLowMC.InPlace.L5.KeyExpansion(a, round, costing);
                }
                else
                {
                    for (i in 0..round)
                    {
                        QLowMC.InPlace.L5.KeyExpansion(a, i, costing);
                    }
                }
            }

            for (i in 1..blocksize)
            {
                set res w/= i-1 <- M(a[i-1]);
            }

            // cleanup
            for (i in 1..blocksize)
            {
                Set(Zero, a[i-1]);
            }
        }
        return res;
    }

    operation Round(in_state: Result[], round_key: Result[], round: Int, id: Int, costing: Bool) : Result[]
    {
        mutable blocksize = 0;
        let sboxes = 10;
        if (id == 0)
        {
            set blocksize = 32;
        }
        if (id == 1)
        {
            set blocksize = 128;
        }
        elif (id == 3)
        {
            set blocksize = 192;
        }
        elif (id == 5)
        {
            set blocksize = 256;
        }
        mutable res = new Result[blocksize];
        using ((in_s, ancillas, rk) = (Qubit[blocksize], Qubit[3*sboxes], Qubit[blocksize]))
        {
            for (i in 1..blocksize)
            {
                Set(in_state[i-1], in_s[i-1]);
                Set(round_key[i-1], rk[i-1]);
            }

            let scheme = QLowMC.Parameters(0, blocksize, blocksize, sboxes, id);
            QLowMC.Round(in_s, ancillas, rk, round, scheme, costing);
            let out_state = in_s[0..(scheme::blocksize - 3*scheme::sboxes - 1)] + ancillas[0..(3*scheme::sboxes-1)];

            for (i in 1..blocksize)
            {
                set res w/= i-1 <- M(out_state[i-1]);
            }

            // cleanup
            for (i in 1..blocksize)
            {
                Set(Zero, in_s[i-1]);
                Set(Zero, rk[i-1]);
            }
            for (i in 1..(3*sboxes))
            {
                Set(Zero, ancillas[i-1]);
            }
        }
        return res;
    }

    operation Encrypt(_key: Result[], _message: Result[], id: Int, costing: Bool) : Result[]
    {
        mutable blocksize = 0;
        mutable rounds = 0;
        let sboxes = 10;
        if (id == 0)
        {
            set blocksize = 32;
            set rounds = 10;
        }
        if (id == 1)
        {
            set blocksize = 128;
            set rounds = 20;
        }
        elif (id == 3)
        {
            set blocksize = 192;
            set rounds = 30;
        }
        elif (id == 5)
        {
            set blocksize = 256;
            set rounds = 38;
        }
        mutable res = new Result[blocksize];
        using ((key, message, ciphertext) = (Qubit[blocksize], Qubit[blocksize], Qubit[blocksize]))
        {
            for (i in 1..blocksize)
            {
                Set(_key[i-1], key[i-1]);
                Set(_message[i-1], message[i-1]);
            }

            let scheme = QLowMC.Parameters(rounds, blocksize, blocksize, sboxes, id);
            QLowMC.Encrypt(key, message, ciphertext, scheme, costing);

            for (i in 1..blocksize)
            {
                set res w/= i-1 <- M(ciphertext[i-1]);
            }

            // cleanup
            for (i in 1..blocksize)
            {
                Set(Zero, key[i-1]);
                Set(Zero, message[i-1]);
                Set(Zero, ciphertext[i-1]);
            }
        }
        return res;
    }

    operation GroverOracle (_key: Result[], _plaintexts: Result[], target_ciphertext: Bool[], pairs: Int, id: Int, costing: Bool) : Result
    {
        mutable blocksize = 0;
        mutable rounds = 0;
        let sboxes = 10;
        if (id == 0)
        {
            set blocksize = 32;
            set rounds = 10;
        }
        if (id == 1)
        {
            set blocksize = 128;
            set rounds = 20;
        }
        elif (id == 3)
        {
            set blocksize = 192;
            set rounds = 30;
        }
        elif (id == 5)
        {
            set blocksize = 256;
            set rounds = 38;
        }
        mutable res = Zero;

        using ((key, success, plaintext) = (Qubit[blocksize], Qubit(), Qubit[blocksize*pairs]))
        {
            for (i in 0..(blocksize-1))
            {
                Set(_key[i], key[i]);
            }
            for (j in 0..(pairs-1))
            {
                for (i in 0..(blocksize-1))
                {
                    Set(_plaintexts[blocksize*j + i], plaintext[blocksize*j + i]);
                }
            }

            let scheme = QLowMC.Parameters(rounds, blocksize, blocksize, sboxes, id);
            // in actual use, we'd initialise set Success to |-), but not in this case
            QLowMC.GroverOracle(key, success, plaintext, target_ciphertext, pairs, scheme, costing);

            set res = M(success);

            // cleanup
            Set(Zero, success);
            for (i in 0..(blocksize-1))
            {
                Set(Zero, key[i]);
            }
            for (j in 0..(pairs-1))
            {
                for (i in 0..(blocksize-1))
                {
                    Set(Zero, plaintext[blocksize*j + i]);
                }
            }
        }
        return res;
    }
}
