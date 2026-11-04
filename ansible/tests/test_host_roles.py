"""Static checks for the host-role compositions (#125). ansible is not installed here, so parse the YAML."""
import hashlib
import pathlib
import re

import jinja2
import yaml

A = pathlib.Path(__file__).parents[1]
ROOT = A.parent
COMMON = ["transactional", "base", "repos"]  # fixed head of every chain, see playbooks/site.yml
CONTAINERIZED = ["server_containerized", "proxy_containerized"]  # share containerized_common (#126)
PORTED = ["minion", "sshminion", "controller", "build_host"] + CONTAINERIZED
SECRET_RE = re.compile(r"password|private_key|kubeconfig_content", re.I)


def load(p):
    return yaml.safe_load((A / p).read_text())


def walk(tasks):
    for t in tasks or []:
        yield t
        for k in ("block", "rescue", "always"):
            yield from walk(t.get(k))


def all_tasks():
    for f in sorted((A / "roles").glob("*/tasks/*.yml")):
        for t in walk(yaml.safe_load(f.read_text())):
            yield f, t


def chains():
    return load("host_roles.yml")["host_role_chains"]


def site_play():
    return load("playbooks/site.yml")[0]


def is_reboot(t):
    inc = t.get("ansible.builtin.include_role") or {}
    return inc.get("name") == "transactional" and inc.get("tasks_from") == "reboot"


def chain_for(roles):
    """Evaluate the real chain expressions of site.yml with jinja2 (extract shim = Ansible's)."""
    env = jinja2.Environment()
    env.filters["extract"] = lambda key, container, *more: container[key][more[0]] if more else container[key]
    env.filters["flatten"] = lambda lists: [x for l in lists for x in l]
    env.filters["unique"] = lambda seq: list(dict.fromkeys(seq))
    out = {}
    for phase in ("prepare", "configure", "install"):
        expr = site_play()["vars"][f"chain_{phase}"]
        hr = yaml.safe_load(env.from_string(site_play()["vars"]["_host_roles"]).render(roles=roles))
        out[phase] = env.from_string(expr).render(_host_roles=hr, host_role_chains=chains())
    return {k: yaml.safe_load(v) for k, v in out.items()}


def test_every_host_role_has_playbook_chain_and_ledger_row():
    ledger = {r["id"]: r for r in yaml.safe_load((A / "ledger/ledger.yml").read_text())["host_roles"]}
    for r in PORTED:
        pb = load(f"playbooks/{r}.yml")
        assert pb[0]["import_playbook"] == "site.yml" and pb[0]["vars"]["only_roles"] == [r]
        c = chains()[r]
        ordered = list(dict.fromkeys(c["prepare"] + c["configure"] + c["install"]))
        assert ledger[r]["roles"] == COMMON + ordered, r
        assert ledger[r]["playbook"] == f"{r}.yml"


def test_chain_roles_have_their_phase_files_and_no_client_host_role():
    for r, c in chains().items():
        for phase in ("prepare", "configure", "install"):
            for role in c[phase]:
                assert (A / "roles" / role / "tasks" / f"{phase}.yml").is_file(), (r, role, phase)
    assert "client" not in chains()  # no module, top.sls entry or salt/client at the pin


def test_ported_list_in_terraform_matches_playbooks():
    tf = (ROOT / "modules/host/main.tf").read_text()
    ported = re.search(r"ansible_ported_roles = \[(.*?)\]", tf).group(1)
    assert sorted(re.findall(r'"(\w+)"', ported)) == sorted(PORTED)
    files = sorted(p.stem for p in (A / "playbooks").glob("*.yml") if p.stem != "site")
    assert files == sorted(PORTED)


def test_site_has_phases_and_one_reboot_per_boundary():
    tasks = site_play()["tasks"]
    assert sum(is_reboot(t) for t in tasks) == 3
    idx = [i for i, t in enumerate(tasks) if "block" in t]
    assert len(idx) == 3  # prepare, configure, product install
    for i in idx:
        assert is_reboot(tasks[i + 1]), tasks[i]["name"]
    prepare, configure, install = (tasks[i]["block"] for i in idx)
    names = lambda b: [t["ansible.builtin.include_role"]["name"] for t in b]  # noqa: E731
    assert names(prepare)[:3] == ["base", "transactional", "repos"]
    assert names(configure)[0] == "base"
    # nothing reboots inside a phase block
    assert not any(is_reboot(t) for t in prepare + configure + install)
    # install is last, with its own reboot step after it, both behind the same condition
    assert tasks[idx[2]]["when"] == tasks[idx[2] + 1]["when"]


