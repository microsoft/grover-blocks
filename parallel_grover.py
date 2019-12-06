# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#!/usr/bin/env sage
from sage.all import RealField, pi, arcsin, sqrt, sin, log, floor, ceil, e, exp, Infinity
R = RealField(1000)

def theta(N, t):
    """
    Given search space of size N with t solutions, returns angle theta that each Grover iteration advances.
    """
    return R(arcsin(sqrt(R(t)/N)))

def p_succ(i, N, t):
    """
    Success probability after i iterations of measuring a solution.

    :params i:  Grover's iterations
    :param  N:  Grover's search space size
    :params t:  target solutions in search space
    """
    return R((sin((2*i+1)*theta(N, t)))**2)

def p_succ_outer(p, S):
    """
    Success probability of outer parallelisation strategy using S computers, each with success probability p.

    :params p:  success probability for single computer
    :params S:  total number of parallel computers
    """
    return R((1-(1-p)**S))

def p_succ_outer_inv(P, S):
    return R(p_succ_outer(P, R(1)/S))

def iterations(p, N, t):
    """
    Grover succeeds with probability p(j) = sin^2((2j+1)theta).
    This is the inverse function for obtaining the number of iterations j from theta and p(j).

    :params p:  Grover's success prob
    :params N:  Grover's search space size
    :params t:  targets. Right now, assumed to be 1.
    """
    return (R(arcsin(sqrt(p)))/theta(N,t) - 1)/2

def cost_out_p(p, S, w, d, N, t):
    """
    DW cost for running Grover on S machines to achieve success probability p.

    :params p:  Grover's success prob
    :params S:  total number of parallel computers
    :params w:  width of the Grover oracle in qubits (=G_W)
    :params d:  depth of the Grover oracle (=G_D)
    :params N:  Grover's search space size
    :params t:  targets, i.e. number of solutions to the problem
    """
    return S * w * d * iterations(p, N, t)

def printS(P, w, d, N, t, Smax, M):
    step = (Smax-1)//M

    for i in xrange(M+1):
        Si = 1 + step*i
        p = p_succ_outer_inv(P, Si)
        it = iterations(p, N, t)
        c = cost_out_p(p, Si, w, d, N, t)
        print "S = %s, p = %.2f, iter = %.2f, cost = %.2f" % (Si, p, it, log(c, 2))




# ////////////////////////////////////////////////////////
def format_pow(a):
    """
    Given positive real a, format as [0, 1) x 2 ^ {integer power}

    :params a:          positive real
    :returns (fa, ea):  a = fa x 2 ^ ea
    """
    loga = log(R(a), 2)
    try:
        ea = floor(loga)
    except:
        import pdb; pdb.set_trace()
    fa = R(a)/2**ea
    return (fa, ea)

logMDs = [40, 64, 96]

def spurious_keys_probability(k, n, r, S):
    """
    Inner parallelization can result in reducing the number of plaintext-ciphertext blocks
    required for a success probability=1 attack, by separating spurious keys in 
    different search spaces.

    We compute here the probability that this is _not_ the case.

    :params k:  key length
    :params n:  block size
    :params r:  number of plaintext-ciphertext pairs
    :params S:  number of key space subsets/parallel instances
    """
    p = 1 - exp(-2**(k-n*r)/S)
    return p

