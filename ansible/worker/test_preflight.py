"""Preflight logic, with stubbed `ansible` (via PATH) and stubbed port check."""
import os
import pathlib
import stat
import subprocess

SCRIPT = pathlib.Path(__file__).with_name("preflight.sh")


def _exe(path, text):
    path.write_text(text)
    path.chmod(path.stat().st_mode | stat.S_IEXEC)


def run(tmp, hosts, ansible_rc=0, closed=(), build="42"):
    bindir = tmp / "bin"
    bindir.mkdir(exist_ok=True)
    _exe(bindir / "ansible",
         '#!/bin/bash\necho "ansible [core 2.16.0]"\n'
         f'[ "$1" = --version ] || echo "$ANSIBLE_HOME|$ANSIBLE_LOCAL_TEMP|$ANSIBLE_REMOTE_TEMP" > "{tmp}/env"\n'
         f"exit {ansible_rc}\n")
    _exe(bindir / "chk",
         '#!/bin/bash\ncase " %s " in *" $1 "*) exit 1;; esac\n' % " ".join(closed))
    env = {**os.environ, "PATH": f"{bindir}:{os.environ['PATH']}",
           "PORT_CHECK": str(bindir / "chk"), "BUILD_NUMBER": build, "TMPDIR": str(tmp)}
    return subprocess.run(["bash", str(SCRIPT), *hosts], env=env, capture_output=True, text=True)


def test_all_good(tmp_path):
    r = run(tmp_path, ["a.example", "b.example"])
    assert r.returncode == 0, r.stderr
    assert "preflight OK" in r.stdout


def test_unreachable_site_fails_clearly(tmp_path):
    r = run(tmp_path, ["a.example", "b.example"], closed=["b.example"])
    assert r.returncode != 0
    assert "b.example" in r.stderr and "port 22" in r.stderr


def test_ping_failure_fails(tmp_path):
    r = run(tmp_path, ["a.example"], ansible_rc=4)
    assert r.returncode != 0 and "ping" in r.stderr


def test_missing_ansible_fails(tmp_path):
    r = subprocess.run(["/bin/bash", str(SCRIPT), "a"],
                       env={"PATH": "/usr/bin:/bin", "PORT_CHECK": "true"},
                       capture_output=True, text=True)
    assert r.returncode != 0 and "ansible" in r.stderr


def test_per_build_dirs(tmp_path):
    run(tmp_path, ["a.example"], build="77")
    home, local, remote = (tmp_path / "env").read_text().strip().split("|")
    assert "77" in home and "77" in local and "77" in remote
    assert len({home, local, remote}) == 3


def test_no_hosts_is_usage_error(tmp_path):
    assert run(tmp_path, []).returncode == 2
