"""Seam: ansible/catalog/repos.yml + roles/repos (python+yaml only, ansible is not installed)."""
import copy
import importlib.util
import pathlib
import re

import pytest
import yaml

ROOT = pathlib.Path(__file__).parents[2]
ROLE = ROOT / "ansible/roles/repos"
CATALOG = yaml.safe_load((ROOT / "ansible/catalog/repos.yml").read_text())

spec = importlib.util.spec_from_file_location("repos_plan", ROLE / "filter_plugins/repos_plan.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
plan = mod.repos_plan


def facts(dist, version, major=None, arch="x86_64"):
    return {"distribution": dist, "distribution_version": version,
            "distribution_major_version": major or version.split(".")[0], "architecture": arch}


def names(p):
    return {r["name"] for r in p["repos"]}


# ---- coverage: everything Salt references is in the catalog -------------------------------

SALT_FILES = [*(ROOT / "salt/repos").rglob("*.sls"), *(ROOT / "salt/scc").glob("*.sls")]
FAMILY_MARKERS = {"SUSE"}  # grains['os'] == 'SUSE' is a family test, not an OS name


def salt_text():
    return [(f, f.read_text()) for f in SALT_FILES]


def test_every_salt_os_name_is_in_the_catalog():
    known = {n for o in CATALOG["os"].values() for n in o["salt_names"]}
    found = set()
    pat = r"""grains(?:\[|\.get\()\s*['"](?:os|osfullname)['"]\s*[\])]*\s*(?:not in|in|==|!=)\s*(\[[^\]]*\]|'[^']*'|"[^"]*")"""
    for _, text in salt_text():
        for m in re.finditer(pat, text):
            found |= set(re.findall(r"""['"]([^'"]+)['"]""", m.group(1)))
    found -= FAMILY_MARKERS
    assert {"SLES", "Leap", "SL-Micro"} <= found, "extractor is broken"
    assert found <= known, f"Salt names missing from catalog: {found - known}"


def test_every_salt_os_version_is_in_the_catalog():
    known = {v for o in CATALOG["os"].values() for v in o["versions"]}
    found = set()
    for _, text in salt_text():
        for line in text.splitlines():
            if "osrelease" in line:
                found |= set(re.findall(r"""['"](\d+\.\d+)['"]""", line))
    assert {"12.5", "15.4", "15.7"} <= found, "extractor is broken"
    assert found <= known, f"Salt versions missing from catalog: {found - known}"


def test_every_deployable_image_has_a_catalog_entry():
    # sles16, slmicro62, ubuntu2604 ... come from the libvirt base images; Salt keys off facts for them
    for os_id, ver in [("sles", "16.0"), ("sl-micro", "6.2"), ("ubuntu", "26.04"), ("debian", "13"),
                       ("leap", "16.1"), ("sle-micro", "5.5"), ("tumbleweed", "*")]:
        assert ver in CATALOG["os"][os_id]["versions"], (os_id, ver)
    assert {"7", "8", "9", "10"} <= set(CATALOG["os"]["el"]["versions"])


# ---- no per-OS hardcoding in the role ------------------------------------------------------

OS_WORDS = re.compile(r"(?i)ansible_(distribution|os_family)|osfullname|\b(sles?|suse|leap|ubuntu|debian|"
                      r"redhat|rhel|centos|rocky|alma\w*|amazon|oracle\w*|openeuler|micro|tumbleweed|opensuse)\b")


def test_role_has_no_os_names():
    files = [*ROLE.rglob("*.yml"), *ROLE.rglob("*.py")]
    assert files
    for f in files:
        for n, line in enumerate(f.read_text().splitlines(), 1):
            if f.suffix == ".yml" and not re.search(r"\bwhen:", line):
                continue
            if f.suffix == ".py" and line.lstrip().startswith("#"):
                continue
            assert not OS_WORDS.search(line), f"{f.name}:{n} hardcodes an OS: {line.strip()}"


def test_plugin_has_no_catalog_ids_as_literals():
    src = (ROLE / "filter_plugins/repos_plan.py").read_text()
    for os_id, o in CATALOG["os"].items():
        for lit in [os_id, *o["distributions"]]:
            assert f"'{lit}'" not in src and f'"{lit}"' not in src, lit


# ---- behaviour -----------------------------------------------------------------------------

MINION = {"roles": ["minion"], "testsuite": True, "product_version": "5.2-nightly"}


def test_sles_nightly_minion():
    p = plan(CATALOG, facts("SLES", "15.7"), MINION)
    assert {"os_pool_repo", "os_update_repo", "tools_pool_repo", "tools_update_repo",
            "tools_additional_repo", "test_repo_rpm_pool"} <= names(p)
    pool = next(r for r in p["repos"] if r["name"] == "os_pool_repo")
    assert pool["url"] == "http://dist.suse.de/ibs/SUSE/Products/SLE-Module-Basesystem/15-SP7/x86_64/product/"
    assert pool["kind"] == "rpm"


def test_mirror_replaces_the_host():
    p = plan(CATALOG, facts("SLES", "15.7"), {**MINION, "mirror": "mirror.tf.local"})
    pool = next(r for r in p["repos"] if r["name"] == "os_pool_repo")
    assert pool["url"].startswith("http://mirror.tf.local/SUSE/Products/")


def test_scc_replaces_os_repos_and_registers():
    p = plan(CATALOG, facts("SLES", "15.7"), {**MINION, "sles_registration_code": "SECRET"})
    assert "os_pool_repo" not in names(p)
    reg = [c for c in p["commands"]["scc"] if "SUSEConnect --url" in c["cmd"]]
    assert reg and reg[0]["masked"] and "SECRET" in reg[0]["cmd"]


def test_unknown_version_fails_loudly():
    with pytest.raises(ValueError, match="repos.yml"):
        plan(CATALOG, facts("SLES", "99.1"), MINION)


def test_el_head():
    p = plan(CATALOG, facts("Rocky", "9.4", "9"), {"roles": ["minion"], "product_version": "head"})
    assert {"tools_pool_repo", "tools_update_repo", "tools_additional_repo"} <= names(p)
    assert {k["name"] for k in p["keys"]} >= {"suse_el9_key", "galaxy_key"}


def test_amazon_maps_to_el_release():
    p = plan(CATALOG, facts("Amazon", "2023", "2023"), {"roles": ["minion"], "product_version": "5.1-released"})
    assert "MultiLinuxManagerTools/EL-9/" in next(r for r in p["repos"] if r["name"] == "tools_pool_repo")["url"]


def test_no_client_tools_on_infrastructure_roles():
    p = plan(CATALOG, facts("SLES", "15.7"), {"roles": ["server_containerized"], "product_version": "5.2-nightly"})
    assert "tools_pool_repo" not in names(p) and "manager52_repo" in names(p)


def test_ubuntu_additional_repos_and_micro_skip():
    hv = {"roles": ["minion"], "product_version": "5.2-released", "additional_repos": {"x": "http://h/x"}}
    p = plan(CATALOG, facts("Ubuntu", "22.04"), hv)
    assert any(r["name"] == "x_repo" and r["kind"] == "deb" for r in p["repos"])
    assert p["pins"]
    p = plan(CATALOG, facts("SL-Micro", "6.2"), hv)
    assert "x_repo" not in names(p)


def test_gpg_keys_and_additional_repos_only():
    hv = {"roles": ["minion"], "product_version": "5.2-released", "gpg_keys": ["default/gpg_keys/galaxy.key"],
          "additional_repos": {"x": "http://h/x"}, "additional_repos_only": True}
    p = plan(CATALOG, facts("SLES", "15.7"), hv)
    assert names(p) == {"x_repo"}
    assert p["gpg_keys"] == []  # Salt: gpg_keys live in default_settings, skipped by additional_repos_only
    p = plan(CATALOG, facts("SLES", "15.7"), {**hv, "additional_repos_only": False})
    assert p["gpg_keys"] == ["default/gpg_keys/galaxy.key"]


def test_adding_a_version_is_data_only():
    cat = copy.deepcopy(CATALOG)
    cat["os"]["sles"]["versions"]["15.8"] = copy.deepcopy(cat["os"]["sles"]["versions"]["15.7"])
    p = plan(cat, facts("SLES", "15.8"), MINION)
    assert "os_pool_repo" in names(p)