def instances(GD, N, MD, p):
    """
    The formula from "Optimizing the oracle under a depth limit". Assuming single-target, t = 1.

    :params GD: Grover's oracle depth
    :params N:  keyspace size
    :params MD: MAXDEPTH
    :params p:  target success probability

    Assuming p = 1
        In depth MD can fit j = floor(MD/GD) iterations.
        These give probability 1 for a search space of size M. 
            p(j) = sin((2j+1)theta)**2
            1 = sin((2j+1)theta)**2
            1 = sin((2j+1)theta)
            (2j+1)theta = pi/2
            theta = pi/(2(2j+1)) = sqrt(t/M) = 1/sqrt(M).
            sqrt(M) = 2(2j+1)/pi
            M = (2(2j+1)/pi)**2

        Hence need S = ceil(N/M) machines.
            S = ceil(N/(2(2*floor(MD/GD)+1)/pi)**2)
    Else
        Could either lower each individual computer's success prob, since the target is inside only one computer's state.
            Then given a requested p, we have
            p = sin((2j+1)theta)**2
            arcsine(sqrt(p)) = (2j+1)theta = (2j+1)/sqrt(M)
            M = (2j+1)**2/arcsine(sqrt(p))**2
            S = ceil(N*(arcsine(sqrt(p))/(2j+1))**2)

        Or could just run full depth but have less machines.
            For a target p, one would choose to have ceil(p*S) machines, where S is chosen as in the p = 1 case.
        Then look at which of both strategies gives lower cost.
    """

    # compute the p=1 case first
    S1 = ceil(N/(2*(2*floor(MD/GD)+1)/pi)**2)

    # An alternative reasoning giving the same result for p == 1 (up to a very small difference):
    # Inner parallelisation gives sqrt(S) speedup without loosing success prob.
    # Set ceil(sqrt(N) * pi/4) * GD/sqrt(S) = MAXDEPTH
    # S1 = float(ceil(((pi*sqrt(N)/4) * GD / MD)**2))

    if p == 1:
        return S1
    else:
        Sp = ceil(N*(arcsin(sqrt(R(p)))/(2*floor(MD/GD)+1))**2)
        if ceil(p*S1) == Sp:
            print "NOTE: for (GD, log2(N), log2(MD), p) == (%d, %.2f, %.2f, %.2f) naive reduction of parallel machines is not worse!" % (GD, log(N, 2).n(), log(MD, 2).n(), p)
        elif ceil(p*S1) < Sp:
            print "NOTE: for (GD, log2(N), log2(MD), p) == (%d, %.2f, %.2f, %.2f) naive reduction of parallel machines is better!" % (GD, log(N, 2).n(), log(MD, 2).n(), p)
            
        res = min(Sp, ceil(p*S1))
        return res

