#!/bin/bash
###############################################################################
### Installing Arch Linux By:                                               ###
### Erik Sundquist                                                          ###
###############################################################################
### Review and edit before using                                            ###
###############################################################################

set -e
clear
echo "################################################################################"
echo "### Getting things ready to install                                          ###"
echo "################################################################################"

################### Variables - will change to menus later ###########################
# Change to the correct language file
alocale='en_US.UTF-8'
# Change to the country
akeymap='us'
# Change to the namme you want the machine
ahostname='arch'
# Change to the device wanting to format
drive='/dev/vda'
# Change to the default terminal font
deffnt='gr928-8x16-thin'

######################################################################################

##### Partition the drive ############################################################
sgdisk -Z ${drive}
#UEFI Partition
parted mkpart ${drive} fat32 1MiB 301MiB
parted set 1 esp on
parted mkpart ${drive} ext4 301MiB 100%
#BIOS Partition

echo "################################################################################"
echo "### Install of Arch Completed                                                ###"
echo "################################################################################"
sleep 2