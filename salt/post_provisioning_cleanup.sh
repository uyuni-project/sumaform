#!/bin/bash

# If we are using Salt Bundle (venv-salt-minion), then we need to remove
# the original Salt package installed on the instance.

# Nothing to do in case "install_salt_bundle" grain is not true
INSTALL_SALT_BUNDLE=$(salt-call --local --log-level=quiet --output=txt grains.get install_salt_bundle)

if [[ "$INSTALL_SALT_BUNDLE" != "local: True" ]]; then
    exit 0
fi

echo "This instance is configured to use Salt Bundle in /etc/salt/grains !"

echo "Copying /etc/salt/grains to /etc/venv-salt-minion"
cp /etc/salt/grains /etc/venv-salt-minion/grains

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
if [[ "$INSTALLER" == "zypper" ]]; then
zypper -q --non-interactive remove salt salt-minion python3-salt python2-salt ||:
elif [[ "$INSTALLER" == "yum" ]]; then
yum -y remove salt salt-minion python3-salt python2-salt ||:
elif [[ "$INSTALLER" == "apt" ]]; then
apt-get --yes purge salt-common ||:
fi

echo "Done!"
