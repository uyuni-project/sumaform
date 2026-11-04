"""Seam: ansible/inventory.py CLI (per-host handoff JSON in, inventory dir out)."""
import json
import os
import pathlib
import stat
import subprocess
import sys

import yaml

SCRIPT = pathlib.Path(__file__).parents[1] / "inventory.py"

HOST = {
    "name": "mini-1", "address": "10.0.0.5", "user": "root", "port": 22,
    "bastion": None, "roles": ["minion"],
    "vars": {"domain": "tf.local", "install_salt_bundle": True},
}


def gen(tmp, hosts, env=None):
    src = tmp / "hosts.json"
    src.write_text(json.dumps(hosts))
    out = tmp / "inv"
    r = subprocess.run([sys.executable, "-I", str(SCRIPT), str(src), str(out)],
                       env={**os.environ, **(env or {})}, capture_output=True, text=True)
    return r, out


def test_single_host_inventory(tmp_path):
    r, out = gen(tmp_path, [HOST], env={"SUMAFORM_VM_PASSWORD": ""})
    assert r.returncode == 0, r.stderr
    inv = yaml.safe_load((out / "hosts.yml").read_text())
    h = inv["all"]["hosts"]["mini-1"]
    assert h["ansible_host"] == "10.0.0.5" and h["ansible_user"] == "root"
    assert "mini-1" in inv["all"]["children"]["minion"]["hosts"]
    hv = yaml.safe_load((out / "host_vars" / "mini-1.yml").read_text())
    assert hv == {"domain": "tf.local", "install_salt_bundle": True, "roles": ["minion"]}


def test_bastion_becomes_proxyjump(tmp_path):
    host = {**HOST, "bastion": {"host": "jump.example", "user": "ec2", "port": 2222}}
    r, out = gen(tmp_path, [host])
    inv = yaml.safe_load((out / "hosts.yml").read_text())
    assert "-J ec2@jump.example:2222" in inv["all"]["hosts"]["mini-1"]["ansible_ssh_common_args"]


def test_password_only_in_0600_host_vars(tmp_path):
    r, out = gen(tmp_path, [HOST], env={"SUMAFORM_VM_PASSWORD": "s3cret"})
    assert "s3cret" not in (out / "hosts.yml").read_text()
    f = out / "host_vars" / "mini-1.yml"
    assert yaml.safe_load(f.read_text())["ansible_password"] == "s3cret"
    assert stat.S_IMODE(f.stat().st_mode) == 0o600
    assert stat.S_IMODE((out / "host_vars").stat().st_mode) == 0o700
