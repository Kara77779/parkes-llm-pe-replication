# Replication — “Accelerated Preference Elicitation with LLM-Based Proxies” (Huang, Marmolejo-Cossío, Lock, Parkes, 2025)

This repository reproduces the main results of the paper using the authors’ official codebase.
- Original paper: *Accelerated Preference Elicitation with LLM-Based Proxies* (2025)
- Original code: https://github.com/davidzqhuang/alpha

> ✅ Status: We reproduce **Fig. 2** on both a small sanity benchmark (`first`) and the paper benchmark (`threes`).  
> Figures are in `results/first/` and `results/threes/` below.

---

## Repo layout
```text
parkes-llm-pe-replication/
├─ README.md # this file
├─ .gitignore
├─ .env.example # template (no real key)
├─ requirements.txt # minimal deps for this wrapper
├─ scripts/
│ ├─ run_first.sh # small-benchmark one-click wrapper
│ └─ run_threes.sh # paper benchmark one-click wrapper (optional)
└─ results/
├─ first/
│ ├─ efficiency_first.png
│ └─ h_vs_xor_first.png
└─ threes/
├─ efficiency_threes.png
└─ h_vs_xor_threes.png
```

> The heavy-weight dependencies (OR-Tools, plotnine, etc.) are installed inside the **authors’ repo** (`alpha/`).  
> This wrapper only manages orchestration and result collection.

---

## Prerequisites

1. Clone and install the authors’ repo (assume at `~/alpha`).  
   If your path is different, set an env var later: `export ALPHA_DIR=/abs/path/to/alpha`.
2. Create your own `.env` in this replication repo:
   ```bash
   cp .env.example .env
   # edit .env and set:
   # OPENAI_API_KEY="sk-xxxxxxxx"

## Quick start
# from this repo root
# optional: point to authors’ repo if not at ~/alpha
# export ALPHA_DIR="/abs/path/to/alpha"

bash scripts/run_threes.sh    # runs XOR/VD1/VD2/NVD/H sequentially and copies figures
open results/threes

## What we reproduce (Fig. 2)

Efficiency vs. Interactions (on threes, 3 scenarios × 3 setups × 3 people) shows the expected trend:

NVD reaches ~75% within ~2 interactions;

VD2 within ~4 interactions;

XOR around ~10 interactions;

Hybrid rises fast initially and converges to the same optimum as XOR.

See:

results/threes/efficiency_threes.png

results/threes/h_vs_xor_threes.png

We also include the small benchmark figures in results/first/ as a smoke test.

## Citation

If you use this repo, please cite the original paper and code:

Huang, Marmolejo-Cossío, Lock, Parkes (2025). Accelerated Preference Elicitation with LLM-Based Proxies.

Code: https://github.com/davidzqhuang/alpha