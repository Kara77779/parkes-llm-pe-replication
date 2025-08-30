#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Small-benchmark one-click runner (Fig.2-style smoke test on "first")
#
# This wrapper calls the authors' repo scripts and copies the generated figures
# back into this replication repo under results/first/.
#
# Requirements:
#   - You have cloned and installed the authors' repo at $ALPHA_DIR (default ~/alpha)
#   - You have a .env in THIS replication repo with OPENAI_API_KEY set
#   - DO NOT run proxies concurrently (to control token cost)
#
# Override via env vars if needed:
#   export ALPHA_DIR="/path/to/alpha"
#   export ENV_FILE="/path/to/your/.env"
# -----------------------------------------------------------------------------

ALPHA_DIR="${ALPHA_DIR:-$HOME/alpha}"   # authors' repo location
ENV_FILE="${ENV_FILE:-.env}"            # .env in this replication repo

# ---- preflight checks --------------------------------------------------------
if [[ ! -d "$ALPHA_DIR" ]]; then
  echo "❌ Not found: $ALPHA_DIR (please set ALPHA_DIR to the authors' repo path)"
  exit 1
fi
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Not found: $ENV_FILE (cp .env.example .env and fill OPENAI_API_KEY)"
  exit 1
fi

# Load OPENAI_API_KEY into current shell (only for this session)
set -a
source "$ENV_FILE"
set +a

# Enter authors' repo and activate venv if present
cd "$ALPHA_DIR"
if [[ -d venv ]]; then
  # shellcheck disable=SC1091
  source venv/bin/activate
fi
echo "== Step 1/6: make-benchmark (first) =="
python scripts/make-benchmark.py --scenarios TRANSPORTATION --benchmark first --num_setups 1 --num_people 5

echo "== Step 2/6: Proxy-XOR (baseline) =="
python scripts/run-proxy-xor.py --env_path .env --benchmark first

echo "== Step 3/6: Proxy-VD1 =="
python scripts/run-proxy-vd1.py --env_path .env --benchmark first \
  --cap 129 --min_iterations 128 \
  --check_priority high --target_bundle_priority highest \
  --happy_priority low \
  --anchor_num_target_bundles "20 to 30" \
  --target_bundle_emphasis "Quickly explore the person's valuation and get to the essence of things"

echo "== Step 4/6: Proxy-VD2 (with inferred values) =="
python scripts/run-proxy-vd2.py --env_path .env --benchmark first \
  --cap 129 --min_iterations 128 \
  --check_priority high --target_bundle_priority highest \
  --happy_priority low \
  --anchor_num_target_bundles "20 to 30" \
  --target_bundle_emphasis "Quickly explore the person's valuation and get to the essence of things"

echo "== Step 5/6: Proxy-NVD (plus-question) and Proxy-H (hybrid) =="
python scripts/run-proxy-nvd.py --env_path .env --benchmark first \
  --num_questions 1 \
  --cap 129 --min_iterations 128 \
  --check_priority high --target_bundle_priority highest \
  --happy_priority low \
  --anchor_num_target_bundles "20 to 30" \
  --target_bundle_emphasis "Quickly explore the person's valuation and get to the essence of things"

python scripts/run-proxy-h.py --env_path .env --benchmark first \
  --cap 129 --min_iterations 128 \
  --check_priority high --target_bundle_priority highest \
  --happy_priority low \
  --anchor_num_target_bundles "20 to 30" \
  --target_bundle_emphasis "Quickly explore the person's valuation and get to the essence of things"

echo "== Step 6/6: visualize (efficiency vs. interactions) =="
python scripts/vis-benchmark-fig.py first

# Copy figures back to this replication repo
cd - >/dev/null
mkdir -p results/first
# copy any first-related images generated in the last 90 minutes
find "${ALPHA_DIR}" -type f \( -iname "*first*.png" -o -iname "*first*.pdf" -o -iname "*first*.svg" \) -mmin -90 -exec cp {} results/first/ \;

echo "✅ Done. Figures copied to results/first/"
