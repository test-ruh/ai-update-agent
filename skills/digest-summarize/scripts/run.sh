#!/usr/bin/env bash
# Auto-generated script for digest-summarize
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="digest-summarize"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${LLM_API_KEY:?ERROR: LLM_API_KEY not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/news-search_${RUN_ID}.json"
OUTPUT_FILE="/tmp/digest-summarize_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
```bash
python3 - <<'PY'
import json
import os
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

input_file = os.environ["INPUT_FILE"]
output_file = os.environ["OUTPUT_FILE"]
api_key = os.environ["LLM_API_KEY"]

with open(input_file, "r", encoding="utf-8") as f:
    source = json.load(f)

candidates = source.get("candidates") or []
run_id = source.get("run_id") or os.environ.get("RUN_ID")

# Normalize and deduplicate again so the ranking step works from clean input.
def norm_text(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "")).strip().lower()

seen = set()
clean = []
for item in candidates:
    key = (
        norm_text(item.get("source_url")),
        norm_text(item.get("headline")),
    )
    if not item.get("source_url") or key in seen:
        continue
    seen.add(key)
    clean.append(item)

# No credible items: emit a short fallback note and stop cleanly.
if not clean:
    fallback = "Good morning — today’s India news briefing could not find enough credible items in the last 24 hours."
    payload = {
        "run_id": run_id,
        "status": "partial",
        "item_count": 0,
        "digest_text": fallback,
        "fallback_note": fallback,
        "items": [],
    }
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    sys.exit(0)

# Keep the prompt small: pass only the top candidate fields needed for ranking/summarization.
compact = [{
    "headline": c.get("headline", ""),
    "source_name": c.get("source_name", ""),
    "source_url": c.get("source_url", ""),
    "published_at": c.get("published_at"),
    "snippet": c.get("snippet", ""),
    "topic_guess": c.get("topic_guess"),
} for c in clean]

prompt = {
    "task": "Rank and summarize India news for a WhatsApp group digest.",
    "rules": [
        "Select at most 10 distinct stories from the last 24 hours.",
        "Prefer high-signal, credible, non-duplicative items.",
        "Keep each summary to 1-2 sentences.",
        "Include a source URL for every item.",
        "Write neutral, factual, group-chat friendly English.",
        "If coverage is thin, return a short fallback note rather than inventing items.",
    ],
    "candidates": compact,
}

# Approved LLM connector endpoint is injected by the final scaffold.
LLM_ENDPOINT = "https://<approved-llm-provider>/v1/chat/completions"
request_body = json.dumps({
    "model": "daily-digest",
    "messages": [
        {"role": "system", "content": "You rank and summarize India news for a WhatsApp briefing."},
        {"role": "user", "content": json.dumps(prompt, ensure_ascii=False)},
    ],
    "temperature": 0.2,
}).encode("utf-8")

req = Request(
    LLM_ENDPOINT,
    data=request_body,
    headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    },
    method="POST",
)

try:
    with urlopen(req, timeout=90) as resp:
        status = resp.status
        body = resp.read().decode("utf-8")
except HTTPError as e:
    error_body = e.read().decode("utf-8", errors="replace")
    print(f"LLM HTTP {e.code}: {error_body}", file=sys.stderr)
    sys.exit(1)
except URLError as e:
    print(f"LLM transport error: {e}", file=sys.stderr)
    sys.exit(1)

if status != 200:
    print(f"LLM HTTP {status}: {body}", file=sys.stderr)
    sys.exit(1)

try:
    llm = json.loads(body)
except json.JSONDecodeError:
    print(f"LLM returned invalid JSON: {body}", file=sys.stderr)
    sys.exit(1)

# Accept either a direct structured response or an assistant message containing JSON.
content = llm.get("output") or llm.get("content") or llm.get("choices", [{}])[0].get("message", {}).get("content", "")
try:
    result = json.loads(content)
except Exception:
    print(f"LLM response was not valid JSON: {content}", file=sys.stderr)
    sys.exit(1)

items = result.get("items") or []
items = items[:10]
for idx, item in enumerate(items, start=1):
    item["rank"] = idx

# Compose a WhatsApp-readable text body if the model did not supply one.
if result.get("digest_text"):
    digest_text = result["digest_text"].strip()
else:
    lines = ["Good morning — here’s your India news briefing for today:", ""]
    for item in items:
        published = f" ({item.get('published_at')})" if item.get("published_at") else ""
        lines.append(f"{item['rank']}. {item.get('headline','').strip()}{published}")
        lines.append(f"{item.get('summary','').strip()}")
        lines.append(f"Source: {item.get('source_name','').strip()} — {item.get('source_url','').strip()}")
        lines.append("")
    digest_text = "\n".join(lines).strip()

payload = {
    "run_id": run_id,
    "status": "success" if items else "partial",
    "item_count": len(items),
    "digest_text": digest_text,
    "items": items,
}

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
PY
```

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: digest-summarize complete"
