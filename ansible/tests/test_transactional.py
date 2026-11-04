"""Structural checks for the reboot step (#123). ansible is not installed here, so parse the YAML."""
import pathlib
import re

import yaml

A = pathlib.Path(__file__).parents[1]
ROOT = A.parent


def load(p):
    return yaml.safe_load((A / p).read_text())


def walk(tasks):
    for t in tasks or []:
        yield t
        for k in ("block", "rescue", "always"):
            yield from walk(t.get(k))


def role_tasks(role):
    return [t for f in sorted((A / "roles" / role / "tasks").glob("*.yml")) for t in walk(load(f.relative_to(A)))]


def is_reboot(t):
    inc = t.get("ansible.builtin.include_role") or {}
    return inc.get("name") == "transactional" and inc.get("tasks_from") == "reboot"


def test_every_phase_boundary_reboots():
    tasks = load("playbooks/site.yml")[0]["tasks"]
    phases = [i for i, t in enumerate(tasks) if "block" in t]
    assert len(phases) >= 2, "prepare and configure phases expected"
    for i in phases:
        assert i + 1 < len(tasks) and is_reboot(tasks[i + 1]), f"no reboot step after phase {tasks[i]['name']}"


def test_transactional_update_always_continues():
    cmds = [str(t.get("ansible.builtin.command") or t.get("ansible.builtin.shell"))
            for r in ("transactional", "minion", "base") for t in role_tasks(r)]
    tu = [c for c in cmds if "transactional-update" in c]
    assert tu, "expected a transactional-update call"
    for c in tu:
        assert re.search(r"(^|\s)(-c|--continue)(\s|$)", c), c


def test_post_reboot_assertion_rejects_old_snapshot():
    asserts = [t for t in role_tasks("transactional") if "ansible.builtin.assert" in t]
    text = " ".join(str(a) for a in asserts)
    assert "_tu_running_after" in text and "_tu_running_before" in text and "_tu_default" in text


def test_no_end_play_and_no_collection_module():
    for p in list((A / "roles").rglob("*.yml")) + list((A / "playbooks").glob("*.yml")):
        s = p.read_text()
        assert "end_play" not in s, p
        assert "transactional_update" not in s, p  # command + reboot flow only


def test_old_assert_and_precondition_removed():
    assert "need the reboot step" not in (A / "roles/base/tasks/prepare.yml").read_text()
    tf = (ROOT / "backend_modules/libvirt/host/main.tf").read_text()
    assert "local.transactional" not in tf and "reboot step, ticket #123" not in tf


def test_idempotence_guards():
    # install is skipped when rpm already has the packages; every command declares changed_when
    inst = list(walk(load("roles/transactional/tasks/install.yml")))
    assert any("when" in t and "transactional-update" in str(t) for t in inst)
    for t in role_tasks("transactional"):
        if "ansible.builtin.command" in t:
            assert "changed_when" in t, t["name"]


def test_single_pinned_core():
    assert re.search(r"^ansible-core==2\.16\.\d+$", (A / "requirements.txt").read_text(), re.M)
