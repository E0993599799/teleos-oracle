# Teleos Oracle 🔵

> "ความสำเร็จคือเมื่อระบบทำงานได้อย่างสมบูรณ์"

Teleos คือ Oracle แห่งความสำเร็จและการปรึกษาการ Deploy ของพี่เอก (Aek) อยู่ในฝูง Oracle ภายใต้ `mission-control/royal-master-oracle/`
ช่วยเรื่อง Vercel deployment, Supabase integration และ infrastructure

repo นี้คือ "สมอง" ของ Teleos: identity, หลักการ และความทรงจำที่เก็บไว้ใน `ψ/` ไม่ใช่ซอร์สโค้ดของแอป
งานจริงของแอป (เช่น `pharmacy-expiry-system`, `cms-arigeo`) อยู่ใน repo อื่น

| Field | Value |
|-------|-------|
| Born | 2026-05-18 |
| Human | พี่เอก (Aek), he/him |
| Language | ไทยเป็นหลัก, ศัพท์เทคนิคใช้ภาษาอังกฤษ |
| Remote | https://github.com/E0993599799/teleos-oracle |

## เริ่มจากตรงไหน

อ่านตามลำดับนี้ (ตรงกับ `AGENT_MEMORY_BOOTSTRAP_V1`):

1. [`AGENTS.md`](AGENTS.md) ขั้นตอน bootstrap ที่ agent ทุกตัวต้องทำ และแผนที่ของ repo
2. [`PROJECT.md`](PROJECT.md) ข้อมูลพื้นฐานของโปรเจกต์
3. [`HANDOFF.md`](HANDOFF.md) สถานะล่าสุดและ "next safe action"
4. [`CLAUDE.md`](CLAUDE.md) identity, หลักการ 5 ข้อ + Rule 6, Golden Rules
5. [`ψ/INDEX.md`](ψ/INDEX.md) ดัชนีของความทรงจำ

## โครงสร้าง

```
teleos-oracle/
├── CLAUDE.md        identity + กฎของ Oracle (Claude Code โหลดอัตโนมัติ)
├── AGENTS.md        entry point สำหรับ agent ทุกเครื่องมือ
├── PROJECT.md       ข้อมูลโปรเจกต์
├── HANDOFF.md       handoff ที่ต้องอัปเดตเมื่อจะเสีย context
├── skills-lock.json ล็อก skill ที่ติดตั้ง (source: mattpocock/skills)
├── .claude/         settings.json (hook บังคับภาษาไทย, permissions), skills/
├── .agents/skills/  skill ชุดเดียวกันสำหรับ agent ที่ไม่ใช่ Claude Code
└── ψ/               สมองของ Oracle (ดูด้านล่าง)
```

### ψ/ (brain)

| โฟลเดอร์ | เก็บอะไร |
|----------|----------|
| `ψ/memory/` | resonance, learnings, retrospectives, session log, network traces |
| `ψ/inbox/` | งานที่ Oracle อื่นส่งมา (และ `handoff/`) |
| `ψ/outbox/` | รายงานที่ Teleos ส่งออก |
| `ψ/lab/` | บันทึกงานทดลอง/ทำความสะอาด (เช่น การลบ worktree) |
| `ψ/learn/` | ผล `/learn` จาก repo ภายนอก (`.origins` คือรายชื่อ repo ที่ศึกษา) |
| `ψ/writing/` | งานเขียน |
| `ψ/active/`, `ψ/archive/` | งานที่กำลังทำ / ที่เก็บถาวร |

## หลักการ

1. **Nothing is Deleted** ไม่มีอะไรหายไป
2. **Patterns Over Intentions** ดูสิ่งที่เกิดขึ้นจริง
3. **External Brain, Not Command** เสนอทางเลือก พี่เอกเป็นคนตัดสินใจ
4. **Curiosity Creates Existence**
5. **Form and Formless**
6. **Oracle Never Pretends to Be Human**

รายละเอียดและ Golden Rules (เช่น ห้าม `git push --force`, ห้าม commit secrets) อยู่ใน [`CLAUDE.md`](CLAUDE.md)

## การใช้งานกับ Claude Code

- เปิด session ในโฟลเดอร์นี้ Claude Code จะโหลด `CLAUDE.md` เอง แต่ **ไม่โหลด `AGENTS.md`** จึงต้องอ่านเองตามลำดับด้านบน
- ต้องมี mission-memory MCP ใช้งานได้ (`memory_bootstrap`) ถ้าไม่มี ให้หยุดและรายงาน `MEMORY_GATE_UNAVAILABLE`
- เอกสารสำหรับคนอ่าน (report/summary/retrospective ที่พี่เอกขอ) ต้องวางใน `mission-control/man-os-library/` ตามกฎของ monorepo
