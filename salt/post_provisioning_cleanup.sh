#!/bin/bash

# If we are using Salt Bundle (venv-salt-minion), then we need to remove
# the original Salt package installed on the instance.

# Nothing to do in case "install_salt_bundle" grain is not true
if ! grep -q '"install_salt_bundle": true' /etc/salt/grains; then
    exit 0
fi

echo "This instance is configured to use Salt Bundle in /etc/salt/grains !"

if [ -x /usr/bin/dnf ]; then
    INSTALLER=yum
elif [ -x /usr/bin/zypper ]; then
    INSTALLER=zypper
elif [ -x /usr/bin/yum ]; then
    INSTALLER=yum
elif [ -x /usr/bin/apt ]; then
    INSTALLER=apt
fi

echo "Removing Salt packages, except Salt Bundle (venv-salt-minion) ..."
if [ "$INSTALLER" == "zypper" ] || [ "$INSTALLER" == "dnf" ] || [ "$INSTALLER" == "yum" ]; then
zypper -q --non-interactive remove salt salt-minion python3-salt python2-salt ||:
elif [ "$INSTALLER" == "apt" ]; then
apt-get --yes purge salt-common ||:
fi

echo "Done!"
