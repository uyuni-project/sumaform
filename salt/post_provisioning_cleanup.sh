#!/bin/bash

# If we are using Salt Bundle (venv-salt-minion), then we need to remove
# the original Salt package installed on the instance.

if [ -x /usr/bin/venv-salt-call ]; then
    SALT_CALL=venv-salt-call
elif [ -x /usr/bin/salt-call ]; then
    SALT_CALL=salt-call
else
    echo "Error: Cannot find venv-salt-call or salt-call on the system"
    exit 1
fi

# Nothing to do in case "install_salt_bundle" grain is not true
INSTALL_SALT_BUNDLE=$(${SALT_CALL} --local --log-level=quiet --output=txt grains.get install_salt_bundle)
SERVER=false
ROLES=$(${SALT_CALL} --local --log-level=quiet --output=txt grains.get roles)
if [[ "${ROLES}" == "local: ['server']" ]];then
    echo "This is a server"
    SERVER=true
    PKGS="Salt minion"
else
    echo "This is not a server"
    PKGS="Salt"
fi


if [[ "$INSTALL_SALT_BUNDLE" != "local: True" ]]; then
    exit 0
fi

echo "This instance is configured to use Salt Bundle in grains !"

if [ -x /usr/bin/dnf ]; then
    INSTALLER=yum
elif [ -x /usr/bin/zypper ]; then
    INSTALLER=zypper
elif [ -x /usr/bin/yum ]; then
    INSTALLER=yum
elif [ -x /usr/bin/apt ]; then
    INSTALLER=apt
fi

echo "Removing ${PKGS} packages, except Salt Bundle (venv-salt-minion) ..."
if [[ "$INSTALLER" == "zypper" ]]; then
    if [[ "$SERVER" == "true" ]];then
        zypper -q --non-interactive remove salt-minion > /dev/null 2>&1 ||:
    else
        zypper -q --non-interactive remove salt salt-minion python3-salt python2-salt > /dev/null 2>&1 ||:
    fi
elif [[ "$INSTALLER" == "yum" ]]; then
    if [[ "$SERVER" == "true" ]];then
        yum -y remove salt-minion > /dev/null 2>&1 ||:
    else
        yum -y remove salt salt-minion python3-salt python2-salt > /dev/null 2>&1 ||:
    fi
elif [[ "$INSTALLER" == "apt" ]]; then
    if [[ "$SERVER" == "true" ]];then
        apt-get --yes purge salt-client > /dev/null 2>&1 ||:
    else
        apt-get --yes purge salt-common > /dev/null 2>&1 ||:
    fi
fi

echo "Done!"