def GroverDWCost(cipher, GDs, Ws, Gs, key_pc, ps, spurious_key_threshold=2**(-20), caption="", ignore_r=False, lowmc=False):
    """
    Given a single-target Grover problem limited by MAXDEPTH, computes the appropriate inner-parallel strategy.
    """
    # print "Unique key:"
    for p in ps:
        # print "@@@ target p = %.2f" % p
        table = """
\\begin{table}
    \\centering
    \\renewcommand{\\tabcolsep}{0.05in}
    \\renewcommand{\\arraystretch}{1.3}
    \\resizebox{\\textwidth}{!}{
        \\begin{tabular}{lccccccccc}
            \\toprule\n"""
        table += "            scheme & \\texttt{MD} & %s $S$ & %s $D$ & $W$ & $G$-cost & $DW$-cost \\\\ \midrule\n" % (
            "" if ignore_r else "$r$ &",
            "" if ignore_r else "$\\log_2{(\\text{SKP})}$ &",
        )
        for lMD in logMDs:
            # print "@@@ MAXDEPTH = 2^%s" % lMD
            # table += "            \\multicolumn{6}{c}$\\nistmaxdepth = 2^{%d}$} \\\\ \midrule\n" % lMD
            # table += "\\midrule"

            MD = 2**lMD
            
            for i in range(len(key_pc)):
                # obtain size of search problem and maxdepth info
                lk, pairs = key_pc[i]
                N = 2**lk
                
                # compute iterations for targetted success p with traditional Grover (1 target only)
                ip = iterations(p, N, 1)    

                """
                we look at how likely are spurious keys in the subset we are searching. 
                if they arent (< 1/(1<<20)), then we can reduce r, even down to 1!
                only cost the lowest r, and re-cost the value of W. calling this full function 
                    with different r' != r > whatever we actually need, should result in the same costs

                we also want to deal with the no parallelism required case of aes128 in md96 (check whatsapp)
                """
                for r in range(1, pairs+1):
                    GD = GDs[r][i]  
                    # Total depth for traditional Grover
                    Dp = ip*GD
                    # Used depth: either MAXDEPTH or the depth of traditional grover
                    D = min(Dp, MD)
                    # How many quantum computers are needed for targetted MAXDEPTH?
                    S = instances(GD, N, MD, p)
                    
                    skp = spurious_keys_probability(lk, 128 if not lowmc else lk, r, S)

                    c_p = pi/4
                    GW = Ws[r][i]
                    GG = Gs[r][i]
                    if S > 1:
                        G_cost = c_p**2 * 2**(lk-lMD) * GD * GG
                        DW_cost = c_p**2 * 2**(lk-lMD) * GD**2 * GW
                    else:
                        # Serial Grover!
                        G_cost = floor(c_p * 2**(lk/2)) * GG
                        DW_cost = GW * D
                    
                    # print "@@@@ k = %d,\tMD = %d,\tlog(S) = %.1f,\tr = %d,\tlog2(spurious key prob) %.1f,\tG-cost %.1f,\tDW-cost %.1f" % (lk, lMD, R(log(S,2)), r, R(log(skp,2)), R(log(G_cost,2)), R(log(DW_cost,2)))
                
                    if skp <= spurious_key_threshold:
                        pairs = r
                        break 
                
                # total width given S parallel instances
                W = S * Ws[pairs][i] 

                # Formatting circuit size
                Sf, Se = format_pow(S)
                Df, De = format_pow(D)
                Wf, We = format_pow(W)
                DWf, DWe = format_pow(D*W)
                G_costf, G_coste = format_pow(G_cost)
                DW_costf, DW_coste = format_pow(DW_cost)
                # timeCf, timeCe = format_pow(S * key_pc[i][1])
                # timeQf, timeQe = format_pow(D)

                # print "%s-%s: " % (cipher, lk),
                # print "S = %.2f \cdot 2^{%s}, D = %.2f \cdot 2^{%s}, W = %.2f \cdot 2^{%s}, DW = %.2f \cdot 2^{%s}" % (Sf, Se, Df, De, Wf, We, DWf, DWe)
                table += "            \\%s-%d & $2^{%d}$ & %s $%.2f \cdot 2^{%s}$ & %s $%.2f \cdot 2^{%s}$ & $%.2f \cdot 2^{%s}$ & $%.2f \cdot 2^{%s}$ & $%.2f \cdot 2^{%s}$ \\\\\n" % (
                    cipher, lk, lMD, 
                    "" if ignore_r else (" $%d$ &" % pairs), 
                    Sf, Se, 
                    "" if ignore_r else ("$%s$ &" % (("%.2f" % R(log(skp,2))) if R(log(skp,2)) > (-Infinity) else "-\infty")), # prob
                    Df, De, 
                    Wf, We, 
                    # DWf, DWe,
                    G_costf, G_coste,
                    DW_costf, DW_coste,
                    # timeCf, timeCe, # Clas
                    # cipher, lk,
                    # timeQf, timeQe, # Quant
                    )
            table += "            \\midrule\n"
        table += """        \end{tabular}
    }
    \\caption{%s}
\\end{table}\n""" % caption
        print table


