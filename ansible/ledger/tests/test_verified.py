"""Fixture-based tests for `verified` enforcement and propose.py (#128)."""
import copy
import json
import pathlib
import sys

import pytest
import yaml

T = pathlib.Path(__file__).parent
sys.path.insert(0, str(T.parent))
import propose  # noqa: E402
import validate  # noqa: E402

TREE = T / "tree"
BASE = yaml.safe_load((T / "good.yml").read_text())
RUN = {"id": "run-1", "pin": "abc123", "kind": "host-state-diff",
       "rows_covered": ["modules/m:b"], "result": "pass",
       "non_default": ["modules/m:b"]}


@pytest.fixture
def mk(tmp_path):
    """mk(ledger_edit, runs=[RUN], **flags) -> (errors, ledger path); builds ledger + runs/ in tmp_path."""
    def make(edit=lambda led: None, runs=(RUN,), **kw):
        led = copy.deepcopy(BASE)
        edit(led)
        (tmp_path / "runs").mkdir(exist_ok=True)
        for r in runs:
            (tmp_path / "runs" / f"{r['id']}.json").write_text(json.dumps(r))
        (tmp_path / "l.yml").write_text(yaml.safe_dump(led))
        return validate.validate(tmp_path / "l.yml", root=TREE, **kw), tmp_path / "l.yml"
    return make


def var(led):
    return led["variables"][1]


def has(e, needle):
    assert any(needle in x for x in e), e


def claim(section, idx, level, **extra):
    def edit(led):
        led[section][idx]["verified"] = {"level": level, "evidence": "run-1", "pin": "abc123"}
        led[section][idx].update(extra)
    return edit


def test_valid_passes(mk):
    assert mk()[0] == []


def test_missing_run(mk):
    has(mk(runs=())[0], "missing run")


def test_stale_pin(mk):
    def edit(led):
        led["pin"] = "new"
    has(mk(edit)[0], "stale")


def test_run_pin_mismatch(mk):
    has(mk(runs=[dict(RUN, pin="other")])[0], "!= verified pin")


def test_run_not_covering_or_failed(mk):
    has(mk(runs=[dict(RUN, rows_covered=[])])[0], "does not cover")
    has(mk(runs=[dict(RUN, result="fail")])[0], "result")


def test_bad_level(mk):
    has(mk(claim("variables", 1, 5))[0], "not in 1-4")


def test_variable_needs_level_2_and_non_default(mk):
    has(mk(claim("variables", 1, 1))[0], "below minimum 2")
    has(mk(runs=[dict(RUN, non_default=[])])[0], "non-default")


def test_run_proves_less_than_claim(mk):
    has(mk(claim("variables", 1, 3))[0], "proves less")
    assert mk(claim("variables", 1, 3), runs=[dict(RUN, level=3)])[0] == []


def test_behaviour_state_changing_vs_not(mk):
    has(mk(claim("behaviours", 0, 1), runs=[dict(RUN, rows_covered=["grain-x"])])[0], "below minimum 2")
    assert mk(claim("behaviours", 0, 1, changes_state=False), runs=[dict(RUN, rows_covered=["grain-x", "modules/m:b"])])[0] == []
    assert mk(claim("behaviours", 0, 2), runs=[dict(RUN, rows_covered=["grain-x", "modules/m:b"])])[0] == []


def test_host_role_needs_level_3(mk):
    has(mk(claim("host_roles", 0, 2), runs=[dict(RUN, rows_covered=["minion"])])[0], "below minimum 3")
    assert mk(claim("host_roles", 0, 3), runs=[dict(RUN, kind="compare-runs", rows_covered=["minion", "modules/m:b"])])[0] == []


def test_tf_only_level_1_ok(mk):
    edit = claim("variables", 0, 1, target="tf-only")
    assert mk(edit, runs=[dict(RUN, rows_covered=["modules/m:a", "modules/m:b"])])[0] == []


def test_unverified_ignored_unless_required(mk):
    def edit(led):
        del var(led)["verified"]
    assert mk(edit)[0] == []
    has(mk(edit, require_verified=True)[0], "verified missing")


def test_require_verified_skips_dropped(mk):
    e, _ = mk(require_verified=True)
    assert not any("y-state" in x for x in e)


def test_deletion_gate_blocks_deferred(mk):
    def edit(led):
        led["behaviours"][1].update(target="deferred", reason="later")
        led["behaviours"][1].pop("signoff")
    assert mk(edit)[0] == []
    has(mk(edit, deletion_gate=True)[0], "blocks Salt deletion")


def repin(touched):
    def edit(led):
        led["pin"] = "new"
        led["repins"] = [{"from": "abc123", "to": "new", "touched": touched}]
        led["variables"][0]["verified"] = {"level": 2, "evidence": "run-1", "pin": "abc123"}
        led["variables"][0]["target"] = "var"
    return edit


BOTH = dict(rows_covered=["modules/m:a", "modules/m:b"], non_default=["modules/m:a", "modules/m:b"])


def test_repin_invalidates_only_touched(mk):
    e, _ = mk(repin(["modules/m:b"]), runs=[dict(RUN, **BOTH)])
    assert [x for x in e if "stale" in x] == ["variable modules/m:b: verified pin 'abc123' is stale"]


def test_repin_untouched_stay_valid(mk):
    assert mk(repin([]), runs=[dict(RUN, **BOTH)])[0] == []


def test_propose(mk):
    def edit(led):
        del var(led)["verified"]
    _, path = mk(edit)
    before = path.read_text()
    assert propose.propose(path) == [("modules/m:b", {"level": 2, "evidence": "run-1", "pin": "abc123"})]
    assert path.read_text() == before  # never edits the ledger
    _, path = mk()  # already proven at this level
    assert propose.propose(path) == []
    _, path = mk(edit, runs=[dict(RUN, result="fail")])
    assert propose.propose(path) == []
