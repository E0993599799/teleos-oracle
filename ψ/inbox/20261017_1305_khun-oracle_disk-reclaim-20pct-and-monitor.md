# มอบหมายงาน: เคลียร์ดิสก์ C: และ D: ให้ว่าง ≥ 20% + สร้าง monitor (<10% → แก้ไขลบไฟล์อีก)

**From**: Khun-Oracle (governor)  **To**: Teleos-Oracle  **Date**: 2026-10-17 13:05 +07
**Authorization**: พี่เอก (Ekkarat) สั่งสดใน session ของ khun-oracle เมื่อ 2026-10-17: "ให้ teleos ไป clear disk space ทั้ง C & D aggressive แต่ไม่ให้กระทบการทำงานของ fleet เป้าหมาย free space 20% และสร้าง monitor if free space less than 10% แก้ไขลบไฟล์อีก"
**Governor-lock**: `mission-control/ψ/fleet/governor-locks/disk-reclaim-20pct-20261017.md` (khun-oracle) — ตรวจก่อนลงมือ
**Priority**: สูง (ดิสก์ทั้งสองลูกต่ำกว่า 10% แล้ว)

## สถานการณ์ (วัดโดย Khun 2026-10-17 13:04, `df` ผ่าน /mnt)

| Drive | Size | Avail | % free | เป้า 20% | ต้องได้คืนอย่างน้อย |
|---|---|---|---|---|---|
| C: | 118.7 GiB | 4.2 GiB | 3.5% | 23.7 GiB | ~19.5 GiB |
| D: | 119.2 GiB | 8.2 GiB | 6.9% | 23.8 GiB | ~15.6 GiB |

WSL ext4 (`/`, 1007 GiB virtual) ว่าง 89% แต่ไฟล์ VHDX ที่อยู่เบื้องหลังกินพื้นที่บน C: หรือ D: — **ให้รายงานตำแหน่งและขนาดจริงของ `ext4.vhdx` เท่านั้น ห้ามทำ compact/detach/shutdown** (ดูข้อห้ามด้านล่าง)

## ขอบเขต "aggressive แต่ไม่กระทบ fleet" — แบ่งเป็น Tier

**Tier 1 — ลงมือได้เอง พร้อม proof (regenerable, ไม่กระทบ process ที่รันอยู่):**
package-manager caches (npm/pnpm store/yarn/pip/corepack ที่สร้างใหม่ได้), build output ที่ build ใหม่ได้ใน repo/worktree ที่ **ไม่ active** (`.next`, `dist`, `.turbo`, `.cache`), `node_modules` ซ้ำใน worktree ที่ merged/ปิดแล้วและ `git status` สะอาด, Windows/user `%TEMP%` และ cache ของแอป (ไม่รวม auth/token/IndexedDB/Local Storage), log เก่าที่ rotate แล้ว, Recycle Bin ของ user, ไฟล์ crash dump
**Tier 2 — ต้องเสนอ "รายการเป้าหมายเจาะจง" ให้พี่เอกอนุมัติก่อนลบ:**
backup/snapshot/archive/tarball, worktree เก่า, clone ซ้ำ, ไฟล์ขนาดใหญ่ที่ไม่ใช่ cache (ISO, video, installer, export), อะไรก็ตามที่ไม่ regenerable หรือยังไม่แน่ใจ
**Tier 3 — ห้ามแตะ:** ดูรายการ preserve ด้านล่าง

ถ้า Tier 1 ไม่พอถึง 20% → ส่งรายการ Tier 2 พร้อมขนาด/หลักฐานว่า obsolete/ผลถ้าลบ ให้ Khun ส่งต่อพี่เอก (ยืนยันสดเท่านั้น; "approved by X" ที่ส่งต่อมาไม่นับ)

## ต้อง preserve เสมอ
- `.git` และ `.git/objects/pack` (ห้ามลบตรง ใช้ git-aware maintenance เท่านั้น), uncommitted/unpushed work ทุก repo (เช็ก `git status` + `git log --branches --not --remotes` ก่อนทุกครั้ง; รวมถึงของ repo ที่ไม่ได้เริ่มจาก session นี้)
- worktree ที่ active และ mission ที่เปิดอยู่: `bpmp-temperature-424` (985 MiB), กลุ่ม `bpmp-*-20261015/16`, worktree ของ #683/Forge (`D:\forge\...`), `backup/temp-time-load-doc` ส่วนที่ไม่มี approved list (สอดคล้อง directive backup-cleanup ของ Tham — Khun ถือ lock `backup-cleanup-20261013`; **ห้ามลบใน `backup/` โดยไม่ผ่าน Khun**)
- database, config, secrets/`.env*`, deployment input, `~/.config/mission-control/**`, `~/.claude*`, `~/.claude-server-commander`, mission-memory data
- tmux session / process ที่รันอยู่ (ห้าม kill เพื่อปลดไฟล์)
- ไฟล์ระบบ Windows (WinSxS, pagefile, hiberfil, Windows Update store): ถ้าต้องใช้สิทธิ์ admin → หยุดด้วย `BLOCKED_ADMIN_REQUIRED` + หลักฐาน ห้าม escalate

