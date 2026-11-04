"""Seam: ansible/run_host.sh, with a stubbed ansible-playbook (via PATH)."""
import json
import os
import pathlib
import stat
import subprocess

SCRIPT = pathlib.Path(__file__).parents[1] / "run_host.sh"
HOST = {"name": "mini-1", "address": "10.0.0.5", "user": "root", "port": 22,
        "bastion": None, "roles": ["minion"], "vars": {"domain": "tf.local"}}


def run(tmp, host=HOST, rc=0):
    bindir = tmp / "bin"
    bindir.mkdir()
    stub = bindir / "ansible-playbook"
    stub.write_text(f'#!/bin/bash\necho "$@" > "{tmp}/args"\n'
                    f'cp "${{2}}" "{tmp}/inv.yml"\nexit {rc}\n')
    stub.chmod(stub.stat().st_mode | stat.S_IEXEC)
    env = {**os.environ, "PATH": f"{bindir}:{os.environ['PATH']}", "TMPDIR": str(tmp),
           "BUILD_NUMBER": "7", "HOST_JSON": json.dumps([host])}
    return subprocess.run(["bash", str(SCRIPT)], env=env, capture_output=True, text=True)


def test_one_run_with_host_role_playbook(tmp_path):
    r = run(tmp_path)
    assert r.returncode == 0, r.stderr
    args = (tmp_path / "args").read_text().split()
    assert args[args.index("--limit") + 1] == "mini-1"
    assert args[-1].endswith("playbooks/minion.yml")
    assert "mini-1" in (tmp_path / "inv.yml").read_text()
    # per-build dirs, scratch inventory removed afterwards
    assert (tmp_path / "ansible-build-7" / "home").is_dir()
    assert not list((tmp_path / "ansible-build-7").glob("host.*"))


def test_playbook_failure_fails_the_run(tmp_path):
    assert run(tmp_path, rc=2).returncode != 0
