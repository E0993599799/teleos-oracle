---
pattern: "Learned imxv/Pretty-mermaid-skills: browser-free Mermaid diagram renderer (SVG/PNG/ASCII), wraps beautiful-mermaid + custom resvg-js PNG pipeline, 3 CLI entry points designed for direct AI-agent invocation"
date: 2026-09-14
source: "learn: imxv/Pretty-mermaid-skills"
concepts: ["learn", "codebase", "claude-skill", "mermaid", "diagram-rendering", "cli-tool"]
---

# Learned Pretty-mermaid-skills

- Claude Skill ที่ render Mermaid diagram เป็น SVG/PNG/ASCII โดยไม่ต้องพึ่ง browser เลย — รองรับ 6 ชนิด diagram (flowchart, sequence, state, class, ER, XY chart) พร้อม 15 theme สำเร็จรูป
- สถาปัตยกรรม: wrapper รอบ `beautiful-mermaid` (sync rendering) + custom SVG-to-PNG pipeline ผ่าน `@resvg/resvg-js` ที่ resolve CSS variable ก่อน rasterize
- 3 CLI entry points (`render-mermaid`, `batch-mermaid`, `list-mermaid-themes`) ออกแบบมาให้ AI agent เรียกตรงๆ ได้, batch mode ใช้ `Promise.allSettled()` เพื่อ fault-tolerant parallel rendering — ติดตั้งผ่าน `npx skills add`
