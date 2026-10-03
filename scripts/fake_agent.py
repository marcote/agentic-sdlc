#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""fake_agent.py ROLE PROMPT — a scripted agent for tests.

FAKE_PLAN: JSON file {role: [response, ...]}; responses pop in order, the last one repeats.
A response may carry "_write": {path: content} to simulate edits. FAKE_LOG: JSON lines of calls.
"""
import json
import os
import sys
from pathlib import Path

role, prompt = sys.argv[1], sys.argv[2]
plan_file = Path(os.environ["FAKE_PLAN"])
plan = json.loads(plan_file.read_text())
queue = plan.get(role) or [{}]
resp = queue.pop(0) if len(queue) > 1 else queue[0]
plan_file.write_text(json.dumps(plan))
with open(os.environ["FAKE_LOG"], "a") as log:
    log.write(json.dumps({"role": role, "prompt": prompt}) + "\n")
resp = dict(resp)
for path, content in resp.pop("_write", {}).items():
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(content)
if resp.pop("_crash", False):
    sys.exit(7)
print(json.dumps(resp))
