import os
import re
import logging
log = logging.getLogger(__name__)

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
            - name: |
                /etc/rhn/rhn.conf
            - mgrctl: True
            - regex_escape_keys: True
            - key_value:
                package_import_skip_changelog: 1
                java.max_changelog_entries: 3
    """

    name = name.rstrip()

    ret = {"name": name, "result": True, "changes": {}, "comment": ""}

    if not name:
        return _error(ret, "Must provide name to manage_config.manage_lines")

    if key_value == None:
        return _error(ret, f"key_value is \'{key_value}\' and should be a valid yaml dict")

    if not isinstance(key_value, dict):
        return _error(ret, f"key_value must be a valid dictionary")

    name_basename = os.path.basename(name)
    file_path = name

    if mgrctl == True:
        file_path = f"/tmp/{name_basename}"
        cmd = f"mgrctl cp server:{name} {file_path}"
        cmd = cmd.replace('\n', '')
        __salt__['cmd.run'](cmd)

    changes = []
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
            backup=".bak",
            dry_run=__opts__["test"],
            show_changes=True,
            ignore_if_missing=False,
            backslash_literal=False,
        )

        changes.append(repl_changes)

    "\n".join(changes)
    ret["changes"]["diff"] = changes
    if len(changes) > 0:
        ret["result"] = True
    else:
        ret["result"] = None

    if mgrctl:
        cmd = f"mgrctl cp {file_path} server:/etc/rhn/rhn.conf"
        cmd = cmd.replace('\n', '')
        __salt__['cmd.run'](cmd)

    return ret
