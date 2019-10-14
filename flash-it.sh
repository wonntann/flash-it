#!/bin/bash

VERSION="0.1"
BRANCH=u-boot
UBOOT_JOB=u-boot
UBOOT_DIR=u-boot-bootloader
ROOTFS_PINEPHONE_JOB=pinephone-rootfs
ROOTFS_PINETAB_JOB=pinetab-rootfs
ROOTFS_DEVKIT_JOB=devkit-rootfs
ROOTFS_PINEPHONE_DIR=pinephone
ROOTFS_PINETAB_DIR=pinetab
ROOTFS_DEVKIT_DIR=devkit

# Header
echo -e "\e[1m\e[91mSailfish OS Pine64 device flasher V$VERSION\e[0m"
echo "======================================"
echo ""

# Image selection
echo -e "\e[1mWhich image do you want to flash?\e[0m"
select OPTION in "PinePhone device" "PineTab device" "Dont Be Evil devkit"; do
    case $OPTION in
        "PinePhone device" ) ROOTFS_JOB=$ROOTFS_PINEPHONE_JOB; ROOTFS_DIR=$ROOTFS_PINEPHONE_DIR; break;;
        "PineTab device" ) ROOTFS_JOB=$ROOTFS_PINETAB_JOB; ROOTFS_DIR=$ROOTFS_PINETAB_DIR; break;;
        "Dont Be Evil devkit" ) ROOTFS_JOB=$ROOTFS_DEVKIT_JOB; ROOTFS_DIR=$ROOTFS_DEVKIT_DIR; break;;
    esac
done
    
# Downloading images
echo -e "\e[1mDownloading images...\e[0m"
wget -O "${UBOOT_JOB}.zip" "https://gitlab.com/sailfishos-porters-ci/dont_be_evil-ci/-/jobs/artifacts/$BRANCH/download?job=$UBOOT_JOB"
wget -O "${ROOTFS_JOB}.zip" "https://gitlab.com/sailfishos-porters-ci/dont_be_evil-ci/-/jobs/artifacts/$BRANCH/download?job=$ROOTFS_JOB"

# Select flash target
echo -e "\e[1mWhich SD card do you want to flash?\e[0m"
read -p "Device node (/dev/sdX): " DEVICE_NODE
echo "Flashing image to: $DEVICE_NODE"
echo "WARNING: All data will be erased! You have been warned!"
echo "Some commands require root permissions, you might be asked to enter your sudo password."

# Creating EXT4 file system
echo -e "\e[1mCreating EXT4 file system...\e[0m"
#sudo mkfs.ext4 $DEVICE_NODE

# Flashing u-boot
echo -e "\e[1mFlashing U-boot...\e[0m"
unzip "${UBOOT_JOB}.zip"
#sudo dd if="./u-boot-bootloader/u-boot/u-boot-sunxi-with-spl.bin" of="$DEVICE_NODE" bs=8k seek=1

# Flashing rootFS
echo -e "\e[1mFlashing rootFS...\e[0m"
unzip "${ROOTFS_JOB}.zip"
TEMP=`ls $ROOTFS_DIR/*/*.tar.bz2`
echo "$TEMP"
#sudo bsdtar -xpf "$TEMP" -C "$DEVICE_NODE"

# Clean up files
echo -e "\e[1mCleaning up!\e[0m"
rm "${UBOOT_JOB}.zip"
rm -r "$UBOOT_DIR"
rm "${ROOTFS_JOB}.zip"
rm -r "$ROOTFS_DIR"

# Done :)
sync
echo -e "\e[1mFlashing $DEVICE_NODE OK!\e[0m"
echo "You may now remove the SD card and insert it in your Pine64 device!"
