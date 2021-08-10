mount /dev/mapper/ubuntu--vg-root /target
for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done 
chroot /target
