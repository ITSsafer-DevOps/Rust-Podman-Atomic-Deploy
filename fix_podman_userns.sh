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

echo "Spúšťam podman system migrate..."
podman system migrate

echo "Hotovo. Odporúčam odhlásiť/prihlásiť sa alebo reštartovať session, ak bol mapping pridaný."
