# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
"""
In Picnic notation:
    n The LowMC key and blocksize, in bits.
    s The LowMC number of s-boxes.
    r The LowMC number of rounds

L1
    n 128
    s 10
    r 20

L3
    n 192
    s 10
    r 30

L5
    n 256
    s 10
    r 38
"""

def toffoli(a, b, c):
    """
    Compute c + ab over GF2.

    :param a: bit
    :param b: bit
    :param c: bit

    TESTS:
        >>> toffoli(0, 0, 0)
        0
        >>> toffoli(0, 0, 1)
        1
        >>> toffoli(0, 1, 0)
        0
        >>> toffoli(0, 1, 1)
        1
        >>> toffoli(1, 0, 0)
        0
        >>> toffoli(1, 0, 1)
        1
        >>> toffoli(1, 1, 0)
        1
        >>> toffoli(1, 1, 1)
        0
    """
    assert(a in [0, 1])
    assert(b in [0, 1])
    assert(c in [0, 1])
    return c ^ (a & b)


def RoundKey(k, t, scheme, in_place=False, IKM=None):
    """
    Returns rk^t

    :param k: key
    :param t: round
    :param scheme: lowmc parametrization + constants

    TESTS:
        >>> import L1
        >>> LowMCL1 = { 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 }
        >>> str_to_buf = lambda s: [0 if s[i] == '0' else 1 for i in range(len(s))]
        >>> from in_place_km_L1 import IKM
        >>> LowMCL1['IKM'] = IKM
        >>> # Testing L1
        >>> k = str_to_buf("10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        >>> rks = []
        >>> irks = []
        >>> for t in range(LowMCL1['rounds'] + 1): rks.append(RoundKey(k, t, LowMCL1, in_place=False))
        >>> for t in range(LowMCL1['rounds'] + 1): irks.append(RoundKey(k if t == 0 else irks[-1], t, LowMCL1, in_place=True, IKM=IKM))
        >>> assert(rks == irks)
        >>> kk = RoundKey(irks[-1], LowMCL1['rounds'] + 1, LowMCL1, in_place=True, IKM=IKM)
        >>> assert(kk == k)
    """
    rk = []
    for i in range(scheme['blocksize']):
        if in_place: # this branch only exists to verify possibility of expanding the round keys in-place
            rk_i = sum([k[j] & IKM[t][i][j] for j in range(scheme['keysize'])]) % 2
        else:
            rk_i = sum([k[j] & scheme['KM'][t][i][j] for j in range(scheme['keysize'])]) % 2
        rk.append(rk_i)
    return rk


def KeyAddition(s, rks, t, scheme, in_place=False):
    """
    KeyAddition function from LowMC spec.

    :params s:  state
    :params rks: round keys
    :params t:  round
    :param scheme: lowmc parametrization + constants
    """
    if in_place:
        return [s[i] ^ rks[i] for i in range(scheme['blocksize'])]
    else:
        return [s[i] ^ rks[t][i] for i in range(scheme['blocksize'])]


def ConstantAddition(s, t, scheme):
    """
    ConstantAddition function from LowMC spec.

    :params s:  state
    :params bs: round constants
    :params t:  round
    :param scheme: lowmc parametrization + constants
    """
    return [s[i] ^ scheme['b'][t-1][i] for i in range(scheme['blocksize'])]


def LinearLayer(s, t, scheme):
    """
    Compute LinearLayer matrix multiplication.

    :params s:  state
    :params t:  round
    :param scheme: lowmc parametrization + constants
    """
    ll = []
    for i in range(scheme['blocksize']):
        ll_i = sum([s[j] & scheme['LM'][t-1][i][j] for j in range(scheme['blocksize'])]) % 2
        ll.append(ll_i)
    return ll


def Sbox(a, b, c):
    """
    LowMC 3-bit S-box.
    TESTS:
        >>> inp = [(0,0,0),(0,0,1),(0,1,0),(0,1,1),(1,0,0),(1,0,1),(1,1,0),(1,1,1)]
        >>> [Sbox(t[0], t[1], t[2]) for t in inp] == [(0,0,0), (0,0,1), (0,1,1), (1,1,0), (1,1,1), (1,0,0), (1,0,1), (0,1,0)]
        True
    """
    # from the LowMC paper
    return (toffoli(b, c, a), a ^ toffoli(a, c, b), a ^ b ^ toffoli(a, b, c))

    # Lowest gate count and total depth, no extra wires
    # a ^= b & c
    # b ^= a & c
    # c ^= a & b
    # b ^= a
    # c ^= b
    # return (a, b, c)

    # Lowest T-depth
    # aa = a
    # bb = b
    # cc = c

    # z = a & b
    # y = c & aa
    # x = bb & cc

    # x ^= aa
    # y ^= bb
    # z ^= cc

    # y ^= aa
    # z ^= bb

    # z ^= aa
    # return (x, y, z)


