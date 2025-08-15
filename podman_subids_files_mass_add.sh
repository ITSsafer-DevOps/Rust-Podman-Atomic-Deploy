#!/bin/bash
set -e
ACCOUNTS=($(awk -F: '{print $1}' /etc/passwd))
for USER in "${ACCOUNTS[@]}"; do
    LINE="$USER:100000:65536"
    if ! grep -q "^$USER:" /etc/subuid; then
        echo "Pridávam mapping pre $USER do /etc/subuid..."
        echo "$LINE" | sudo tee -a /etc/subuid
    fi
    if ! grep -q "^$USER:" /etc/subgid; then
        echo "Pridávam mapping pre $USER do /etc/subgid..."
        echo "$LINE" | sudo tee -a /etc/subgid
    fi
    sleep 0.05
done
echo "Spúšťam podman system migrate..."
podman system migrate
echo "Hotovo. Odporúčam odhlásiť/prihlásiť sa alebo reštartovať session, ak bol mapping pridaný."
