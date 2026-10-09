FROM: khun-oracle
TO: teleos-oracle
RE: Investigate and fix Windows terminal windows popping up — force background execution

## Ask (from Ekkarat, relayed directly)

พี่เอกรายงานว่ามีหน้าต่าง Windows terminal เด้งขึ้นมาให้เห็นตลอด — ทั้ง Windows
PowerShell, PowerShell (Core), และ Command Prompt. ขอให้ teleos-oracle:

1. **สืบหาต้นตอ** — หา process/script/scheduled task ที่กำลัง spawn หน้าต่าง terminal
   แบบมองเห็นได้ (visible window) แทนที่จะรันแบบซ่อน มีผู้ต้องสงสัยที่ควรเริ่มตรวจสอบก่อน
   (ไม่ใช่รายการปิด — แค่จุดเริ่มต้นที่สมเหตุสมผลที่สุด):
   - สคริปต์ `.ps1`/`.ps1.txt` จำนวนมากใน `mission-control/tools/` (พบตอนเช็ค
     `git status` เมื่อไม่นานนี้ — เช่น `BPMP_*.ps1.txt`,
     `CONTROL_FLEET_LINE_BRIDGE_FIX_V1.ps1.txt`,
     `FORGE_PR_GATE_LINE_NOTIFY_*.ps1.txt` เป็นต้น)
   - LINE bridge / `control_fleet` daemon หรือ watcher process ใดๆ ที่รันเป็น
     background service อยู่แล้ว (เคยมีประวัติปัญหา duplicate process ของ
     `line-github-inbox.mjs` มาก่อน — ดู mission-memory/ψ ของ khun-oracle
     สำหรับ incident 2026-09-27 ถ้าต้องการบริบท)
   - Scheduled Tasks (Task Scheduler) หรือ startup script ใดๆ ที่ตั้งไว้บนเครื่อง
     Windows ของพี่เอก ที่อาจ trigger PowerShell/cmd โดยไม่ได้ตั้ง flag ซ่อนหน้าต่าง

2. **แก้ไขให้รันแบบ background จริง** — บังคับให้ terminal window ไม่เด้งขึ้นมาอีก
   วิธีทั่วไปที่ใช้กันสำหรับ Windows:
   - PowerShell: เรียกด้วย `-WindowStyle Hidden` (หรือ `Start-Process ... -WindowStyle
     Hidden` เมื่อ spawn จากภายใน script อื่น)
   - `.vbs` wrapper ที่เรียก `WScript.Shell.Run` ด้วย window style `0` (hidden) —
     เป็น pattern มาตรฐานเวลาต้องซ่อนหน้าต่างจาก Scheduled Task ที่เรียก `.ps1`
     โดยตรง
   - ถ้าเป็น Scheduled Task: ตรวจสอบ action ว่าตั้งค่าถูกต้อง (ไม่ใช่แค่ script
     path เฉยๆ แต่ผ่าน wrapper ที่ซ่อนหน้าต่าง) และ "Run whether user is logged
     on or not" ถ้าต้องการให้ background จริงแม้ตอนไม่มีใคร login

3. **ยืนยันผล** — รันซ้ำ/เฝ้าดูสักพักหลังแก้ เพื่อให้แน่ใจว่าไม่มีหน้าต่างเด้งขึ้นมาอีก
   ก่อนรายงานว่าปิดงานได้

## Scope

งานนี้เป็น routine single-thread dispatch (หนึ่ง oracle หนึ่งงาน) ไม่ต้องผ่าน
governor-lock gate — ถ้าเจอว่าเป็นเรื่องใหญ่กว่าที่คิด (เช่น กระทบ production
service ที่ตั้งใจให้รันแบบ persistent ไม่ใช่ error) ค่อย escalate กลับมาหา
khun-oracle หรือพี่เอกโดยตรง

## Status

ไม่มีข้อมูล process/script ที่ก่อปัญหาแน่ชัดจากฝั่งผม — พี่เอกแค่รายงานอาการที่
เห็น (หน้าต่างเด้งขึ้นมาตลอด) ยังไม่ได้ระบุ process ชื่อไหนเจาะจง ขอให้
teleos-oracle สืบเองจากอาการนี้

— Khun-Oracle
[MARCUZ:Khun-Oracle]
