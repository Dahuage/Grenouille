OBJS = \
	100kinit.o\
	\
	101trap.o\
	102trapentry.o\
	103idt.o\
	vectors.o\
	\
	104console.o\
	105clock.o\
	106picirq.o\
	\
	string.o\
	stdio.o\
	printfmt.o\
	
	# kalloc.o\
	# vm.o\
	# mp.o\

	# proc.o\	
	# exec.o\
	# pipe.o\
	# sysproc.o\
	# syscall.o\

	# file.o\
	# fs.o\
	# sysfile.o\

	# lapic.o\
	# ioapic.o\
	# spinlock.o\
	# sleeplock.o\
	# swtch.o\

	# bio.o\
	# ide.o\
	# uart.o\
	# log.o\

# Cross-compiling (e.g., on Mac OS X)
# TOOLPREFIX = i386-jos-elf

# Using native tools (e.g., on X86 Linux)
#TOOLPREFIX = 

# Try to infer the correct TOOLPREFIX if not set
ifndef TOOLPREFIX
TOOLPREFIX := $(shell if i386-jos-elf-objdump -i 2>&1 | grep '^elf32-i386$$' >/dev/null 2>&1; \
	then echo 'i386-jos-elf-'; \
	elif objdump -i 2>&1 | grep 'elf32-i386' >/dev/null 2>&1; \
	then echo ''; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find an i386-*-elf version of GCC/binutils." 1>&2; \
	echo "*** Is the directory with i386-jos-elf-gcc in your PATH?" 1>&2; \
	echo "*** If your i386-*-elf toolchain is installed with a command" 1>&2; \
	echo "*** prefix other than 'i386-jos-elf-', set your TOOLPREFIX" 1>&2; \
	echo "*** environment variable to that prefix and run 'make' again." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

# If the makefile can't find QEMU, specify its path here
# QEMU = qemu-system-i386

# Try to infer the correct QEMU
ifndef QEMU
QEMU = $(shell if which qemu > /dev/null; \
	then echo qemu; exit; \
	elif which qemu-system-i386 > /dev/null; \
	then echo qemu-system-i386; exit; \
	elif which qemu-system-x86_64 > /dev/null; \
	then echo qemu-system-x86_64; exit; \
	else \
	qemu=/Applications/Q.app/Contents/MacOS/i386-softmmu.app/Contents/MacOS/i386-softmmu; \
	if test -x $$qemu; then echo $$qemu; exit; fi; fi; \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "*** or have you tried setting the QEMU variable in Makefile?" 1>&2; \
	echo "***" 1>&2; exit 1)
endif

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump
INCLUDE	+= include/

CFLAGS = -fno-pic -I $(INCLUDE) -I ./boot/ -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32  -fno-omit-frame-pointer
#CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -fvar-tracking -fvar-tracking-assignments -O0 -g -Wall -MD -gdwarf-2 -m32 -Werror -fno-omit-frame-pointer
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
ASFLAGS = -m32 -gdwarf-2 -Wa,-divide -I ./boot/ -I ./include -fno-builtin
# FreeBSD ld wants ``elf_i386_fbsd''
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1)



# /dev/null  ： 在类Unix系统中，/dev/null，或称空设备，是一个特殊的设备文件
# 它丢弃一切写入其中的数据（但报告写入操作成功），读取它则会立即得到一个EOF。
# 在程序员行话，尤其是Unix行话中，/dev/null 被称为位桶(bit bucket)或者黑洞(black hole)。
# 空设备通常被用于丢弃不需要的输出流，或作为用于输入流的空文件。这些操作通常由重定向完成。


# /dev/zero  ： 在类UNIX 操作系统中, /dev/zero 是一个特殊的文件，当你读它的时候
# ，它会提供无限的空字符(NULL, ASCII NUL, 0x00)。
# 其中的一个典型用法是用它提供的字符流来覆盖信息，另一个常见用法是产生一个特定大小的空白文件。
# BSD就是通过mmap把/dev/zero映射到虚地址空间实现共享内存的。
# 可以使用mmap将/dev/zero映射到一个虚拟的内存空间，这个操作的效果等同于使用一段匿名的内存
# （没有和任何文件相关）。

