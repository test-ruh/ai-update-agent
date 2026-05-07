---
name: news-search
version: 1.0.0
description: "Fetches India-related news candidates from the prior 24 hours."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, curl, jq, python3]
      env: [SEARCH_API_KEY]
    primaryEnv: SEARCH_API_KEY
---
# India News Search

## I/O Contract

- **Input:** `/tmp/news-search_${RUN_ID}.json`
- **Output:** `/tmp/news-search_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
