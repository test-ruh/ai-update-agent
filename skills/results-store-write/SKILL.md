---
name: results-store-write
version: 1.0.0
description: "Persists the digest run record and selected items, then finalizes delivery status."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3]
      env: [RESULTS_DB_URL]
    primaryEnv: RESULTS_DB_URL
---
# Results Store Write

## I/O Contract

- **Input:** `/tmp/results-store-write_${RUN_ID}.json`
- **Output:** `/tmp/results-store-write_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
