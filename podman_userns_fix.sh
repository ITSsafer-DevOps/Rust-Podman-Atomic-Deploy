#!/bin/bash
set -e
USER_NAME="$(whoami)"
SUBUID_LINE="${USER_NAME}:100000:65536"
if ! grep -q "^${USER_NAME}:" /etc/subuid; then
    echo "Pridávam mapping do /etc/subuid..."
    echo "$SUBUID_LINE" | sudo tee -a /etc/subuid
else
    echo "/etc/subuid už obsahuje mapping."
fi
if ! grep -q "^${USER_NAME}:" /etc/subgid; then
    echo "Pridávam mapping do /etc/subgid..."
    echo "$SUBUID_LINE" | sudo tee -a /etc/subgid
else
    echo "/etc/subgid už obsahuje mapping."
fi
if grep -q "CONFIG_USER_NS=y" /boot/config-$(uname -r); then
    echo "User namespace je povolený v jadre."
else
    echo "User namespace NIE JE povolený v jadre!"
    echo "Prosím, povolte CONFIG_USER_NS v kernel konfigurácii."
    exit 1
fi
SYSCTL_VAL=$(sysctl -n kernel.unprivileged_userns_clone 2>/dev/null || echo "notfound")
if [ "$SYSCTL_VAL" != "1" ]; then
    echo "Povoľujem kernel.unprivileged_userns_clone..."
    sudo sysctl -w kernel.unprivileged_userns_clone=1
else
    echo "kernel.unprivileged_userns_clone je už povolený."
fi
echo "Spúšťam podman system migrate..."
podman system migrate
echo "Hotovo. Odporúčam odhlásiť/prihlásiť sa alebo reštartovať session, ak bol mapping pridaný."
