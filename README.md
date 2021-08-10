full disk encryption Ubuntu install scripts, from https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019

run `sh pre-install.sh` before running installer

follow the installer, selecting the appropriate mount points, including the boot partition as described [here](https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019)

run `sh install.sh` after all configurations in installer are completed and immediately after installation begins

run `sh chroot.sh` then `mount -a` then run `sh post-install.sh` after installer has completed install, but before reboot
