module

public import Mathlib

@[expose] public section

/-!
# Warm-up: algebraic facts about single-node network calculus bounds

Setting: a flow with token-bucket arrival curve `α(t) = b + r·t` crosses a
rate-latency server `β(t) = R·[t − T]⁺`, with `r ≤ R`.
Textbook bounds: delay ≤ `T + b/R`, backlog ≤ `b + r·T`.

These lemmas only cover the *last algebraic step*, not the min-plus theory.
-/

namespace NCProofs

/-- The delay bound `T + b/R` is at least the latency `T`. -/
theorem delay_ge_latency (b R T : ℝ) (hR : 0 < R) (hb : 0 ≤ b) :
    T ≤ T + b / R := by
  have h : 0 ≤ b / R := div_nonneg hb (le_of_lt hR)
  linarith

/-- A faster server (larger `R`) gives a smaller delay bound. -/
theorem delay_antitone_in_rate (b R₁ R₂ T : ℝ) (hb : 0 ≤ b) (h₁ : 0 < R₁)
    (h : R₁ ≤ R₂) : T + b / R₂ ≤ T + b / R₁ := by
  have : b / R₂ ≤ b / R₁ := div_le_div_of_nonneg_left hb h₁ h
  linarith

/-- The backlog bound `b + r·T` is at least the burst `b`. -/
theorem backlog_ge_burst (b r T : ℝ) (hr : 0 ≤ r) (hT : 0 ≤ T) :
    b ≤ b + r * T := by
  nlinarith [mul_nonneg hr hT]

end NCProofs
