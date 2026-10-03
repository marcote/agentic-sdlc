---
name: prune-from-inventory
description: "A removal spec must list every live reference from a full-repo scan, not from memory or a partial listing"
metadata:
  node_type: memory
  type: feedback
  originSessionId: ff50ddcf-483c-4295-a51b-13d14d2243d0
  modified: 2026-10-03T11:06:59.634Z
---

When a spec removes steps, files or commands, build its disposition from a full scan of every tracked file that names them, not from memory or a directory listing.

**Why:** The owner had asked for a clean, clear SDLC. Spec 029's disposition table came from a partial listing, and a second layer of the old flow survived: `evals/` (with `distill`), the `verification/` templates, the north star's alignment section, and dead engine commands. The owner found it, called it "grave", and asked whose fault it was. It was mine: I wrote that table, and the per-task reviews only saw diffs, so they could not catch what was never touched.

**How to apply:**
- Before writing a prune list, grep every tracked file for each removed name and classify every hit as live or history.
- Spec 031 adds the stale-name check (a test) and constitution D7 for this.
- A review scoped to a diff cannot find omissions; say so when relying on it.

Related: [[feature-029-autonomous-loop]].
