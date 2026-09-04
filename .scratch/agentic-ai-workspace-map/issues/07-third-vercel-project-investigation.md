Type: research
Status: resolved

## Question

Ticket 03 found that `mission-control-vercel-curated2`'s working tree (a "salary-certificate" Next.js feature) is linked via its own `.vercel/project.json` to `prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` / `team_okNwqr3o8ikdFxEEpcckhPlC` — a **third distinct Vercel project and team**, different from both mission-control root's own link (`prj_hfdIL1BYKitpZTxpH5EixAputdzQ` / `team_OS8nENECHPCuieeZsEhya9sF`) and anything else seen in this effort so far, despite Vercel showing the same display name "mission-control" for more than one of these.

Investigate (via the Vercel MCP tools if authenticated, or by asking พี่เอก to check the Vercel dashboard if not): is `prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` a live, currently-deployed project? What does it actually serve? Is the "salary-certificate" feature the real, current source for it, or a stale/abandoned checkout? This determines whether `mission-control-vercel-curated2`'s working tree is load-bearing (needs proper version control before anyone touches it) or dead weight.

See [CONTEXT.md](../CONTEXT.md), "mission-control-vercel-curated2", and ticket 03's `## Answer`.

## Answer

Vercel MCP couldn't reach it directly: the connected account only has access to team `omega--project` (`team_OS8nENECHPCuieeZsEhya9sF`, the same team mission-control root deploys under), not `team_okNwqr3o8ikdFxEEpcckhPlC`. That team belongs to พี่เอก's **personal** Vercel account, separate from the `E0993599799`/omega-oracle org account used for mission-control and everything else audited so far.

พี่เอก checked directly: **`prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` is live**, and it is genuinely serving the "salary-certificate" feature.

**This changes ticket 03's recommendation.** `mission-control-vercel-curated2`'s working tree is not dead weight or a stale leftover — it's the **only known source for a live production deployment**, currently sitting with zero real version control (the `.git` there is the inert leftover ticket 03 found — 8KB, no object database). This is now a genuine risk: a live site with no git history backing it, one accidental `rm -rf` away from being unrecoverable. Recommend a follow-up task ticket to give it real version control (init a proper repo, or fold into an existing one) — not urgent-blocking, but higher priority than the "safe to remove the .git leftover" framing ticket 03 originally implied.
