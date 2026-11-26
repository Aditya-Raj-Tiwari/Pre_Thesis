import Mathlib

-- Expected: compiles with "declaration uses 'sorry'". The checker must count this as FAILED.
theorem delay_ge_latency_sorry (b R T : ℝ) (hR : 0 < R) (hb : 0 ≤ b) :
    T ≤ T + b / R := by
  sorry
