export DEV="/dev/sda"
export DM="${DEV##*/}"
export DEVP="${DEV}$( if [[ "$DEV" =~ "nvme" ]]; then echo "p"; fi )"
export DM="${DM}$( if [[ "$DM" =~ "nvme" ]]; then echo "p"; fi )"

mount /dev/mapper/ubuntu--vg-root /target
for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done 
chroot /target

mount -a

apt install -y cryptsetup-initramfs

echo "KEYFILE_PATTERN=/etc/luks/*.keyfile" >> /etc/cryptsetup-initramfs/conf-hook 
echo "UMASK=0077" >> /etc/initramfs-tools/initramfs.conf

mkdir /etc/luks
dd if=/dev/urandom of=/etc/luks/boot_os.keyfile bs=512 count=1

chmod u=rx,go-rwx /etc/luks
chmod u=r,go-rwx /etc/luks/boot_os.keyfile

cryptsetup luksAddKey ${DEVP}1 /etc/luks/boot_os.keyfile
cryptsetup luksAddKey ${DEVP}5 /etc/luks/boot_os.keyfile 

echo "LUKS_BOOT UUID=$(blkid -s UUID -o value ${DEVP}1) /etc/luks/boot_os.keyfile luks,discard" >> /etc/crypttab
echo "${DM}5_crypt UUID=$(blkid -s UUID -o value ${DEVP}5) /etc/luks/boot_os.keyfile luks,discard" >> /etc/crypttab

update-initramfs -u -k all
