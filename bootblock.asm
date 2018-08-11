
bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
 */

.code16
.global start
start:
    cli
    7c00:	fa                   	cli    
    cld
    7c01:	fc                   	cld    
    xorw    %ax,    %ax
    7c02:	31 c0                	xor    %eax,%eax
    # xorw    %si,    %si

    # xorw    %sp,    %sp
    # xorw    %bp,    %bp

    movw    %ax,    %es
    7c04:	8e c0                	mov    %eax,%es
    movw    %ax,    %ds
    7c06:	8e d8                	mov    %eax,%ds
    movw    %ax,    %ss
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
 *  切换保护模式，与端口为$0x64的8042键盘控制器通讯。先测试键盘的输入
 *  缓冲区为空。负责忙等待输入缓冲区为空。发送0xd1命令到0x64端口；发送
 *  0xdf到0x60。以激活a20地址总线。
 */
seta20.1:
    inb     $0x64,  %al 
    7c0a:	e4 64                	in     $0x64,%al
    testb   $0x2,   %al
    7c0c:	a8 02                	test   $0x2,%al
    jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>
    movb    $0xd1,  %al
    7c10:	b0 d1                	mov    $0xd1,%al
    outb    %al,    $0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
    inb     $0x64,  %al 
    7c14:	e4 64                	in     $0x64,%al
    testb   $0x2,   %al
    7c16:	a8 02                	test   $0x2,%al
    jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>
    movb    $0xdf,  %al
    7c1a:	b0 df                	mov    $0xdf,%al
    outb    %al,    $0x60
    7c1c:	e6 60                	out    %al,$0x60

    lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64 7c 0f             	fs jl  7c33 <protectmode+0x1>
    #####################################################
    #cr3| 页目录基址  |  0000000000000
    #####################################################

    #开启cr0的b0位
    movl    %cr0,   %eax
    7c24:	20 c0                	and    %al,%al
    orl     $0x1,   %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
    movl    %eax,   %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
    ljmp    $0x8,   $protectmode #jump to gdt[1]+protectmode
    7c2d:	ea                   	.byte 0xea
    7c2e:	32 7c 08 00          	xor    0x0(%eax,%ecx,1),%bh

00007c32 <protectmode>:


.code32
protectmode:
    movw    $0x10,  %ax #数据段寄存器就位, bin(0x10) = 0b10 00 0, 因此可得gdtr的索引为0b10=2
    7c32:	66 b8 10 00          	mov    $0x10,%ax
    movw    %ax,    %ds
    7c36:	8e d8                	mov    %eax,%ds
    movw    %ax,    %es
    7c38:	8e c0                	mov    %eax,%es
    movw    %ax,    %fs
    7c3a:	8e e0                	mov    %eax,%fs
    movw    %ax,    %gs 
    7c3c:	8e e8                	mov    %eax,%gs
    movw    %ax,    %ss
    7c3e:	8e d0                	mov    %eax,%ss
    # movl  $0x0,   %ebp
    movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
     * acturally, from now on, no more assembly.
     * if necessary on occasions when c was un-
     * able to do sth. we will implement the code
     * as c functions with inline assembly. 
     */ 
    call    bootmain
    7c45:	e8 8f 00 00 00       	call   7cd9 <bootmain>

00007c4a <spin>:
spin:
    jmp     spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00                   	.byte 0x0
    7c61:	92                   	xchg   %eax,%edx
    7c62:	cf                   	iret   
	...

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <readsect>:
 * 试着搞一个硬盘读写函数，参照ucore 
 * @para:addr内存地址
 * @para:secno扇区号
 */
static void
readsect(void *dst, uint32_t secno) {
    7c6a:	55                   	push   %ebp
    7c6b:	89 e5                	mov    %esp,%ebp
    7c6d:	57                   	push   %edi
    7c6e:	89 c7                	mov    %eax,%edi
    7c70:	89 d1                	mov    %edx,%ecx

/* 从指定端口读取一个字节 */ 
static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
    7c72:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c77:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40)
    7c78:	83 e0 c0             	and    $0xffffffc0,%eax
    7c7b:	3c 40                	cmp    $0x40,%al
    7c7d:	75 f8                	jne    7c77 <readsect+0xd>
}

// 向指定端口写一个字节
static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
    7c7f:	b8 01 00 00 00       	mov    $0x1,%eax
    7c84:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c89:	ee                   	out    %al,(%dx)
    7c8a:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c8f:	89 c8                	mov    %ecx,%eax
    7c91:	ee                   	out    %al,(%dx)
     * 扇区寻址范围为2^28扇区。硬盘大小=2^28*单扇区字节数
     * 以下4行，设置起始扇区号。扇区号28位，分4次进行。以
     * 8-8-8-4进行。
     */
    outb(0x1F3, secno & 0xFF);                
    outb(0x1F4, (secno >> 8) & 0xFF);
    7c92:	89 c8                	mov    %ecx,%eax
    7c94:	c1 e8 08             	shr    $0x8,%eax
    7c97:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7c9c:	ee                   	out    %al,(%dx)
    outb(0x1F5, (secno >> 16) & 0xFF);
    7c9d:	89 c8                	mov    %ecx,%eax
    7c9f:	c1 e8 10             	shr    $0x10,%eax
    7ca2:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7ca7:	ee                   	out    %al,(%dx)
    //高四位设置LBA模式,主硬盘,以及LBA地址 27～24
    outb(0x1F6, ((secno >> 24) & 0xFF) | 0xE0);
    7ca8:	89 c8                	mov    %ecx,%eax
    7caa:	c1 e8 18             	shr    $0x18,%eax
    7cad:	83 c8 e0             	or     $0xffffffe0,%eax
    7cb0:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cb5:	ee                   	out    %al,(%dx)
    7cb6:	b8 20 00 00 00       	mov    $0x20,%eax
    7cbb:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc0:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
    7cc1:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40)
    7cc2:	83 e0 c0             	and    $0xffffffc0,%eax
    7cc5:	3c 40                	cmp    $0x40,%al
    7cc7:	75 f8                	jne    7cc1 <readsect+0x57>
    asm volatile (
    7cc9:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cce:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cd3:	fc                   	cld    
    7cd4:	f2 6d                	repnz insl (%dx),%es:(%edi)
    /*
     * 0x1F0为磁盘的数据端口
     * 
     */
    insl(0x1F0, dst, SECTSIZE / 4);
}
    7cd6:	5f                   	pop    %edi
    7cd7:	5d                   	pop    %ebp
    7cd8:	c3                   	ret    

