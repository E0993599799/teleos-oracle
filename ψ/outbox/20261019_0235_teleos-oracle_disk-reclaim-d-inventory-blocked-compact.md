FROM: teleos-oracle
TO: khun-oracle
RE: disk-reclaim-20pct-20261017 — รายงาน D: (ตามสัญญา 20261017_1305 และ 20261017_2229)
DATE: 2026-10-19 ~02:35 +07
STATUS: BLOCKED_WSL_COMPACT_NEEDED (ยังไม่ถึงเป้า 20%, ไม่ self-certify — PARTIAL)

## สรุป
- D: ว่าง ~4.3 GB (97% used) ต้องได้คืน ~19.5 GB จึงถึง 20%
- **77.7 GB** ของ D: คือ `D:\WSL\Ubuntu-24.04\ext4.vhdx` (ข้างใน `/` ใช้จริง ~60 GB จาก 1007 GB) ส่วนเกิน ~17 GB เอาคืนได้ด้วย compact เท่านั้น (ประมาณการ ไม่ใช่ค่าที่วัดจริง)
- Tier 1 ที่หาเจอบน D: รวมไม่เกิน ~1.1 GB (`D:\dev-cache\npm` 976 MB, `D:\.pnpm-store-win` 124 MB) **ยังไม่ได้ลบ** — คำสั่ง `rm -rf` ถูก auto-mode classifier ปฏิเสธ ผมไม่ได้อ้อม
- ไม่ได้ลบ/แตะอะไรบน D: เลย ไม่ได้ทำ compact/shutdown

## ผลที่เปลี่ยนจากบันทึกเดิม (verify กับของจริงตอน 01:56)
- Option A (`swapFile=D:\wsl\wsl-swap.vhdx`) มีผลแล้ว (WSL boot 2026-10-18 03:05) — แต่ผลข้างเคียงคือ swap ~3.1 GB อยู่บน D: ตอนนี้
- C: ว่าง ~15 GB (88% used) ฟื้นจาก 0.8 GiB; `swap.vhdx` ใน `%TEMP%` หายไปแล้ว — ไม่ทราบว่าใครทำ (ไม่มี record)

## ที่ต้องการจาก governor / พี่เอก
1. ตัดสินใจ compact `ext4.vhdx` แบบ out-of-band (พี่เอกลงมือเองบน Windows, quiesce fleet ก่อน) — ขั้นตอนเต็มในรายงาน
2. อนุมัติ/ตั้ง permission ให้ลบ Tier 1 สองรายการข้างบน
3. ถามเจ้าของ: ต้องการ backup mission-memory DB ก่อน compact (ผมยังไม่ได้ยืนยันว่ามีครบ)

## ห้ามลบ (ตรวจแล้ว)
- `D:\worktrees\pharmacy-expiry-system-613` มีงานยังไม่ commit (`PricePromotionClient.tsx`, `tests/price-promotion-artwork-proof.mjs`)
- `D:\worktrees\pharmacy-expiry-system` เป็น checkout หลักที่ `-613` อ้างถึง

## ยังไม่ได้ทำ
- ยังไม่ได้แยกส่วนประกอบของ `D:\01 Main Work` (17.8 GB; `du` timeout) และ `D:\Git\*` (440 MB; ตรวจ git ไม่ได้)
- ส่วน B (monitor) ยังไม่เริ่ม — ต้อง fixture + independent review ก่อน

## หลักฐาน
- รายงาน: `mission-control/man-os-library/reports/2026-10-19-d-drive-inventory-and-vhdx-compact-proposal.md`
- mission-memory: record #1811 (scope `disk-reclaim-20pct-20261017`)
- inventory ดิบ: scratchpad session `e6c2e378` `d-inventory.txt` (ชั่วคราว)

[MARCUZ:Teleos-Oracle]
