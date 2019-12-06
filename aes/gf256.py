# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
class GF256Element:

    _m = [1, 1, 0, 1, 1, 0, 0, 0, 1] # m(x) = x**8 + x**4 + x**3 + x + 1

    def __init__(self, coeffs):
        if isinstance(coeffs, int):
            if coeffs not in range(256):
                raise ValueError("%d not a byte" % coeffs)
            coeffs = [int(bool(coeffs & (1 << i))) for i in range(8)]
        elif isinstance(coeffs, GF256Element):
            coeffs = coeffs.coeffs
        self._coeffs = GF256Element.reduce(coeffs)

    @staticmethod
    def one():
        return GF256Element([1])

    @staticmethod
    def zero():
        return GF256Element([0])

    @staticmethod
    def reduce(coeffs):
        """
        TEST:
            >>> GF256Element.reduce([1])
            [1, 0, 0, 0, 0, 0, 0, 0]
            >>> GF256Element.reduce([0, 1])
            [0, 1, 0, 0, 0, 0, 0, 0]
            >>> GF256Element.reduce([0, 1, 0, 0, 0, 0, 0, 0])
            [0, 1, 0, 0, 0, 0, 0, 0]
            >>> GF256Element.reduce([1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1])
            [1, 0, 0, 0, 0, 0, 1, 1]
        """
        return GF256Element.reduce_mod_m(coeffs, GF256Element._m)

    @staticmethod
    def reduce_mod_m(coeffs, char_poly):
        """
        TEST:
            >>> GF256Element.reduce_mod_m([1], [1, 0, 1])
            [1, 0]
            >>> GF256Element.reduce_mod_m([0, 1], [1, 0, 1])
            [0, 1]
            >>> GF256Element.reduce_mod_m([0, 1, 0, 0, 0, 0, 0, 0], [1, 0, 1])
            [0, 1]
            >>> GF256Element.reduce_mod_m([1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1], [1, 0, 1])
            [0, 1]
            >>> GF256Element.reduce_mod_m([1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1], [0, 0, 1])
            [1, 0]
        """
        char_poly = [x % 2 for x in char_poly]
        deg = len(char_poly) - 1
        c = [x % 2 for x in coeffs]
        if len(c) < deg:
            c += [0] * (deg - len(c))

        for i in range(len(c)-1, deg - 1, -1):
            if c[i] == 1:
                for j in range(deg + 1):
                    c[i - deg + j] += char_poly[j]
                    c[i - deg + j] %= 2
        return c[:deg]

    @property
    def coeffs(self):
        return self._coeffs

    def __getitem__(self, key):
        return self.coeffs[key]

    def __repr__(self):
        c = self.coeffs
        if c == [0] * 8:
            return "0"
        elif c == [1, 0, 0, 0, 0, 0, 0, 0]:
            return "1"
        else:
            return " + ".join(["x^%d" % i for i in range(len(c)-1, 0, -1) if c[i] == 1]) + ((" + 1" if c[1:7] != [0] * 7 else "1") if c[0] == 1 else "")

    def __add__(self, other):
        """
        TEST:
            >>> from random import randint
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = randint(0, 255)
            ...     y = randint(0, 255)
            ...     X = GF256Element(x)
            ...     Y = GF256Element(y)
            ...     res.append(X + Y == GF256Element(x^y))
            >>> res == [True] * trials
            True
        """
        return GF256Element([(self.coeffs[i] + other.coeffs[i]) % 2 for i in range(8)])

    def __mul__(self, other):
        """
        TEST:
            >>> x = GF256Element([1,1,1,0,1,0,1,0])
            >>> y = GF256Element([1,1,0,0,0,0,0,1])
            >>> xy = GF256Element([1,0,0,0,0,0,1,1])
            >>> z = GF256Element([1])
            >>> x*z == x
            True
            >>> y*z == y
            True
            >>> x*y == xy
            True
        """
        # schoolbook
        # x = self.coeffs
        # y = other.coeffs
        # xy = [0] * 16

        # for j in range(8):
        #     for i in range(8):
        #         xy[i+j] += y[j] * x[i]
        return GF256Element(self.mul_mod(self, other, GF256Element._m))

    @staticmethod
    def mul_mod(self, other, min_poly):
        """
        TEST:
            >>> x = GF256Element([1,1,1,0,1,0,1,0])
            >>> y = GF256Element([1,1,0,0,0,0,0,1])
            >>> xy = GF256Element([1,0,0,0,0,0,1,1])
            >>> z = GF256Element([1])
            >>> x*z == x
            True
            >>> y*z == y
            True
            >>> x*y == xy
            True
        """
        # schoolbook
        x = self.coeffs
        y = other.coeffs
        xy = [0] * 16

        for j in range(8):
            for i in range(8):
                xy[i+j] += y[j] * x[i]

        return GF256Element.reduce_mod_m(xy, min_poly)

    def __lshift__(self, shift):
        """
        TEST:
            >>> x = GF256Element([1])
            >>> y = GF256Element([0,1])
            >>> z = GF256Element([0,0,0,0,0,0,0,1])
            >>> zero = GF256Element([0])
            >>> (x<<1) == y
            True
            >>> (z<<1) == zero
            True
        """
        c = [0] + self.coeffs[:7]
        return GF256Element(c)

    def xtime(self):
        """
        TEST:
            >>> x = GF256Element([0, 1])
            >>> from random import randint
            >>> res1 = []
            >>> res2 = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     y = randint(0, 255)
            ...     Y = GF256Element(y)
            ...     Z = Y.xtime()
            ...     if (x*Y != Z):
            ...         print (x, Y, x*Y, Z)
            ...     res1.append(x*Y == Z)
            ...     res2.append(x*Y == GF256Element(((y<<1)^(0x1b if y > 127 else 0)) & 255))
            >>> res1 == [True] * trials
            True
            >>> res2 == [True] * trials
            True
        """
        up = self << 1
        if self.coeffs[7] == 1:
            return up + GF256Element([1,1,0,1,1])
        else:
            return up

    def __pow__(self, degree):
        """
        SLOW: should do square/multiply
        TEST:
            >>> x = GF256Element([0, 1])
            >>> y = x.xtime()
            >>> y == x**2
            True
        """
        acc = GF256Element.one()
        for _ in range(degree):
            acc *= self
        return acc

    def inverse(self):
        """
        TEST:
            >>> from random import randint
            >>> one = GF256Element([1])
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = randint(0, 255)
            ...     X = GF256Element(x)
            ...     X_inv = X.inverse()
            ...     res.append(X*X_inv == (GF256Element.one() if X != 0 else GF256Element.zero()))
            >>> res == [True] * trials
            True
        """
        cube = self * self**2
        return (cube*cube**4*cube**16*self**64)**2
        # return self ** 254

    def __eq__(self, other):
        """
        TEST:
            >>> from random import randint
            >>> bits = lambda x: [int(bool(x & (1 << i))) for i in range(8)]
            >>> one = GF256Element([1])
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = randint(0, 255)
            ...     X = GF256Element(x)
            ...     res.append([X == X, X == GF256Element(bits(x)), X == GF256Element(x)])
            >>> res == [[True, True, True]] * trials
            True
        """
        if isinstance(other, GF256Element):
            return self.coeffs == other.coeffs
        else:
            return self.coeffs == GF256Element(other).coeffs

    def __ne__(self, other):
        """
        TEST:
            >>> from random import randint
            >>> one = GF256Element([1])
            >>> bits = lambda x: [int(bool(x & (1 << i))) for i in range(8)]
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = randint(0, 255)
            ...     X = GF256Element(bits(x))
            ...     res.append([X != X, X != GF256Element(bits(x)), X != GF256Element(x), X + GF256Element.one() != X])
            >>> res == [[False, False, False, True]] * trials
            True
        """
        return not self.__eq__(other)

    def __int__(self):
        """
        TEST:
            >>> res = []
            >>> trials = 256
            >>> for i in range(trials):
            ...     I = GF256Element(i)
            ...     res.append(int(I) == i)
            >>> res == [True] * trials
            True
        """
        return sum([self[k] * (1 << k) for k in range(8)])


