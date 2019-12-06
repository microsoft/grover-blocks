# Copyright (c) Microsoft Corporation.// Licensed under the MIT license.
from gf256 import GF256Element, GF256Poly

COUNT = 0
def GenState(Nb, message):
    if Nb not in [4, 6, 8]:
        raise ValueError("Nb not supported")
    return {'Nb': Nb, 'a': [ message[4*j:4*(j+1)] for j in range(0, Nb)]}


def GenKey(Nb, Nk, random_bytes):
    if Nk not in [4, 6, 8]:
        raise ValueError("Nk not supported")

    if len(random_bytes) != 4 * Nk:
        raise ValueError("Key material provided has wrong length %d != 4 * Nk = %d" % (len(random_bytes), 4 * Nk))

    return {'Nb': Nb, 'Nk': Nk, 'k': [ [random_bytes[i + 4 * j] for i in range(4)] for j in range(Nk)]}


def SBox(x):
    """
    TEST:
    >>> SBOX = [
    ...     0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    ...     0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    ...     0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    ...     0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    ...     0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    ...     0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    ...     0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    ...     0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    ...     0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    ...     0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    ...     0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    ...     0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    ...     0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    ...     0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    ...     0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    ...     0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
    ... ]
    >>> SBOX == list(map(SBox, range(256)))
    True
    """
    global COUNT
    a_ij = GF256Element(x)
    a_ij_inverse = a_ij.inverse()
    COUNT += 1
    b_ij = GF256Element(GF256Element.mul_mod(a_ij_inverse, GF256Element([1, 1, 1, 1, 1, 0, 0, 0]), [1, 0, 0, 0, 0, 0, 0, 0, 1])) + GF256Element([1, 1, 0, 0, 0, 1, 1, 0])
    return int(b_ij)


def SBoxInv(x):
    """
    TEST:
    >>> SBOXINV = [
    ...     0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    ...     0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    ...     0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    ...     0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    ...     0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    ...     0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    ...     0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    ...     0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    ...     0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    ...     0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    ...     0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    ...     0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    ...     0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    ...     0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    ...     0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    ...     0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
    ... ]
    >>> SBOXINV == list(map(SBoxInv, range(256)))
    True
    """
    a_ij = GF256Element(x)
    a_ij = GF256Element(GF256Element.mul_mod(a_ij, GF256Element([0, 1, 0, 1, 0, 0, 1, 0]), [1, 0, 0, 0, 0, 0, 0, 0, 1])) + GF256Element([1, 0, 1, 0, 0, 0, 0, 0])
    b_ij = a_ij.inverse()
    return sum([b_ij[k] * (1 << k) for k in range(8)])


def ByteSub(state, inverse=False):
    # parallel for
    for i in range(4):
        for j in range(state['Nb']):
            state['a'][j][i] = (SBoxInv if inverse else SBox)(state['a'][j][i])


def ShiftRow(state, inverse=False):
    """
    TEST:
        >>> state = {'Nb': 4, 'a': [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]}
        >>> ShiftRow(state)
        >>> state['a'] == [[0, 5, 10, 15], [4, 9, 14, 3], [8, 13, 2, 7], [12, 1, 6, 11]]
        True
        >>> ShiftRow(state, inverse=True)
        >>> state['a'] == [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]
        True
    """
    Nb = state['Nb']
    if Nb == 4 or Nb == 6:
        C = [0, 1, 2, 3]
    elif Nb == 8:
        C = [0, 1, 3, 4]
    else:
        raise ValueError("Nb = %d not valid" % Nb)
    if inverse:
        C = [Nb - c for c in C]

    state['a'] = [ [ state['a'][(j + C[i]) % Nb][i] for i in range(4) ] for j in range(Nb)]


def MixColumn(state, inverse=False):
    """
    TEST:
    """
    if inverse:
        c = GF256Poly([0x0E, 0x09, 0x0D, 0x0B])
    else:
        c = GF256Poly([0x02, 0x01, 0x01, 0x03])

    Nb = state['Nb']
    for j in range(Nb):
        a_x = GF256Poly(state['a'][j])
        ca_x = c * a_x
        state['a'][j] = [int(co) for co in ca_x.coeffs]


def RotByte(word):
    """
    Part of KeyExpansion.
    TEST:
        >>> RotByte([1, 2, 3, 4]) == [2, 3, 4, 1]
        True
    """
    return word[1:4] + [word[0]]