#  dd - 用于复制文件并对原文件的内容进行转换和格式化处理，有需要的时候使用dd 对物理磁盘操作
# bs=<字节数>：将ibs（输入）与欧巴桑（输出）设成指定的字节数；
# cbs=<字节数>：转换时，每次只转换指定的字节数；
# conv=<关键字>：指定文件转换的方式；
# count=<区块数>：仅读取指定的区块数；
# ibs=<字节数>：每次读取的字节数；
# obs=<字节数>：每次输出的字节数；
# of=<文件>：输出到文件；
# seek=<区块数>：一开始输出时，跳过指定的区块数；
# skip=<区块数>：一开始读取时，跳过指定的区块数；
# --help：帮助；
# --version：显示版本信息。


# $@--目标文件，$^--所有的依赖文件，$<--第一个依赖文件。
grenouille.img: bootblock kernel #fs.img
	dd if=/dev/zero of=grenouille.img count=10000
	dd if=bootblock of=grenouille.img conv=notrunc
	dd if=kernel of=grenouille.img seek=1 conv=notrunc

# xv6memfs.img: bootblock kernelmemfs
# 	dd if=/dev/zero of=xv6memfs.img count=10000
# 	dd if=bootblock of=xv6memfs.img conv=notrunc
# 	dd if=kernelmemfs of=xv6memfs.img seek=1 conv=notrunc

bootblock: boot/boot.S boot/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c boot/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I ./boot/ -c boot/boot.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o boot.o bootmain.o
	$(OBJDUMP) -S bootblock.o > bootblock.asm
	$(OBJCOPY) -S -O binary -j .text bootblock.o bootblock
	python3 ./tools/sign.py bootblock

# entryother: entryother.S
# 	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c entryother.S
# 	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7000 -o bootblockother.o entryother.o
# 	$(OBJCOPY) -S -O binary -j .text bootblockother.o entryother
# 	$(OBJDUMP) -S bootblockother.o > entryother.asm

# initcode: initcode.S
# 	$(CC) $(CFLAGS) -nostdinc -I. -c initcode.S
# 	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o initcode.out initcode.o
# 	$(OBJCOPY) -S -O binary initcode.out initcode
# 	$(OBJDUMP) -S initcode.o > initcode.asm

# kernel: $(OBJS) entry.o entryother initcode kernel.ld
# 	$(LD) $(LDFLAGS) -T kernel.ld -o kernel entry.o $(OBJS) -b binary initcode entryother
# 	$(OBJDUMP) -S kernel > kernel.asm
# 	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym

# we assume single cpu 
kernel: $(OBJS) 000entry.o  ./tools/kernel.ld
	$(LD) $(LDFLAGS) -T ./tools/kernel.ld -o kernel 000entry.o $(OBJS) #-b binary initcode
	$(OBJDUMP) -S kernel > kernel.asm
	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym



# kernelmemfs is a copy of kernel that maintains the
# disk image in memory instead of writing to a disk.
# This is not so useful for testing persistent storage or
# exploring disk buffering implementations, but it is
# great for testing the kernel on real hardware without
# needing a scratch disk.
MEMFSOBJS = $(filter-out ide.o,$(OBJS)) memide.o
kernelmemfs: $(MEMFSOBJS) entry.o entryother initcode kernel.ld fs.img
	$(LD) $(LDFLAGS) -T kernel.ld -o kernelmemfs entry.o  $(MEMFSOBJS) -b binary initcode entryother fs.img
	$(OBJDUMP) -S kernelmemfs > kernelmemfs.asm
	$(OBJDUMP) -t kernelmemfs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernelmemfs.sym

tags: $(OBJS) entryother.S _init
	etags *.S *.c

vectors.S: ./tools/vector.py
	python3 ./tools/vector.py > vectors.S

ULIB = ulib.o usys.o printf.o umalloc.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $@ $^
	$(OBJDUMP) -S $@ > $*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

_forktest: forktest.o $(ULIB)
	# forktest has less library code linked in - needs to be small
	# in order to be able to max out the proc table.
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o _forktest forktest.o ulib.o usys.o
	$(OBJDUMP) -S _forktest > forktest.asm

mkfs: mkfs.c fs.h
	gcc -Werror -Wall -o mkfs mkfs.c

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

