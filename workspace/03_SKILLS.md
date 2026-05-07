# Step 3 of 5 — Skills

## Added Skills

| #    | Skill ID                  | Skill Name               | Mode   | Risk Level | Description                |
|------|---------------------------|--------------------------|--------|------------|----------------------------|
| S1   | `data-writer` | Data Writer | Auto | Low | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| S2   | `result-query` | Result Query | Auto | Low | Read stored records from the agent result tables for inspection and follow-up questions. |
| S3   | `github-action` | GitHub Action | Auto | Low | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| S4   | `news-search` | India News Search | Auto | Low | Fetches India-related news candidates from the prior 24 hours. |
| S5   | `digest-summarize` | Digest Summarization | Auto | Low | Deduplicates, ranks, and formats the top 10 India news items into a WhatsApp-ready digest. |
| S6   | `results-store-write` | Results Store Write | Auto | Low | Persists the digest run record and selected items, then finalizes delivery status. |

## Skill Dependencies (Execution Order)

```
data-writer
result-query
github-action
news-search
digest-summarize ← depends on news-search
results-store-write ← depends on digest-summarize
```

## Execution Mode Summary

| Mode  | Count          |
|-------|----------------|
| HiTL  | 0              |
| Auto  | 6 |
