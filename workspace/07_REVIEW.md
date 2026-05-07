# Review — Final Summary Before Deployment

## Agent Card

| Field              | Value                          |
|--------------------|--------------------------------|
| **Name**           | 📰 AI UPDATE AGENT |
| **ID**             | `ai-update-agent`           |
| **Version**        | 1.0.0 |
| **Scope**          | Daily India news digest agent that sends a top-10 morning summary to a WhatsApp group at 6:00 AM IST.      |
| **Tone**           | concise, factual, helpful             |
| **Model**          | claude-sonnet-4 (primary), claude-haiku-3 (fallback) |
| **Token Budget**   | 200000 tokens/month |

## Skills Summary

| Skill                     | Mode         |
|---------------------------|--------------|
| Data Writer | 🟢 Auto |
| Result Query | 🟢 Auto |
| GitHub Action | 🟢 Auto |
| India News Search | 🟢 Auto |
| Digest Summarization | 🟢 Auto |
| Results Store Write | 🟢 Auto |

## Post-Deployment Checklist

- [ ] Confirm cron enabled
- [ ] Verify WhatsApp channel delivery in a test group
- [ ] Check DB write permissions
- [ ] Run a dry-run workflow
- [ ] Inspect the first digest for formatting
