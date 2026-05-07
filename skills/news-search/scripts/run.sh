#!/usr/bin/env bash
# Auto-generated script for news-search
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="news-search"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${SEARCH_API_KEY:?ERROR: SEARCH_API_KEY not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/news-search_${RUN_ID}.json"
OUTPUT_FILE="/tmp/news-search_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
```bash
python3 - <<'PY'
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta, timezone

input_file = os.environ["INPUT_FILE"]
output_file = os.environ["OUTPUT_FILE"]
api_key = os.environ["SEARCH_API_KEY"]

with open(input_file, "r", encoding="utf-8") as f:
    raw = f.read().strip()
    seed = json.loads(raw) if raw else {}

now_utc = datetime.now(timezone.utc)
window_end = seed.get("window_end") or now_utc.isoformat()
window_start = seed.get("window_start") or (now_utc - timedelta(hours=24)).isoformat()
queries = seed.get("queries") or [
    'India news',
    'site:*.in India politics economy business sports',
    'India policy markets infrastructure state news',
]

# Approved search connector endpoint is injected by the final scaffold.
SEARCH_ENDPOINT = "https://<approved-search-provider>/v1/news/search"

all_candidates = []
for q in queries:
    payload = {
        "query": q,
        "from": window_start,
        "to": window_end,
        "limit": 20,
        "country": "in",
        "language": "en",
    }
    body = json.dumps(payload).encode("utf-8")
    req = [
        "curl", "-sS", "-X", "POST", SEARCH_ENDPOINT,
        "-H", "Content-Type: application/json",
        "-H", f"Authorization: Bearer {api_key}",
        "-d", body.decode("utf-8"),
        "-w", "\n%{http_code}",
    ]

    proc = subprocess.run(req, capture_output=True, text=True)
    if proc.returncode != 0:
        print(proc.stderr.strip() or "search request failed", file=sys.stderr)
        sys.exit(proc.returncode)

    stdout = proc.stdout.rsplit("\n", 1)
    response_body = stdout[0]
    http_code = stdout[1] if len(stdout) > 1 else "000"
    if http_code != "200":
        print(f"search HTTP {http_code}: {response_body}", file=sys.stderr)
        sys.exit(1)

    try:
        data = json.loads(response_body)
    except json.JSONDecodeError:
        print(f"search returned invalid JSON: {response_body}", file=sys.stderr)
        sys.exit(1)

    hits = data.get("items") or data.get("results") or []
    for hit in hits:
        all_candidates.append({
            "headline": hit.get("title") or hit.get("headline") or "",
            "source_name": hit.get("source_name") or hit.get("source") or "",
            "source_url": hit.get("url") or hit.get("link") or "",
            "published_at": hit.get("published_at") or hit.get("date_published"),
            "snippet": hit.get("snippet") or hit.get("description") or "",
            "topic_guess": hit.get("topic") or hit.get("category"),
            "query": q,
        })

# Lightweight normalization/dedup before the summarizer sees the pool.
seen = set()
normalized = []
for item in all_candidates:
    key = (item["source_url"].strip().lower(), item["headline"].strip().lower())
    if not item["source_url"] or key in seen:
        continue
    seen.add(key)
    normalized.append(item)

payload = {
    "run_id": seed.get("run_id") or os.environ.get("RUN_ID"),
    "window_start": window_start,
    "window_end": window_end,
    "queries": queries,
    "candidate_count": len(normalized),
    "candidates": normalized,
}

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
PY
```

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: news-search complete"
