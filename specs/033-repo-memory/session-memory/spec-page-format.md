---
name: spec-page-format
description: "Owner reviews specs as an HTML page with interfig scenario SVGs, written ~80% ASD-STE100 (glossary, EARS, examples)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: ff50ddcf-483c-4295-a51b-13d14d2243d0
  modified: 2026-10-03T02:35:18.291Z
---

The owner reviews a spec at gate H1 as an HTML page, not as markdown in chat. The page has the glossary, the EARS requirements linked to concrete examples, an amendments section, and interfig animated scenarios. The owner said: "me encanta como quedo lo de interfig!!!"

**Why:** Karpathy's point is that humans move up to oversight, so the review gate needs high bandwidth. Writing about 80% in ASD-STE100 makes spec ambiguity visible. That ambiguity is the owner's recurring pain.

**How to apply:**
- Render the scenarios with interfig at `~/code/interfig`, using `npm run svg -- - out.svg < spec.json`, with one scenario per SVG and CSS tabs on the page.
- Screenshot them first with `npm run shot`, using a temporary figure file that you delete afterwards.
- Never mark a claim as decided unless the owner decided it.

Related: [[feature-029-autonomous-loop]], [[writing-terse]].
