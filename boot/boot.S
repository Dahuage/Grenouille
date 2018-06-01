/*
 * 不同的硬件架构，启动的实现不同。在同一个硬件架构下，又存在不同的启动方式
 * 。我们的目的主要集中于后续的进程模型，内存管理，文件系统，中断等核心概念
 * 因此，启动例程的实现我们以古老而又简单的mbr方式进行。并且，为了方便我们
 * 只关注x86-32架构。
 *
 */


.globle start
start:
.code16
	cli
	cld
	xorw	%ax,	%ax
	movw	%ax,	%es
	movw	%ax,	%ds
	movw	%ax,	%ss
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
	movb	$0xd1	%al
	outb	%al		$0x64

seta20.2:
	inb		$0x60,	%al	
	testb	$0x2,	%al
	jnz		seta20.2
	movb	$0xdf,	%al
	outb	%al,	$0x60

	lgdt	gdtdesc
	movl	$0x1, 	%cr0
	ljmp	$0x8,	$protectmode 


protectmode:
.code32
	movw 	$0x10, 	%ax
	movw	%ax, 	%ds
	movw 	%ax, 	%es
	movw 	%ax,	%fs
	movw 	%ax, 	%gs 
	movw 	%ax, 	%ss
	movw 	$0x0, 	$ebp
	movw 	$start, $esp
	call	os_loader
spin:
	jmp 	spin


gdt:
	0x0, 0x0
	0x0, 0x0, 0x0, 0x0


gdtdesc:
	.word	0x17
 	.long	gdt







	

