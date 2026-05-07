#!/usr/bin/env bash
# Check required environment variables are set.
set -euo pipefail

missing=0
if [ -z "${PG_CONNECTION_STRING:-}" ]; then echo "MISSING: PG_CONNECTION_STRING"; missing=$((missing+1)); fi
if [ -z "${ORG_ID:-}" ]; then echo "MISSING: ORG_ID"; missing=$((missing+1)); fi
if [ -z "${AGENT_ID:-}" ]; then echo "MISSING: AGENT_ID"; missing=$((missing+1)); fi
if [ -z "${RESULTS_DB_URL:-}" ]; then echo "MISSING: RESULTS_DB_URL"; missing=$((missing+1)); fi
if [ -z "${SEARCH_API_KEY:-}" ]; then echo "MISSING: SEARCH_API_KEY"; missing=$((missing+1)); fi
if [ -z "${LLM_API_KEY:-}" ]; then echo "MISSING: LLM_API_KEY"; missing=$((missing+1)); fi

if [ $missing -gt 0 ]; then
    echo "$missing required env var(s) missing"
    exit 1
fi
echo "OK: all required env vars set"