def SubByte(word):
    """
    Part of KeyExpansion.
    TEST:
        >>> SubByte([1, 2, 3, 4]) == [0x7c, 0x77, 0x7b, 0xf2]
        True
    """
    return list(map(SBox, word))


def KeyExpansion(key, Nr, debug=False):
    Nb = key['Nb']
    Nk = key['Nk']
    W = [[0] * 4 for _ in range(Nb*(Nr + 1))]
    x = GF256Element(2)

    for i in range(Nk):
        W[i] = key['k'][i]

    for i in range(Nk, Nb * (Nr + 1)):
        temp = W[i - 1]

        if i % Nk == 0:
            temp = SubByte(RotByte(temp))
            if debug:
                # print(i//Nk, (i//Nk - 1) % 255, hex(int(x ** ((i//Nk - 1) % 255))))
                pass
            temp[0] ^= int(x ** ((i//Nk - 1) % 255))
        elif i % Nk == 4 and Nk > 6:
            temp = SubByte(temp)
        W[i] = [W[i - Nk][j] ^ temp[j] for j in range(4)]

    return [W[i:i+Nb] for i in range(0, Nb*(Nr + 1), Nb)]


def AddRoundKey(state, round_key, debug=False):
    Nb = state['Nb']
    if debug:
        # for i in range(4):
        #     for j in range(Nb):
        #         print (hex(state['a'][j][i])[2:], hex(round_key[j][i])[2:])
        pass
    state['a'] = [ [ state['a'][j][i] ^ round_key[j][i] for i in range(4)] for j in range(Nb) ]


def Round(state, round_key, i=None, debug=False):
    ByteSub(state)
    if debug:
        print("ByteSub(%d)" % i)
        print_state(state['a'])
        print()
    ShiftRow(state)
    if debug:
        print("ShiftRow(%d)" % i)
        print_state(state['a'])
        print()
    MixColumn(state)
    if debug:
        print("MixColumn(%d)" % i)
        print_state(state['a'])
        print()
    AddRoundKey(state, round_key)


def InvRound(state, round_key, i=None, debug=False):
    AddRoundKey(state, round_key)
    MixColumn(state, inverse=True)
    if debug:
        print("MixColumn(%d)" % i)
        print_state(state['a'])
        print()
    ShiftRow(state, inverse=True)
    if debug:
        print("ShiftRow(%d)" % i)
        print_state(state['a'])
        print()
    ByteSub(state, inverse=True)
    if debug:
        print("ByteSub(%d)" % i)
        print_state(state['a'])
        print()


def FinalRound(state, round_key, debug=False):
    ByteSub(state)
    if debug:
        print("ByteSub(last)")
        print_state(state['a'])
        print()
    ShiftRow(state)
    if debug:
        print("ShiftRow(last)")
        print_state(state['a'])
        print()
    AddRoundKey(state, round_key)
    if debug:
        print("MixColumn(last)")
        print_state(state['a'])
        print()


def InvFinalRound(state, round_key, debug=False):
    AddRoundKey(state, round_key)
    if debug:
        print("MixColumn(last)")
        print_state(state['a'])
        print()
    ShiftRow(state, inverse=True)
    if debug:
        print("ShiftRow(last)")
        print_state(state['a'])
        print()
    ByteSub(state, inverse=True)
    if debug:
        print("ByteSub(last)")
        print_state(state['a'])
        print()


def print_state(a):
    print(" ".join([hex(l[i])[2:] for l in a for i in range(4)]))


def InnerRijndael(key, state, Nb=4, Nk=8, Nr=14, debug=False):

    expanded_key = KeyExpansion(key, Nr, debug=debug)
    if debug:
        print("Expanded key:")
        for _ in expanded_key:
            print_state(_)

    AddRoundKey(state, expanded_key[0], debug=debug)
    if debug:
        print("AddRoundKey(0)")
        print_state(state['a'])
        print()

    for i in range(1, Nr):
        Round(state, expanded_key[i], i=i, debug=debug)
        if debug:
            print("Round(%d)" % i)
            print_state(state['a'])
            print()

    FinalRound(state, expanded_key[Nr], debug=debug)
    if debug:
        print("Round(Final)")
        print_state(state['a'])
        print()

    return bytes(bytearray([l[i] for l in state['a'] for i in range(4)]))


def Rijndael(message, cipher_key, Nb=4, Nk=8, Nr=14, debug=False):
    key = GenKey(Nb, Nk, cipher_key)
    state = GenState(Nb, message)

    if debug:
        print ('Message:')
        print(message.hex())
        print()
        print ('Initial state')
        print_state(state['a'])
        print()

    return InnerRijndael(key, state, Nb=Nb, Nk=Nk, Nr=Nr, debug=debug)


def InvRijndael(ciphertext, cipher_key, Nb=4, Nk=8, Nr=14, debug=False):
    key = GenKey(Nb, Nk, cipher_key)
    state = GenState(Nb, ciphertext)

    if debug:
        print ('Ciphertext:')
        print(ciphertext.hex())
        print()
        print ('Initial state')
        print_state(state['a'])
        print()

    expanded_key = KeyExpansion(key, Nr, debug=debug)

    if debug:
        print("Expanded key:")
        for _ in expanded_key:
            print_state(_)

    InvFinalRound(state, expanded_key[Nr], debug=debug)
    if debug:
        print("InvRound(Final)")
        print_state(state['a'])
        print()


    for i in range(Nr-1, 0, -1):
        InvRound(state, expanded_key[i], i=i, debug=debug)
        if debug:
            print("InvRound(%d)" % i)
            print_state(state['a'])
            print()

    AddRoundKey(state, expanded_key[0], debug=debug)
    if debug:
        print("AddRoundKey(0)")
        print_state(state['a'])
        print()

    return bytes(bytearray([l[i] for l in state['a'] for i in range(4)]))

"""
def main():
    from Crypto.Cipher import AES

    key = b'\xe4\xce\xc61i\xf4\xaf\x8c\x19W\xd6\x90\xe94\x1e*\xbe\xbb\x1aX\x05\xb8L\x02\xb2H\xb9\x8d[\xb8H\x97'
    # s = ""
    # for k in key:
    #     s += "(uint8_t) %s, " % hex(k)
    # print (s)
    # print()
    # print()
    message = b'\xa6L\xf4,\xfdcu&\xc4-\xd7\xa2\xf7\xa4\xf7\x9f'
    # s = ""
    # for k in message:
    #     s += "(uint8_t) %s, " % hex(k)
    # print (s)

    # key = b"\x00" * 32
    # message = b"\x01" * 16
    # cipher = AES.new(key, AES.MODE_ECB)
    # ciphertext1 = cipher.encrypt(message)
    # ciphertext1 = [hex(b) for b in ciphertext1]
    ciphertext2 = Rijndael(message, key)

    # print("AES256   = %s" % ciphertext1)
    # print("Rijndael = %s" % ciphertext2)
"""

def test(tries=128):
    from Crypto.Cipher import AES
    import secrets

    params = {
        16: {'Nb': 4, 'Nk': 4, 'Nr': 10},
        24: {'Nb': 4, 'Nk': 6, 'Nr': 12},
        32: {'Nb': 4, 'Nk': 8, 'Nr': 14}
    }

    for keylen in [16, 24, 32]:
        res = []
        for _ in range(tries):
            if _ % 32 == 0: print (_)
            # print (_)
            key = secrets.token_bytes(keylen)
            message = secrets.token_bytes(16)
            cipher = AES.new(key, AES.MODE_ECB)
            ciphertext1 = cipher.encrypt(message)
            ciphertext2 = Rijndael(message, key, debug=False, **params[keylen])
            recovered_message = InvRijndael(ciphertext2, key, debug=False, **params[keylen])
            res.append(ciphertext1 == ciphertext2 and message == recovered_message)
            if ciphertext1 != ciphertext2:
                print (key)
                print (message)

            # print("AES256   = %s" % ciphertext1)
            # print("Rijndael = %s" % ciphertext2)
        assert(res == [True] * tries)
        print("Keylen %d: success over %d tries!" % (keylen, tries))


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    # import cProfile
    # cProfile.run("test()")
    # main()
    # test(4)

    # import secrets
    # for keylen in [16, 24, 32]:
    #     COUNT = 0
    #     key = secrets.token_bytes(keylen)
    #     message = secrets.token_bytes(16)
    #     params = {
    #         16: {'Nb': 4, 'Nk': 4, 'Nr': 10},
    #         24: {'Nb': 4, 'Nk': 6, 'Nr': 12},
    #         32: {'Nb': 4, 'Nk': 8, 'Nr': 14}
    #     }
    #     ciphertext2 = Rijndael(message, key, debug=False, **params[keylen])
    #     print("keylen %d inversions %d" % (keylen, COUNT))
