import subprocess

from conftest import HARNESS, run
from stale_names import stale_hits


def test_e12_seed_names_scripts_test_sh(tmp_path):
    run("bash", str(HARNESS / "scripts/vendor.sh"), "--apply", str(tmp_path), check=True)
    toml = (tmp_path / "harness.toml").read_text()
    assert "tests/run.sh" not in toml
    assert "Bash(bash scripts/test.sh)" in toml


def test_e13_stale_name_check_flags_dead_guard_pointer(tmp_path):
    f = tmp_path / "memory/stack/stack.md"
    f.parent.mkdir(parents=True)
    f.write_text("- Guard:      bash scripts/guards/no-prescribe.sh\n")
    subprocess.run(["git", "init", "-q", str(tmp_path)], check=True)
    subprocess.run(["git", "-C", str(tmp_path), "add", "-A"], check=True)
    assert "memory/stack/stack.md: scripts/guards" in stale_hits(tmp_path)
