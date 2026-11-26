"""Smoke test for the Python side (verification layers 1-2).

Single node: token bucket (b, r) through rate-latency (R, T), r <= R.
Textbook delay bound: T + b/R.
"""
import os
import tempfile

import sympy as sp
import z3

# panco only looks for lp_solve on Linux/Windows; point it at the Homebrew
# binary on macOS. Must run before importing any panco analysis module.
import panco.lpSolvePath
panco.lpSolvePath.LPSOLVEPATH = panco.lpSolvePath.LPSOLVEPATH or ["lp_solve", "-s5"]

from panco.descriptor.curves import RateLatency, TokenBucket
from panco.descriptor.flow import Flow
from panco.descriptor.network import Network
from panco.descriptor.server import Server
from panco.fifo.tfaLP import TfaLP

b, r, R, T = 2.0, 1.0, 4.0, 3.0
formula = T + b / R

# Layer 1: numeric answer from an NC tool (panco calls lp_solve).
net = Network([Server([RateLatency(R, T)], [])], [Flow([TokenBucket(b, r)], [0])])
with tempfile.TemporaryDirectory() as d:
    panco_delay = TfaLP(net, filename=os.path.join(d, "tfa.lp")).delay(0)
print(f"panco TFA delay = {panco_delay:.6f}, formula T + b/R = {formula:.6f}")
assert abs(panco_delay - formula) < 1e-6

# Layer 2a: SymPy checks an algebraic step symbolically.
bs, Rs, Ts = sp.symbols("b R T", positive=True)
assert sp.simplify((Ts + bs / Rs) - Ts - bs / Rs) == 0
print("sympy: identity check ok")

# Layer 2b: Z3 checks that an inequality step follows from the hypotheses.
zb, zR, zT = z3.Reals("b R T")
s = z3.Solver()
s.add(zR > 0, zb >= 0, z3.Not(zT <= zT + zb / zR))  # search for a counterexample
assert s.check() == z3.unsat
print("z3: T <= T + b/R holds whenever R > 0, b >= 0")
print("ALL OK")
