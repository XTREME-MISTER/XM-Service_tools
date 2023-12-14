#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <device> <mount_path>"
    exit 1
fi

device="$1"
mount_path="$2"

# Unmount any mounted partitions on the device
umount -t -a "${device}"* >/dev/null 2>&1

# Delete partition table
parted "${device}" --script mklabel gpt

# Create a new partition using full disk
parted "${device}" --script mkpart primary 0% 100%

# Unmount any mounted partitions on the device
umount -t -a "${device}"* >/dev/null 2>&1

# Format partition
mkfs.exfat -L "Xtreme" "${device}1" >/dev/null

# Mount new partition
mkdir -p "${mount_path}"
mount "${device}1" "${mount_path}"