00007cd9 <bootmain>:
 * 我们将以下两个结构整理到elf.h
 */


void
bootmain(void){
    7cd9:	55                   	push   %ebp
    7cda:	89 e5                	mov    %esp,%ebp
    7cdc:	57                   	push   %edi
    7cdd:	56                   	push   %esi
    7cde:	53                   	push   %ebx
    7cdf:	83 ec 1c             	sub    $0x1c,%esp
    uint32_t sector_no = (offset / SECTSIZE) + 1;
    7ce2:	bb 01 00 00 00       	mov    $0x1,%ebx
        readsect((uint32_t*)addr, sector_no);
    7ce7:	8d 43 7f             	lea    0x7f(%ebx),%eax
    7cea:	c1 e0 09             	shl    $0x9,%eax
    7ced:	89 da                	mov    %ebx,%edx
    7cef:	e8 76 ff ff ff       	call   7c6a <readsect>
        sector_no++;
    7cf4:	83 c3 01             	add    $0x1,%ebx
    while(addr < addr_end){
    7cf7:	83 fb 09             	cmp    $0x9,%ebx
    7cfa:	75 eb                	jne    7ce7 <bootmain+0xe>
    struct elf_hdr *kernel_elf_header;
    kernel_elf_header = (struct kernel_elf_header *)0x10000; // 就写在这里，爱谁谁。

    read_elf_header((uintptr_t)kernel_elf_header, 512*8, 0);
    // 检查elf文件是否合法
    if (kernel_elf_header->e_magic != ELF_MAGIC)
    7cfc:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d03:	45 4c 46 
    7d06:	74 08                	je     7d10 <bootmain+0x37>
        read_elf_header(ph->p_pa, ph->p_memsz, ph->p_offset);
        ph++;
    }
    // 调起os的入口，永不返回
    ((void (*)(void)) (kernel_elf_header->e_entry))();
}
    7d08:	83 c4 1c             	add    $0x1c,%esp
    7d0b:	5b                   	pop    %ebx
    7d0c:	5e                   	pop    %esi
    7d0d:	5f                   	pop    %edi
    7d0e:	5d                   	pop    %ebp
    7d0f:	c3                   	ret    
    ph = (struct elf_pro_hdr *)((uintptr_t)kernel_elf_header+kernel_elf_header->e_phoff);
    7d10:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d15:	8d b8 00 00 01 00    	lea    0x10000(%eax),%edi
    end_ph = ph + kernel_elf_header->e_phnum;
    7d1b:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7d22:	c1 e0 05             	shl    $0x5,%eax
    7d25:	01 f8                	add    %edi,%eax
    7d27:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(ph<end_ph){
    7d2a:	39 c7                	cmp    %eax,%edi
    7d2c:	73 44                	jae    7d72 <bootmain+0x99>
        read_elf_header(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d2e:	8b 77 04             	mov    0x4(%edi),%esi
    7d31:	8b 5f 0c             	mov    0xc(%edi),%ebx
    uintptr_t addr_end = addr + count;
    7d34:	89 d9                	mov    %ebx,%ecx
    7d36:	03 4f 14             	add    0x14(%edi),%ecx
    addr -= offset % SECTSIZE;
    7d39:	89 f0                	mov    %esi,%eax
    7d3b:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d40:	29 c3                	sub    %eax,%ebx
    uint32_t sector_no = (offset / SECTSIZE) + 1;
    7d42:	c1 ee 09             	shr    $0x9,%esi
    7d45:	83 c6 01             	add    $0x1,%esi
    while(addr < addr_end){
    7d48:	39 d9                	cmp    %ebx,%ecx
    7d4a:	76 1e                	jbe    7d6a <bootmain+0x91>
    7d4c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    7d4f:	89 cf                	mov    %ecx,%edi
        readsect((uint32_t*)addr, sector_no);
    7d51:	89 f2                	mov    %esi,%edx
    7d53:	89 d8                	mov    %ebx,%eax
    7d55:	e8 10 ff ff ff       	call   7c6a <readsect>
        addr += SECTSIZE;
    7d5a:	81 c3 00 02 00 00    	add    $0x200,%ebx
        sector_no++;
    7d60:	83 c6 01             	add    $0x1,%esi
    while(addr < addr_end){
    7d63:	39 df                	cmp    %ebx,%edi
    7d65:	77 ea                	ja     7d51 <bootmain+0x78>
    7d67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        ph++;
    7d6a:	83 c7 20             	add    $0x20,%edi
    while(ph<end_ph){
    7d6d:	39 7d e0             	cmp    %edi,-0x20(%ebp)
    7d70:	77 bc                	ja     7d2e <bootmain+0x55>
    ((void (*)(void)) (kernel_elf_header->e_entry))();
    7d72:	ff 15 18 00 01 00    	call   *0x10018
    7d78:	eb 8e                	jmp    7d08 <bootmain+0x2f>
