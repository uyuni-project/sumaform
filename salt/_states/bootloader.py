import logging

from salt.exceptions import CommandExecutionError

__virtualname__ = 'bootloader'

LOG = logging.getLogger(__name__)

# Define not exported variables from Salt, so this can be imported as
# a normal module
try:
    __opts__
    __salt__
    __states__
except NameError:
    __opts__ = {}
    __salt__ = {}
    __states__ = {}

def __virtual__():
    return True

def grub_set_default(name):
    ret = {
        'name': name,
        'result': False,
        'changes': {},
        'comment': [],
    }
    cmd = 'sed -nre "s/[[:blank:]]*menuentry \'([^\']+)\'.*/\\1/p;" /boot/grub2/grub.cfg'
    entries = __salt__['cmd.run'](cmd).splitlines()
    filtered_entries = [entry for entry in entries if name in entry]
    if len(filtered_entries) == 0:
        ret['comment'] = 'No matching grub2 entry in configuration'
        return ret

    entry = filtered_entries[0]
    return __states__['file.replace'](name='/etc/default/grub',
                                      pattern='^GRUB_DEFAULT=.*$',
                                      repl='GRUB_DEFAULT="{0}"'.format(entry))

def mod_watch(name, **kwargs):
    """
    Set grub default kernel based on a watch requisite

    .. note::
        This state exists to support special handling of the ``watch``
        :ref:`requisite <requisites>`. It should not be called directly.

        Parameters for this function should be set by the state being triggered.
    """
    sfun = kwargs.pop("sfun", None)
    mapfun = {
        "grub_set_default": grub_set_default,
    }
    if sfun in mapfun:
        return mapfun[sfun](name, **kwargs)
    return {
        "name": name,
        "changes": {},
        "comment": "bootloader.{0} does not work with the watch requisite".format(sfun),
        "result": False,
    }
