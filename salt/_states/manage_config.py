import os
from pathlib import Path
import re

def _check_file(name):
    ret = True
    msg = ""

    if not os.path.isabs(name):
        ret = False
        msg = f"Specified file {name} is not an absolute path"
    elif not os.path.exists(name):
        ret = False
        msg = f"{name}: file not found"

    return ret, msg

def _error(ret, err_msg):
    ret["result"] = False
    ret["comment"] = err_msg
    return ret

def manage_lines(name, key_value, mgrctl=False, regex_escape_keys=False):
    r"""
    Manage lines of configuration in a file

    name
        Filesystem path to the file to be edited

    key_value
        A yaml dictionary with 'key: value' pairs with the key to search for and the value to set/replace

    mgrctl
        If the file can be accessed through mgrctl

    regex_escape_keys
        Set to true if the key should be run through re.escape()

    .. code-block:: yaml

        rhn_conf:
          manage_config.manage_lines:
            - name: /etc/rhn/rhn.conf
            - mgrctl: True
            - regex_escape_keys: True
            - key_value:
                package_import_skip_changelog: 1
                java.max_changelog_entries: 3
    """

    ret = {"name": name, "result": None, "changes": {}, "comment": ""}

    if not name:
        return _error(ret, "Must provide name to manage_config.manage_lines")

    if not key_value:
        return _error(ret, f"key_value is '{key_value}' and should be a valid yaml dict")

    if not isinstance(key_value, dict):
        return _error(ret, f"key_value must be a valid dictionary")

    name = Path(name)
    file_path = name

    if mgrctl:
        file_path = f"/tmp/{os.path.basename(name)}"
        cmd = f"mgrctl cp server:{name} {file_path}"
        try:
            mgrctl_rc = __salt__["cmd.run_all"](cmd)
            rc = mgrctl_rc.get("retcode", -1)
        except Exception as e:
            return _error(ret, "Error while trying to copy file with mgrctl:  {0}".format(e))
        if rc != 0:
            return _error(ret, f"{cmd} failed with rc {rc}: {mgrctl_rc.get('stderr')}")

        cmd = f"mgrctl exec 'stat -c \"%U %G\" \"{name}\"'"
        try:
            mgrctl_rc = __salt__['cmd.run_all'](cmd)
            rc = mgrctl_rc.get("retcode", -1)
        except Exception as e:
            return _error(ret, "Error while trying to get file user and group with mgrctl:  {0}".format(e))
        if rc != 0:
            return _error(ret, f"{cmd} failed with rc {rc}: {mgrctl_rc.get('stderr')}")
        user, group = mgrctl_rc.get("stdout", "root root").split()


    check_res, check_msg = _check_file(file_path)
    if not check_res:
        return _error(ret, check_msg)

    changes = {}
    for key in key_value:
        re_key = key
        if regex_escape_keys:
            re_key = re.escape(key)
        repl_changes = __salt__["file.replace"](
            file_path,
            f"^{re_key} *=.*",
            f"{key} = {key_value[key]}",
            count=0,
            flags=8,
            bufsize=1,
            append_if_not_found=True,
            prepend_if_not_found=False,
            not_found_content=None,
            backup=False,
            dry_run=False,
            show_changes=True,
            ignore_if_missing=False,
            backslash_literal=False,
        )

        if repl_changes:
            changes[key] = repl_changes

    if len(changes) > 0:
        ret["changes"] = changes
        ret["comment"] = "Changes were made"
        ret["result"] = True

    if mgrctl:
        cmd = f"mgrctl cp --user {user} --group {group} {file_path} server:{name}"
        try:
            mgrctl_rc = __salt__["cmd.run_all"](cmd)
            rc = mgrctl_rc.get("retcode", -1)
        except Exception as e:
            return _error(ret, "Error while trying to copy file to container with mgrctl:  {0}".format(e))
        if rc != 0:
            return _error(ret, f"{cmd} failed with rc {rc}: {mgrctl_rc.get('stderr')}")

    return ret
