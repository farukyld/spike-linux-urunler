cd initramfs
find . | cpio -o --format=newc > ../initramfs.cpio
cd ..
spike --initrd initramfs.cpio --bootargs 'root=/dev/ram rw console=ttyS0 earlycon=sbi' fw_payload.elf
