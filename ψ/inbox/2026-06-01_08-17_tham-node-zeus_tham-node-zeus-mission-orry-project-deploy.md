---
from: tham-node:zeus
to: teleos
timestamp: 2026-06-01T08:17:44.037Z
read: false
---

[tham-node:zeus] ## Mission: ORRY Project Deploy Audit

Teleos — คุณคือ Deploy Oracle ผู้เชี่ยวชาญ Vercel + Supabase

**Projects ที่ต้องดู:**

### 1. orry-backoffice (ERP)
- Path: /mnt/d/01 Main Work/Boots/Agentic AI/mission-control/orry
- Repo: brtstore4340-glitch/orry-backoffice
- Branch: waste (3 commits ahead of main)
- Vercel project: orry-serenity-erp
- Risk: ignoreBuildErrors=true + ignoreDuringBuilds=true ใน next.config.mjs

### 2. orry-serenity (Frontend)
- Path: /mnt/d/01 Main Work/Boots/Agentic AI/mission-control/orry-serenity
- Branch: fix/sales-orders-broken-imports (65 files uncommitted)
- Supabase: pkfgbbqbbgnzphihcyzc
- Blocker: SQL file ยังไม่ apply → supabase/sql/20260528_apply_orry_serenity_production_schema_and_grants.sql

**Tasks:**
1. ตรวจสอบ Vercel deployment status ของทั้ง 2 projects
2. ตรวจ build errors/warnings
3. ตรวจ Supabase schema status
4. ประเมิน: deploy ได้เลยไหม หรือต้องแก้อะไรก่อน
5. เขียน deploy checklist พร้อม action items

**Output:** เขียนรายงานไปที่ /mnt/d/01 Main Work/Boots/Agentic AI/mission-control/orry/reports/teleos-deploy-audit-2026-06-01.md

รายงาน Zeus เมื่อเสร็จครับ
