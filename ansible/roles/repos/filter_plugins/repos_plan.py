"""Filter `repos_plan`: turn the repository catalog plus a host's facts and vars into a concrete plan.

All knowledge about OSes, versions and channels lives in ansible/catalog/repos.yml. This module only
evaluates the catalog's `applies` conditions and fills in templates, so it names no OS.
"""

CATALOG_FILE = "ansible/catalog/repos.yml"
FALSY = ("", "0", "false", "none", "no")


def _truthy(value):
    if isinstance(value, str):
        return value.strip().lower() not in FALSY
    return bool(value)


class _Strict(dict):
    def __missing__(self, key):
        raise ValueError(f"template variable {{{key}}} is not defined, check {CATALOG_FILE}")


def _fmt(text, ctx):
    return text.format_map(ctx) if isinstance(text, str) else text


def _tags_and_vars(catalog, product):
    tags, extra = set(), {}
    for rule in catalog.get("tag_rules", []):
        kind, value = rule["match"], rule.get("value", "")
        hit = {"empty": not product, "prefix": product.startswith(value),
               "contains": value in product, "equals": product == value}[kind]
        if hit:
            tags.add(rule["tag"])
            extra.update(rule.get("vars", {}))
    return tags, extra


def _find_os(catalog, facts):
    dist = facts.get("distribution")
    for os_id, entry in catalog["os"].items():
        if dist in entry["distributions"]:
            return os_id, entry
    raise ValueError(f"OS '{dist}' is not in {CATALOG_FILE}: add it there")


def _version_key(entry, facts):
    dist = facts.get("distribution")
    by = entry.get("version_by", "full")
    if by == "none":
        return "*"
    if by == "major":
        major = str(facts.get("distribution_major_version"))
        vmap = entry.get("version_map", {})
        return vmap.get(f"{dist}:{major}", vmap.get(major, major))
    return str(facts.get("distribution_version"))


class _State:
    def __init__(self, os_id, entry, tags, roles, hv, ctx, transactional):
        self.os_id, self.pkg = os_id, entry["pkg"]
        self.tags, self.roles, self.hv, self.ctx = tags, roles, hv, ctx
        self.transactional = transactional

    def ok(self, a):  # a: an `applies` mapping
        a = a or {}
        hv, roles = self.hv, self.roles
        checks = [
            "os" not in a or self.os_id in a["os"],
            "os_not" not in a or self.os_id not in a["os_not"],
            "pkg" not in a or self.pkg in a["pkg"],
            all(t in self.tags for t in a.get("tags", [])),
            not a.get("tags_any") or any(t in self.tags for t in a["tags_any"]),
            not any(t in self.tags for t in a.get("not_tags", [])),
            not a.get("roles_any") or any(r in roles for r in a["roles_any"]),
            not any(r in roles for r in a.get("roles_none", [])),
            all(_truthy(hv.get(v)) for v in a.get("vars_all", [])),
            not any(_truthy(hv.get(v)) for v in a.get("vars_none", [])),
            not a.get("vars_any") or any(_truthy(hv.get(v)) for v in a["vars_any"]),
            all(_truthy(self.ctx.get(v)) for v in a.get("requires", [])),
            not a.get("not_transactional") or not self.transactional,
        ]
        if "any_of" in a:
            o = a["any_of"]
            checks.append(any(r in roles for r in o.get("roles", [])) or
                          any(_truthy(hv.get(v)) for v in o.get("vars", [])))
        return all(checks)


def _host(catalog, key, hv):
    spec = catalog["hosts"][key]
    mirror = hv.get("mirror")
    if not mirror:
        return spec if isinstance(spec, str) else spec["default"]
    return _spec_host(spec, mirror, hv) if isinstance(spec, dict) else mirror


def _spec_host(spec, mirror, hv):
    if spec.get("no_mirror"):
        return spec["default"]
    gate = spec.get("mirror_only_if")
    if gate and not _truthy(hv.get(gate)):
        return spec["default"]
    return mirror


def _url(catalog, host_key, path, hv, ctx):
    host = _host(catalog, _fmt(host_key, ctx), hv)
    return f"http://{host}/{_fmt(path, ctx).lstrip('/')}"


def _deb_item(name, url, key_url, file, keyring, pin=None):
    ring = f"/etc/apt/keyrings/{keyring}.asc"
    return {"name": name, "kind": "deb", "url": url, "key_url": key_url, "keyring": ring,
            "file": f"/etc/apt/sources.list.d/{file}.list", "line": f"deb [signed-by={ring}] {url} /",
            "pin": pin}


def _repo(catalog, r, st):
    ctx, hv = st.ctx, st.hv
    url = _url(catalog, r["host"], r["path"], hv, ctx)
    name = _fmt(r["name"], ctx)
    if st.pkg == "apt":
        d = {k: _fmt(v, ctx) for k, v in r.get("deb", {}).items()}
        file = d.get("file", name)
        pin = None
        if d.get("pin_label"):
            pin = {"path": f"/etc/apt/preferences.d/{d.get('pin_file', file)}",
                   "content": f"Package: *\nPin: release l={d['pin_label']}\nPin-Priority: 800\n"}
        return _deb_item(name, url, url.rstrip("/") + "/Release.key", file,
                         d.get("keyring", f"sumaform-{file}"), pin)
    key = url.rstrip("/") + "/repodata/repomd.xml.key" if r.get("gpgkey") else None
    return {"name": name, "kind": "rpm", "url": url, "gpgkey": key, "gpgcheck": r.get("gpgcheck"),
            "priority": r.get("priority"), "autoimport": bool(r.get("autoimport"))}


