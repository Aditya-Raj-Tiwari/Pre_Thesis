import Mathlib

-- Expected: REJECTED. Without the `have`, `linarith` cannot see `0 ≤ b / R`.
theorem delay_ge_latency_broken (b R T : ℝ) (hR : 0 < R) (hb : 0 ≤ b) :
    T ≤ T + b / R := by
  linarith
