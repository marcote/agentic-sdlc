# Workflow

One feature moves through four steps. The owner approves once, at gate H1.

![The workflow](figures/workflow.svg)

Setup runs once: the north star, the charter (`/stack`) and the module map.
Roles and CLIs live in `harness.toml`. Any CLI with a headless JSON mode can fill a role.

1. **Brief.** `harness/steps/brief.md`. The owner and the agent write the slice brief.
2. **Spec.** `harness/steps/spec.md`. The spec renders to `spec.html`. The owner approves it at gate H1.
3. **Build.** `uv run scripts/build.py specs/<slice>`. No owner.
4. **Accept.** `uv run scripts/accept.py specs/<slice>`. Machine checks, then merge.

## Build loop

![The build loop](figures/build-loop.svg)

The build script runs each task in turn. The tests come first and stay frozen.
The judge's model family must differ from the implementer's. A task that keeps failing escalates to the owner.

## Accept

![Accept](figures/accept.svg)

Accept runs the checks by machine. It reports the results and merges only when every check passes.
