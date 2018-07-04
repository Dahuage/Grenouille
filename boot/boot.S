#include <asm.h>
/*
 * 不同的硬件架构，启动的实现不同。在同一个硬件架构下，又存在不同的启动方式
 * 。我们的目的主要集中于后续的进程模型，内存管理，文件系统，中断等核心概念
 * 因此，启动例程的实现我们以古老而又简单的mbr方式进行。并且，为了方便我们
 * 只关注x86-32架构。
 *
 */


.global start
start:
	.code16
	cli
	cld
	xorw	%ax,	%ax
	xorw 	%bx,    %bx
	xorw 	%cx,    %cx
	xorw 	%dx,    %dx

	xorw 	%di,    %di
	xorw 	%si,    %si

	xorw 	%sp,    %sp
	xorw 	%bp,    %bp

	movw	%ax,	%es
	movw	%ax,	%ds
	movw	%ax,	%ss
	movw	%ax,	%fs
	movw	%ax,	%gs
/*
 * 	
 *  切换保护模式，与端口为$0x64的8042键盘控制器通讯。先测试键盘的输入
 *  缓冲区为空。负责忙等待输入缓冲区为空。发送0xd1命令到0x64端口；发送
 *	0xdf到0x60。以激活a20地址总线。
 */
seta20.1:
	inb		$0x64,	%al	
	testb	$0x2,	%al
	jnz		seta20.1
	movb	$0xd1,	%al
	outb	%al,	$0x64

seta20.2:
	inb		$0x60,	%al	
	testb	$0x2,	%al
	jnz		seta20.2
	movb	$0xdf,	%al
	outb	%al,	$0x60

	lgdt	gdtdesc
	#####################################################
    #crx|b31|b30-b12|b11-b5|b4|b3|b2|b1|b0
    #####################################################
    #cr0| PG|000000000..000|ET|TS|EM|MP|PE
    #####################################################
    #cr1| 保留
    #####################################################
    #cr2| 页故障线向地址
    #####################################################
    #cr3页目录物理页码| 00000000000000000000
    #####################################################

    #开启cr0的b0位
    movl 	%cr0, 	%eax
    orl 	$0x1,  	%eax
    movl 	%eax, 	%cr0
	ljmp	$0x8,	$protectmode #jump to gdt[1]+protectmode

.code32
protectmode:
	movw 	$0x10, 	%ax #数据段寄存器就位, bin(0x10) = 0b10 00 0, 因此可得gdtr的索引为0b10=2
	movw	%ax, 	%ds
	movw 	%ax, 	%es
	movw 	%ax,	%fs
	movw 	%ax, 	%gs 
	movw 	%ax, 	%ss
	# movl 	$0x0, 	%ebp
	movl 	$start, %esp
	/*
	 * acturally, from now on, no more assembly.
	 * if necessary on occasions when c was un-
	 * able to do sth. we will implement the code
	 * as c functions with inline assembly. 
	 */ 
	call	bootmain
spin:
	jmp 	spin


.p2align 2
gdt:
	SEG_NULLASM                            #gdt[0] null
	SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)  #gdt[1] cs,read&x, with 0x8 access this entry
	SEG_ASM(STA_W      , 0x0, 0xffffffff)  #gdt[2] ds,write , with ox10 access this entry

#the GDTR's content what is gdt address.
gdtdesc:
	.word	0x17 # gdt长度 6bytes per gdt entry. thougth a 18 total
 	.long	gdt  # gdt基址