def product_install_runs(**host):
    env = jinja2.Environment()
    env.filters["bool"] = lambda v: str(v).lower() in ("true", "1", "yes")
    tasks = site_play()["tasks"]
    expr = next(t for t in tasks if "block" in t and "install" in t["name"].lower())["when"]
    return env.from_string("{{ " + expr + " }}").render(**host) == "True"


def test_product_install_is_skipped_when_install_uyuni_via_testsuite_is_set():
    assert product_install_runs()
    assert product_install_runs(install_uyuni_via_testsuite=False)
    assert not product_install_runs(install_uyuni_via_testsuite=True)
    assert not product_install_runs(skip_server_install=True)  # Salt's own switch, same effect
    assert {r for r, c in chains().items() if c["install"]} == set(CONTAINERIZED)


def tasks_of(role):
    return [t for f in sorted((A / "roles" / role / "tasks").glob("*.yml"))
            for t in walk(yaml.safe_load(f.read_text()))]


def test_containerized_roles_share_common_role_without_duplicated_tasks():
    common = {t["name"] for t in tasks_of("containerized_common") if "name" in t}
    assert common
    server, proxy = ({t["name"] for t in tasks_of(r) if "name" in t} for r in CONTAINERIZED)
    assert not server & proxy  # no task tree repeated between the thin roles
    assert not (server | proxy) & common  # nor repeated from the shared role
    for r in CONTAINERIZED:
        assert chains()[r]["prepare"][0] == "containerized_common", r
        text = " ".join(str(t) for t in tasks_of(r))
        assert "write_config" in text and "authorize_peers" in text, r
    # non-containerized server and proxy are not ported: plan-time failure keeps working
    assert not (A / "playbooks" / "server.yml").exists() and not (A / "playbooks" / "proxy.yml").exists()


def test_terraform_ordering_server_proxy_client_is_untouched():
    tf = (ROOT / "modules/cucumber_testsuite/main.tf").read_text()
    assert "depends_on = [module.server_containerized]" in tf
    assert "ansible" not in tf  # no Ansible edits in the orchestration module


def test_libvirt_handoff_passes_peer_public_keys():
    assert "peer_public_keys" in (ROOT / "backend_modules/libvirt/host/main.tf").read_text()


def test_multi_role_chain_order_and_once():
    c = chain_for(["minion", "controller"])
    assert c["prepare"] == ["minion", "testsuite_pkgs", "controller_packages"]
    assert c["configure"][:2] == ["sshd_challenge_response", "minion"]
    assert c["configure"][2:] == chains()["controller"]["configure"]
    both = chain_for(["controller", "build_host", "sshminion"])
    for phase in both.values():
        assert len(phase) == len(set(phase)), phase  # shared roles run once
    assert both["configure"].count("ssh_keypair") == 1
    assert both["prepare"].index("controller_packages") < both["prepare"].index("testsuite_pkgs")


def test_controller_testsuite_before_https_service():
    c = chains()["controller"]["configure"]
    assert c.index("controller_testsuite") < c.index("controller_https")
    assert c.index("controller_ruby") < c.index("controller_testsuite")  # bundle install needs the symlinks


def test_no_copies_of_task_or_data_files():
    seen = {}
    for p in (A / "roles").rglob("*"):
        if p.is_file() and p.suffix in (".yml", ".j2", ".py", ".service", ".pem") or p.name == "run-testsuite":
            if "__pycache__" in p.parts or "filter_plugins" in p.parts:
                continue
            h = hashlib.sha256(p.read_bytes()).hexdigest()
            assert h not in seen, f"{p} is a copy of {seen[h]}"
            seen[h] = p


def test_every_package_install_branches_on_is_transactional():
    for f in (A / "roles").glob("*/tasks/*.yml"):
        s = f.read_text()
        if "ansible.builtin.package" in s or re.search(r"\b(zypper|dnf|yum|apt)\b.*install", s):
            assert "is_transactional" in s, f


def test_secret_tasks_are_masked():
    for f, t in all_tasks():
        text = str(t)
        src = (t.get("ansible.builtin.template") or {}).get("src")
        if src:
            text += (A / "roles" / f.parts[-3] / "templates" / src).read_text()
        if SECRET_RE.search(text):
            assert t.get("no_log") is True, f"{f.relative_to(A)}: {t.get('name')}"


def test_run_host_is_one_combined_run():
    s = (A / "run_host.sh").read_text()
    assert "site.yml" in s and "for role in" not in s
