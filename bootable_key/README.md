# Make Debian bootable external device (with extra space for data 😃 )

## USE AT YOUR OWN RISK
## AN INCORRECT USE CAN DESTROY YOUR SYSTEM AND DATA 

make a bootable device (in most cases a USB key) with three consecutive partitions:
1) EFI partition for booting (100MB)
2) ext4 partition for storing ISO images
3) NTFS partition for storing any kind of user data

This script support the following arguments:
```
 -h | --help 
 -a | --arch {i386|amd64} 		 [ Optional, default: amd64  ]
 -s | --iso-space N 			 [ Optional, default: 2 (GB) ]
 -t | --distro-type {stable|testing} 	 [ Optional, default: stable ]
 -d | --device /dev/sd{a..z} 		 [ Required ]
```
For more information please visit https://lambroconsulting.blogspot.com/2020/10/make-debian-bootable-external-device.html

Best regards,

Lambro