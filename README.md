# Pre-thesis: verifying LLM-generated network calculus proofs

Preparation work for my bachelor thesis on checking network calculus (NC)
proofs written by LLMs.

- `docs/NC_Proof_Verification_Findings.pdf`: findings, related work and the
  proposed verification framework (source: `docs/findings.html`).
- A Lean 4 + Mathlib project (`NCProofs`) with a proof checker.
- A Python environment with numeric NC tools for answer checking.

## What is installed

| Piece | Version | Purpose |
|---|---|---|
| elan (Homebrew `elan-init`) | 4.4.0 | Lean toolchain manager |
| Lean | 4.36.0 (pinned in `lean-toolchain`) | proof checker |
| Mathlib | v4.36.0 (pinned in `lakefile.toml`) | reals, inequalities, `linarith`, `nlinarith`, ... |
| VS Code extension `leanprover.lean4` | | live goals and errors in the editor |
| Python 3.12 venv (`uv`) | | `sympy`, `z3-solver`, `panco` |
| lp_solve (Homebrew) | 5.5.2.14 | LP solver that panco calls |

## Layout

```
docs/                 findings report (PDF + HTML source)
NCProofs/Basic.lean   proven NC warm-up lemmas (e.g. delay_ge_latency)
Examples/Broken.lean  proof that Lean rejects (linarith fails)
Examples/Sorry.lean   proof with `sorry`: compiles with a warning, must count as failure
Examples/Axiom.lean   proof that smuggles in an axiom: compiles silently, must count as failure
scripts/check.sh      the verifier: PASS / FAIL for a file + theorem names
tools/smoke_test.py   panco delay bound vs T + b/R, plus a SymPy and a Z3 check
```

## Everyday commands

```sh
lake build                                   # check the whole library
lake env lean Examples/Broken.lean           # check one file, show errors
scripts/check.sh Examples/Sorry.lean delay_ge_latency_sorry   # verdict: FAIL
scripts/check.sh NCProofs/Basic.lean NCProofs.delay_ge_latency  # verdict: PASS
uv run python tools/smoke_test.py            # Python tools work
lake exe cache get                           # re-download prebuilt Mathlib (after updating it)
```

`check.sh` passes a proof only if Lean reports no errors, no `sorry`, and each
named theorem depends on nothing beyond `propext`, `Classical.choice` and
`Quot.sound`. Checking that the LLM did not change the theorem *statement* is
not done yet; that belongs to the benchmark harness.

## In VS Code

Open this folder (not a parent folder) in VS Code, open `NCProofs/Basic.lean`,
and put the cursor inside a proof. The "Lean Infoview" panel shows the current
goal; "No goals" after the last tactic means the proof is done.
The first open takes a few seconds while Mathlib loads.

## Notes

- `NCProofs/Basic.lean` starts with `module` / `public import` / `public section`.
  That is Lean's new module system; it silences a build warning and has no
  effect on the proofs. Scratch files can use a plain `import Mathlib`.
- panco only looks for `lp_solve` on Linux and Windows. `tools/smoke_test.py`
  sets the path for macOS before importing panco's analyses; do the same in
  your own scripts.
