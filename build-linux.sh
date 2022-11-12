#!/bin/sh

# This script assembles the DayaOS bootloader, kernel and programs with NASM, and then creates floppy and CD images (on Linux)



if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/DayaOS.flp ]
then
	echo ">>> Creating new DayaOS floppy image..."
	mkdosfs -C disk_images/DayaOS.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit


echo ">>> Assembling DayaOS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Assembling programs..."





echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/DayaOS.flp || exit


echo ">>> Copying DayaOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/DayaOS.flp tmp-loop && cp source/kernel.bin tmp-loop/



sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/DayaOS.iso
mkisofs -quiet -V 'DayaOS' -input-charset iso8859-1 -o disk_images/DayaOS.iso -b DayaOS.flp disk_images/ || exit

echo '>>> Done!'
