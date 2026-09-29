#!/bin/bash
# Print the sandbox's public exit IP and geo information.
set -u
echo "=== ifconfig.me ==="
curl -s --max-time 20 ifconfig.me
echo
echo "=== ipinfo.io ==="
curl -s --max-time 20 ipinfo.io
echo
