#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""fake_agent.py ROLE — a scripted agent for tests. The prompt comes on stdin.

FAKE_PLAN: JSON file {role: [response, ...]}; responses pop in order, the last one repeats.
A response may carry "_write": {path: content} to simulate edits, "_sleep": seconds, "_crash": true.
FAKE_LOG: JSON lines of calls. Prints {"result": response, "tokens": n}.
"""
import json
import os
import sys
import time
from pathlib import Path

role, prompt = sys.argv[1], sys.stdin.read()
plan_file = Path(os.environ["FAKE_PLAN"])
plan = json.loads(plan_file.read_text())
queue = plan.get(role) or [{}]
resp = queue.pop(0) if len(queue) > 1 else queue[0]
plan_file.write_text(json.dumps(plan))
with open(os.environ["FAKE_LOG"], "a") as log:
    log.write(json.dumps({"role": role, "prompt": prompt}) + "\n")
for path, content in resp.get("_write", {}).items():
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(content)
time.sleep(resp.get("_sleep", 0))
if resp.get("_crash"):
    sys.exit(7)
result = {k: v for k, v in resp.items() if not k.startswith("_") and k != "tokens"}
print(json.dumps({"result": result, "tokens": resp.get("tokens", 0)}))
