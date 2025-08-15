#!/bin/bash
set -e
ACCOUNTS=(root nobody debian podman www-data systemd-coredump)
for USER in "${ACCOUNTS[@]}"; do
    LINE="$USER:100000:65536"
    if ! grep -q "^$USER:" /etc/subuid; then
        echo "Pridávam mapping pre $USER do /etc/subuid..."
        echo "$LINE" | sudo tee -a /etc/subuid
    else
        echo "/etc/subuid už obsahuje mapping pre $USER."
    fi
    if ! grep -q "^$USER:" /etc/subgid; then
        echo "Pridávam mapping pre $USER do /etc/subgid..."
        echo "$LINE" | sudo tee -a /etc/subgid
    else
        echo "/etc/subgid už obsahuje mapping pre $USER."
    fi
    sleep 0.1
done
echo "Spúšťam podman system migrate..."
podman system migrate
echo "Hotovo. Odporúčam odhlásiť/prihlásiť sa alebo reštartovať session, ak bol mapping pridaný."
