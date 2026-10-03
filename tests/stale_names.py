import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
from spec import HISTORY  # noqa: E402

REMOVED = re.compile(
    r"(?<![\w-])(/align|/distill|distill|/contract|/tasks|/verify|/uat|/retro|wow-report"
    r"|coverage\.md|acceptance\.md|alignment\.md|mutate\.sh|nvc\.sh|amendment-gate"
    r"|alignment-rubric|amendment-protocol)(?![\w-])"
)


def stale_hits(root):
    files = subprocess.run(["git", "-C", str(root), "ls-files"], capture_output=True, text=True, check=True).stdout.split("\n")
    hits = []
    for f in files:
        if not f or f.startswith(HISTORY) or not (root / f).is_file():
            continue
        m = REMOVED.search((root / f).read_text(errors="ignore"))
        if m:
            hits.append(f"{f}: {m.group(1)}")
    return hits
