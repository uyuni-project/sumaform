"""Seam: secrets handling (ticket #122): no key material, 0600 host_vars, masked secret tasks."""
import pathlib
import re
import stat
import sys

import yaml

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from test_inventory import HOST, gen  # noqa: E402

ROOT = pathlib.Path(__file__).parents[1]
PASSWORD = "pw-" + "canary-42"


def test_no_private_key_material_under_ansible():
    marker = re.compile("BEGIN [A-Z ]*PRIVATE " + "KEY")
    hits = [str(p) for p in ROOT.rglob("*")
            if p.is_file() and "__pycache__" not in p.parts and marker.search(p.read_text(errors="ignore"))]
    assert not hits


def test_host_vars_0600_and_hosts_yml_secret_free(tmp_path):
    hosts = [{**HOST, "name": n, "private_key_file": "~/.ssh/id_ed25519"} for n in ("a", "b")]
    r, out = gen(tmp_path, hosts, env={"SUMAFORM_VM_PASSWORD": PASSWORD})
    assert r.returncode == 0, r.stderr
    assert PASSWORD not in (out / "hosts.yml").read_text()
    for n in ("a", "b"):
        f = out / "host_vars" / f"{n}.yml"
        assert stat.S_IMODE(f.stat().st_mode) == 0o600
        assert PASSWORD in f.read_text()


def test_key_path_is_referenced_not_embedded(tmp_path):
    r, out = gen(tmp_path, [{**HOST, "private_key_file": "~/.ssh/id_ed25519"}])
    h = yaml.safe_load((out / "hosts.yml").read_text())["all"]["hosts"]["mini-1"]
    assert h["ansible_ssh_private_key_file"] == "~/.ssh/id_ed25519"


def test_no_password_when_unset_and_no_key_default(tmp_path):
    r, out = gen(tmp_path, [HOST], env={"SUMAFORM_VM_PASSWORD": ""})
    assert "ansible_password" not in (out / "host_vars" / "mini-1.yml").read_text()
    assert "ansible_ssh_private_key_file" not in (out / "hosts.yml").read_text()


def test_secret_tasks_are_no_log():
    secret = re.compile(r"password|secret|token|private_key|passphrase", re.I)
    bad = []
    for f in ROOT.glob("roles/*/*/*.yml"):
        for t in yaml.safe_load(f.read_text()) or []:
            if secret.search(yaml.safe_dump(t)) and t.get("no_log") is not True:
                bad.append(f"{f.name}: {t.get('name')}")
    assert not bad
