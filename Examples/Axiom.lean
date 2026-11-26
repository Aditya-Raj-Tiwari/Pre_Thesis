import Mathlib

-- Expected: compiles with no warning, but `#print axioms` exposes the cheat.
-- The checker must count this as FAILED too.
axiom cheat : ∀ (b R T : ℝ), T ≤ T + b / R

theorem delay_ge_latency_axiom (b R T : ℝ) (hR : 0 < R) (hb : 0 ≤ b) :
    T ≤ T + b / R :=
  cheat b R T
