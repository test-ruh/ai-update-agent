# 📰 AI UPDATE AGENT

Daily India news digest agent that sends a top-10 morning summary to a WhatsApp group at 6:00 AM IST.

## Quick Start

```bash
git clone git@github.com:${GITHUB_OWNER}/ai-update-agent.git
cd ai-update-agent

# 1. Configure
cp .env.example .env
# Edit .env with your credentials (see "Required Environment Variables" below)

# 2. One-shot setup: validates env, installs deps, provisions DB, registers cron
chmod +x setup.sh
./setup.sh
```

## Manual Setup (if you prefer step-by-step)

```bash
cp .env.example .env             # then edit it
set -a; source .env; set +a       # load vars into the current shell
bash check-environment.sh         # verify everything required is set
bash install-dependencies.sh      # pip install psycopg2-binary, pyyaml
python3 scripts/data_writer.py provision   # create tables in your schema
openclaw cron add --file cron/daily-india-news.json
```

## Running

```bash
bash test-workflow.sh             # run every skill in order locally (smoke test)
openclaw cron run --name daily-india-news    # trigger manually
openclaw cron list                # see registered jobs
openclaw cron runs                # see run history
```

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `PG_CONNECTION_STRING` | Postgres Connection String |
| `ORG_ID` | Org Id |
| `AGENT_ID` | Agent Id |
| `RESULTS_DB_URL` | PostgreSQL connection string |
| `SEARCH_API_KEY` | Web/news search API key |
| `LLM_API_KEY` | LLM summarization API key |

## Skills

| Skill | Mode | Description |
|-------|------|-------------|
| `data-writer` | Auto | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| `result-query` | User-invocable | Read stored records from the agent result tables for inspection and follow-up questions. |
| `github-action` | User-invocable | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| `news-search` | Auto | Fetches India-related news candidates from the prior 24 hours. |
| `digest-summarize` | Auto | Deduplicates, ranks, and formats the top 10 India news items into a WhatsApp-ready digest. |
| `results-store-write` | Auto | Persists the digest run record and selected items, then finalizes delivery status. |

## Scheduled Jobs

| Job Name | Schedule | Notes |
|----------|----------|-------|
| `daily-india-news` | `0 6 * * *` | Timezone: Asia/Kolkata |


## Architecture

- **Runtime**: OpenClaw AI agent framework
- **Data Layer**: PostgreSQL via `scripts/data_writer.py`
- **Scheduling**: OpenClaw cron
- **Schema**: `org_{org_id}_a_ai_update_agent`

## Directory Structure

```
ai-update-agent/
├── README.md
├── openclaw.json
├── result-schema.yml
├── env-manifest.yml
├── .env.example
├── requirements.txt
├── .gitignore
├── check-environment.sh
├── install-dependencies.sh
├── test-workflow.sh
├── cron/
├── workflows/
├── scripts/
│   ├── data_writer.py
│   └── github_action.py
├── skills/
└── workspace/
    ├── SOUL.md
    ├── 01_IDENTITY.md
    ├── 02_RULES.md
    ├── 03_SKILLS.md
    ├── 04_TRIGGERS.md
    ├── 05_ACCESS.md
    ├── 06_WORKFLOW.md
    └── 07_REVIEW.md
```
