#!/bin/bash

# 1.0 - Sat 07 Nov 2020 04:33:29 PM CET - first version

usage () {
    echo ""
    echo ""
    echo "================="
    echo ""
    echo "-h | --help"
    echo -e "-i | --install \t\t [Optional]"
    echo -e "-c | --cmdline newstring \t [Optional]"
    echo -e "-r | --remove \t\t [Optional]"
    echo ""
}

kernel=
cmdline=
install_dir="/usr/local/sbin"

apt list efibootmgr | grep installed
if [ "$?" != "0" ]; then
    echo "Error: the efibootmgr package is required, please use --install switch"
    usage
    exit 1
fi

# argument parsing
while [ "$1" != "" ]; do
    case "$1" in
	-h|--help)
	    usage
	    exit 1
	    ;;
	-i|--install)
	    apt list efibootmgr | grep installed
	    if [ "$?" != "0" ]; then
		apt install efibootmgr
	    fi
	    cp update-unikernel $install_dir
	    mkdir --parents /etc/initramfs/post-update.d/
	    ln -s $install_dir/update-unikernel /etc/initramfs/post-update.d/z_update-unikernel
	    chmod 755 $install_dir/update-unikernel
	    shift 1
	    ;;
	-r|--remove)
	    #rm /etc/kernel/postinst.d/z_update-unikernel
	    rm /etc/initramfs/post-update.d/z_update-unikernel
	    rm $install_dir/update-unikernel
	    shift 1
	    exit 0
	    ;;
	-c|--cmdline)
	    if [ -n "$2" ]&&[ ${2:0:1} != "-" ]; then
		cmdline="$2"
		shift 2
	    else
		echo "Error: missing argument for $1"
	    fi
	    ;;
	*|-*|--*=)
	    # the kernel version is passed by update-initramfs script
	    kernel="$1"
	    #echo "$1"
	    shift 1
    esac
done

if [ ! -f "$install_dir/update-unikernel" ]; then
    echo "Error: unikernel not installed"
    exit 1
fi

# unikernel parameter settings
tempdir="$(mktemp -d)"
if [ "$cmdline" != "" ]; then
    echo $cmdline >  $tempdir/kernel_cmdline
else
    cat /proc/cmdline | head -1 > $tempdir/kernel_cmdline
fi

if [ -z "$kernel" ]; then
    kernel=$(uname -r)
else
    kernel=$(echo "$kernel" | awk '{split($0,s,"-"); print s[2]"-"s[3]"-"s[4]}')
fi

osrel="--add-section .osrel="/etc/os-release" --change-section-vma .osrel=0x20000"
kline="--add-section .cmdline="$tempdir/kernel_cmdline" --change-section-vma .cmdline=0x30000"
linux="--add-section .linux="/vmlinuz" --change-section-vma .linux=0x20000000"
initrd="--add-section .initrd="/initrd.img" --change-section-vma .initrd=0x30000000"
stub="/usr/lib/systemd/boot/efi/linuxx64.efi.stub /boot/efi/unikernel-$kernel-$(date +%Y%m%d-%H%M%S).efi"

# unikernel creation
/usr/bin/objcopy $osrel $kline $linux $initrd $stub

# end
exit 0