def SboxLayer(s, scheme):
    """
    Apply S-box layer to the state.

    :params s:  state
    :param scheme: lowmc parametrization + constants
    """
    for i in range(scheme['blocksize']-1, scheme['blocksize'] - 1 - 3 * scheme['sboxes'], -3):
        triple = Sbox(s[i-2], s[i-1], s[i])
        for j in range(3):
            s[i-j] = triple[2-j]
    return s


def LowMCRound(s, rks, t, scheme, in_place=False):
    """
    Compute a LowMC round.
    :params s:  state
    :params rk: round key
    :params t:  round
    :param scheme: lowmc parametrization + constants
    """
    s = SboxLayer(s, scheme)
    s = LinearLayer(s, t, scheme)
    s = ConstantAddition(s, t, scheme)
    s = KeyAddition(s, rks, t, scheme, in_place=in_place)
    return s


def Encrypt(k, m, scheme):
    """
    LowMC block evaluation.

    :params k:  key
    :params m:  message
    :param scheme: lowmc parametrization + constants

    TESTS:
        # >>> import L1
        # >>> import L3
        # >>> import L5
        # >>> LowMCL1 = { 'rounds': L1.rounds, 'blocksize': L1.blocksize, 'keysize': L1.keysize, 'KM': L1.KM, 'LM': L1.LM, 'b': L1.b, 'sboxes': 10 }
        # >>> LowMCL3 = { 'rounds': L3.rounds, 'blocksize': L3.blocksize, 'keysize': L3.keysize, 'KM': L3.KM, 'LM': L3.LM, 'b': L3.b, 'sboxes': 10 }
        # >>> LowMCL5 = { 'rounds': L5.rounds, 'blocksize': L5.blocksize, 'keysize': L5.keysize, 'KM': L5.KM, 'LM': L5.LM, 'b': L5.b, 'sboxes': 10 }
        # >>> str_to_buf = lambda s: [0 if s[i] == '0' else 1 for i in range(len(s))]
        # >>> # Testing L1
        # >>> k = str_to_buf("10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        # >>> m = str_to_buf("10101011111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        # >>> c = str_to_buf("01000101011001010111011101011001101111001110000110101110010000110110000010010101001001110010110110111010011101111001000110000101")
        # >>> c == Encrypt(k, m, LowMCL1)
        # True
        # >>> k = str_to_buf("10110100110100111111111101110011011101010110101101001110111100111100000100110010111111110000000110100110001101100111001001010110")
        # >>> m = str_to_buf("01110010001110100010100010100011000101010000101110000001101110100010100101110000010011100000111100010101010001010011001010100011")
        # >>> c = str_to_buf("10111100011110000011100111001100011111100110010011100101011001110011011111001111100100110111110101001000011111101111110011110001")
        # >>> c == Encrypt(k, m, LowMCL1)
        # True
        # >>> k = str_to_buf("01000010100010010101110101100011111001110000001000010110111000000000000110100101000101000100110101100101111101101000001110011001")
        # >>> m = str_to_buf("00110010010011101100011100010001001111111111001101100011110000101011111110111010001110111111000011011001101001011110110110110010")
        # >>> c = str_to_buf("01011111010010100001011100110000011111000000101100100110111110010101111100000000111001111101110101001001011110110010001100010110")
        # >>> c == Encrypt(k, m, LowMCL1)
        # True
        # >>> # Testing L3
        # >>> k = str_to_buf('100001100000000000110100100010101010111000001101101000000001000000100101110000000010101001010100000010110001100001110111011111111110100001111111110100000001101000101110110010110010000011100001')
        # >>> m = str_to_buf('101001101111110110100000110010100100011010110001110010110001001000100010100110101111011110001011110101111011011100101000101010100000100110110011100101011101010101101010111110101111101011000101')
        # >>> c = str_to_buf('100001010011000111101100011000000000001011001100110010001100001101000000101111000010000101001010111000001111011011101000111111101111100100110101000011001011011010001010101011101111000110100010')
        # >>> c == Encrypt(k, m, LowMCL3)
        # True
        # >>> k = str_to_buf('101000010110001101001100011000001001000010001110000010010011011101001101011011010100011111010101110111001110110000110111000010111110110000110101001111111000011111011111001110001010010110100001')
        # >>> m = str_to_buf('000110000010001001111101101011100011011110000100100010001010100101100010101010100110000010001100110000011001100100001000010001001010100110110101011110001100110010110001010100010000001110000000')
        # >>> c = str_to_buf('010110110110110101110100101010110111010001001111100001010000100011110101001000111010010000011001000110000101001100100100000111010010111100110001000011110011110101101001100011010011010001011001')
        # >>> c == Encrypt(k, m, LowMCL3)
        # True
        # >>> k = str_to_buf('100111100001100010111010111100101011010100110011101010101111100101011001000110001100101001010000110110010101000011101000101101001010001010001111001110011010101111111011100100011000111010101011')
        # >>> m = str_to_buf('101011101111001111010001000000111000010100001110110010100001110001010000111110101000101010101001110010000010011011001100011000100001101101011111011101111111001000011011111000111001100011101001')
        # >>> c = str_to_buf('010100100011010100111000000110011011000010010001101110111010100100010101000011010011111111011001111100000000000000100111111011011100110011011101010110100100001101111000100110001100111100011011')
        # >>> c == Encrypt(k, m, LowMCL3)
        # True
        # >>> k = str_to_buf('1100100100100011100000001011000000001010110101000011110001000010000010001011111100110111011001111111001010110101000011111111100001101010010101100111110100100000101110011001001101000010110110101000011100010110111101001010110010100010101011000000111101000001')
        # >>> m = str_to_buf('0101001110000011010100110111101101001000111111111111100100011001000110100010110001010011010001011100010010000110101010110101011011001110110110111000001111000101101100100100001110110011100001001000101010000011101101100111011000101110101110101111100010010100')
        # >>> c = str_to_buf('1000100000110110100011100101011101000011000000001000100101001100000010100101100000000011011100100011111011010111001111010010110001110101001000000110101001000000011010101010000111111011010000001101111001010000010110100011001100001101101100100110000110010000')
        # >>> c == Encrypt(k, m, LowMCL5)
        # True
        # >>> k = str_to_buf('0011111001100000100111110101000100010100001010100100110100110111101000001000110010011101001100010011000101001011000011101111101010110110010000000110001000000100110001000101101001111001000001010101110000000001101100101110101001001000100000100010000000100100')
        # >>> m = str_to_buf('1101110001001101110001111010001111100100100000001000101011011010010110100111101011110100001000000010001001010001101101010101010010000011010101101110000010101011101011010100001110001010111101100000001111111101000001010011100100110000000010100000011001111010')
        # >>> c = str_to_buf('1110011011111010011000110100111101111000011001110010001011110100111010100001001011011100110011111111000111110000000110100110111000111001001110011011110001010100101101001011101001001101011111010101000101101001010000111000110110101111100000110011001100100100')
        # >>> c == Encrypt(k, m, LowMCL5)
        # True
        # >>> k = str_to_buf('1111110011000000110011111100101001001110100011001101001101101110111001110101001011000010001100100110000111100101011100000001101101011111000101010011100001010001100011010000001111111001001000100010000001010111110010001100010000000100001100011001011001000001')
        # >>> m = str_to_buf('0101110000111000000100010011110000110101010000011101110100111100000101100101110110001101100111011011001001100101011000010110100011010001111011111000000110111000010011101111001100111111111101100110100101010001101111111100000101010001000111000010001001010101')
        # >>> c = str_to_buf('0001101011100010000110010000111110011101110100111110101111010110111111101011001101001111101111000000100111110001011010000010001100001101111010111111010000000101010111101001110010111101001101001110011110011110010010000101110000001001001000110100101011101000')
        # >>> c == Encrypt(k, m, LowMCL5)
        # True
    """
    rks = [RoundKey(k, t, scheme) for t in range(scheme['rounds'] + 1)]
    s = KeyAddition(m, rks, 0, scheme)
    for t in range(1, scheme['rounds']+1):
        s = LowMCRound(s, rks, t, scheme)
    return s


def print_buf(buf, lable=""):
    print(lable + (" " if lable != "" else "") + "".join(map(str, buf)))


def str_to_buf(s):
    return [0 if s[i] == '0' else 1 for i in range(len(s))]


if __name__ == "__main__":
    import doctest
    doctest.testmod()
