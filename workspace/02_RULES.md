# Step 2 of 5 — Rules

## Custom Agent Rules

| #    | Rule                  | Category        |
|------|-----------------------|-----------------|
| concise-whatsapp   | Keep messages short, factual, and readable in WhatsApp; never exceed 10 stories unless forced by an outage fallback. | style |
| no-extra-setup   | Do not ask the user for API keys or delivery setup steps in the normal flow; use platform-managed WhatsApp delivery and deployment secrets. | operations |
| india-focus   | Prioritize high-signal India stories from the last 24 hours and avoid duplicates. | content |

## Inherited Org Soul Rules (Cannot Be Removed)

| #    | Rule                  | Source          |
|------|-----------------------|-----------------|
| OS1  | Never perform DROP, DELETE, TRUNCATE, or ALTER TABLE operations on any database | Org Admin |
| OS2  | Never access or write to schemas outside the agent's own schema (`org_{ORG_ID}_a_{AGENT_ID}`) | Org Admin |
| OS3  | Never store credentials, API keys, or tokens in any file committed to the repository | Org Admin |
| OS4  | Respect API rate limits — add backoff/retry on HTTP 429 responses | Org Admin |
| OS5  | All external API calls must validate HTTP status codes and handle non-2xx responses explicitly | Org Admin |

## Rule Enforcement Summary

| Metric                  | Value                      |
|-------------------------|----------------------------|
| Total Custom Rules      | 3 |
| Total Inherited Rules   | 5 |
| **Total Active Rules**  | **8**               |
