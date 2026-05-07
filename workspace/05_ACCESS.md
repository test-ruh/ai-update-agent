# Step 5 of 5 — Access

## User Access

### Authorized Teams

| Team               | Access Level | Members (approx) |
|--------------------|-------------|-------------------|
| Operators | read/write | OpenClaw workspace admins |

### Restricted From

| Team / Role          | Reason                          |
|----------------------|---------------------------------|
| Guest users | They should not modify secrets or delivery configuration. |

## HiTL Approvers

| Skill                | Action                         | Approver             | Fallback Approver    |
|----------------------|--------------------------------|----------------------|----------------------|
| digest-summarize | approve fallback or rerun after structured-output failure | Workspace operator | Auto-fail with partial status and send the fallback note |

## Model Configuration

| Field                | Value                          |
|----------------------|--------------------------------|
| **Primary Model**    | claude-sonnet-4   |
| **Fallback Model**   | claude-haiku-3  |

## Token Budget

| Field                  | Value                  |
|------------------------|------------------------|
| **Monthly Budget**     | 200000 tokens |
| **Alert Threshold**    | 160000 tokens |
| **Auto-Pause on Limit**| Yes |

## Security & Permissions

| Permission                         | Allowed    |
|------------------------------------|------------|
| Send WhatsApp messages | ✅ |
| Read/write run records | ✅ |
| Modify secrets | ❌ |
