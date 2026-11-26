#!/usr/bin/env bash
# Verify a Lean proof file the way an LLM-proof benchmark should.
#
#   scripts/check.sh FILE.lean THEOREM [THEOREM ...]
#
# PASS only if: the file compiles with no errors, no `sorry`, and every named
# theorem depends on nothing beyond Lean's standard axioms
# (propext, Classical.choice, Quot.sound).
set -uo pipefail
[ $# -ge 2 ] || { echo "usage: $0 FILE.lean THEOREM [THEOREM ...]" >&2; exit 2; }
file=$1; shift
root=$(cd "$(dirname "$0")/.." && pwd)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
tmp="$tmpdir/$(basename "$file")"

cat "$file" > "$tmp"
printf '\n' >> "$tmp"
for thm in "$@"; do printf '#print axioms %s\n' "$thm" >> "$tmp"; done

out=$(cd "$root" && lake env lean "$tmp" 2>&1); status=$?
echo "$out"
echo "----"

fail() { echo "FAIL: $1"; exit 1; }
[ $status -eq 0 ] || fail "Lean reported errors (exit $status)"
grep -qE "declaration uses [\`']sorry" <<<"$out" && fail "proof contains sorry"

for thm in "$@"; do
  line=$(grep -E "^'[^']*${thm}' (depends on axioms|does not depend)" <<<"$out" | head -1)
  [ -n "$line" ] || fail "no axiom report for $thm"
  axioms=$(sed -n 's/.*depends on axioms: \[\(.*\)\]/\1/p' <<<"$line" | tr -d ' ' | tr ',' '\n')
  for ax in $axioms; do
    case $ax in propext|Classical.choice|Quot.sound) ;; *) fail "$thm uses non-standard axiom: $ax" ;; esac
  done
done
echo "PASS"