UPROGS=\
	_cat\
	_echo\
	_forktest\
	_grep\
	_init\
	_kill\
	_ln\
	_ls\
	_mkdir\
	_rm\
	_sh\
	_stressfs\
	_usertests\
	_wc\
	_zombie\

fs.img: mkfs README $(UPROGS)
	./mkfs fs.img README $(UPROGS)

-include *.d

clean: 
	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
	*.o *.d *.asm *.sym vectors.S bootblock entryother \
	initcode initcode.out kernel xv6.img fs.img kernelmemfs mkfs \
	.gdbinit \
	$(UPROGS)

# make a printout
FILES = $(shell grep -v '^\#' runoff.list)
PRINT = runoff.list runoff.spec README toc.hdr toc.ftr $(FILES)

xv6.pdf: $(PRINT)
	./runoff
	ls -l xv6.pdf

print: xv6.pdf

# run in emulators

bochs : fs.img xv6.img
	if [ ! -e .bochsrc ]; then ln -s dot-bochsrc .bochsrc; fi
	bochs -q

# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)
# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)
ifndef CPUS
# CPUS := 2
CPUS := 1
endif
# QEMUOPTS = -drive file=fs.img,index=1,media=disk,format=raw -drive file=xv6.img,index=0,media=disk,format=raw -smp $(CPUS) -m 512 $(QEMUEXTRA)
QEMUOPTS = -drive file=grenouille.img,index=0,media=disk,format=raw -smp $(CPUS) -m 512 $(QEMUEXTRA)

# qemu: fs.img xv6.img
# 	$(QEMU) -serial mon:stdio $(QEMUOPTS)
qemu: grenouille.img
	$(QEMU) -serial mon:stdio $(QEMUOPTS)

qemu-memfs: xv6memfs.img
	$(QEMU) -drive file=xv6memfs.img,index=0,media=disk,format=raw -smp $(CPUS) -m 256

qemu-nox: fs.img xv6.img
	$(QEMU) -nographic $(QEMUOPTS)

.gdbinit: .gdbinit.tmpl
	sed "s/localhost:1234/localhost:$(GDBPORT)/" < $^ > $@

# qemu-gdb: fs.img xv6.img .gdbinit
# 	@echo "*** Now run 'gdb'." 1>&2
# 	$(QEMU) -serial mon:stdio $(QEMUOPTS) -S $(QEMUGDB)

qemu-gdb: grenouille.img .gdbinit
	@echo "*** Now run 'gdb'." 1>&2
	$(QEMU) -serial mon:stdio $(QEMUOPTS) -S $(QEMUGDB)

qemu-nox-gdb: fs.img xv6.img .gdbinit
	@echo "*** Now run 'gdb'." 1>&2
	$(QEMU) -nographic $(QEMUOPTS) -S $(QEMUGDB)

# CUT HERE
# prepare dist for students
# after running make dist, probably want to
# rename it to rev0 or rev1 or so on and then
# check in that version.

EXTRA=\
	mkfs.c ulib.c user.h cat.c echo.c forktest.c grep.c kill.c\
	ln.c ls.c mkdir.c rm.c stressfs.c usertests.c wc.c zombie.c\
	printf.c umalloc.c\
	README dot-bochsrc *.pl toc.* runoff runoff1 runoff.list\
	.gdbinit.tmpl gdbutil\

dist:
	rm -rf dist
	mkdir dist
	for i in $(FILES); \
	do \
		grep -v PAGEBREAK $$i >dist/$$i; \
	done
	sed '/CUT HERE/,$$d' Makefile >dist/Makefile
	echo >dist/runoff.spec
	cp $(EXTRA) dist

dist-test:
	rm -rf dist
	make dist
	rm -rf dist-test
	mkdir dist-test
	cp dist/* dist-test
	cd dist-test; $(MAKE) print
	cd dist-test; $(MAKE) bochs || true
	cd dist-test; $(MAKE) qemu

# update this rule (change rev#) when it is time to
# make a new revision.
tar:
	rm -rf /tmp/xv6
	mkdir -p /tmp/xv6
	cp dist/* dist/.gdbinit.tmpl /tmp/xv6
	(cd /tmp; tar cf - xv6) | gzip >xv6-rev10.tar.gz  # the next one will be 10 (9/17)

.PHONY: dist-test dist
