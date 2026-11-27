import pathlib
import sys

import pytest

T = pathlib.Path(__file__).parent
sys.path.insert(0, str(T.parent))
import validate  # noqa: E402

TREE = T / "tree"


def errs(name):
    return validate.validate(T / f"{name}.yml", root=TREE)


def test_post_pin_since_pin_passes():
    assert errs("post_pin") == []


def test_good_passes():
    assert errs("good") == []


def test_deferred_with_reason_passes():
    assert errs("deferred_ok") == []


@pytest.mark.parametrize("name,needle", [
    ("missing_row", "no row"),
    ("unknown_var", "not in pin"),
    ("blank_target", "blank target"),
    ("bad_target", "unknown target"),
    ("dropped_no_signoff", "signoff"),
    ("dropped_no_reason", "reason"),
    ("deferred_no_reason", "reason"),
    ("missing_playbook", "playbook"),
    ("missing_role", "role"),
    ("uncited_salt", "uncited"),
    ("no_since_pin", "since_pin"),
    ("bad_since_pin", "since_pin"),
])
def test_failure(name, needle):
    e = errs(name)
    assert any(needle in x for x in e), e


def test_markdown_lists_rows():
    md = validate.markdown(T / "good.yml")
    assert "modules/m:a" in md and "grain-x" in md and "minion.yml" in md


def test_pending_signoff_is_not_an_error_but_is_reported():
    assert errs("dropped_pending") == []
    assert validate.pending(T / "dropped_pending.yml") == ["y-state"]
    assert validate.pending(T / "good.yml") == []
