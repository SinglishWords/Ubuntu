export DEV="/dev/sda"
export DM="${DEV##*/}"
export DEVP="${DEV}$( if [[ "$DEV" =~ "nvme" ]]; then echo "p"; fi )"
export DM="${DM}$( if [[ "$DM" =~ "nvme" ]]; then echo "p"; fi )"

# Partitioning

sgdisk --print $DEV

sgdisk --zap-all $DEV

sgdisk --new=1:0:+768M $DEV
sgdisk --new=2:0:+2M $DEV
sgdisk --new=3:0:+128M $DEV
sgdisk --new=5:0:0 $DEV
sgdisk --typecode=1:8301 --typecode=2:ef02 --typecode=3:ef00 --typecode=5:8301 $DEV
sgdisk --change-name=1:/boot --change-name=2:GRUB --change-name=3:EFI-SP --change-name=5:rootfs $DEV
sgdisk --hybrid 1:2:3 $DEV

sgdisk --print $DEV

# LUKS Encrypt

cryptsetup luksFormat --type=luks1 ${DEVP}1

cryptsetup luksFormat ${DEVP}5

# LUKS Unlock

cryptsetup open ${DEVP}1 LUKS_BOOT

cryptsetup open ${DEVP}5 ${DM}5_crypt

ls /dev/mapper/

# Format File-Systems 

mkfs.ext4 -L boot /dev/mapper/LUKS_BOOT

mkfs.vfat -F 16 -n EFI-SP ${DEVP}3

# LVM

pvcreate /dev/mapper/${DM}5_crypt
vgcreate ubuntu-vg /dev/mapper/${DM}5_crypt

lvcreate -n root -L 100G ubuntu-vg
lvcreate -n tmp -L 50G ubuntu-vg
lvcreate -n var -L 50G ubuntu-vg
lvcreate -n vartmp -L 50G ubuntu-vg
lvcreate -n varlog -L 50G ubuntu-vg
lvcreate -n varlogaudit -L 50G ubuntu-vg
lvcreate -n home -L 50G ubuntu-vg

