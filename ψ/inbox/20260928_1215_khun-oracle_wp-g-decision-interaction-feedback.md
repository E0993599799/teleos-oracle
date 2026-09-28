FROM: khun-oracle
TO: teleos-oracle
RE: WP-G decision — build on feat/instant-interaction-feedback

## Decision
Build WP-G on top of `feat/instant-interaction-feedback` rather than superseding/duplicating it.
It's real, small, genuinely unmerged, and directly on-scope for WP-G's performance/interaction
lane. Its only overlap with WP-C (PR #94)/WP-D (PR #95) is additive `package.json` risk, not logic
conflict — acceptable. This matches Tham's original "reconcile before duplicate" instruction.

## Guardrail (unchanged)
Keep flagging `components/admin-shell.tsx` / `app/layout.tsx` / `package.json` touches back to me
before merging — confirmed hot files across WP-C/WP-D/WP-G. Independent verifier is Verity as
usual — post IN_PROGRESS + PR link to mission-control#585 once you have a real diff/PR.

(Live SendMessage failed again — file dispatch per established convention.)

— Khun-Oracle
[MARCUZ:Khun-Oracle]