def _additional(catalog, st, entry):
    out = {"repos": [], "pins": [], "certs": []}
    if entry.get("additional_repos") is False:
        return out
    add = catalog["additional"]
    repos = st.hv.get("additional_repos") or {}
    for label, url in repos.items():
        if st.pkg == "apt":
            d = add["deb"]
            out["repos"].append(_deb_item(f"{label}_repo", url, url.rstrip("/") + "/Release.key",
                                          d["file"], f"sumaform-additional-{label}"))
        else:
            out["repos"].append({"name": f"{label}_repo", "kind": "rpm", "url": url, "gpgkey": None,
                                 "gpgcheck": add["rpm"]["gpgcheck"], "priority": add["rpm"]["priority"],
                                 "autoimport": False})
    if repos:
        out["pins"] = [{"path": p["path"], "content": p["content"]}
                       for p in add["pins"] if st.ok(p.get("applies"))]
    for c in add["certs"]:
        if st.ok(c.get("applies")):
            out["certs"] = [{"label": k, "url": v, "dir": c["dir"], "update": c["update"]}
                            for k, v in (st.hv.get("additional_certs") or {}).items()]
    return out


def repos_plan(catalog, facts, hostvars):
    hv = hostvars or {}
    os_id, entry = _find_os(catalog, facts)
    key = _version_key(entry, facts)
    if key not in entry["versions"]:
        raise ValueError(f"{facts.get('distribution')} {key} is not in {CATALOG_FILE}: add it under os.{os_id}.versions")
    tags, tag_vars = _tags_and_vars(catalog, hv.get("product_version") or "")
    roles = hv.get("roles") or []
    if isinstance(roles, str):
        roles = [roles]

    base = {**catalog.get("default_vars", {}), **tag_vars,
            "arch": facts.get("architecture", ""),
            "osrelease": "" if key == "*" else key,
            "osrelease_short": key.replace(".", "")}
    ctx = _Strict(base)
    for k, v in {**entry.get("vars", {}), **(entry["versions"][key] or {})}.items():
        ctx[k] = _fmt(v, base) if isinstance(v, str) else v

    st = _State(os_id, entry, tags, roles, hv, ctx, _truthy(hv.get("is_transactional")))
    only = _truthy(hv.get("additional_repos_only"))

    plan = {"os_id": os_id, "pkg": entry["pkg"], "repo_dir": catalog["pkg_kinds"][entry["pkg"]].get("repo_dir"),
            "repos": [], "keys": [], "gpg_keys": [], "files": [], "packages": [],
            "services_stopped": [], "pins": [], "certs": [],
            "commands": {"pre": [], "scc": [], "post": []}}

    if not only:
        for r in catalog["repos"]:
            if st.ok(r.get("applies")):
                item = _repo(catalog, r, st)
                plan["repos"].append(item)
                if item.get("pin"):
                    plan["pins"].append(item["pin"])
        for k in catalog["keys"]:
            if st.ok(k.get("applies")):
                item = {"name": k["name"], "file": k.get("file"), "transactional": bool(k.get("transactional")),
                        "env": {n: ctx[v] for n, v in k.get("env", {}).items() if _truthy(ctx.get(v))}}
                if "url" in k:
                    item["url"] = _url(catalog, k["url"]["host"], k["url"]["path"], hv, ctx)
                plan["keys"].append(item)
        for p in catalog["packages"]:
            if st.ok(p.get("applies")):
                plan["packages"].append(p["name"])
        plan["gpg_keys"] = list(hv.get("gpg_keys") or [])

    for f in catalog["files"]:
        if st.ok(f.get("applies")):
            plan["files"].append({"path": f["path"], "mode": f.get("mode", "0644"),
                                  "state": f.get("state", "present"), "content": f.get("content", "")})
    # commands may also use plain host vars, e.g. the SCC registration code
    cctx = _Strict({**{k: v for k, v in hv.items() if isinstance(v, (str, int))}, **ctx})
    for c in catalog["commands"]:
        if st.ok(c.get("applies")):
            plan["commands"][c["phase"]].append(
                {"name": c["name"], "cmd": _fmt(c["cmd"], cctx), "unless": _fmt(c.get("unless"), cctx),
                 "creates": c.get("creates"), "secret": bool(c.get("secret")), "readonly": bool(c.get("readonly")),
                 "retries": c.get("retries", 0), "delay": c.get("delay", 0)})
    for s in catalog["services_stopped"]:
        if st.ok(s.get("applies")):
            plan["services_stopped"] += s["names"]

    extra = _additional(catalog, st, entry)
    plan["repos"] += extra["repos"]
    plan["pins"] += extra["pins"]
    plan["certs"] = extra["certs"]
    return plan


class FilterModule:
    def filters(self):
        return {"repos_plan": repos_plan}
