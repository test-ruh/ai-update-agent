#!/usr/bin/env bash
# Auto-generated script for results-store-write
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="results-store-write"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${RESULTS_DB_URL:?ERROR: RESULTS_DB_URL not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/results-store-write_${RUN_ID}.json"
OUTPUT_FILE="/tmp/results-store-write_${RUN_ID}.json"
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
from pathlib import Path

input_file = Path(os.environ["INPUT_FILE"])
output_file = Path(os.environ["OUTPUT_FILE"])
project_root = Path(os.environ["PROJECT_ROOT"])
run_id = os.environ.get("RUN_ID")
_ = os.environ["RESULTS_DB_URL"]

with input_file.open("r", encoding="utf-8") as f:
    payload = json.load(f)

# The workflow may call this skill twice:
# 1) after summarization to persist the draft run + item rows
# 2) after WhatsApp delivery to finalize delivery_status/message_id
mode = payload.get("mode") or ("final" if payload.get("delivery_status") else "draft")
run_row = {
    "id": payload.get("run_id") or run_id,
    "scheduled_for": payload["scheduled_for"],
    "started_at": payload.get("started_at"),
    "completed_at": payload.get("completed_at"),
    "status": payload.get("status", "pending"),
    "item_count": int(payload.get("item_count", 0)),
    "summary_text": payload.get("summary_text") or payload.get("digest_text"),
    "delivery_status": payload.get("delivery_status", "skipped" if mode == "draft" else "failed"),
    "delivery_message_id": payload.get("delivery_message_id"),
    "error_message": payload.get("error_message"),
    "created_at": payload.get("created_at") or payload.get("started_at") or payload.get("completed_at"),
    "updated_at": payload.get("updated_at") or payload.get("completed_at") or payload.get("started_at"),
}

items = payload.get("items") or []
item_rows = []
for idx, item in enumerate(items, start=1):
    item_rows.append({
        "id": item.get("id"),
        "run_id": run_row["id"],
        "rank": item.get("rank") or idx,
        "headline": item.get("headline", ""),
        "source_name": item.get("source_name", ""),
        "source_url": item.get("source_url", ""),
        "published_at": item.get("published_at"),
        "summary": item.get("summary", ""),
        "topic": item.get("topic"),
        "created_at": item.get("created_at") or run_row["updated_at"],
    })

# Persist the exact records payload used by the database writer for auditability.
record_file = output_file.with_suffix(".records.json")
with record_file.open("w", encoding="utf-8") as f:
    json.dump({"run": run_row, "items": item_rows}, f, ensure_ascii=False, indent=2)

data_writer = project_root / "scripts" / "data_writer.py"
subprocess.run(
    [
        "python3", str(data_writer), "write",
        "--table", "result_digest_runs",
        "--conflict", "scheduled_for",
        "--run-id", str(run_id),
        "--records", json.dumps([run_row], ensure_ascii=False),
    ],
    check=True,
)

if item_rows:
    subprocess.run(
        [
            "python3", str(data_writer), "write",
            "--table", "result_digest_items",
            "--conflict", "run_id,source_url",
            "--run-id", str(run_id),
            "--records", json.dumps(item_rows, ensure_ascii=False),
        ],
        check=True,
    )

result = {
    "run_id": run_row["id"],
    "mode": mode,
    "run_upserted": True,
    "item_rows_upserted": len(item_rows),
    "status": run_row["status"],
    "delivery_status": run_row["delivery_status"],
    "delivery_message_id": run_row["delivery_message_id"],
}

with output_file.open("w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, indent=2)
PY
```

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: results-store-write complete"