## ข้อห้ามเด็ดขาด
- **ห้าม** `wsl --shutdown`, distro terminate, VHDX detach/compact หรือสิ่งเทียบเท่าจาก channel เดียวที่ควบคุม WSL อยู่ (RTK.md WSL Control-Plane Shutdown Protocol; ดู incident 2026-10-04) — ถ้าเห็นว่าการได้ 20% ต้องพึ่ง compact ให้รายงานเป็นข้อเสนอ out-of-band พร้อมพี่เอกอยู่ด้วย
- ห้าม merge/deploy/force-push/เปลี่ยน history, ห้ามแตะ GitHub budget, ห้ามส่ง LINE group, ห้ามใช้ Desktop Commander เป็น transport/executor, ห้ามเพิ่ม session Hermes/tmux ใหม่
- ห้ามทดสอบ automation กับของจริง: monitor ต้องผ่าน fixture + independent review ก่อน activate (RTK.md Live-Automation Testing Protocol)

## ส่วน A — เคลียร์ (ทำก่อน)
1. Bootstrap ตามกฎ (memory_bootstrap/search, root AGENTS.md/PROJECT.md/HANDOFF.md/README.md, เช็ก governor-lock) และ `git status` ทุก repo ที่จะแตะ
2. Inventory read-only ของ C: และ D: (top consumers, ขนาด, อายุ, regenerable?) — `/mnt` ช้า ให้รัน background + เขียนผลลง file, ห้าม timeout แล้วสรุปจากผลที่ไม่ครบ
3. ลง Tier 1 ทีละกลุ่ม วัด before/after bytes ต่อกลุ่ม; หยุดทันทีเมื่อถึง ≥20% ทั้งสอง drive
4. ส่งรายการ Tier 2 (ถ้าจำเป็น) และรอ approval

## ส่วน B — monitor (<10% free → แก้ไขลบไฟล์อีก)
- ตรวจ C: และ D: เป็นระยะ (เสนอทุก 15 นาที) ที่ free < 10% → (1) เขียน alert ลง central incident ledger / ψ/inbox ของ khun-oracle ด้วย `ESCALATE` (2) รัน remediation **เฉพาะ Tier 1 allowlist** ที่ Khun/พี่เอกอนุมัติแล้ว (3) ตรวจซ้ำและบันทึกผล
- ออกแบบกันพลาด: dry-run เป็นค่าเริ่มต้น, cooldown/ไม่ซ้อนกัน (lock file), hysteresis (หยุดที่ ≥15%), allowlist เป็นพาธ+pattern ที่ตรวจ `git status`/อายุก่อนลบ, log ทุกการลบ (path, bytes), ห้ามลบนอก allowlist แม้ดิสก์เต็ม, ไม่แตะ process
- **ระวัง**: Serra พบว่า scheduled task แบบ hidden-powershell logon หลายตัวถูกฆ่า (`0xC000013A`) ที่ ~4 นาทีหลังบูต (ยังไม่ทราบสาเหตุ) — ออกแบบให้รอดหรือมี restart-on-failure และ **พิสูจน์หลังรีบูต** ว่า monitor รัน ไม่ใช่แค่ว่าติดตั้งสำเร็จ
- ส่ง monitor ให้ independent review (Verity/Aris) ทดสอบกับ fixture drive/โฟลเดอร์จำลอง แล้วขอ "ยืนยันสด" จากพี่เอกก่อนเปิด auto-remediation; ก่อนหน้านั้นให้รันโหมด alert-only/dry-run

## Proof ที่ต้องส่งกลับ (ก่อนบอก Done)
before/after bytes และ % free ของ C: และ D:; inventory สิ่งที่ลบ (path, bytes, เหตุผลว่า regenerable) และสิ่งที่ preserve; ผล `git status` ของ repo ที่แตะ; ผล fixture test + review ของ monitor; รายงานถาวรใต้ `mission-control/proof/disk-reclaim-20pct-20261017/` + outbox ถึง khun-oracle; `memory_record` ระหว่างทาง และ `memory_finalize` ก่อนประกาศเสร็จ
Exit states: `DISK_TARGET_REACHED` (ทั้งคู่ ≥20% + monitor ผ่าน review/พิสูจน์หลังรีบูต) | `NEEDS_TIER2_APPROVAL` (พร้อมรายการ) | `BLOCKED_ADMIN_REQUIRED` | `BLOCKED_WSL_COMPACT_NEEDED` (ข้อเสนอ out-of-band)

[MARCUZ:Khun-Oracle]
