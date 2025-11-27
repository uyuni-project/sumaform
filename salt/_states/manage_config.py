def _error(ret, err_msg):
    ret["result"] = False
    ret["comment"] = err_msg
    return ret

def manage_lines(name, key_value, container_cmd):
    r"""
    Maintain an edit in a file.

    name
        Filesystem path to the file to be edited.

    key_value
        A yaml dictionary with 'key: value' pairs with the key to search for and the value to set/replace

    container_cmd
        The exec command if the target file is in a container. E.g. 'mgrctl exec'

    When regex capture groups are used in ``pattern:``, their captured value is
    available for reuse in the ``repl:`` part as a backreference (ex. ``\1``).

    .. code-block:: yaml

        rhn_conf:
          manage_config.manage_lines:
            - name: |
                /etc/rhn/rhn.conf
            - container_cmd: "mgrctl exec"
            - key_value:
                package_import_skip_changelog: 1
                java.max_changelog_entries: 3
    """

    ret = {"name": name, "result": True, "changes": {}, "comment": ""}

    if not name:
        return _error(ret, "Must provide name to manage_config.manage_lines")

    if key_value == None:
        return _error(ret, f"key_value is \'{key_value}\' and should be a valid yaml dict")

    if not isinstance(key_value, dict):
        ret["result"] = False
        ret["comment"] = f" is no instance of dict"
        return _error(ret, f"key_value must be a valid yaml dictionary, has value \'{key_value}\' and type \'{type(key_value)}\'")

    cmds = []

    for key in key_value:
        cmd = f'grep -q "^{key} *=.*$" {name} && sed -i "s/^{key} *=.*/{key} = {key_value[key]}/" {name} || echo "{key} = {key_value[key]}" >> {name}'
        cmds.append(cmd)

    cmds = '; '.join(cmds)

    if container_cmd != None:
        cmds = f"{container_cmd} \'{cmds}\'"

    cmds = cmds.replace('\n', '')

    ret["result"] = True

    ret_cmd_run = __salt__['state.single'](fun='cmd.run', name=cmds)

    if ret_cmd_run["result"] == False:
        return _error(ret, ret_cmd_run["comment"])

    return ret
