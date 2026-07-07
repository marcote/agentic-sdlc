# Pattern: Hermetic Tests (given practice)

**Principle:** a test depends only on what it builds; it never assumes the machine it runs on.
**Applies to:** any feature whose tests reach outside the process — a network/remote source, a
`/dev/tty` terminal, the git branch layout, `$TMPDIR`, the clock, or the locale. (A green run on
the dev box is not a green run in CI: prove it under a detached-HEAD, no-terminal checkout.)
**Injected criteria:**
- `[given]` an external/remote dependency (network fetch, remote repo, live service) is reached
  through an **override seam** (env var or parameter) so the suite runs **offline against a local
  fixture**, never the live source. → maps to `eval: hermetic-offline`.
- `[given]` the test assumes nothing about the ambient environment (a controlling terminal, a
  local `main` branch, a writable well-known path, a locale) — it **builds its own fixture** and
  passes on a detached-HEAD, no-terminal CI checkout. → maps to `eval: hermetic-env`.
