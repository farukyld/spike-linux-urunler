# https://risc-v-machines.readthedocs.io/en/latest/linux/simple/
# https://www.reddit.com/r/RISCV/comments/1alnmm9/booting_linux_on_spike/?rdt=64067
mkdir initramfs
cd initramfs
mkdir -p {bin,sbin,dev,etc,home,mnt,proc,sys,usr,tmp}
mkdir -p usr/{bin,sbin}
mkdir -p proc/sys/kernel
cd dev
sudo mknod sda b 8 0 
sudo mknod console c 5 1
cd ../..
cp busybox initramfs/bin
cat >initramfs/init << 'EOF'
#!/bin/busybox sh

# Make symlinks
/bin/busybox --install -s

# Mount system
mount -t devtmpfs  devtmpfs  /dev
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t tmpfs     tmpfs     /tmp

# Busybox TTY fix
setsid cttyhack sh

# https://git.busybox.net/busybox/tree/docs/mdev.txt?h=1_32_stable
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s

sh
EOF
chmod +x initramfs/init
