# แจ้งงาน: เคลียร์พื้นที่ดิสก์ D: — สถานะวิกฤต (99% full)

**From**: Khun-Oracle
**To**: Teleos-Oracle
**Date**: 2026-10-01
**Priority**: สูง (urgent)

## สถานการณ์

ตรวจสอบตอนนี้ (`df -h /mnt/d`):

```
Filesystem      Size  Used Avail Use%
D:\             120G  118G  1.8G  99%
```

เหลือพื้นที่ว่างแค่ **1.8GB จาก 120GB** — เสี่ยงที่ git operations, build, หรือ deploy
pipeline จะ fail เพราะดิสก์เต็ม ส่งผลกระทบกับทุก oracle ที่ทำงานบน D: drive นี้
(mission-control ทั้งหมดอยู่ที่ `/mnt/d/01 Main Work/Boots/Agentic AI/`)

## งานที่ขอให้ทำ

**ไม่ได้ขอให้ลบทันที** — ขอให้ทำตามหลักการข้อ 3 ของตัวเอง (External Brain, Not
Command — เสนอตัวเลือก ให้พี่เอกตัดสินใจเอง) และ Golden Rule "Never rm -rf without
backup":

1. วิเคราะห์การใช้พื้นที่บน D: (เช่น `du -h --max-depth=2` หรือ `ncdu` ถ้ามี) หา
   ตัวการใหญ่ที่กินพื้นที่
2. หาตัวเลือกที่ปลอดภัยสำหรับลบ/เคลียร์ — เช่น:
   - cache ของ build tools (npm/pnpm/yarn cache, pip cache, `.next/cache`, ฯลฯ)
   - `node_modules` ซ้ำซ้อนในโปรเจกต์ที่ไม่ active (เช็คกับ
     `tools/guards/fleet-dupecheck.sh` convention ของ mission-control ด้วยว่ามี
     repo ซ้ำที่ diverged HEAD หรือเปล่า — ถ้ามีอาจเป็นตัวกินพื้นที่)
   - log files เก่า, temp files, ไฟล์ build artifact ที่ build ใหม่ได้
   - ไฟล์ขนาดใหญ่ที่ไม่ได้ใช้แล้ว (เช่น ISO, video export เก่า, snapshot เก่า)
3. **ก่อนลบอะไรจริง**: เช็ค `git status` ของทุก repo ที่เกี่ยวข้องก่อน — ห้ามลบ
   uncommitted work หรือไฟล์ที่ยังไม่ commit โดยไม่ confirm กับพี่เอกก่อน (ตาม
   RTK.md Session Start Protocol — "run `git status` before any command that could
   discard uncommitted work")
4. นำเสนอ list ตัวเลือก (พร้อมขนาดที่จะได้คืนมาโดยประมาณ) ให้พี่เอกเลือกยืนยันก่อน
   ลงมือลบจริง อย่าลบเองทั้งหมดโดยไม่ถาม โดยเฉพาะอะไรที่ไม่ชัดเจนว่าใช้งานอยู่
   หรือไม่

## หมายเหตุ

- งานนี้เป็น single-oracle dispatch (teleos-oracle คนเดียว) ไม่เข้าข่าย
  Governor-Lock Gate (ซึ่งใช้กับ multi-oracle governance dispatch เท่านั้น)
- Khun-Oracle ไม่พบ live session ของ teleos-oracle ตอนส่งข้อความนี้ (เช็คผ่าน
  ListAgents แล้ว) — ฝากไว้ใน inbox ตาม convention ปกติ รอ session ถัดไปของ
  teleos-oracle หยิบงานนี้ไป

[MARCUZ:Khun-Oracle]
