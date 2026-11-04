#!/usr/bin/env python3
"""Inventory generator: per-host Terraform handoff JSON in, Ansible inventory dir out.

Usage: inventory.py <hosts.json> <outdir>

hosts.json is a list of {name, address, user, port, bastion|null, roles, vars[, private_key_file]}
(the `ansible_hosts` entries of the host module `configuration` output).
Writes <outdir>/hosts.yml (no secrets) and <outdir>/host_vars/<name>.yml (0600).
Env SUMAFORM_VM_PASSWORD, if non-empty, becomes ansible_password in host_vars
(key auth is the default; this is the documented fallback; see ticket #122).
"""
import json
import os
import sys

import yaml


def write_private(path, data):
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        yaml.safe_dump(data, f)
    os.chmod(path, 0o600)


def main(src, out):
    hosts = json.load(open(src))
    password = os.environ.get("SUMAFORM_VM_PASSWORD", "")
    os.makedirs(os.path.join(out, "host_vars"), mode=0o700, exist_ok=True)
    os.chmod(os.path.join(out, "host_vars"), 0o700)
    inv = {"all": {"hosts": {}, "children": {}}}
    for h in hosts:
        entry = {"ansible_host": h["address"], "ansible_user": h.get("user", "root"),
                 "ansible_port": h.get("port") or 22}
        if h.get("private_key_file"):  # a path only, never key material
            entry["ansible_ssh_private_key_file"] = h["private_key_file"]
        b = h.get("bastion")
        if b and b.get("host"):
            jump = f'{b.get("user") or "root"}@{b["host"]}:{b.get("port") or 22}'
            entry["ansible_ssh_common_args"] = f"-J {jump}"
        inv["all"]["hosts"][h["name"]] = entry
        for role in h["roles"]:
            inv["all"]["children"].setdefault(role, {"hosts": {}})["hosts"][h["name"]] = {}
        hv = {**h.get("vars", {}), "roles": h["roles"]}
        if password:
            hv["ansible_password"] = password
        write_private(os.path.join(out, "host_vars", f'{h["name"]}.yml'), hv)
    with open(os.path.join(out, "hosts.yml"), "w") as f:
        yaml.safe_dump(inv, f)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(*sys.argv[1:])
