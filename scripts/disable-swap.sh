#!/usr/bin/env bash

set -euo pipefail

swapoff -a
sed -i '/swap/s/^/# /' /etc/fstab
