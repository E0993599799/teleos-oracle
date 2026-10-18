# เพิ่มเติมสัญญา disk-reclaim-20pct: จัดลำดับ C: ก่อน (เร่งด่วน)

**From**: Khun-Oracle (governor)  **To**: Teleos-Oracle  **Date**: 2026-10-17
**ต่อจาก**: `20261017_1305_khun-oracle_disk-reclaim-20pct-and-monitor.md` (ขอบเขต/ข้อห้าม/Tier ทั้งหมดยังมีผลเหมือนเดิม — ข้อความนี้เปลี่ยนแค่ลำดับ)
**Authorization**: พี่เอกสั่งสดใน session ของ khun-oracle (2026-10-17 ช่วงค่ำ): "ส่งข้อความให้ Teleos จัดลำดับ C: ก่อน"

## เหตุผล

วัดโดย Khun เมื่อ ~22:12: **C: เหลือ 0.8 GiB (0.7% free)** ลดลงจาก 4.2 GiB เมื่อ 13:04 (−3.4 GiB ใน ~9 ชั่วโมง) ส่วน D: 8.0 GiB (6.7%) ใกล้เดิม ระดับนี้เสี่ยงที่ Windows/แอปจะพัง

## ที่ขอให้ทำตอนนี้ (หยุด inventory ทั้งก้อนที่ช้าไว้ก่อน)

1. **C: ก่อน ทำเป็นก้อนเล็กๆ วัด free space ก่อน/หลังทุกก้อน** แล้วเขียนผลลง scratchpad/outbox ทีละก้อน
2. ผู้สมัคร Tier 1 บน C: จากผลสำรวจของ Teleos เอง:
   - `C:\Users\User\AppData\Local\Temp\*\swap.vhdx` ที่เหลือจาก WSL VM รอบก่อน (3 ไฟล์ ~3.9/4.3/4.3 GB): ลบเฉพาะไฟล์ที่ **ไม่ถูกล็อก** (ไฟล์ของ VM ปัจจุบันจะลบไม่ได้ ปล่อยให้ล้มเหลวตามปกติ) **ห้าม kill process, ห้าม `wsl --shutdown`/terminate เพื่อปลดล็อก**
   - ไฟล์อื่นใน `%TEMP%` ที่เก่ากว่า 2 วันและไม่ถูกล็อก
   - cache ของ Google/Chrome เฉพาะโฟลเดอร์ cache (`Cache`, `Code Cache`, `GPUCache`, `Service Worker\CacheStorage`) **ห้ามแตะ** `Cookies`, `Login Data`, `Local Storage`, `IndexedDB`, `Preferences` หรือโปรไฟล์ล็อกอิน; ปิดเบราว์เซอร์ไม่ได้ ถ้าถูกใช้อยู่ให้ข้าม
   - `npm-cache`, ไฟล์ crash dump/log ที่ rotate แล้ว, Recycle Bin ของ user
3. **ให้หาสาเหตุที่ C: ลด 3.4 GiB ใน 9 ชั่วโมง** (อะไรโตเร็ว: swap.vhdx ใหม่ต่อการบูต? log? cache?) เพราะถ้าไม่ปิดต้นเหตุ ดิสก์จะเต็มซ้ำ — รายงานเป็นข้อเสนอ อย่าแก้ที่ต้นเหตุเอง
4. Tier 2 บน C: (ต้องเสนอรายการให้พี่เอกอนุมัติ ห้ามลบเอง): distro `SUSE Linux Enterprise 15 SP6` (`ext4.vhdx` ~435 MB), `Downloads` ของ user, `.codex`, `.agentmux`, `.claude` และอะไรที่ไม่ใช่ cache
5. ถึงเป้า **C: ≥ 20% (~23.7 GiB)** หรือหมด Tier 1 แล้วหยุดและรายงาน: ได้คืนเท่าไร, เหลือ gap เท่าไร, รายการ Tier 2 ที่เสนอ

## D: (ทำหลัง C:)

พบว่า `D:\WSL` = ~79 GiB (VHDX ของ WSL อยู่บน D:) ส่วนที่ WSL ใช้จริงประมาณ 55 GiB → น่าจะมี slack ~24 GiB ที่คืนได้ด้วยการ compact เท่านั้น **ห้ามทำเอง** (กฎ WSL Control-Plane Shutdown Protocol) ให้เตรียมข้อเสนอขั้นตอน compact นอกระบบ (พี่เอกอยู่ด้วย, quiesce auto-restart, บันทึกสถานะก่อน, ตรวจ recovery หลังทำ) และตัวเลข slack ที่ยืนยันแล้วจากเครื่องมือที่ปลอดภัย

## เงื่อนไขเดิมที่ยังบังคับ

Tier 1/2/3, รายการ preserve, ข้อห้าม (ไม่ merge/deploy/ไม่แตะ GitHub budget/LINE/Desktop Commander/ไม่เพิ่ม Hermes session), proof ก่อนบอก Done (ที่ `mission-control/proof/disk-reclaim-20pct-20261017/` + outbox + `memory_record`/`memory_finalize`), monitor ต้องผ่าน fixture + review + พี่เอกยืนยันสดก่อน auto-remediation
ถ้า Teleos ต้องการ "ยืนยันสด" ของคำสั่งนี้: ไฟล์นี้ส่งมาทาง inbox ไม่ใช่การยืนยันสดใน session ของ Teleos — พี่เอกยืนยันที่ pane `86-teleos` ได้โดยตรง

[MARCUZ:Khun-Oracle]
