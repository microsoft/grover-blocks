# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
import qsharp
from gf256 import GF256Element, GF256Poly
import aes

class Tests:

    @staticmethod
    def Mul(unrolled=False, cost=False):
        # """
        # Slow exhaustive tests
        # TESTS:
        #     >>> Tests.Mul(unrolled=False)
        #     Testing Mul (unrolled=False)
        #     >>> Tests.Mul(unrolled=True)
        #     Testing Mul (unrolled=True)
        # """
        print("%s Mul (unrolled=%s)" % ("Costing" if cost else "Testing", unrolled))
        from QTests.GF256 import Mul # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            for _y in range(256):
                x = GF256Element(_x)
                y = GF256Element(_y)
                if cost:
                    return Mul.estimate_resources(_a=x.coeffs, _b=y.coeffs, unrolled=unrolled)

                xy = x*y
                _xy = GF256Element(Mul.toffoli_simulate(_a=x.coeffs, _b=y.coeffs, unrolled=unrolled))
                res.append(xy == _xy)
                if (xy != _xy):
                    print("Error")
                    print("  x:", x)
                    print("  y:", y)
                    print(" xy:", xy)
                    print("qxy:", _xy)

    @staticmethod
    def Square(in_place=False, cost=False):
        """
        TESTS:
            >>> Tests.Square(in_place=True)
            Testing Square (in_place=True)
            >>> Tests.Square(in_place=False)
            Testing Square (in_place=False)
        """
        print("%s Square (in_place=%s)" % ("Costing" if cost else "Testing", in_place))
        from QTests.GF256 import Square # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            x = GF256Element(_x)
            if cost:
                return Square.estimate_resources(_a=x.coeffs, in_place=in_place, costing=True)

            xx = x*x
            _xx = GF256Element(Square.toffoli_simulate(_a=x.coeffs, in_place=in_place, costing=False))
            res.append(xx == _xx)
            if (xx != _xx):
                print("Error")
                print("  x:", x)
                print(" xx:", xx)
                print("qxx:", _xx)

    @staticmethod
    def Fourth(in_place=False, cost=False):
        """
        TESTS:
            >>> Tests.Fourth(in_place=True)
            Testing Fourth (in_place=True)
            >>> Tests.Fourth(in_place=False)
            Testing Fourth (in_place=False)
        """
        print("%s Fourth (in_place=%s)" % ("Costing" if cost else "Testing", in_place))
        from QTests.GF256 import Fourth # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            x = GF256Element(_x)
            if cost:
                return Fourth.estimate_resources(_a=x.coeffs, in_place=in_place, costing=True)

            xx = x**4
            _xx = GF256Element(Fourth.toffoli_simulate(_a=x.coeffs, in_place=in_place, costing=False))
            res.append(xx == _xx)
            if (xx != _xx):
                print("Error")
                print("  x:", x)
                print(" x4:", xx)
                print("qx4:", _xx)

    @staticmethod
    def Sixteenth(cost=False):
        """
        TESTS:
            >>> Tests.Sixteenth()
            Testing Sixteenth
        """
        print("%s Sixteenth" % ("Costing" if cost else "Testing"))
        from QTests.GF256 import Sixteenth # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            x = GF256Element(_x)
            if cost:
                return Sixteenth.estimate_resources(_a=x.coeffs, costing=True)

            x16 = x**16
            _x16 = GF256Element(Sixteenth.toffoli_simulate(_a=x.coeffs, costing=False))
            res.append(x16 == _x16)
            if (x16 != _x16):
                print("Error")
                print("  x:", x)
                print(" x16:", x16)
                print("qx16:", _x16)

    @staticmethod
    def SixtyFourth(in_place=False, cost=False):
        """
        TESTS:
            >>> Tests.SixtyFourth(in_place=True)
            Testing SixtyFourth (in_place=True)
        """
        print("%s SixtyFourth (in_place=%s)" % ("Costing" if cost else "Testing", in_place))
        from QTests.GF256 import SixtyFourth # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            x = GF256Element(_x)
            if cost:
                return SixtyFourth.estimate_resources(_a=x.coeffs, in_place=in_place, costing=True)

            xx = x**64
            _xx = GF256Element(SixtyFourth.toffoli_simulate(_a=x.coeffs, in_place=in_place, costing=False))
            res.append(xx == _xx)
            if (xx != _xx):
                print("Error")
                print("  x:", x)
                print(" x64:", xx)
                print("qx64:", _xx)
                print()
        pass

    @staticmethod
    def Inverse(cost=False):
        """
        TESTS:
            >>> Tests.Inverse()
            Testing Inverse
        """
        print("%s Inverse" %("Costing" if cost else "Testing"))
        from QTests.GF256 import Inverse # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            x = GF256Element(_x)
            if cost:
                return Inverse.estimate_resources(_a=x.coeffs, costing=True)

            x16 = x.inverse()
            _x16 = GF256Element(Inverse.toffoli_simulate(_a=x.coeffs, costing=False))
            res.append(x16 == _x16)
            if (x16 != _x16):
                print("Error")
                print("  x:", x)
                print(" x16:", x16)
                print("qx16:", _x16)
        pass

    @staticmethod
    def SBox(cost=False, tower_field=True, LPS19=False):
        """
        TESTS:
            >>> Tests.SBox(tower_field=True)
            Testing SBox(tower_field=True, LPS19=False)
            >>> Tests.SBox(tower_field=False)
            Testing SBox(tower_field=False, LPS19=False)
            >>> Tests.SBox(LPS19=True)
            Testing SBox(tower_field=True, LPS19=True)
        """
        print("%s SBox(tower_field=%s, LPS19=%s)" %("Costing" if cost else "Testing", tower_field, LPS19))
        from QTests.AES import SBox # pylint: disable=no-name-in-module,import-error
        res = []
        for _x in range(256):
            x = GF256Element(_x)
            if cost:
                return SBox.estimate_resources(_a=x.coeffs, tower_field=tower_field, LPS19=LPS19, costing=True)

            sbox = GF256Element(aes.SBox(x))
            qsbox = GF256Element(SBox.toffoli_simulate(_a=x.coeffs, tower_field=tower_field, LPS19=LPS19, costing=False))
            res.append(sbox == qsbox)
            if (sbox != qsbox):
                print("Error")
                print("       x:", x)
                print(" sbox(x):", sbox)
                print("qsbox(x):", qsbox)
        pass

    @staticmethod
    def ByteSub(cost=False):
        """
        TEST:
            >>> Tests.ByteSub()
            Testing ByteSub
        """
        print("%s ByteSub" %("Costing" if cost else "Testing"))
        from QTests.AES import ByteSub # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
        qstate = [[GF256Element(state['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
        qstate = [ [e for sub in qstate[j] for e in sub] for j in range(4)]
        qstate = [ i for e in qstate for i in e ]
        if cost:
            return ByteSub.estimate_resources(_input_state=qstate, costing=True)
        aes.ByteSub(state)
        qstate = ByteSub.toffoli_simulate(_input_state=qstate, costing=False)
        qstate = [ [bits_to_int(qstate[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]
        assert(state['a'] == qstate)

    @staticmethod
    def ShiftRow(cost=False):
        """
        TEST:
            >>> Tests.ShiftRow()
            Testing ShiftRow
        """
        print("%s ShiftRow" %("Costing" if cost else "Testing"))
        from QTests.AES import ShiftRow # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
        qstate = [[GF256Element(state['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
        qstate = [ [e for sub in qstate[j] for e in sub] for j in range(4)]
        qstate = [ i for e in qstate for i in e ]
        if cost:
            return ShiftRow.estimate_resources(_state=qstate, costing=True)
        aes.ShiftRow(state)
        qstate = ShiftRow.toffoli_simulate(_state=qstate, costing=False)
        qstate = [ [bits_to_int(qstate[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]
        assert(state['a'] == qstate)

    @staticmethod
    def MixWord(in_place=True, cost=False):
        """
        TEST:
            >>> Tests.MixWord(in_place=True)
            Testing MixWord(in_place=True)
            >>> Tests.MixWord(in_place=False)
            Testing MixWord(in_place=False)
        """
        print("%s MixWord(in_place=%s)" %("Costing" if cost else "Testing", in_place))
        from QTests.AES import MixWord # pylint: disable=no-name-in-module,import-error
        from random import randint
        c = GF256Poly(map(int, [0x02, 0x01, 0x01, 0x03]))

        trials = 128
        res = []
        for t in range(trials):
            word = list(map(GF256Element, map(int, [randint(0,255) for _ in range(4)])))
            qword = [word[i].coeffs for i in range(4)]
            qword = [e for sub in qword for e in sub]

            if cost:
                return MixWord.estimate_resources(_word=qword, in_place=in_place, costing=True)

            def bits_to_int(bits):
                return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])

            # Mixcols using GF256 library
            mix_cols_word = c * GF256Poly(word)
            mix_cols_word = [bits_to_int(w.coeffs) for w in mix_cols_word]

            # Mixcols using Q#
            qword = MixWord.toffoli_simulate(_word=qword, in_place=in_place, costing=False)
            qword = [bits_to_int(qword[i*8:(i+1)*8]) for i in range(4)]

            res.append(mix_cols_word == qword)
        assert(res == [True] * trials)

    @staticmethod
    def MixColumn(in_place=True, cost=False):
        """
        TEST:
            >>> Tests.MixColumn(in_place=True)
            Testing MixColumn(in_place=True)
            >>> Tests.MixColumn(in_place=False)
            Testing MixColumn(in_place=False)
        """
        from random import randint
        print("%s MixColumn(in_place=%s)" %("Costing" if cost else "Testing", in_place))
        from QTests.AES import MixColumn # pylint: disable=no-name-in-module,import-error

        trials = 128
        res = []
        for _ in range(trials):
            state = {'Nb': 4, 'a': [[randint(0, 255) for _ in range(4)] for __ in range(4)]}
            # state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
            qstate = [[GF256Element(state['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
            qstate = [ [e for sub in qstate[j] for e in sub] for j in range(4)]
            qstate = [ i for e in qstate for i in e ]

            if cost:
                return MixColumn.estimate_resources(_state=qstate, in_place=in_place, costing=True)

            def bits_to_int(bits):
                return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])

            # Mixcols using GF256 library
            aes.MixColumn(state)

            # Mixcols using Q#
            qstate = MixColumn.toffoli_simulate(_state=qstate, in_place=in_place, costing=False)
            qstate = [[bits_to_int(qstate[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]

            res.append(state['a'] == qstate)
            if state['a'] != qstate:
                print (" state: ", state['a'])
                print ("qstate: ", qstate)
        assert(res == [True] * trials)

    @staticmethod
    def AddRoundKey(cost=False):
        """
        TEST:
            >>> Tests.AddRoundKey()
            Testing AddRoundKey
        """
        print("%s AddRoundKey" %("Costing" if cost else "Testing"))
        from random import randint
        from QTests.AES import AddRoundKey # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        trials = 128
        res = []
        for t in range(trials):
            state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
            key = [[randint(0, 255) for i in range(4)] for j in range(4)]
            qstate = [[GF256Element(state['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
            qstate = [ [e for sub in qstate[j] for e in sub] for j in range(4)]
            qstate = [ i for e in qstate for i in e ]
            qkey = [[GF256Element(key[j][i]).coeffs for i in range(4)] for j in range(4)]
            qkey = [ [e for sub in qkey[j] for e in sub] for j in range(4)]
            qkey = [ i for e in qkey for i in e ]
            if cost:
                return AddRoundKey.estimate_resources(_state=qstate, _round_key=qkey)
            aes.AddRoundKey(state, key)
            qstate = AddRoundKey.toffoli_simulate(_state=qstate, _round_key=qkey)
            qstate = [ [bits_to_int(qstate[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]
            res.append(state['a'] == qstate)
        assert(res == [True] * trials)

    @staticmethod
    def KeyExpansion(in_place=False, cost=False, Nr=10, Nk=4):
        """
        TEST:
            >>> Tests.KeyExpansion(in_place=True, Nr=10, Nk=4)
            Testing KeyExpansion(in_place=True, Nr=10, Nk=4)
            >>> Tests.KeyExpansion(in_place=True, Nr=12, Nk=6)
            Testing KeyExpansion(in_place=True, Nr=12, Nk=6)
            >>> Tests.KeyExpansion(in_place=True, Nr=14, Nk=8)
            Testing KeyExpansion(in_place=True, Nr=14, Nk=8)
            >>> Tests.KeyExpansion(in_place=False, Nr=10, Nk=4)
            Testing KeyExpansion(in_place=False, Nr=10, Nk=4)
            >>> Tests.KeyExpansion(in_place=False, Nr=12, Nk=6)
            Testing KeyExpansion(in_place=False, Nr=12, Nk=6)
            >>> Tests.KeyExpansion(in_place=False, Nr=14, Nk=8)
            Testing KeyExpansion(in_place=False, Nr=14, Nk=8)
        """
        print("%s KeyExpansion(in_place=%s, Nr=%d, Nk=%d)" %("Costing" if cost else "Testing", in_place, Nr, Nk))
        from random import randint
        if in_place:
            from QTests.AES import InPlaceKeyExpansion as KeyExpansion # pylint: disable=no-name-in-module,import-error
        else:
            from QTests.AES import KeyExpansion # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        trials = 1
        res = []
        for t in range(trials):
            key = {'Nb': 4, 'Nk': Nk, 'k': [ [randint(0, 255) for i in range(4)] for j in range(Nk)]}
            qkey = [GF256Element(key['k'][j][i]).coeffs for j in range(Nk) for i in range(4)]
            qkey = [e for sub in qkey for e in sub]
            if cost:
                return KeyExpansion.estimate_resources(_key=qkey, Nr=Nr, Nk=Nk, costing=True)

            key = aes.KeyExpansion(key, Nr)
            qkey = KeyExpansion.toffoli_simulate(_key=qkey, Nr=Nr, Nk=Nk, costing=False)
            qkey = [bits_to_int(qkey[i*8:(i+1)*8]) for i in range(len(qkey)//8)]
            qkey = [qkey[i*4:(i+1)*4] for i in range(len(qkey)//4)]
            qkey = [qkey[i*4:(i+1)*4] for i in range(len(qkey)//4)]
            if key != qkey:
                print('c', key)
                print('q', qkey)
            res.append(key == qkey)
        assert(res == [True] * trials)

    @staticmethod
    def Round(smart_wide=False, round=0, Nk=4, cost=False):
        """
        TEST:
            >>> Tests.Round(smart_wide=False, round=0, Nk=4)
            Testing Round(smart_wide=False, round=0, Nk=4)
        """
        print("%s Round(smart_wide=%s, round=%d, Nk=%d)" %("Costing" if cost else "Testing", smart_wide, round, Nk))
        from random import randint
        from QTests.AES import Round # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        trials = 32
        res = []
        for t in range(trials):
            state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
            key = [[randint(0, 255) for i in range(4)] for j in range(4)]
            qstate = [[GF256Element(state['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
            qstate = [ [e for sub in qstate[j] for e in sub] for j in range(4)]
            qstate = [ i for e in qstate for i in e ]
            qkey = [[GF256Element(key[j][i]).coeffs for i in range(4)] for j in range(4)]
            qkey = [ [e for sub in qkey[j] for e in sub] for j in range(4)]
            qkey = [ i for e in qkey for i in e ]
            if cost:
                return Round.estimate_resources(_state=qstate, _round_key=qkey, round=round, smart_wide=smart_wide, Nk=Nk, in_place_mixcolumn=True, costing=True)
            aes.Round(state, key)
            qstate = Round.toffoli_simulate(_state=qstate, _round_key=qkey, round=round, smart_wide=smart_wide, Nk=Nk, in_place_mixcolumn=True, costing=False)
            qstate = [ [bits_to_int(qstate[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]
            res.append(state['a'] == qstate)
        assert(res == [True] * trials)

    @staticmethod
    def FinalRound(smart_wide=True, Nr=10, cost=False):
        """
        TEST:
            >>> Tests.FinalRound(smart_wide=False)
            Testing FinalRound(smart_wide=False)
        """
        print("%s FinalRound(smart_wide=%s)" %("Costing" if cost else "Testing", smart_wide))
        from random import randint
        if smart_wide:
            pass
        else:
            from QTests.AES import FinalRound # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        trials = 32
        res = []
        for t in range(trials):
            state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
            key = [[randint(0, 255) for i in range(4)] for j in range(4)]
            qstate = [[GF256Element(state['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
            qstate = [ [e for sub in qstate[j] for e in sub] for j in range(4)]
            qstate = [ i for e in qstate for i in e ]
            qkey = [[GF256Element(key[j][i]).coeffs for i in range(4)] for j in range(4)]
            qkey = [ [e for sub in qkey[j] for e in sub] for j in range(4)]
            qkey = [ i for e in qkey for i in e ]
            if cost:
                return FinalRound.estimate_resources(_state=qstate, _round_key=qkey, smart_wide=smart_wide, Nr=Nr, costing=True)
            aes.FinalRound(state, key)
            qstate = FinalRound.toffoli_simulate(_state=qstate, _round_key=qkey, smart_wide=smart_wide, Nr=Nr, costing=False)
            qstate = [ [bits_to_int(qstate[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]
            res.append(state['a'] == qstate)
        assert(res == [True] * trials)

    @staticmethod
    def Rijndael(smart_wide=True, Nr=10, Nk=4, in_place_mixcolumn=False, cost=False):
        """
        TEST:
            >>> Tests.Rijndael(smart_wide=True, in_place_mixcolumn=False, Nr=10, Nk=4)
            Testing Rijndael(smart_wide=True, in_place_mixcolumn=False, Nr=10, Nk=4)
            >>> Tests.Rijndael(smart_wide=True, in_place_mixcolumn=False, Nr=12, Nk=6)
            Testing Rijndael(smart_wide=True, in_place_mixcolumn=False, Nr=12, Nk=6)
            >>> Tests.Rijndael(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8)
            Testing Rijndael(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8)
            >>> Tests.Rijndael(smart_wide=True, in_place_mixcolumn=True, Nr=10, Nk=4)
            Testing Rijndael(smart_wide=True, in_place_mixcolumn=True, Nr=10, Nk=4)
            >>> Tests.Rijndael(smart_wide=True, in_place_mixcolumn=True, Nr=12, Nk=6)
            Testing Rijndael(smart_wide=True, in_place_mixcolumn=True, Nr=12, Nk=6)
            >>> Tests.Rijndael(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8)
            Testing Rijndael(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8)
            >>> Tests.Rijndael(smart_wide=False, in_place_mixcolumn=True, Nr=10, Nk=4)
            Testing Rijndael(smart_wide=False, in_place_mixcolumn=True, Nr=10, Nk=4)
            >>> Tests.Rijndael(smart_wide=False, in_place_mixcolumn=True, Nr=12, Nk=6)
            Testing Rijndael(smart_wide=False, in_place_mixcolumn=True, Nr=12, Nk=6)
            >>> Tests.Rijndael(smart_wide=False, in_place_mixcolumn=True, Nr=14, Nk=8)
            Testing Rijndael(smart_wide=False, in_place_mixcolumn=True, Nr=14, Nk=8)
        """
        print("%s Rijndael(smart_wide=%s, in_place_mixcolumn=%s, Nr=%d, Nk=%d)" %("Costing" if cost else "Testing", smart_wide, in_place_mixcolumn, Nr, Nk))
        from random import randint
        if smart_wide:
            from QTests.AES import SmartWideRijndael as Rijndael # pylint: disable=no-name-in-module,import-error
        else:
            from QTests.AES import WideRijndael as Rijndael # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        trials = 4
        res = []
        for t in range(trials):
            message = {'Nb': 4, 'a': [[randint(0, 255) for i in range(4)] for j in range(4)]}
            key = {'Nb': 4, 'Nk': Nk, 'k': [ [randint(0, 255) for i in range(4)] for j in range(Nk)]}
            qmessage = [[GF256Element(message['a'][j][i]).coeffs for i in range(4)] for j in range(4)]
            qmessage = [ [e for sub in qmessage[j] for e in sub] for j in range(4)]
            qmessage = [ i for e in qmessage for i in e ]
            qkey = [[GF256Element(key['k'][j][i]).coeffs for i in range(4)] for j in range(Nk)]
            qkey = [ [e for sub in qkey[j] for e in sub] for j in range(Nk)]
            qkey = [ i for e in qkey for i in e ]
            if cost:
                return Rijndael.estimate_resources(_message=qmessage, _key=qkey, Nr=Nr, Nk=Nk, in_place_mixcolumn=in_place_mixcolumn, costing=True)
            # qstate = [e for sub in qstate for e in sub]
            aes.InnerRijndael(key, message, Nb=4, Nk=Nk, Nr=Nr)
            qmessage = Rijndael.toffoli_simulate(_message=qmessage, _key=qkey, Nr=Nr, Nk=Nk, in_place_mixcolumn=in_place_mixcolumn, costing=False)
            qmessage = [ [bits_to_int(qmessage[j][i*8:(i+1)*8]) for i in range(4)] for j in range(4)]
            if message['a'] != qmessage:
                print('c', message['a'])
                print('q', qmessage)
                print()
            res.append(message['a'] == qmessage)
        assert(res == [True] * trials)

    @staticmethod
    def GroverOracle(smart_wide=True, Nr=10, Nk=4, pairs=1, in_place_mixcolumn=False, cost=False):
        """
        TEST:
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=10, Nk=4, pairs=1)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=10, Nk=4, pairs=1)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=10, Nk=4, pairs=2)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=10, Nk=4, pairs=2)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=12, Nk=6, pairs=1)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=12, Nk=6, pairs=1)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=12, Nk=6, pairs=2)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=12, Nk=6, pairs=2)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8, pairs=1)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8, pairs=1)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8, pairs=2)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8, pairs=2)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=10, Nk=4, pairs=1)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=10, Nk=4, pairs=1)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=10, Nk=4, pairs=2)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=10, Nk=4, pairs=2)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=12, Nk=6, pairs=1)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=12, Nk=6, pairs=1)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=12, Nk=6, pairs=2)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=12, Nk=6, pairs=2)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8, pairs=1)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8, pairs=1)
            >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8, pairs=2)
            Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8, pairs=2)

        # >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8, pairs=3)
        # Testing GroverOracle(smart_wide=True, in_place_mixcolumn=False, Nr=14, Nk=8, pairs=3)
        # >>> Tests.GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8, pairs=3)
        # Testing GroverOracle(smart_wide=True, in_place_mixcolumn=True, Nr=14, Nk=8, pairs=3)
        """
        print("%s GroverOracle(smart_wide=%s, in_place_mixcolumn=%s, Nr=%d, Nk=%d, pairs=%d)" %("Costing" if cost else "Testing", smart_wide, in_place_mixcolumn, Nr, Nk, pairs))
        from random import randint
        if smart_wide:
            from QTests.AES import SmartWideGroverOracle as GroverOracle # pylint: disable=no-name-in-module,import-error
        def bits_to_int(bits):
            return sum([1 << i if bits[i] == 1 else 0 for i in range(8)])
        trials = 10
        res = []
        for t in range(trials):
            message = {'Nb': 4, 'a': [[randint(0, 255) for i in range(4)] for j in range(4*pairs)]}
            qmessage = [[GF256Element(message['a'][j][i]).coeffs for i in range(4)] for j in range(4*pairs)]
            qmessage = [ [e for sub in qmessage[j] for e in sub] for j in range(4*pairs)]
            qmessage = [ i for e in qmessage for i in e ]

            key = {'Nb': 4, 'Nk': Nk, 'k': [ [randint(0, 255) for i in range(4)] for j in range(Nk)]}
            qkey = [[GF256Element(key['k'][j][i]).coeffs for i in range(4)] for j in range(Nk)]
            qkey = [ [e for sub in qkey[j] for e in sub] for j in range(Nk)]
            qkey = [ i for e in qkey for i in e ]

            # compute p-c pairs
            ciphertexts = []
            for _ in range(pairs):
                ciphertext = {'Nb': 4, 'a': message['a'][_*4:(_+1)*4]}
                aes.InnerRijndael(key, ciphertext, Nb=4, Nk=Nk, Nr=Nr)
                ciphertexts.append(ciphertext)

            target_ciphertext = [[GF256Element(c['a'][j][i]).coeffs for i in range(4)] for c in ciphertexts for j in range(4)]
            target_ciphertext = [ [e for sub in target_ciphertext[j] for e in sub] for j in range(4*pairs)]
            target_ciphertext = [ i for e in target_ciphertext for i in e ]

            # test also that we correctly fail to identify wrong keys
            flip = bool(randint(0, 1))
            if flip:
                qkey[0] = 0 if qkey[0] == 1 else 1

            qgrover = GroverOracle.toffoli_simulate(_key=qkey, _plaintexts=qmessage, target_ciphertext=target_ciphertext, pairs=pairs, Nr=Nr, Nk=Nk, in_place_mixcolumn=in_place_mixcolumn, costing=False)
            res.append(qgrover == int(not flip))
        assert(res == [True] * trials)


def costs():
    # deprecated and incomplete, use C# Driver.cs
    print(Tests.Mul(unrolled=False, cost=True))
    print(Tests.Mul(unrolled=True, cost=True))
    print(Tests.Square(in_place=False, cost=True))
    print(Tests.Square(in_place=True, cost=True))
    print(Tests.Fourth(in_place=False, cost=True))
    print(Tests.Fourth(in_place=True, cost=True))
    print(Tests.Sixteenth(cost=True))
    print(Tests.SixtyFourth(in_place=True, cost=True))
    print(Tests.Inverse(cost=True))
    print(Tests.SBox(cost=True))
    print(Tests.ByteSub(cost=True))
    print(Tests.ShiftRow(cost=True))
    print(Tests.MixWord(cost=True))
    print(Tests.MixColumn(cost=True))
    print(Tests.AddRoundKey(cost=True))
    print(Tests.KeyExpansion(in_place=False, Nr=10, Nk=4, cost=True))
    print(Tests.KeyExpansion(in_place=False, Nr=12, Nk=6, cost=True))
    print(Tests.KeyExpansion(in_place=False, Nr=14, Nk=8, cost=True))
    print(Tests.KeyExpansion(in_place=True, Nr=10, Nk=4, cost=True))
    print(Tests.KeyExpansion(in_place=True, Nr=12, Nk=6, cost=True))
    print(Tests.KeyExpansion(in_place=True, Nr=14, Nk=8, cost=True))
    print(Tests.Round(cost=True))
    print(Tests.FinalRound(cost=True))
    print(Tests.Rijndael(smart_wide=True, Nr=10, Nk=4, cost=True))
    print(Tests.Rijndael(smart_wide=True, Nr=12, Nk=6, cost=True))
    print(Tests.Rijndael(smart_wide=True, Nr=14, Nk=8, cost=True))
    print(Tests.Rijndael(smart_wide=False, Nr=10, Nk=4, cost=True))
    print(Tests.Rijndael(smart_wide=False, Nr=12, Nk=6, cost=True))
    print(Tests.Rijndael(smart_wide=False, Nr=14, Nk=8, cost=True))


if __name__ == "__main__":
    import doctest
    doctest.testmod()
