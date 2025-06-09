#!/bin/bash

################################################################################
# Purpose: Remove all old Linux kernel images except the currently running one 
## Author: Dat Nguyen
## Date: June 9th, 2025
## Version: 1.0
## Date: $(date +%Y-%m-%d)
###############################################################################

LOGFILE="/var/log/kernel_cleanup.log"
CURRENT_KERNEL=$(uname -r)

echo "Current kernel version: $CURRENT_KERNEL" | tee -a $LOGFILE

# Get list of installed linux-image packages excluding the current kernel and meta-package
OLD_KERNELS=$(dpkg -l | grep '^ii' | grep 'linux-image-' | awk '{print $2}' | grep -v "$CURRENT_KERNEL" | grep -v 'linux-image-amd64')

if [ -z "$OLD_KERNELS" ]; then
    echo "No old kernels to remove." | tee -a $LOGFILE
else
    echo "Removing old kernels:" | tee -a $LOGFILE
    for pkg in $OLD_KERNELS; do
        echo "Removing $pkg..." | tee -a $LOGFILE
        apt remove --purge -y "$pkg" | tee -a $LOGFILE
    done
fi

# Cleanup and update GRUB
apt autoremove --purge -y | tee -a $LOGFILE
update-grub | tee -a $LOGFILE

echo "Kernel cleanup completed." | tee -a $LOGFILE
