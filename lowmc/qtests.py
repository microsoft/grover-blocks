# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
import qsharp
import lowmc

class Tests:

    @staticmethod
    def SBox(cost=False, in_place=False):
        """
        TESTS:
            >>> Tests.SBox(in_place=True)
            Testing SBox(in_place=True)
            >>> Tests.SBox(in_place=False)
            Testing SBox(in_place=False)
        """
        print("%s SBox(in_place=%s)" %("Costing" if cost else "Testing", in_place))
        from QTests.LowMC import SBox # pylint: disable=no-name-in-module,import-error
        bits = lambda n : [int(bool(n & (1 << i))) for i in range(3)]
        res = []
        for _x in range(8):
            x = bits(_x)
            if cost:
                return SBox.estimate_resources(_a=x, in_place=in_place)

            sbox = lowmc.Sbox(x[0], x[1], x[2])
            qsbox = tuple(SBox.toffoli_simulate(_a=x, in_place=in_place, costing=False))
            res.append(sbox == qsbox)
            if (sbox != qsbox):
                print("Error")
                print("       x:", x)
                print(" sbox(x):", sbox)
                print("qsbox(x):", qsbox)

    @staticmethod
    def SBoxLayer(cost=False, blocksize=128, sboxes=10, in_place=False):
        """
        TESTS:
            >>> Tests.SBoxLayer(blocksize=128, sboxes=10, in_place=True)
            Testing SBoxLayer(blocksize=128, sboxes=10, in_place=True)
            >>> Tests.SBoxLayer(blocksize=192, sboxes=10, in_place=True)
            Testing SBoxLayer(blocksize=192, sboxes=10, in_place=True)
            >>> Tests.SBoxLayer(blocksize=256, sboxes=10, in_place=True)
            Testing SBoxLayer(blocksize=256, sboxes=10, in_place=True)
            >>> Tests.SBoxLayer(blocksize=128, sboxes=10, in_place=False)
            Testing SBoxLayer(blocksize=128, sboxes=10, in_place=False)
            >>> Tests.SBoxLayer(blocksize=192, sboxes=10, in_place=False)
            Testing SBoxLayer(blocksize=192, sboxes=10, in_place=False)
            >>> Tests.SBoxLayer(blocksize=256, sboxes=10, in_place=False)
            Testing SBoxLayer(blocksize=256, sboxes=10, in_place=False)
        """
        print("%s SBoxLayer(blocksize=%d, sboxes=%d, in_place=%s)" %("Costing" if cost else "Testing", blocksize, sboxes, in_place))
        import random
        from QTests.LowMC import SBoxLayer # pylint: disable=no-name-in-module,import-error
        res = []
        trials = 4
        for _ in range(trials):
            in_state = [random.randint(0, 1) for __ in range(blocksize)]
            if cost:
                return SBoxLayer.estimate_resources(_a=in_state, blocksize=blocksize, sboxes=sboxes, in_place=in_place)
            state = lowmc.SboxLayer(in_state[::], { 'blocksize': blocksize, 'sboxes': sboxes })
            qstate = SBoxLayer.toffoli_simulate(_a=in_state, blocksize=blocksize, sboxes=sboxes, in_place=in_place, costing=False)
            res.append(state == qstate)
            if (state != qstate):
                print("Error")
                print("blocksize:", blocksize)
                print("   sboxes:", sboxes)
                print("  sbox(x):", state)
                print(" qsbox(x):", qstate)
        assert(res == [True] * trials)

    @staticmethod
    def AffineLayer(cost=False):
        """
        TESTS:
            >>> Tests.AffineLayer()
            Testing AffineLayer()
        """
        print("%s AffineLayer()" %("Costing" if cost else "Testing"))
        import random
        from QTests.LowMC import AffineLayer # pylint: disable=no-name-in-module,import-error
        import L1, L3, L5
        import L0
        def detect_schemes():
            import os.path
            ret = []
            for i in [0, 1, 3, 5]:
                if os.path.exists('in_place_key_expansion_L%d.qs' % i) and os.path.exists('affine_layers_L%d.qs' % i):
                    ret.append(i)
            return ret

        schemes = list(filter(lambda x: x['id'] in detect_schemes(), [
            { 'id': 0, 'rounds': L0.rounds, 'blocksize': L0.blocksize, 'keysize': L0.keysize, 'KM': L0.KM, 'LM': L0.LM, 'b': L0.b, 'sboxes': 10 },
            { 'id': 1, 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 },
            { 'id': 3, 'rounds': L3.rounds, 'blocksize': L3.blocksize, 'keysize': L3.keysize, 'KM': L3.KM, 'LM': L3.LM, 'b': L3.b, 'sboxes': 10 },
            { 'id': 5, 'rounds': L5.rounds, 'blocksize': L5.blocksize, 'keysize': L5.keysize, 'KM': L5.KM, 'LM': L5.LM, 'b': L5.b, 'sboxes': 10 },
        ]))

        for scheme in schemes:
            rounds, blocksize = scheme['rounds'], scheme['blocksize']
            for _round in range(1, rounds+1):
                res = []
                trials = 4
                for _ in range(trials):
                    in_state = [random.randint(0, 1) for __ in range(blocksize)]
                    if cost:
                        raise ValueError("Use Driver.cs")
                    state = lowmc.ConstantAddition(lowmc.LinearLayer(in_state[::], _round, scheme), _round, scheme)
                    qstate = AffineLayer.toffoli_simulate(_a=in_state, round=_round, id=scheme['id'], costing=False)
                    res.append(state == qstate)
                    if (state != qstate):
                        print("Error")
                        print("  state:", state)
                        print(" qstate:", qstate)
                assert(res == [True] * trials)

    @staticmethod
    def KeyExpansion(cost=False):
        """
        TESTS:
            >>> Tests.KeyExpansion()
            Testing KeyExpansion()
        """
        print("%s KeyExpansion()" %("Costing" if cost else "Testing"))
        import random
        from QTests.LowMC import KeyExpansion # pylint: disable=no-name-in-module,import-error
        import L1, L3, L5
        import L0
        def detect_schemes():
            import os.path
            ret = []
            for i in [0, 1, 3, 5]:
                if os.path.exists('in_place_key_expansion_L%d.qs' % i) and os.path.exists('affine_layers_L%d.qs' % i):
                    ret.append(i)
            return ret

        schemes = list(filter(lambda x: x['id'] in detect_schemes(), [
            { 'id': 0, 'rounds': L0.rounds, 'blocksize': L0.blocksize, 'keysize': L0.keysize, 'KM': L0.KM, 'LM': L0.LM, 'b': L0.b, 'sboxes': 10 },
            { 'id': 1, 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 },
            { 'id': 3, 'rounds': L3.rounds, 'blocksize': L3.blocksize, 'keysize': L3.keysize, 'KM': L3.KM, 'LM': L3.LM, 'b': L3.b, 'sboxes': 10 },
            { 'id': 5, 'rounds': L5.rounds, 'blocksize': L5.blocksize, 'keysize': L5.keysize, 'KM': L5.KM, 'LM': L5.LM, 'b': L5.b, 'sboxes': 10 },
        ]))

        for scheme in schemes:
            rounds, keysize = scheme['rounds'], scheme['keysize']
            for _round in range(rounds+2):
                res = []
                trials = 4
                for _ in range(trials):
                    k = [random.randint(0, 1) for __ in range(keysize)]
                    if cost:
                        raise ValueError("Use Driver.cs")
                    if _round < rounds + 1:
                        rk = lowmc.RoundKey(k, _round, scheme, in_place=False)
                    else:
                        # the last "round" is ficticious, just the adjoint operation to recover the original key from the last round
                        rk = k
                    qrk = KeyExpansion.toffoli_simulate(_a=k, round=_round, id=scheme['id'], costing=False)
                    res.append(rk == qrk)
                    if (rk != qrk):
                        print("Error")
                        print("  rk:", rk)
                        print(" qrk:", qrk)
                assert(res == [True] * trials)

    @staticmethod
    def Round(cost=False):
        """
        TESTS:
            # >>> Tests.Round()
            # Testing Round()
        """
        print("%s Round()" %("Costing" if cost else "Testing"))
        import random
        from QTests.LowMC import Round # pylint: disable=no-name-in-module,import-error
        import L1, L3, L5
        import L0
        def detect_schemes():
            import os.path
            ret = []
            for i in [0, 1, 3, 5]:
                if os.path.exists('in_place_key_expansion_L%d.qs' % i) and os.path.exists('affine_layers_L%d.qs' % i):
                    ret.append(i)
            return ret

        schemes = list(filter(lambda x: x['id'] in detect_schemes(), [
            { 'id': 0, 'rounds': L0.rounds, 'blocksize': L0.blocksize, 'keysize': L0.keysize, 'KM': L0.KM, 'LM': L0.LM, 'b': L0.b, 'sboxes': 10 },
            { 'id': 1, 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 },
            { 'id': 3, 'rounds': L3.rounds, 'blocksize': L3.blocksize, 'keysize': L3.keysize, 'KM': L3.KM, 'LM': L3.LM, 'b': L3.b, 'sboxes': 10 },
            { 'id': 5, 'rounds': L5.rounds, 'blocksize': L5.blocksize, 'keysize': L5.keysize, 'KM': L5.KM, 'LM': L5.LM, 'b': L5.b, 'sboxes': 10 },
        ]))

        for scheme in schemes:
            rounds, keysize, blocksize = scheme['rounds'], scheme['keysize'], scheme['blocksize']
            for _round in range(1, rounds+1):
                res = []
                trials = 4
                for _ in range(trials):
                    rk = [random.randint(0, 1) for __ in range(keysize)]
                    in_s = [random.randint(0, 1) for __ in range(blocksize)]
                    if cost:
                        raise ValueError("Use Driver.cs")
                    state = lowmc.LowMCRound(in_s[::], rk[::], _round, scheme, in_place=True)
                    qstate = Round.toffoli_simulate(in_state=in_s, round_key=lowmc.RoundKey(rk, _round, scheme, in_place=True, IKM=IKM), round=_round, id=scheme['id'], costing=False)
                    res.append(state == qstate)
                    if (state != qstate):
                        print("Error")
                        print("  state:", state)
                        print(" qstate:", qstate)
                assert(res == [True] * trials)

    @staticmethod
    def Encrypt(cost=False):
        """
        TESTS:
            >>> Tests.Encrypt()
            Testing Encrypt()
        """
        print("%s Encrypt()" %("Costing" if cost else "Testing"))
        import random
        from QTests.LowMC import Encrypt # pylint: disable=no-name-in-module,import-error
        import L1, L3, L5
        import L0
        def detect_schemes():
            import os.path
            ret = []
            for i in [0, 1, 3, 5]:
                if os.path.exists('in_place_key_expansion_L%d.qs' % i) and os.path.exists('affine_layers_L%d.qs' % i):
                    ret.append(i)
            return ret

        schemes = list(filter(lambda x: x['id'] in detect_schemes(), [
            { 'id': 0, 'rounds': L0.rounds, 'blocksize': L0.blocksize, 'keysize': L0.keysize, 'KM': L0.KM, 'LM': L0.LM, 'b': L0.b, 'sboxes': 10 },
            { 'id': 1, 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 },
            { 'id': 3, 'rounds': L3.rounds, 'blocksize': L3.blocksize, 'keysize': L3.keysize, 'KM': L3.KM, 'LM': L3.LM, 'b': L3.b, 'sboxes': 10 },
            { 'id': 5, 'rounds': L5.rounds, 'blocksize': L5.blocksize, 'keysize': L5.keysize, 'KM': L5.KM, 'LM': L5.LM, 'b': L5.b, 'sboxes': 10 },
        ]))

        for scheme in schemes:
            keysize, blocksize = scheme['keysize'], scheme['blocksize']
            res = []
            trials = 4
            for _ in range(trials):
                key = [random.randint(0, 1) for __ in range(keysize)]
                message = [random.randint(0, 1) for __ in range(blocksize)]
                if cost:
                    raise ValueError("Use Driver.cs")
                state = lowmc.Encrypt(key[::], message[::], scheme)
                qstate = Encrypt.toffoli_simulate(_key=key, _message=message, id=scheme['id'], costing=False)
                res.append(state == qstate)
                if (state != qstate):
                    print("Error")
                    print("  state:", state)
                    print(" qstate:", qstate)
            assert(res == [True] * trials)

    @staticmethod
    def GroverOracle(pairs=1, cost=False):
        """
        TEST:
            >>> Tests.GroverOracle(pairs=1)
            Testing GroverOracle(pairs=1)
            >>> Tests.GroverOracle(pairs=2)
            Testing GroverOracle(pairs=2)
        """
        print("%s GroverOracle(pairs=%d)" %("Costing" if cost else "Testing", pairs))
        from random import randint
        from QTests.LowMC import GroverOracle # pylint: disable=no-name-in-module,import-error
        import L1, L3, L5
        import L0
        def detect_schemes():
            import os.path
            ret = []
            for i in [0, 1, 3, 5]:
                if os.path.exists('in_place_key_expansion_L%d.qs' % i) and os.path.exists('affine_layers_L%d.qs' % i):
                    ret.append(i)
            return ret

        schemes = list(filter(lambda x: x['id'] in detect_schemes(), [
            { 'id': 0, 'rounds': L0.rounds, 'blocksize': L0.blocksize, 'keysize': L0.keysize, 'KM': L0.KM, 'LM': L0.LM, 'b': L0.b, 'sboxes': 10 },
            { 'id': 1, 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 },
            { 'id': 3, 'rounds': L3.rounds, 'blocksize': L3.blocksize, 'keysize': L3.keysize, 'KM': L3.KM, 'LM': L3.LM, 'b': L3.b, 'sboxes': 10 },
            { 'id': 5, 'rounds': L5.rounds, 'blocksize': L5.blocksize, 'keysize': L5.keysize, 'KM': L5.KM, 'LM': L5.LM, 'b': L5.b, 'sboxes': 10 },
        ]))

        for scheme in schemes:
            keysize, blocksize = scheme['keysize'], scheme['blocksize']
            res = []
            trials = 10
            for _ in range(trials):
                key = [randint(0, 1) for __ in range(keysize)]
                messages = [randint(0, 1) for __ in range(blocksize * pairs)]
                if cost:
                    raise ValueError("Use Driver.cs")

                # compute p-c pairs
                target_ciphertext = []
                for _ in range(pairs):
                    target_ciphertext += lowmc.Encrypt(key[::], messages[_*blocksize:(_+1)*blocksize], scheme)

                # test also that we correctly fail to identify wrong keys
                flip = bool(randint(0, 1))
                if flip:
                    key[0] = 0 if key[0] == 1 else 1

                qgrover = GroverOracle.toffoli_simulate(_key=key, _plaintexts=messages, target_ciphertext=target_ciphertext, pairs=pairs, id=scheme['id'], costing=False)
                res.append(qgrover == int(not flip))
            assert(res == [True] * trials)


def costs():
    print(Tests.SBox(cost=True, in_place=False))
    print(Tests.SBox(cost=True, in_place=True))
    print(Tests.SBoxLayer(blocksize=128, sboxes=10, cost=True, in_place=True))
    print(Tests.SBoxLayer(blocksize=192, sboxes=10, cost=True, in_place=True))
    print(Tests.SBoxLayer(blocksize=256, sboxes=10, cost=True, in_place=True))


if __name__ == "__main__":
    import doctest
    doctest.testmod()
