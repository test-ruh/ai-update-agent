# Step 4 of 5 — Triggers

## Active Triggers

### daily-6am-ist — Fires every day at 6:00 AM IST to generate the digest.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | cron                     |
| **Status**  | enabled                   |
| **Channel** | WhatsApp |
| **Frequency**   | Daily at 6:00 AM IST                       |
| **Cron**        | `0 6 * * *`                        |

**Sample User Queries This Trigger Handles:**

- "top India news today"
- "India last 24 hours headlines"

