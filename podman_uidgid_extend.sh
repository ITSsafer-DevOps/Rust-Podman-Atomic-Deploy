#!/bin/bash
set -e
if ! grep -q "^root:" /etc/subuid; then
    echo "Pridávam mapping pre root do /etc/subuid..."
    echo "root:100000:65536" | sudo tee -a /etc/subuid
else
    echo "/etc/subuid už obsahuje mapping pre root."
fi
if ! grep -q "^root:" /etc/subgid; then
    echo "Pridávam mapping pre root do /etc/subgid..."
    echo "root:100000:65536" | sudo tee -a /etc/subgid
else
    echo "/etc/subgid už obsahuje mapping pre root."
fi
if ! grep -q "^nobody:" /etc/subuid; then
    echo "nobody:100000:65536" | sudo tee -a /etc/subuid
fi
if ! grep -q "^nobody:" /etc/subgid; then
    echo "nobody:100000:65536" | sudo tee -a /etc/subgid
fi
echo "Spúšťam podman system migrate..."
podman system migrate
echo "Hotovo. Odporúčam odhlásiť/prihlásiť sa alebo reštartovať session, ak bol mapping pridaný."
