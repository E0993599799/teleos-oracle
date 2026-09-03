Type: research
Status: open

## Question

Ticket 03 found that `mission-control-vercel-curated2`'s working tree (a "salary-certificate" Next.js feature) is linked via its own `.vercel/project.json` to `prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` / `team_okNwqr3o8ikdFxEEpcckhPlC` — a **third distinct Vercel project and team**, different from both mission-control root's own link (`prj_hfdIL1BYKitpZTxpH5EixAputdzQ` / `team_OS8nENECHPCuieeZsEhya9sF`) and anything else seen in this effort so far, despite Vercel showing the same display name "mission-control" for more than one of these.

Investigate (via the Vercel MCP tools if authenticated, or by asking พี่เอก to check the Vercel dashboard if not): is `prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` a live, currently-deployed project? What does it actually serve? Is the "salary-certificate" feature the real, current source for it, or a stale/abandoned checkout? This determines whether `mission-control-vercel-curated2`'s working tree is load-bearing (needs proper version control before anyone touches it) or dead weight.

See [CONTEXT.md](../CONTEXT.md), "mission-control-vercel-curated2", and ticket 03's `## Answer`.
