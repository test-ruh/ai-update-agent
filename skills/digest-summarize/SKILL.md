---
name: digest-summarize
version: 1.0.0
description: "Deduplicates, ranks, and formats the top 10 India news items into a WhatsApp-ready digest."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [python3, bash]
      env: [LLM_API_KEY]
    primaryEnv: LLM_API_KEY
---
# Digest Summarization

## I/O Contract

- **Input:** `/tmp/news-search_${RUN_ID}.json`
- **Output:** `/tmp/digest-summarize_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
