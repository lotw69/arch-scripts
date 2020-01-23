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
cntry='US'
akeymap='us'
# Change to the namme you want the machine
ahostname='arch'
# Change to the device wanting to format
drive='/dev/vda'
# Change to the default terminal font
deffnt='gr928-8x16-thin'
# Change the timezones
timezne='America/Los_Angeles'
rpwd='rootpassword'
usrname='username'
usrpwd='userpassword'
######################################################################################
timedatectl set-ntp true

##### Partition the drive ############################################################
sgdisk -Z ${drive}

if [[ -d /sys/firmware/efi/efivars ]]; then
  #UEFI Partition
  parted ${drive} mklabel gpt mkpart primary fat32 1MiB 301MiB set 1 esp on mkpart primary ext4 301MiB 100%
  mkfs.fat -F32 ${drive}1
  mkfs.ext4 ${drive}2
else
  #BIOS Partition
  parted ${drive} mklabel msdos mkpart primary ext4 2MiB 100% set 1 boot on
  mkfs.ext4 ${drive}1
fi
mount ${drive}2 /mnt
mkdir /mnt/boot
mount ${drive}1 /mnt/boot
######################################################################################

##### Install base packages ##########################################################
pacstrap /mnt base base-devel linux linux-firmware nano networkmanager
######################################################################################

##### Install a Bootloader ###########################################################
if [[ -d /sys/firmware/efi/efivars ]]; then
  pacstrap /mnt grub efibootmgr
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
  pacstrap /mnt grub
  arch-chroot /mnt grub-install --target=i386-pc ${drive}
fi
######################################################################################

##### Setup some stuff ###############################################################
arch-chroot /mnt systemctl enable NetworkManager
ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
arch-chroot /mnt systemctl enable systemd-resolved
pacstrap /mnt man-db man-pages
sed -i "s/^#\(${alocale}\)/\1/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=${alocale}" > /mnt/etc/locale.conf
echo "${ahostname}" > /mnt/etc/hostname
sed -i 's/^#\ \(%wheel\ ALL=(ALL)\ NOPASSWD:\ ALL\)/\1/' /mnt/etc/sudoers
echo 'KEYMAP='"${akeymap}" > /mnt/etc/vconsole.conf
sed -i "$ a FONT=${deffnt}" /mnt/etc/vconsole.conf
#echo 'FONT='"${deffnt}" > /mnt/etc/vconsole.conf
arch-chroot /mnt ln -sf /usr/share/zoneinfo/${timezne} /etc/localtime
sed -i 's/'#Color'/'Color'/g' /mnt/etc/pacman.conf
#sed -i 's/\#Include/Include'/g /mnt/etc/pacman.conf
sed -i '/^#\[multilib\]/{
  N
  s/^#\(\[multilib\]\n\)#\(Include\ .\+\)/\1\2/
}' /mnt/etc/pacman.conf
sed -i 's/\#\[multilib\]/\[multilib\]'/g /mnt/etc/pacman.conf
#######################################################################################

##### Setup users and passwords #######################################################
arch-chroot /mnt passwd ${rpwd}
arch-chroot /mnt useradd -m -g users -G storage,wheel,power,kvm -s /bin/bash ${usrname}
arch-chroot /mnt passwd ${usrpwd}

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
echo "################################################################################"
echo "### Install of Arch Completed                                                ###"
echo "################################################################################"
sleep 2