def CostAES(t_depth_only, in_place_mixcolumn):
    if t_depth_only:
        # indexed by number of p-c pairs
        GDs = {
            1: [121, 120, 126],
            2: [121, 120, 126],
            3: [121, 120, 126],
        }
    else:
        # indexed by number of p-c pairs
        if in_place_mixcolumn:
            GDs = {
                1: [2816, 2978, 3353],
                2: [2815, 2981, 3356],
                3: [2830, 2982, 3347],
            }
        else:
            GDs = {
                1: [2086, 1879, 1951],
                2: [2096, 1890, 1952],
                3: [2102, 1888, 1956],
            }

    # indexed by number of p-c pairs
    if in_place_mixcolumn:
        Ws = {
            1: [257 + 1408, 321 + 1664, 385 + 1920],
            2: [385 + 2944, 449 + 3520, 513 + 4096],
            3: [513 + 4480, 577 + 5376, 641 + 6272],
        }
        Gs = {
            1: [292313 + 84428 + 54908 + 13727, 329697 + 94316 + 61436 + 15359, 404139 + 116286 + 75580 + 18895],
            2: [585051 + 169184 + 109820 + 27455, 659727 + 188520 + 122876 + 30719, 808071 + 231124 + 151164 + 37791],
            3: [877081 + 252524 + 164732 + 41183, 989879 + 282968 + 184316 + 46079, 1212905 + 347766 + 226748 + 56687]
        }
    else:
        Ws = {
            1: [257 + 2560, 321 + 3072, 385 + 3584],
            2: [385 + 5248, 449 + 6336, 513 + 7424],
            3: [513 + 7936, 577 + 9600, 641 + 11264],
        }
        Gs = {
            1: [294863 + 84488 + 54908 + 13727, 332665 + 94092 + 61436 + 15359, 407667 + 116062 + 75580 + 18895],
            2: [589643 + 168288 + 109820 + 27455, 665899 + 188544 + 122876 + 30719, 815645 + 231712 + 151164 + 37791],
            3: [884817 + 252876 + 164732 + 41183, 999491 + 283712 + 184316 + 46079, 1223087 + 346290 + 226748 + 56687]
        }

    # print "@@@ T-depth only: %s" % t_depth_only
    # print "@@@ in-place MC: %s" % in_place_mixcolumn

    # provide r guaranteeing no spurious keys. internally it tries to use less
    # caption = "\\aes: D = %s, %s MixColumn" % ("T-depth" if t_depth_only else "full depth", "in-place" if in_place_mixcolumn else "Maximov's")
    caption = "Circuit sizes for parallel Grover key search against \\aes (using %s MixColumn implementation), using \emph{inner} parallelization (cf. Section~\\ref{sec:groverparallel}). \\texttt{MD} is \\nistmaxdepth, $r$ is the number of plaintext-ciphertext pairs used in the Grover oracle, S is the number of subsets in which the key-space is divided into, SKP is the probability of spurious keys being present in the subset where the target key is present, D and W are the %sdepth and qubit width of the full circuit, DW is the %sdepth~$\\times$~width circuit cost. After the Grover search is completed, each of the S measured candidate keys is classically checked against 2 (resp. 2, 3) plaintext-ciphertext pairs for \\aes-128 (resp. -192, -256)." % (
        "an in-place" if in_place_mixcolumn else "Maximov's~\\cite{cryptoeprint:2019:833}",
        "T-" if t_depth_only else "full ",
        "T-" if t_depth_only else "full ",
    )
    GroverDWCost("aes", GDs, Ws, Gs, [(128, 2), (192, 2), (256, 3)], [1], caption=caption) #, 0.5, R(1/e)])


def CostLowMC(t_depth_only):
    if t_depth_only:
        # indexed by number of p-c pairs
        GDs = {
                1: [41, 61, 77],
                2: [41, 61, 77]
            }
    else:
        # indexed by number of p-c pairs
        GDs = { 
            1: [98709, 319323, 693477],
            2: [98707, 319329, 693483] 
        }

    # indexed by number of p-c pairs
    Ws = {
        1: [257 + 1328, 385 + 1992, 513 + 2536],
        2: [385 + 2784, 577 + 4176, 769 + 5328],
    }

    Gs = {
        1: [690961 + 5917 + 8908 + 191, 2273397 + 10881 + 13364 + 286, 5072343 + 16209 + 16980 + 372],
        2: [1382143 + 11774 + 17820 + 362, 4547191 + 21783 + 26732 + 576, 10145281 + 32567 + 33964 + 783]
    }
    # print "T-depth only: %s" % t_depth_only

    # Not sure it makes sense to have lower than 1 prob for these next values
    caption = "Circuit sizes for parallel Grover key search against \\lowmc, using \\emph{inner} parallelization (cf. Section~\\ref{sec:groverparallel}). \\texttt{MD} is \\nistmaxdepth, S is the number of subsets in which the key-space is divided into, D and W are the %sdepth and qubit width of the full circuit, DW is the %sdepth~$\\times$~width circuit cost. The Grover oracle is always implemented using a single plaintext-ciphertext pair, given that this is sufficient for key-recovery againist \picnic. After the Grover search is completed, each of the S measured candidate keys is classically checked against 1 plaintext-ciphertext pairs." % (
        "T-" if t_depth_only else "full ",
        "T-" if t_depth_only else "full ",
    )
    GroverDWCost("lowmc", GDs, Ws, Gs, [(128, 2), (192, 2), (256, 2)], [1], spurious_key_threshold=2**(-20), caption=caption, ignore_r=False, lowmc=True)


# print "@@@ ########## in-place MC"
CostAES(False, True)
CostAES(True, True)
# print "@@@"
# print "@@@"
# print "@@@ ########## Maximov's MC"
CostAES(False, False)
CostAES(True, False)
# print "@@@"
# print "@@@"
# print "@@@ ########## LowMC"
CostLowMC(False)
# print "@@@"
# print "@@@"
CostLowMC(True)
