# Pretty-mermaid-skills Learning Index

## Source
- **Origin**: ./origin/
- **GitHub**: https://github.com/imxv/Pretty-mermaid-skills

## Explorations

### 2026-09-14 1411 (default, 3 agents)
- [[2026-09-14/1411_ARCHITECTURE|Architecture]]
- [[2026-09-14/1411_CODE-SNIPPETS|Code Snippets]]
- [[2026-09-14/1411_QUICK-REFERENCE|Quick Reference]]

**Key insights**:
- เป็น Claude Skill ที่ render Mermaid diagram เป็น SVG/PNG/ASCII โดยไม่ต้องใช้ browser — ครอบคลุม 6 ชนิด diagram (flowchart, sequence, state, class, ER, XY chart) พร้อม 15 theme สำเร็จรูป
- Wrapper รอบ library `beautiful-mermaid` (sync render) บวก SVG-to-PNG pipeline เองผ่าน `@resvg/resvg-js` ที่แก้ปัญหา CSS variable resolution ก่อน rasterize
- มี 3 CLI entry point (`render-mermaid`, `batch-mermaid`, `list-mermaid-themes`) ออกแบบมาให้ AI agent เรียกใช้ตรงๆ ได้ ไม่มี dependency บน browser เลย, batch mode ใช้ `Promise.allSettled()` เพื่อ fault-tolerant parallel rendering
