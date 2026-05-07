# Workflow — End-to-End Process Flow

## Workflow Steps

1. **data-writer** → data-writer
2. **news-search** → news-search
3. **digest-summarize** → digest-summarize (depends on news-search)
4. **persist-draft** → results-store-write (depends on digest-summarize)
5. **send-whatsapp** → native-tool: message (depends on persist-draft)
6. **persist-delivery** → results-store-write (depends on send-whatsapp)

## Diagram

```
data-writer → news-search → digest-summarize → persist-draft → send-whatsapp → persist-delivery
```