class GF256Poly:

    _f = [GF256Element.one(), GF256Element.zero(), GF256Element.zero(), GF256Element.zero(), GF256Element.one()]

    def __init__(self, coeffs):
        self._coeffs = GF256Poly.reduce(coeffs)

    @property
    def coeffs(self):
        return self._coeffs

    def __getitem__(self, key):
        return self.coeffs[key]

    def __repr__(self):
        c = self.coeffs
        return " + ".join(["(%s) y^%d" % (c[i], i) for i in range(len(c)-1, 0, -1) if c[i] != 0]) + ("%s%s" % (" + " if c[1:7] != [0] * 7 else "", c[0]) if c[0] != 0 else "")

    @staticmethod
    def one():
        return GF256Poly([1])

    @staticmethod
    def zero():
        return GF256Poly([0])

    @staticmethod
    def reduce(coeffs):
        """
        TEST:
            >>> GF256Poly.reduce([1])
            [1, 0, 0, 0]
            >>> GF256Poly.reduce([0, 1])
            [0, 1, 0, 0]
            >>> GF256Poly.reduce([0, 1, 0, 0])
            [0, 1, 0, 0]
            >>> GF256Poly.reduce([0, 0, 0, 0, 1])
            [1, 0, 0, 0]
            >>> GF256Poly.reduce([0, 0, 0, 0, 0, 1])
            [0, 1, 0, 0]
            >>> GF256Poly.reduce([0, 0, 0, 0, 1, GF256Element(123)]) == [1, GF256Element(123), 0, 0]
            True
        """
        c = [GF256Element(x) for x in coeffs]
        if len(c) < 4:
            c += [GF256Element.zero()] * (4 - len(c))

        for i in range(len(c)-1, 3, -1):
            if c[i] != 0:
                for j in range(5):
                    c[i - 4 + j] += c[i] * GF256Poly._f[j]

        return c[:4]

    def __add__(self, other):
        """
        TEST:
            >>> from random import randint
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = [GF256Element(randint(0, 255)) for _ in range(4)]
            ...     y = [GF256Element(randint(0, 255)) for _ in range(4)]
            ...     X = GF256Poly(x)
            ...     Y = GF256Poly(y)
            ...     res.append(X + Y == GF256Poly([x[i] + y[i] for i in range(4)]))
            ...     if res[-1] == False:
            ...         print ("x = ", x)
            ...         print ("X = ", X)
            ...         print ("y = ", y)
            ...         print ("Y = ", Y)
            ...         print ("X + Y = ", X + Y)
            ...         print (GF256Poly([x[i] + y[i] for i in range(4)]))
            >>> res == [True] * trials
            True
        """
        return GF256Poly([self.coeffs[i] + other.coeffs[i] for i in range(4)])

    def __mul__(self, other):
        """
        TEST:
            >>> x = GF256Poly(map(GF256Element, [1, 2, 3, 4]))
            >>> y = GF256Poly(map(GF256Element, [15,16,17,18]))
            >>> xy = GF256Poly(map(GF256Element,
            ...     [
            ...         x[0] * y[0] + x[3] * y[1] + x[1] * y[3] + x[2] * y[2],
            ...         x[1] * y[0] + x[0] * y[1] + x[3] * y[2] + x[2] * y[3],
            ...         x[2] * y[0] + x[0] * y[2] + x[1] * y[1] + x[3] * y[3],
            ...         x[3] * y[0] + x[2] * y[1] + x[1] * y[2] + x[0] * y[3]
            ...     ]))
            >>> z = GF256Poly([1])
            >>> x*z == x
            True
            >>> x*y == xy
            True
        """
        # schoolbook
        x = self.coeffs
        y = other.coeffs
        xy = [GF256Element.zero()] * 8

        for j in range(4):
            for i in range(4):
                xy[i+j] += y[j] * x[i]
        return GF256Poly(xy)

    def xtime(self):
        """
        TEST:
            >>> from random import randint
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = [GF256Element(randint(0, 255)) for _ in range(4)]
            ...     X = GF256Poly(x)
            ...     res.append(X.xtime() == X * GF256Poly([0, 1, 0, 0]))
            >>> res == [True] * trials
            True
        """
        return GF256Poly([self.coeffs[3]] + self.coeffs[:3])

    def __eq__(self, other):
        """
        TEST:
            >>> from random import randint
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = [GF256Element(randint(0, 255)) for i in range(4)]
            ...     X = GF256Poly(x)
            ...     res.append([X == X, X == GF256Poly(x)]) # kind of circular testing :(
            >>> res == [[True, True]] * trials
            True
        """
        if isinstance(other, GF256Poly):
            return self.coeffs == other.coeffs
        else:
            return self.coeffs == GF256Poly(other).coeffs

    def __ne__(self, other):
        """
        TEST:
            >>> from random import randint
            >>> one = GF256Poly([1])
            >>> bits = lambda x: [int(bool(x & (1 << i))) for i in range(8)]
            >>> res = []
            >>> trials = 128
            >>> for _ in range(trials):
            ...     x = [GF256Element(randint(0, 255)) for i in range(4)]
            ...     X = GF256Poly(x)
            ...     res.append([X != X, X != GF256Poly(x), X + one != X])
            >>> res == [[False, False, True]] * trials
            True
        """
        return not self.__eq__(other)


if __name__ == "__main__":
    import doctest
    doctest.testmod()