HOME_DIR	= "$(CURDIR)"
USER_NAME	= rkx

#---Build Command---
CC		= gcc
CFLAGS		= -fomit-frame-pointer -O2 -I$(HOME_DIR)/include -masm=intel -Wall
LFLAGS		= -T kernel_ld -Map kernel.map -nostdlib -e kernel_main --oformaty binary
ASFLAGS		= -msyntax=intel -march=i686 --32
NASM		= nasm
LD		= ld
DD		= dd
MAKE		= make
#-------------------

CP		= cp
RM		= rm
CD		= cd
CAT		= cat
SUDO		= sudo
WHOAMI		= whoami
GRUB_INSTALL	= grub-install

#---Module path-------
BOOT		= boot
ARCH		= arch
ARCH_BOOT	= arch/i386/boot
KERNEL		= kernel
#---------------------

#---Virtual Loop Device---
SET_LPDEV	= losetup
LPDEV		= /dev/loop0
LPDEV_IMG	= loop_device.img
MNT_PATH	= /media/$(USER_NAME)
#-------------------------


MAIN_O		= $(KERNEL)/main.o
MAIN_C		= $(KERNEL)/main.c

arch/i386/boot/setup.img : Makefile
	($(CD) $(ARCH_BOOT);$(MAKE))
boot/loader.img : Makefile
	($(CD) $(BOOT);$(MAKE))
kernel/kernel.img : Makefile
	($(CD) $(KERNEL);$(MAKE))

Abyon.img : $(BOOT)/loader.img $(ARCH_BOOT)/setup.img $(KERNEL)/kernel.img Makefile
	$(CAT) $(BOOT)/loader.img $(ARCH_BOOT)/setup.img $(KERNEL)/kernel.img > AbyonPlain.img
	$(RM)	$(BOOT)/*.img
	$(RM)	$(ARCH_BOOT)/*.img
	$(RM)	$(KERNEL)/*.img
	$(DD) if=AbyonPlain.img of=Abyon.img conv=sync

default :
	$(MAKE) img

img :
	$(MAKE) Abyon.img

init :
	$(DD) if=/dev/zero of=$(LPDEV_IMG) bs=1k count=1440
	$(SUDO) $(SET_LPDEV) $(LPDEV) $(LPDEV_IMG)
	$(SUDO) mkdosfs $(LPDEV)
	$(SUDO) mount -t vfat $(LPDEV) $(MNT_PATH)

del :
	$(SUDO) umount $(LPDEV)
	$(SUDO) $(SET_LPDEV) -d $(LPDEV)

clean :
	$(SUDO) $(RM) *.img
	$(SUDO) $(RM) *.o

%.o  :  %.c Makefile
	$(CC) -c -o $*.o $*.c -O2 -Wall
