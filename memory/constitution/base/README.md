# How constitution inheritance works

- `base/` is a **vendored** shared asset: copied with the template.
- The project's `constitution.md` declares `extends: base` and adds deltas/overrides.
- Each file in `base/patterns/` is a "given practice": in addition to a prose principle,
  it declares **injected acceptance criteria**.
  The spec step writes the ones that apply as invariants of the slice (template section 4).
- To update the base: edit `base/`, follow `../update-checklist.md`, and re-copy
  to the projects that inherit it (explicit synchronization, no submodules).
