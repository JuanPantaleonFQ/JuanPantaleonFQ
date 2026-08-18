#!/usr/bin/env bash
#
# daily-contrib.sh — generate a randomized "contribution art" panel on this
# personal profile repo, inspired by https://github.com/fenrir2608/goGreen.
#
# Hard requirements (a run that misses either earns ZERO contributions):
#   A. Author email MUST be the GitHub-verified address below.
#   B. Commits MUST land on the default branch `main`.
#
# This script enforces both, then makes 7–20 harmless commits for TODAY.

set -euo pipefail

AUTHOR_EMAIL="juanfemeniaquevedo@gmail.com"
AUTHOR_NAME="JuanPantaleonFQ"
BRANCH="main"

cd "$(git rev-parse --show-toplevel)"

# Requirement A: identity
git config user.email "$AUTHOR_EMAIL"
git config user.name  "$AUTHOR_NAME"

# Requirement B: be on main
git checkout "$BRANCH"

# Random number of commits in [7, 20]
N=$(( (RANDOM % 14) + 7 ))
TODAY=$(date +%Y-%m-%d)
echo "Generating $N contribution commits for $TODAY on branch $BRANCH"

for i in $(seq 1 "$N"); do
  val=$RANDOM
  fname="data/random-test-${val}-$(date +%s)-${i}.txt"
  mkdir -p data
  echo "Random value: $((RANDOM % 100))" > "$fname"
  git add "$fname"
  git commit -q -m "Random commit ${i}/${N} - ${TODAY}"
done

# Verify requirement A before pushing
ae=$(git log -1 --pretty=%ae)
if [ "$ae" != "$AUTHOR_EMAIL" ]; then
  echo "ERROR: author email is '$ae', expected '$AUTHOR_EMAIL' — aborting push." >&2
  exit 1
fi
echo "Verified author email: $ae"

# Push to main with simple retry/backoff
for attempt in 1 2 3 4; do
  if git push origin "$BRANCH"; then
    echo "Pushed $N commits to $BRANCH"
    exit 0
  fi
  sleep $((2 ** attempt))
done
echo "ERROR: push failed after retries" >&2
exit 1
