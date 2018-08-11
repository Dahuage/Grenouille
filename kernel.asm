
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 30 10 00       	mov    $0x103000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  movl $stack, %eax
80100028:	b8 80 51 10 80       	mov    $0x80105180,%eax
  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010002d:	bc 80 61 10 80       	mov    $0x80106180,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $kernel_init, %eax
80100032:	b8 40 00 10 80       	mov    $0x80100040,%eax
  jmp *%eax
80100037:	ff e0                	jmp    *%eax
80100039:	66 90                	xchg   %ax,%ax
8010003b:	66 90                	xchg   %ax,%ax
8010003d:	66 90                	xchg   %ax,%ax
8010003f:	90                   	nop

80100040 <kernel_init>:


void kernel_init(void) __attribute__((noreturn));

void
kernel_init(void){
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	83 ec 08             	sub    $0x8,%esp
	cons_init();
80100046:	e8 25 11 00 00       	call   80101170 <cons_init>
	char *message = "I worked my ass off to figure out this\n";
	cprintf(message);
8010004b:	83 ec 0c             	sub    $0xc,%esp
8010004e:	68 e0 22 10 80       	push   $0x801022e0
80100053:	e8 a8 1b 00 00       	call   80101c00 <cprintf>
80100058:	83 c4 10             	add    $0x10,%esp
8010005b:	eb fe                	jmp    8010005b <kernel_init+0x1b>
8010005d:	66 90                	xchg   %ax,%ax
8010005f:	90                   	nop

80100060 <trap_in_kernel>:
    return "(unknown trap)";
}

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
80100060:	55                   	push   %ebp
80100061:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
80100063:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100066:	5d                   	pop    %ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
80100067:	66 83 78 3c 08       	cmpw   $0x8,0x3c(%eax)
8010006c:	0f 94 c0             	sete   %al
8010006f:	0f b6 c0             	movzbl %al,%eax
}
80100072:	c3                   	ret    
80100073:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100080 <print_regs>:
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
    }
}

void
print_regs(struct pushregs *regs) {
80100080:	55                   	push   %ebp
80100081:	89 e5                	mov    %esp,%ebp
80100083:	53                   	push   %ebx
80100084:	83 ec 0c             	sub    $0xc,%esp
80100087:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cprintf("  edi  0x%08x\n", regs->reg_edi);
8010008a:	ff 33                	pushl  (%ebx)
8010008c:	68 08 23 10 80       	push   $0x80102308
80100091:	e8 6a 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
80100096:	58                   	pop    %eax
80100097:	5a                   	pop    %edx
80100098:	ff 73 04             	pushl  0x4(%ebx)
8010009b:	68 17 23 10 80       	push   $0x80102317
801000a0:	e8 5b 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
801000a5:	59                   	pop    %ecx
801000a6:	58                   	pop    %eax
801000a7:	ff 73 08             	pushl  0x8(%ebx)
801000aa:	68 26 23 10 80       	push   $0x80102326
801000af:	e8 4c 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
801000b4:	58                   	pop    %eax
801000b5:	5a                   	pop    %edx
801000b6:	ff 73 0c             	pushl  0xc(%ebx)
801000b9:	68 35 23 10 80       	push   $0x80102335
801000be:	e8 3d 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
801000c3:	59                   	pop    %ecx
801000c4:	58                   	pop    %eax
801000c5:	ff 73 10             	pushl  0x10(%ebx)
801000c8:	68 44 23 10 80       	push   $0x80102344
801000cd:	e8 2e 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
801000d2:	58                   	pop    %eax
801000d3:	5a                   	pop    %edx
801000d4:	ff 73 14             	pushl  0x14(%ebx)
801000d7:	68 53 23 10 80       	push   $0x80102353
801000dc:	e8 1f 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
801000e1:	59                   	pop    %ecx
801000e2:	58                   	pop    %eax
801000e3:	ff 73 18             	pushl  0x18(%ebx)
801000e6:	68 62 23 10 80       	push   $0x80102362
801000eb:	e8 10 1b 00 00       	call   80101c00 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
801000f0:	58                   	pop    %eax
801000f1:	5a                   	pop    %edx
801000f2:	ff 73 1c             	pushl  0x1c(%ebx)
801000f5:	68 71 23 10 80       	push   $0x80102371
801000fa:	e8 01 1b 00 00       	call   80101c00 <cprintf>
}
801000ff:	83 c4 10             	add    $0x10,%esp
80100102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100105:	c9                   	leave  
80100106:	c3                   	ret    
80100107:	89 f6                	mov    %esi,%esi
80100109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100110 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
80100110:	55                   	push   %ebp
80100111:	89 e5                	mov    %esp,%ebp
80100113:	57                   	push   %edi
80100114:	56                   	push   %esi
80100115:	53                   	push   %ebx
80100116:	83 ec 14             	sub    $0x14,%esp
80100119:	8b 7d 08             	mov    0x8(%ebp),%edi
    cprintf("trapframe at %p\n", tf);
8010011c:	57                   	push   %edi
8010011d:	68 a2 23 10 80       	push   $0x801023a2
80100122:	e8 d9 1a 00 00       	call   80101c00 <cprintf>
    print_regs(&tf->tf_regs);
80100127:	89 3c 24             	mov    %edi,(%esp)
8010012a:	e8 51 ff ff ff       	call   80100080 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
8010012f:	5e                   	pop    %esi
80100130:	58                   	pop    %eax
80100131:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
80100135:	50                   	push   %eax
80100136:	68 b3 23 10 80       	push   $0x801023b3
8010013b:	e8 c0 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
80100140:	58                   	pop    %eax
80100141:	0f b7 47 28          	movzwl 0x28(%edi),%eax
80100145:	5a                   	pop    %edx
80100146:	50                   	push   %eax
80100147:	68 c6 23 10 80       	push   $0x801023c6
8010014c:	e8 af 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
80100151:	0f b7 47 24          	movzwl 0x24(%edi),%eax
80100155:	59                   	pop    %ecx
80100156:	5b                   	pop    %ebx
80100157:	50                   	push   %eax
80100158:	68 d9 23 10 80       	push   $0x801023d9
8010015d:	e8 9e 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
80100162:	5e                   	pop    %esi
80100163:	58                   	pop    %eax
80100164:	0f b7 47 20          	movzwl 0x20(%edi),%eax
80100168:	50                   	push   %eax
80100169:	68 ec 23 10 80       	push   $0x801023ec
8010016e:	e8 8d 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
80100173:	8b 47 30             	mov    0x30(%edi),%eax
    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
80100176:	83 c4 10             	add    $0x10,%esp
80100179:	83 f8 13             	cmp    $0x13,%eax
8010017c:	0f 87 de 00 00 00    	ja     80100260 <print_trapframe+0x150>
        return excnames[trapno];
80100182:	8b 14 85 20 26 10 80 	mov    -0x7fefd9e0(,%eax,4),%edx
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
80100189:	83 ec 04             	sub    $0x4,%esp
8010018c:	52                   	push   %edx
8010018d:	50                   	push   %eax
8010018e:	68 ff 23 10 80       	push   $0x801023ff
80100193:	e8 68 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
80100198:	59                   	pop    %ecx
80100199:	5b                   	pop    %ebx
8010019a:	ff 77 34             	pushl  0x34(%edi)
8010019d:	68 11 24 10 80       	push   $0x80102411
801001a2:	e8 59 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
801001a7:	5e                   	pop    %esi
801001a8:	58                   	pop    %eax
801001a9:	ff 77 38             	pushl  0x38(%edi)
801001ac:	68 20 24 10 80       	push   $0x80102420
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
801001b1:	be 01 00 00 00       	mov    $0x1,%esi
    cprintf("  eip  0x%08x\n", tf->tf_eip);
801001b6:	e8 45 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
801001bb:	58                   	pop    %eax
801001bc:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
801001c0:	5a                   	pop    %edx
801001c1:	50                   	push   %eax
801001c2:	68 2f 24 10 80       	push   $0x8010242f
801001c7:	e8 34 1a 00 00       	call   80101c00 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
801001cc:	59                   	pop    %ecx
801001cd:	5b                   	pop    %ebx
801001ce:	ff 77 40             	pushl  0x40(%edi)
801001d1:	68 42 24 10 80       	push   $0x80102442
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
801001d6:	31 db                	xor    %ebx,%ebx
    cprintf("  flag 0x%08x ", tf->tf_eflags);
801001d8:	e8 23 1a 00 00       	call   80101c00 <cprintf>
801001dd:	8b 47 40             	mov    0x40(%edi),%eax
801001e0:	83 c4 10             	add    $0x10,%esp
801001e3:	90                   	nop
801001e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
801001e8:	85 c6                	test   %eax,%esi
801001ea:	74 1f                	je     8010020b <print_trapframe+0xfb>
801001ec:	8b 14 9d 80 26 10 80 	mov    -0x7fefd980(,%ebx,4),%edx
801001f3:	85 d2                	test   %edx,%edx
801001f5:	74 14                	je     8010020b <print_trapframe+0xfb>
            cprintf("%s,", IA32flags[i]);
801001f7:	83 ec 08             	sub    $0x8,%esp
801001fa:	52                   	push   %edx
801001fb:	68 51 24 10 80       	push   $0x80102451
80100200:	e8 fb 19 00 00       	call   80101c00 <cprintf>
80100205:	8b 47 40             	mov    0x40(%edi),%eax
80100208:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
8010020b:	83 c3 01             	add    $0x1,%ebx
8010020e:	01 f6                	add    %esi,%esi
80100210:	83 fb 18             	cmp    $0x18,%ebx
80100213:	75 d3                	jne    801001e8 <print_trapframe+0xd8>
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
80100215:	c1 e8 0c             	shr    $0xc,%eax
80100218:	83 ec 08             	sub    $0x8,%esp
8010021b:	83 e0 03             	and    $0x3,%eax
8010021e:	50                   	push   %eax
8010021f:	68 55 24 10 80       	push   $0x80102455
80100224:	e8 d7 19 00 00       	call   80101c00 <cprintf>
    if (!trap_in_kernel(tf)) {
80100229:	83 c4 10             	add    $0x10,%esp
8010022c:	66 83 7f 3c 08       	cmpw   $0x8,0x3c(%edi)
80100231:	74 24                	je     80100257 <print_trapframe+0x147>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
80100233:	83 ec 08             	sub    $0x8,%esp
80100236:	ff 77 44             	pushl  0x44(%edi)
80100239:	68 5e 24 10 80       	push   $0x8010245e
8010023e:	e8 bd 19 00 00       	call   80101c00 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
80100243:	58                   	pop    %eax
80100244:	0f b7 47 48          	movzwl 0x48(%edi),%eax
80100248:	5a                   	pop    %edx
80100249:	50                   	push   %eax
8010024a:	68 6d 24 10 80       	push   $0x8010246d
8010024f:	e8 ac 19 00 00       	call   80101c00 <cprintf>
80100254:	83 c4 10             	add    $0x10,%esp
}
80100257:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010025a:	5b                   	pop    %ebx
8010025b:	5e                   	pop    %esi
8010025c:	5f                   	pop    %edi
8010025d:	5d                   	pop    %ebp
8010025e:	c3                   	ret    
8010025f:	90                   	nop
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
80100260:	8d 50 e0             	lea    -0x20(%eax),%edx
        return "Hardware Interrupt";
80100263:	b9 80 23 10 80       	mov    $0x80102380,%ecx
80100268:	83 fa 0f             	cmp    $0xf,%edx
8010026b:	ba 93 23 10 80       	mov    $0x80102393,%edx
80100270:	0f 46 d1             	cmovbe %ecx,%edx
80100273:	e9 11 ff ff ff       	jmp    80100189 <print_trapframe+0x79>
80100278:	90                   	nop
80100279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100280 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 0c             	sub    $0xc,%esp
80100289:	8b 5d 08             	mov    0x8(%ebp),%ebx
    switch (tf->tf_trapno) {
8010028c:	8b 43 30             	mov    0x30(%ebx),%eax
8010028f:	83 f8 2f             	cmp    $0x2f,%eax
80100292:	0f 87 c8 00 00 00    	ja     80100360 <trap+0xe0>
80100298:	83 f8 2e             	cmp    $0x2e,%eax
8010029b:	0f 83 af 00 00 00    	jae    80100350 <trap+0xd0>
801002a1:	83 f8 21             	cmp    $0x21,%eax
801002a4:	0f 84 16 01 00 00    	je     801003c0 <trap+0x140>
801002aa:	83 f8 24             	cmp    $0x24,%eax
801002ad:	0f 84 7d 01 00 00    	je     80100430 <trap+0x1b0>
801002b3:	83 f8 20             	cmp    $0x20,%eax
801002b6:	0f 84 2c 01 00 00    	je     801003e8 <trap+0x168>
        if ((tf->tf_cs & 3) == 0) {
801002bc:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801002c0:	0f 85 8a 00 00 00    	jne    80100350 <trap+0xd0>
            print_trapframe(tf);
801002c6:	89 5d 08             	mov    %ebx,0x8(%ebp)
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
801002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002cc:	5b                   	pop    %ebx
801002cd:	5e                   	pop    %esi
801002ce:	5f                   	pop    %edi
801002cf:	5d                   	pop    %ebp
            print_trapframe(tf);
801002d0:	e9 3b fe ff ff       	jmp    80100110 <print_trapframe>
801002d5:	8d 76 00             	lea    0x0(%esi),%esi
        if (tf->tf_cs != USER_CS) {
801002d8:	66 83 7b 3c 1b       	cmpw   $0x1b,0x3c(%ebx)
801002dd:	74 71                	je     80100350 <trap+0xd0>
            switchk2u = *tf;
801002df:	8b 03                	mov    (%ebx),%eax
801002e1:	bf 84 61 10 80       	mov    $0x80106184,%edi
801002e6:	b9 80 61 10 80       	mov    $0x80106180,%ecx
801002eb:	83 e7 fc             	and    $0xfffffffc,%edi
801002ee:	89 de                	mov    %ebx,%esi
801002f0:	29 f9                	sub    %edi,%ecx
801002f2:	a3 80 61 10 80       	mov    %eax,0x80106180
801002f7:	8b 43 48             	mov    0x48(%ebx),%eax
801002fa:	29 ce                	sub    %ecx,%esi
801002fc:	83 c1 4c             	add    $0x4c,%ecx
801002ff:	c1 e9 02             	shr    $0x2,%ecx
80100302:	a3 c8 61 10 80       	mov    %eax,0x801061c8
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
80100307:	b8 23 00 00 00       	mov    $0x23,%eax
            switchk2u = *tf;
8010030c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
8010030e:	66 a3 a8 61 10 80    	mov    %ax,0x801061a8
80100314:	b8 23 00 00 00       	mov    $0x23,%eax
            switchk2u.tf_cs = USER_CS;
80100319:	be 1b 00 00 00       	mov    $0x1b,%esi
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
8010031e:	66 a3 ac 61 10 80    	mov    %ax,0x801061ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
80100324:	8d 43 44             	lea    0x44(%ebx),%eax
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
80100327:	bf 23 00 00 00       	mov    $0x23,%edi
            switchk2u.tf_cs = USER_CS;
8010032c:	66 89 35 bc 61 10 80 	mov    %si,0x801061bc
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
80100333:	66 89 3d c8 61 10 80 	mov    %di,0x801061c8
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
8010033a:	a3 c4 61 10 80       	mov    %eax,0x801061c4
            switchk2u.tf_eflags |= FL_IOPL_MASK;
8010033f:	81 0d c0 61 10 80 00 	orl    $0x3000,0x801061c0
80100346:	30 00 00 
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
80100349:	c7 43 fc 80 61 10 80 	movl   $0x80106180,-0x4(%ebx)
}
80100350:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100353:	5b                   	pop    %ebx
80100354:	5e                   	pop    %esi
80100355:	5f                   	pop    %edi
80100356:	5d                   	pop    %ebp
80100357:	c3                   	ret    
80100358:	90                   	nop
80100359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch (tf->tf_trapno) {
80100360:	83 f8 78             	cmp    $0x78,%eax
80100363:	0f 84 6f ff ff ff    	je     801002d8 <trap+0x58>
80100369:	83 f8 79             	cmp    $0x79,%eax
8010036c:	0f 85 4a ff ff ff    	jne    801002bc <trap+0x3c>
        if (tf->tf_cs != KERNEL_CS) {
80100372:	66 83 7b 3c 08       	cmpw   $0x8,0x3c(%ebx)
80100377:	74 d7                	je     80100350 <trap+0xd0>
            tf->tf_cs = KERNEL_CS;
80100379:	b8 08 00 00 00       	mov    $0x8,%eax
            tf->tf_eflags &= ~FL_IOPL_MASK;
8010037e:	81 63 40 ff cf ff ff 	andl   $0xffffcfff,0x40(%ebx)
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
80100385:	83 ec 04             	sub    $0x4,%esp
            tf->tf_cs = KERNEL_CS;
80100388:	66 89 43 3c          	mov    %ax,0x3c(%ebx)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
8010038c:	8b 43 44             	mov    0x44(%ebx),%eax
            tf->tf_ds = tf->tf_es = KERNEL_DS;
8010038f:	ba 10 00 00 00       	mov    $0x10,%edx
80100394:	b9 10 00 00 00       	mov    $0x10,%ecx
80100399:	66 89 53 28          	mov    %dx,0x28(%ebx)
8010039d:	66 89 4b 2c          	mov    %cx,0x2c(%ebx)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
801003a1:	83 e8 44             	sub    $0x44,%eax
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
801003a4:	6a 44                	push   $0x44
801003a6:	53                   	push   %ebx
801003a7:	50                   	push   %eax
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
801003a8:	a3 cc 61 10 80       	mov    %eax,0x801061cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
801003ad:	e8 2e 17 00 00       	call   80101ae0 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
801003b2:	a1 cc 61 10 80       	mov    0x801061cc,%eax
801003b7:	83 c4 10             	add    $0x10,%esp
801003ba:	89 43 fc             	mov    %eax,-0x4(%ebx)
801003bd:	eb 91                	jmp    80100350 <trap+0xd0>
801003bf:	90                   	nop
        c = cons_getc();
801003c0:	e8 9b 12 00 00       	call   80101660 <cons_getc>
        cprintf("kbd [%03d] %c\n", c, c);
801003c5:	83 ec 04             	sub    $0x4,%esp
801003c8:	0f be c0             	movsbl %al,%eax
801003cb:	50                   	push   %eax
801003cc:	50                   	push   %eax
801003cd:	68 9c 24 10 80       	push   $0x8010249c
801003d2:	e8 29 18 00 00       	call   80101c00 <cprintf>
801003d7:	83 c4 10             	add    $0x10,%esp
}
801003da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801003dd:	5b                   	pop    %ebx
801003de:	5e                   	pop    %esi
801003df:	5f                   	pop    %edi
801003e0:	5d                   	pop    %ebp
801003e1:	c3                   	ret    
801003e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        ticks ++;
801003e8:	a1 d0 61 10 80       	mov    0x801061d0,%eax
        if (ticks % TICK_NUM == 0) {
801003ed:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
        ticks ++;
801003f2:	83 c0 01             	add    $0x1,%eax
801003f5:	a3 d0 61 10 80       	mov    %eax,0x801061d0
        if (ticks % TICK_NUM == 0) {
801003fa:	8b 0d d0 61 10 80    	mov    0x801061d0,%ecx
80100400:	89 c8                	mov    %ecx,%eax
80100402:	f7 e2                	mul    %edx
80100404:	c1 ea 05             	shr    $0x5,%edx
80100407:	6b d2 64             	imul   $0x64,%edx,%edx
8010040a:	39 d1                	cmp    %edx,%ecx
8010040c:	0f 85 3e ff ff ff    	jne    80100350 <trap+0xd0>
    cprintf("%d ticks\n",TICK_NUM);
80100412:	83 ec 08             	sub    $0x8,%esp
80100415:	6a 64                	push   $0x64
80100417:	68 80 24 10 80       	push   $0x80102480
8010041c:	e8 df 17 00 00       	call   80101c00 <cprintf>
80100421:	83 c4 10             	add    $0x10,%esp
80100424:	e9 27 ff ff ff       	jmp    80100350 <trap+0xd0>
80100429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        c = cons_getc();
80100430:	e8 2b 12 00 00       	call   80101660 <cons_getc>
        cprintf("serial [%03d] %c\n", c, c);
80100435:	83 ec 04             	sub    $0x4,%esp
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	50                   	push   %eax
8010043c:	50                   	push   %eax
8010043d:	68 8a 24 10 80       	push   $0x8010248a
80100442:	e8 b9 17 00 00       	call   80101c00 <cprintf>
80100447:	83 c4 10             	add    $0x10,%esp
}
8010044a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010044d:	5b                   	pop    %ebx
8010044e:	5e                   	pop    %esi
8010044f:	5f                   	pop    %edi
80100450:	5d                   	pop    %ebp
80100451:	c3                   	ret    

80100452 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
80100452:	1e                   	push   %ds
    pushl %es
80100453:	06                   	push   %es
    pushl %fs
80100454:	0f a0                	push   %fs
    pushl %gs
80100456:	0f a8                	push   %gs
    pushal
80100458:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
80100459:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
8010045e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
80100460:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
80100462:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
80100463:	e8 18 fe ff ff       	call   80100280 <trap>

    # pop the pushed stack pointer
    popl %esp
80100468:	5c                   	pop    %esp

80100469 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
80100469:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
8010046a:	0f a9                	pop    %gs
    popl %fs
8010046c:	0f a1                	pop    %fs
    popl %es
8010046e:	07                   	pop    %es
    popl %ds
8010046f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
80100470:	83 c4 08             	add    $0x8,%esp
    iret
80100473:	cf                   	iret   
80100474:	66 90                	xchg   %ax,%ax
80100476:	66 90                	xchg   %ax,%ax
80100478:	66 90                	xchg   %ax,%ax
8010047a:	66 90                	xchg   %ax,%ax
8010047c:	66 90                	xchg   %ax,%ax
8010047e:	66 90                	xchg   %ax,%ax

80100480 <idt_init>:
static struct idt_entry_in_bits_field idt[256] = {{0}};
static struct pseudodesc d = {sizeof(idt)-1, idt};


void
idt_init(void){
80100480:	55                   	push   %ebp
	int i;
	extern uintptr_t __vectors[];
    for (i = 0; i < sizeof(idt) / sizeof(struct idt_entry_in_bits_field); i ++) {
80100481:	31 c0                	xor    %eax,%eax
idt_init(void){
80100483:	89 e5                	mov    %esp,%ebp
80100485:	8d 76 00             	lea    0x0(%esi),%esi
        SET_IDTENTRY(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
80100488:	8b 14 85 06 40 10 80 	mov    -0x7fefbffa(,%eax,4),%edx
8010048f:	c7 04 c5 42 47 10 80 	movl   $0x8e000008,-0x7fefb8be(,%eax,8)
80100496:	08 00 00 8e 
8010049a:	66 89 14 c5 40 47 10 	mov    %dx,-0x7fefb8c0(,%eax,8)
801004a1:	80 
801004a2:	c1 ea 10             	shr    $0x10,%edx
801004a5:	66 89 14 c5 46 47 10 	mov    %dx,-0x7fefb8ba(,%eax,8)
801004ac:	80 
    for (i = 0; i < sizeof(idt) / sizeof(struct idt_entry_in_bits_field); i ++) {
801004ad:	83 c0 01             	add    $0x1,%eax
801004b0:	3d 00 01 00 00       	cmp    $0x100,%eax
801004b5:	75 d1                	jne    80100488 <idt_init+0x8>
    }
	// set for switch from user to kernel
    SET_IDTENTRY(idt[T_SWITCH_TOK], 0, GD_KTEXT,  __vectors[T_SWITCH_TOK],  DPL_USER);
801004b7:	a1 ea 41 10 80       	mov    0x801041ea,%eax
801004bc:	c7 05 0a 4b 10 80 08 	movl   $0xee000008,0x80104b0a
801004c3:	00 00 ee 
801004c6:	66 a3 08 4b 10 80    	mov    %ax,0x80104b08
801004cc:	c1 e8 10             	shr    $0x10,%eax
801004cf:	66 a3 0e 4b 10 80    	mov    %ax,0x80104b0e
}

// 载入中断描述符表
static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
801004d5:	b8 00 40 10 80       	mov    $0x80104000,%eax
801004da:	0f 01 18             	lidtl  (%eax)
	//载入idt到idtr
    lidt(&d);
}
801004dd:	5d                   	pop    %ebp
801004de:	c3                   	ret    

801004df <vector0>:
.text

.globl __alltraps
.globl vector0
vector0:
  pushl $0
801004df:	6a 00                	push   $0x0
  pushl $0
801004e1:	6a 00                	push   $0x0
  jmp __alltraps
801004e3:	e9 6a ff ff ff       	jmp    80100452 <__alltraps>

801004e8 <vector1>:
.globl vector1
vector1:
  pushl $0
801004e8:	6a 00                	push   $0x0
  pushl $1
801004ea:	6a 01                	push   $0x1
  jmp __alltraps
801004ec:	e9 61 ff ff ff       	jmp    80100452 <__alltraps>

801004f1 <vector2>:
.globl vector2
vector2:
  pushl $0
801004f1:	6a 00                	push   $0x0
  pushl $2
801004f3:	6a 02                	push   $0x2
  jmp __alltraps
801004f5:	e9 58 ff ff ff       	jmp    80100452 <__alltraps>

801004fa <vector3>:
.globl vector3
vector3:
  pushl $0
801004fa:	6a 00                	push   $0x0
  pushl $3
801004fc:	6a 03                	push   $0x3
  jmp __alltraps
801004fe:	e9 4f ff ff ff       	jmp    80100452 <__alltraps>

80100503 <vector4>:
.globl vector4
vector4:
  pushl $0
80100503:	6a 00                	push   $0x0
  pushl $4
80100505:	6a 04                	push   $0x4
  jmp __alltraps
80100507:	e9 46 ff ff ff       	jmp    80100452 <__alltraps>

8010050c <vector5>:
.globl vector5
vector5:
  pushl $0
8010050c:	6a 00                	push   $0x0
  pushl $5
8010050e:	6a 05                	push   $0x5
  jmp __alltraps
80100510:	e9 3d ff ff ff       	jmp    80100452 <__alltraps>

80100515 <vector6>:
.globl vector6
vector6:
  pushl $0
80100515:	6a 00                	push   $0x0
  pushl $6
80100517:	6a 06                	push   $0x6
  jmp __alltraps
80100519:	e9 34 ff ff ff       	jmp    80100452 <__alltraps>

8010051e <vector7>:
.globl vector7
vector7:
  pushl $0
8010051e:	6a 00                	push   $0x0
  pushl $7
80100520:	6a 07                	push   $0x7
  jmp __alltraps
80100522:	e9 2b ff ff ff       	jmp    80100452 <__alltraps>

80100527 <vector8>:
.globl vector8
vector8:
  pushl $8
80100527:	6a 08                	push   $0x8
  jmp __alltraps
80100529:	e9 24 ff ff ff       	jmp    80100452 <__alltraps>

8010052e <vector9>:
.globl vector9
vector9:
  pushl $9
8010052e:	6a 09                	push   $0x9
  jmp __alltraps
80100530:	e9 1d ff ff ff       	jmp    80100452 <__alltraps>

80100535 <vector10>:
.globl vector10
vector10:
  pushl $10
80100535:	6a 0a                	push   $0xa
  jmp __alltraps
80100537:	e9 16 ff ff ff       	jmp    80100452 <__alltraps>

8010053c <vector11>:
.globl vector11
vector11:
  pushl $11
8010053c:	6a 0b                	push   $0xb
  jmp __alltraps
8010053e:	e9 0f ff ff ff       	jmp    80100452 <__alltraps>

80100543 <vector12>:
.globl vector12
vector12:
  pushl $12
80100543:	6a 0c                	push   $0xc
  jmp __alltraps
80100545:	e9 08 ff ff ff       	jmp    80100452 <__alltraps>

8010054a <vector13>:
.globl vector13
vector13:
  pushl $13
8010054a:	6a 0d                	push   $0xd
  jmp __alltraps
8010054c:	e9 01 ff ff ff       	jmp    80100452 <__alltraps>

80100551 <vector14>:
.globl vector14
vector14:
  pushl $14
80100551:	6a 0e                	push   $0xe
  jmp __alltraps
80100553:	e9 fa fe ff ff       	jmp    80100452 <__alltraps>

80100558 <vector15>:
.globl vector15
vector15:
  pushl $0
80100558:	6a 00                	push   $0x0
  pushl $15
8010055a:	6a 0f                	push   $0xf
  jmp __alltraps
8010055c:	e9 f1 fe ff ff       	jmp    80100452 <__alltraps>

80100561 <vector16>:
.globl vector16
vector16:
  pushl $0
80100561:	6a 00                	push   $0x0
  pushl $16
80100563:	6a 10                	push   $0x10
  jmp __alltraps
80100565:	e9 e8 fe ff ff       	jmp    80100452 <__alltraps>

8010056a <vector17>:
.globl vector17
vector17:
  pushl $17
8010056a:	6a 11                	push   $0x11
  jmp __alltraps
8010056c:	e9 e1 fe ff ff       	jmp    80100452 <__alltraps>

80100571 <vector18>:
.globl vector18
vector18:
  pushl $0
80100571:	6a 00                	push   $0x0
  pushl $18
80100573:	6a 12                	push   $0x12
  jmp __alltraps
80100575:	e9 d8 fe ff ff       	jmp    80100452 <__alltraps>

8010057a <vector19>:
.globl vector19
vector19:
  pushl $0
8010057a:	6a 00                	push   $0x0
  pushl $19
8010057c:	6a 13                	push   $0x13
  jmp __alltraps
8010057e:	e9 cf fe ff ff       	jmp    80100452 <__alltraps>

80100583 <vector20>:
.globl vector20
vector20:
  pushl $0
80100583:	6a 00                	push   $0x0
  pushl $20
80100585:	6a 14                	push   $0x14
  jmp __alltraps
80100587:	e9 c6 fe ff ff       	jmp    80100452 <__alltraps>

8010058c <vector21>:
.globl vector21
vector21:
  pushl $0
8010058c:	6a 00                	push   $0x0
  pushl $21
8010058e:	6a 15                	push   $0x15
  jmp __alltraps
80100590:	e9 bd fe ff ff       	jmp    80100452 <__alltraps>

80100595 <vector22>:
.globl vector22
vector22:
  pushl $0
80100595:	6a 00                	push   $0x0
  pushl $22
80100597:	6a 16                	push   $0x16
  jmp __alltraps
80100599:	e9 b4 fe ff ff       	jmp    80100452 <__alltraps>

8010059e <vector23>:
.globl vector23
vector23:
  pushl $0
8010059e:	6a 00                	push   $0x0
  pushl $23
801005a0:	6a 17                	push   $0x17
  jmp __alltraps
801005a2:	e9 ab fe ff ff       	jmp    80100452 <__alltraps>

801005a7 <vector24>:
.globl vector24
vector24:
  pushl $0
801005a7:	6a 00                	push   $0x0
  pushl $24
801005a9:	6a 18                	push   $0x18
  jmp __alltraps
801005ab:	e9 a2 fe ff ff       	jmp    80100452 <__alltraps>

801005b0 <vector25>:
.globl vector25
vector25:
  pushl $0
801005b0:	6a 00                	push   $0x0
  pushl $25
801005b2:	6a 19                	push   $0x19
  jmp __alltraps
801005b4:	e9 99 fe ff ff       	jmp    80100452 <__alltraps>

801005b9 <vector26>:
.globl vector26
vector26:
  pushl $0
801005b9:	6a 00                	push   $0x0
  pushl $26
801005bb:	6a 1a                	push   $0x1a
  jmp __alltraps
801005bd:	e9 90 fe ff ff       	jmp    80100452 <__alltraps>

801005c2 <vector27>:
.globl vector27
vector27:
  pushl $0
801005c2:	6a 00                	push   $0x0
  pushl $27
801005c4:	6a 1b                	push   $0x1b
  jmp __alltraps
801005c6:	e9 87 fe ff ff       	jmp    80100452 <__alltraps>

801005cb <vector28>:
.globl vector28
vector28:
  pushl $0
801005cb:	6a 00                	push   $0x0
  pushl $28
801005cd:	6a 1c                	push   $0x1c
  jmp __alltraps
801005cf:	e9 7e fe ff ff       	jmp    80100452 <__alltraps>

801005d4 <vector29>:
.globl vector29
vector29:
  pushl $0
801005d4:	6a 00                	push   $0x0
  pushl $29
801005d6:	6a 1d                	push   $0x1d
  jmp __alltraps
801005d8:	e9 75 fe ff ff       	jmp    80100452 <__alltraps>

801005dd <vector30>:
.globl vector30
vector30:
  pushl $0
801005dd:	6a 00                	push   $0x0
  pushl $30
801005df:	6a 1e                	push   $0x1e
  jmp __alltraps
801005e1:	e9 6c fe ff ff       	jmp    80100452 <__alltraps>

801005e6 <vector31>:
.globl vector31
vector31:
  pushl $0
801005e6:	6a 00                	push   $0x0
  pushl $31
801005e8:	6a 1f                	push   $0x1f
  jmp __alltraps
801005ea:	e9 63 fe ff ff       	jmp    80100452 <__alltraps>

801005ef <vector32>:
.globl vector32
vector32:
  pushl $0
801005ef:	6a 00                	push   $0x0
  pushl $32
801005f1:	6a 20                	push   $0x20
  jmp __alltraps
801005f3:	e9 5a fe ff ff       	jmp    80100452 <__alltraps>

801005f8 <vector33>:
.globl vector33
vector33:
  pushl $0
801005f8:	6a 00                	push   $0x0
  pushl $33
801005fa:	6a 21                	push   $0x21
  jmp __alltraps
801005fc:	e9 51 fe ff ff       	jmp    80100452 <__alltraps>

80100601 <vector34>:
.globl vector34
vector34:
  pushl $0
80100601:	6a 00                	push   $0x0
  pushl $34
80100603:	6a 22                	push   $0x22
  jmp __alltraps
80100605:	e9 48 fe ff ff       	jmp    80100452 <__alltraps>

8010060a <vector35>:
.globl vector35
vector35:
  pushl $0
8010060a:	6a 00                	push   $0x0
  pushl $35
8010060c:	6a 23                	push   $0x23
  jmp __alltraps
8010060e:	e9 3f fe ff ff       	jmp    80100452 <__alltraps>

80100613 <vector36>:
.globl vector36
vector36:
  pushl $0
80100613:	6a 00                	push   $0x0
  pushl $36
80100615:	6a 24                	push   $0x24
  jmp __alltraps
80100617:	e9 36 fe ff ff       	jmp    80100452 <__alltraps>

8010061c <vector37>:
.globl vector37
vector37:
  pushl $0
8010061c:	6a 00                	push   $0x0
  pushl $37
8010061e:	6a 25                	push   $0x25
  jmp __alltraps
80100620:	e9 2d fe ff ff       	jmp    80100452 <__alltraps>

80100625 <vector38>:
.globl vector38
vector38:
  pushl $0
80100625:	6a 00                	push   $0x0
  pushl $38
80100627:	6a 26                	push   $0x26
  jmp __alltraps
80100629:	e9 24 fe ff ff       	jmp    80100452 <__alltraps>

8010062e <vector39>:
.globl vector39
vector39:
  pushl $0
8010062e:	6a 00                	push   $0x0
  pushl $39
80100630:	6a 27                	push   $0x27
  jmp __alltraps
80100632:	e9 1b fe ff ff       	jmp    80100452 <__alltraps>

80100637 <vector40>:
.globl vector40
vector40:
  pushl $0
80100637:	6a 00                	push   $0x0
  pushl $40
80100639:	6a 28                	push   $0x28
  jmp __alltraps
8010063b:	e9 12 fe ff ff       	jmp    80100452 <__alltraps>

80100640 <vector41>:
.globl vector41
vector41:
  pushl $0
80100640:	6a 00                	push   $0x0
  pushl $41
80100642:	6a 29                	push   $0x29
  jmp __alltraps
80100644:	e9 09 fe ff ff       	jmp    80100452 <__alltraps>

80100649 <vector42>:
.globl vector42
vector42:
  pushl $0
80100649:	6a 00                	push   $0x0
  pushl $42
8010064b:	6a 2a                	push   $0x2a
  jmp __alltraps
8010064d:	e9 00 fe ff ff       	jmp    80100452 <__alltraps>

80100652 <vector43>:
.globl vector43
vector43:
  pushl $0
80100652:	6a 00                	push   $0x0
  pushl $43
80100654:	6a 2b                	push   $0x2b
  jmp __alltraps
80100656:	e9 f7 fd ff ff       	jmp    80100452 <__alltraps>

8010065b <vector44>:
.globl vector44
vector44:
  pushl $0
8010065b:	6a 00                	push   $0x0
  pushl $44
8010065d:	6a 2c                	push   $0x2c
  jmp __alltraps
8010065f:	e9 ee fd ff ff       	jmp    80100452 <__alltraps>

80100664 <vector45>:
.globl vector45
vector45:
  pushl $0
80100664:	6a 00                	push   $0x0
  pushl $45
80100666:	6a 2d                	push   $0x2d
  jmp __alltraps
80100668:	e9 e5 fd ff ff       	jmp    80100452 <__alltraps>

8010066d <vector46>:
.globl vector46
vector46:
  pushl $0
8010066d:	6a 00                	push   $0x0
  pushl $46
8010066f:	6a 2e                	push   $0x2e
  jmp __alltraps
80100671:	e9 dc fd ff ff       	jmp    80100452 <__alltraps>

80100676 <vector47>:
.globl vector47
vector47:
  pushl $0
80100676:	6a 00                	push   $0x0
  pushl $47
80100678:	6a 2f                	push   $0x2f
  jmp __alltraps
8010067a:	e9 d3 fd ff ff       	jmp    80100452 <__alltraps>

8010067f <vector48>:
.globl vector48
vector48:
  pushl $0
8010067f:	6a 00                	push   $0x0
  pushl $48
80100681:	6a 30                	push   $0x30
  jmp __alltraps
80100683:	e9 ca fd ff ff       	jmp    80100452 <__alltraps>

80100688 <vector49>:
.globl vector49
vector49:
  pushl $0
80100688:	6a 00                	push   $0x0
  pushl $49
8010068a:	6a 31                	push   $0x31
  jmp __alltraps
8010068c:	e9 c1 fd ff ff       	jmp    80100452 <__alltraps>

80100691 <vector50>:
.globl vector50
vector50:
  pushl $0
80100691:	6a 00                	push   $0x0
  pushl $50
80100693:	6a 32                	push   $0x32
  jmp __alltraps
80100695:	e9 b8 fd ff ff       	jmp    80100452 <__alltraps>

8010069a <vector51>:
.globl vector51
vector51:
  pushl $0
8010069a:	6a 00                	push   $0x0
  pushl $51
8010069c:	6a 33                	push   $0x33
  jmp __alltraps
8010069e:	e9 af fd ff ff       	jmp    80100452 <__alltraps>

801006a3 <vector52>:
.globl vector52
vector52:
  pushl $0
801006a3:	6a 00                	push   $0x0
  pushl $52
801006a5:	6a 34                	push   $0x34
  jmp __alltraps
801006a7:	e9 a6 fd ff ff       	jmp    80100452 <__alltraps>

801006ac <vector53>:
.globl vector53
vector53:
  pushl $0
801006ac:	6a 00                	push   $0x0
  pushl $53
801006ae:	6a 35                	push   $0x35
  jmp __alltraps
801006b0:	e9 9d fd ff ff       	jmp    80100452 <__alltraps>

801006b5 <vector54>:
.globl vector54
vector54:
  pushl $0
801006b5:	6a 00                	push   $0x0
  pushl $54
801006b7:	6a 36                	push   $0x36
  jmp __alltraps
801006b9:	e9 94 fd ff ff       	jmp    80100452 <__alltraps>

801006be <vector55>:
.globl vector55
vector55:
  pushl $0
801006be:	6a 00                	push   $0x0
  pushl $55
801006c0:	6a 37                	push   $0x37
  jmp __alltraps
801006c2:	e9 8b fd ff ff       	jmp    80100452 <__alltraps>

801006c7 <vector56>:
.globl vector56
vector56:
  pushl $0
801006c7:	6a 00                	push   $0x0
  pushl $56
801006c9:	6a 38                	push   $0x38
  jmp __alltraps
801006cb:	e9 82 fd ff ff       	jmp    80100452 <__alltraps>

801006d0 <vector57>:
.globl vector57
vector57:
  pushl $0
801006d0:	6a 00                	push   $0x0
  pushl $57
801006d2:	6a 39                	push   $0x39
  jmp __alltraps
801006d4:	e9 79 fd ff ff       	jmp    80100452 <__alltraps>

801006d9 <vector58>:
.globl vector58
vector58:
  pushl $0
801006d9:	6a 00                	push   $0x0
  pushl $58
801006db:	6a 3a                	push   $0x3a
  jmp __alltraps
801006dd:	e9 70 fd ff ff       	jmp    80100452 <__alltraps>

801006e2 <vector59>:
.globl vector59
vector59:
  pushl $0
801006e2:	6a 00                	push   $0x0
  pushl $59
801006e4:	6a 3b                	push   $0x3b
  jmp __alltraps
801006e6:	e9 67 fd ff ff       	jmp    80100452 <__alltraps>

801006eb <vector60>:
.globl vector60
vector60:
  pushl $0
801006eb:	6a 00                	push   $0x0
  pushl $60
801006ed:	6a 3c                	push   $0x3c
  jmp __alltraps
801006ef:	e9 5e fd ff ff       	jmp    80100452 <__alltraps>

801006f4 <vector61>:
.globl vector61
vector61:
  pushl $0
801006f4:	6a 00                	push   $0x0
  pushl $61
801006f6:	6a 3d                	push   $0x3d
  jmp __alltraps
801006f8:	e9 55 fd ff ff       	jmp    80100452 <__alltraps>

801006fd <vector62>:
.globl vector62
vector62:
  pushl $0
801006fd:	6a 00                	push   $0x0
  pushl $62
801006ff:	6a 3e                	push   $0x3e
  jmp __alltraps
80100701:	e9 4c fd ff ff       	jmp    80100452 <__alltraps>

80100706 <vector63>:
.globl vector63
vector63:
  pushl $0
80100706:	6a 00                	push   $0x0
  pushl $63
80100708:	6a 3f                	push   $0x3f
  jmp __alltraps
8010070a:	e9 43 fd ff ff       	jmp    80100452 <__alltraps>

8010070f <vector64>:
.globl vector64
vector64:
  pushl $0
8010070f:	6a 00                	push   $0x0
  pushl $64
80100711:	6a 40                	push   $0x40
  jmp __alltraps
80100713:	e9 3a fd ff ff       	jmp    80100452 <__alltraps>

80100718 <vector65>:
.globl vector65
vector65:
  pushl $0
80100718:	6a 00                	push   $0x0
  pushl $65
8010071a:	6a 41                	push   $0x41
  jmp __alltraps
8010071c:	e9 31 fd ff ff       	jmp    80100452 <__alltraps>

80100721 <vector66>:
.globl vector66
vector66:
  pushl $0
80100721:	6a 00                	push   $0x0
  pushl $66
80100723:	6a 42                	push   $0x42
  jmp __alltraps
80100725:	e9 28 fd ff ff       	jmp    80100452 <__alltraps>

8010072a <vector67>:
.globl vector67
vector67:
  pushl $0
8010072a:	6a 00                	push   $0x0
  pushl $67
8010072c:	6a 43                	push   $0x43
  jmp __alltraps
8010072e:	e9 1f fd ff ff       	jmp    80100452 <__alltraps>

80100733 <vector68>:
.globl vector68
vector68:
  pushl $0
80100733:	6a 00                	push   $0x0
  pushl $68
80100735:	6a 44                	push   $0x44
  jmp __alltraps
80100737:	e9 16 fd ff ff       	jmp    80100452 <__alltraps>

8010073c <vector69>:
.globl vector69
vector69:
  pushl $0
8010073c:	6a 00                	push   $0x0
  pushl $69
8010073e:	6a 45                	push   $0x45
  jmp __alltraps
80100740:	e9 0d fd ff ff       	jmp    80100452 <__alltraps>

80100745 <vector70>:
.globl vector70
vector70:
  pushl $0
80100745:	6a 00                	push   $0x0
  pushl $70
80100747:	6a 46                	push   $0x46
  jmp __alltraps
80100749:	e9 04 fd ff ff       	jmp    80100452 <__alltraps>

8010074e <vector71>:
.globl vector71
vector71:
  pushl $0
8010074e:	6a 00                	push   $0x0
  pushl $71
80100750:	6a 47                	push   $0x47
  jmp __alltraps
80100752:	e9 fb fc ff ff       	jmp    80100452 <__alltraps>

80100757 <vector72>:
.globl vector72
vector72:
  pushl $0
80100757:	6a 00                	push   $0x0
  pushl $72
80100759:	6a 48                	push   $0x48
  jmp __alltraps
8010075b:	e9 f2 fc ff ff       	jmp    80100452 <__alltraps>

80100760 <vector73>:
.globl vector73
vector73:
  pushl $0
80100760:	6a 00                	push   $0x0
  pushl $73
80100762:	6a 49                	push   $0x49
  jmp __alltraps
80100764:	e9 e9 fc ff ff       	jmp    80100452 <__alltraps>

80100769 <vector74>:
.globl vector74
vector74:
  pushl $0
80100769:	6a 00                	push   $0x0
  pushl $74
8010076b:	6a 4a                	push   $0x4a
  jmp __alltraps
8010076d:	e9 e0 fc ff ff       	jmp    80100452 <__alltraps>

80100772 <vector75>:
.globl vector75
vector75:
  pushl $0
80100772:	6a 00                	push   $0x0
  pushl $75
80100774:	6a 4b                	push   $0x4b
  jmp __alltraps
80100776:	e9 d7 fc ff ff       	jmp    80100452 <__alltraps>

8010077b <vector76>:
.globl vector76
vector76:
  pushl $0
8010077b:	6a 00                	push   $0x0
  pushl $76
8010077d:	6a 4c                	push   $0x4c
  jmp __alltraps
8010077f:	e9 ce fc ff ff       	jmp    80100452 <__alltraps>

80100784 <vector77>:
.globl vector77
vector77:
  pushl $0
80100784:	6a 00                	push   $0x0
  pushl $77
80100786:	6a 4d                	push   $0x4d
  jmp __alltraps
80100788:	e9 c5 fc ff ff       	jmp    80100452 <__alltraps>

8010078d <vector78>:
.globl vector78
vector78:
  pushl $0
8010078d:	6a 00                	push   $0x0
  pushl $78
8010078f:	6a 4e                	push   $0x4e
  jmp __alltraps
80100791:	e9 bc fc ff ff       	jmp    80100452 <__alltraps>

80100796 <vector79>:
.globl vector79
vector79:
  pushl $0
80100796:	6a 00                	push   $0x0
  pushl $79
80100798:	6a 4f                	push   $0x4f
  jmp __alltraps
8010079a:	e9 b3 fc ff ff       	jmp    80100452 <__alltraps>

8010079f <vector80>:
.globl vector80
vector80:
  pushl $0
8010079f:	6a 00                	push   $0x0
  pushl $80
801007a1:	6a 50                	push   $0x50
  jmp __alltraps
801007a3:	e9 aa fc ff ff       	jmp    80100452 <__alltraps>

801007a8 <vector81>:
.globl vector81
vector81:
  pushl $0
801007a8:	6a 00                	push   $0x0
  pushl $81
801007aa:	6a 51                	push   $0x51
  jmp __alltraps
801007ac:	e9 a1 fc ff ff       	jmp    80100452 <__alltraps>

801007b1 <vector82>:
.globl vector82
vector82:
  pushl $0
801007b1:	6a 00                	push   $0x0
  pushl $82
801007b3:	6a 52                	push   $0x52
  jmp __alltraps
801007b5:	e9 98 fc ff ff       	jmp    80100452 <__alltraps>

801007ba <vector83>:
.globl vector83
vector83:
  pushl $0
801007ba:	6a 00                	push   $0x0
  pushl $83
801007bc:	6a 53                	push   $0x53
  jmp __alltraps
801007be:	e9 8f fc ff ff       	jmp    80100452 <__alltraps>

801007c3 <vector84>:
.globl vector84
vector84:
  pushl $0
801007c3:	6a 00                	push   $0x0
  pushl $84
801007c5:	6a 54                	push   $0x54
  jmp __alltraps
801007c7:	e9 86 fc ff ff       	jmp    80100452 <__alltraps>

801007cc <vector85>:
.globl vector85
vector85:
  pushl $0
801007cc:	6a 00                	push   $0x0
  pushl $85
801007ce:	6a 55                	push   $0x55
  jmp __alltraps
801007d0:	e9 7d fc ff ff       	jmp    80100452 <__alltraps>

801007d5 <vector86>:
.globl vector86
vector86:
  pushl $0
801007d5:	6a 00                	push   $0x0
  pushl $86
801007d7:	6a 56                	push   $0x56
  jmp __alltraps
801007d9:	e9 74 fc ff ff       	jmp    80100452 <__alltraps>

801007de <vector87>:
.globl vector87
vector87:
  pushl $0
801007de:	6a 00                	push   $0x0
  pushl $87
801007e0:	6a 57                	push   $0x57
  jmp __alltraps
801007e2:	e9 6b fc ff ff       	jmp    80100452 <__alltraps>

801007e7 <vector88>:
.globl vector88
vector88:
  pushl $0
801007e7:	6a 00                	push   $0x0
  pushl $88
801007e9:	6a 58                	push   $0x58
  jmp __alltraps
801007eb:	e9 62 fc ff ff       	jmp    80100452 <__alltraps>

801007f0 <vector89>:
.globl vector89
vector89:
  pushl $0
801007f0:	6a 00                	push   $0x0
  pushl $89
801007f2:	6a 59                	push   $0x59
  jmp __alltraps
801007f4:	e9 59 fc ff ff       	jmp    80100452 <__alltraps>

801007f9 <vector90>:
.globl vector90
vector90:
  pushl $0
801007f9:	6a 00                	push   $0x0
  pushl $90
801007fb:	6a 5a                	push   $0x5a
  jmp __alltraps
801007fd:	e9 50 fc ff ff       	jmp    80100452 <__alltraps>

80100802 <vector91>:
.globl vector91
vector91:
  pushl $0
80100802:	6a 00                	push   $0x0
  pushl $91
80100804:	6a 5b                	push   $0x5b
  jmp __alltraps
80100806:	e9 47 fc ff ff       	jmp    80100452 <__alltraps>

8010080b <vector92>:
.globl vector92
vector92:
  pushl $0
8010080b:	6a 00                	push   $0x0
  pushl $92
8010080d:	6a 5c                	push   $0x5c
  jmp __alltraps
8010080f:	e9 3e fc ff ff       	jmp    80100452 <__alltraps>

80100814 <vector93>:
.globl vector93
vector93:
  pushl $0
80100814:	6a 00                	push   $0x0
  pushl $93
80100816:	6a 5d                	push   $0x5d
  jmp __alltraps
80100818:	e9 35 fc ff ff       	jmp    80100452 <__alltraps>

8010081d <vector94>:
.globl vector94
vector94:
  pushl $0
8010081d:	6a 00                	push   $0x0
  pushl $94
8010081f:	6a 5e                	push   $0x5e
  jmp __alltraps
80100821:	e9 2c fc ff ff       	jmp    80100452 <__alltraps>

80100826 <vector95>:
.globl vector95
vector95:
  pushl $0
80100826:	6a 00                	push   $0x0
  pushl $95
80100828:	6a 5f                	push   $0x5f
  jmp __alltraps
8010082a:	e9 23 fc ff ff       	jmp    80100452 <__alltraps>

8010082f <vector96>:
.globl vector96
vector96:
  pushl $0
8010082f:	6a 00                	push   $0x0
  pushl $96
80100831:	6a 60                	push   $0x60
  jmp __alltraps
80100833:	e9 1a fc ff ff       	jmp    80100452 <__alltraps>

80100838 <vector97>:
.globl vector97
vector97:
  pushl $0
80100838:	6a 00                	push   $0x0
  pushl $97
8010083a:	6a 61                	push   $0x61
  jmp __alltraps
8010083c:	e9 11 fc ff ff       	jmp    80100452 <__alltraps>

80100841 <vector98>:
.globl vector98
vector98:
  pushl $0
80100841:	6a 00                	push   $0x0
  pushl $98
80100843:	6a 62                	push   $0x62
  jmp __alltraps
80100845:	e9 08 fc ff ff       	jmp    80100452 <__alltraps>

8010084a <vector99>:
.globl vector99
vector99:
  pushl $0
8010084a:	6a 00                	push   $0x0
  pushl $99
8010084c:	6a 63                	push   $0x63
  jmp __alltraps
8010084e:	e9 ff fb ff ff       	jmp    80100452 <__alltraps>

80100853 <vector100>:
.globl vector100
vector100:
  pushl $0
80100853:	6a 00                	push   $0x0
  pushl $100
80100855:	6a 64                	push   $0x64
  jmp __alltraps
80100857:	e9 f6 fb ff ff       	jmp    80100452 <__alltraps>

8010085c <vector101>:
.globl vector101
vector101:
  pushl $0
8010085c:	6a 00                	push   $0x0
  pushl $101
8010085e:	6a 65                	push   $0x65
  jmp __alltraps
80100860:	e9 ed fb ff ff       	jmp    80100452 <__alltraps>

80100865 <vector102>:
.globl vector102
vector102:
  pushl $0
80100865:	6a 00                	push   $0x0
  pushl $102
80100867:	6a 66                	push   $0x66
  jmp __alltraps
80100869:	e9 e4 fb ff ff       	jmp    80100452 <__alltraps>

8010086e <vector103>:
.globl vector103
vector103:
  pushl $0
8010086e:	6a 00                	push   $0x0
  pushl $103
80100870:	6a 67                	push   $0x67
  jmp __alltraps
80100872:	e9 db fb ff ff       	jmp    80100452 <__alltraps>

80100877 <vector104>:
.globl vector104
vector104:
  pushl $0
80100877:	6a 00                	push   $0x0
  pushl $104
80100879:	6a 68                	push   $0x68
  jmp __alltraps
8010087b:	e9 d2 fb ff ff       	jmp    80100452 <__alltraps>

80100880 <vector105>:
.globl vector105
vector105:
  pushl $0
80100880:	6a 00                	push   $0x0
  pushl $105
80100882:	6a 69                	push   $0x69
  jmp __alltraps
80100884:	e9 c9 fb ff ff       	jmp    80100452 <__alltraps>

80100889 <vector106>:
.globl vector106
vector106:
  pushl $0
80100889:	6a 00                	push   $0x0
  pushl $106
8010088b:	6a 6a                	push   $0x6a
  jmp __alltraps
8010088d:	e9 c0 fb ff ff       	jmp    80100452 <__alltraps>

80100892 <vector107>:
.globl vector107
vector107:
  pushl $0
80100892:	6a 00                	push   $0x0
  pushl $107
80100894:	6a 6b                	push   $0x6b
  jmp __alltraps
80100896:	e9 b7 fb ff ff       	jmp    80100452 <__alltraps>

8010089b <vector108>:
.globl vector108
vector108:
  pushl $0
8010089b:	6a 00                	push   $0x0
  pushl $108
8010089d:	6a 6c                	push   $0x6c
  jmp __alltraps
8010089f:	e9 ae fb ff ff       	jmp    80100452 <__alltraps>

801008a4 <vector109>:
.globl vector109
vector109:
  pushl $0
801008a4:	6a 00                	push   $0x0
  pushl $109
801008a6:	6a 6d                	push   $0x6d
  jmp __alltraps
801008a8:	e9 a5 fb ff ff       	jmp    80100452 <__alltraps>

801008ad <vector110>:
.globl vector110
vector110:
  pushl $0
801008ad:	6a 00                	push   $0x0
  pushl $110
801008af:	6a 6e                	push   $0x6e
  jmp __alltraps
801008b1:	e9 9c fb ff ff       	jmp    80100452 <__alltraps>

801008b6 <vector111>:
.globl vector111
vector111:
  pushl $0
801008b6:	6a 00                	push   $0x0
  pushl $111
801008b8:	6a 6f                	push   $0x6f
  jmp __alltraps
801008ba:	e9 93 fb ff ff       	jmp    80100452 <__alltraps>

801008bf <vector112>:
.globl vector112
vector112:
  pushl $0
801008bf:	6a 00                	push   $0x0
  pushl $112
801008c1:	6a 70                	push   $0x70
  jmp __alltraps
801008c3:	e9 8a fb ff ff       	jmp    80100452 <__alltraps>

801008c8 <vector113>:
.globl vector113
vector113:
  pushl $0
801008c8:	6a 00                	push   $0x0
  pushl $113
801008ca:	6a 71                	push   $0x71
  jmp __alltraps
801008cc:	e9 81 fb ff ff       	jmp    80100452 <__alltraps>

801008d1 <vector114>:
.globl vector114
vector114:
  pushl $0
801008d1:	6a 00                	push   $0x0
  pushl $114
801008d3:	6a 72                	push   $0x72
  jmp __alltraps
801008d5:	e9 78 fb ff ff       	jmp    80100452 <__alltraps>

801008da <vector115>:
.globl vector115
vector115:
  pushl $0
801008da:	6a 00                	push   $0x0
  pushl $115
801008dc:	6a 73                	push   $0x73
  jmp __alltraps
801008de:	e9 6f fb ff ff       	jmp    80100452 <__alltraps>

801008e3 <vector116>:
.globl vector116
vector116:
  pushl $0
801008e3:	6a 00                	push   $0x0
  pushl $116
801008e5:	6a 74                	push   $0x74
  jmp __alltraps
801008e7:	e9 66 fb ff ff       	jmp    80100452 <__alltraps>

801008ec <vector117>:
.globl vector117
vector117:
  pushl $0
801008ec:	6a 00                	push   $0x0
  pushl $117
801008ee:	6a 75                	push   $0x75
  jmp __alltraps
801008f0:	e9 5d fb ff ff       	jmp    80100452 <__alltraps>

801008f5 <vector118>:
.globl vector118
vector118:
  pushl $0
801008f5:	6a 00                	push   $0x0
  pushl $118
801008f7:	6a 76                	push   $0x76
  jmp __alltraps
801008f9:	e9 54 fb ff ff       	jmp    80100452 <__alltraps>

801008fe <vector119>:
.globl vector119
vector119:
  pushl $0
801008fe:	6a 00                	push   $0x0
  pushl $119
80100900:	6a 77                	push   $0x77
  jmp __alltraps
80100902:	e9 4b fb ff ff       	jmp    80100452 <__alltraps>

80100907 <vector120>:
.globl vector120
vector120:
  pushl $0
80100907:	6a 00                	push   $0x0
  pushl $120
80100909:	6a 78                	push   $0x78
  jmp __alltraps
8010090b:	e9 42 fb ff ff       	jmp    80100452 <__alltraps>

80100910 <vector121>:
.globl vector121
vector121:
  pushl $0
80100910:	6a 00                	push   $0x0
  pushl $121
80100912:	6a 79                	push   $0x79
  jmp __alltraps
80100914:	e9 39 fb ff ff       	jmp    80100452 <__alltraps>

80100919 <vector122>:
.globl vector122
vector122:
  pushl $0
80100919:	6a 00                	push   $0x0
  pushl $122
8010091b:	6a 7a                	push   $0x7a
  jmp __alltraps
8010091d:	e9 30 fb ff ff       	jmp    80100452 <__alltraps>

80100922 <vector123>:
.globl vector123
vector123:
  pushl $0
80100922:	6a 00                	push   $0x0
  pushl $123
80100924:	6a 7b                	push   $0x7b
  jmp __alltraps
80100926:	e9 27 fb ff ff       	jmp    80100452 <__alltraps>

8010092b <vector124>:
.globl vector124
vector124:
  pushl $0
8010092b:	6a 00                	push   $0x0
  pushl $124
8010092d:	6a 7c                	push   $0x7c
  jmp __alltraps
8010092f:	e9 1e fb ff ff       	jmp    80100452 <__alltraps>

80100934 <vector125>:
.globl vector125
vector125:
  pushl $0
80100934:	6a 00                	push   $0x0
  pushl $125
80100936:	6a 7d                	push   $0x7d
  jmp __alltraps
80100938:	e9 15 fb ff ff       	jmp    80100452 <__alltraps>

8010093d <vector126>:
.globl vector126
vector126:
  pushl $0
8010093d:	6a 00                	push   $0x0
  pushl $126
8010093f:	6a 7e                	push   $0x7e
  jmp __alltraps
80100941:	e9 0c fb ff ff       	jmp    80100452 <__alltraps>

80100946 <vector127>:
.globl vector127
vector127:
  pushl $0
80100946:	6a 00                	push   $0x0
  pushl $127
80100948:	6a 7f                	push   $0x7f
  jmp __alltraps
8010094a:	e9 03 fb ff ff       	jmp    80100452 <__alltraps>

8010094f <vector128>:
.globl vector128
vector128:
  pushl $0
8010094f:	6a 00                	push   $0x0
  pushl $128
80100951:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
80100956:	e9 f7 fa ff ff       	jmp    80100452 <__alltraps>

8010095b <vector129>:
.globl vector129
vector129:
  pushl $0
8010095b:	6a 00                	push   $0x0
  pushl $129
8010095d:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
80100962:	e9 eb fa ff ff       	jmp    80100452 <__alltraps>

80100967 <vector130>:
.globl vector130
vector130:
  pushl $0
80100967:	6a 00                	push   $0x0
  pushl $130
80100969:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
8010096e:	e9 df fa ff ff       	jmp    80100452 <__alltraps>

80100973 <vector131>:
.globl vector131
vector131:
  pushl $0
80100973:	6a 00                	push   $0x0
  pushl $131
80100975:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
8010097a:	e9 d3 fa ff ff       	jmp    80100452 <__alltraps>

8010097f <vector132>:
.globl vector132
vector132:
  pushl $0
8010097f:	6a 00                	push   $0x0
  pushl $132
80100981:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
80100986:	e9 c7 fa ff ff       	jmp    80100452 <__alltraps>

8010098b <vector133>:
.globl vector133
vector133:
  pushl $0
8010098b:	6a 00                	push   $0x0
  pushl $133
8010098d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
80100992:	e9 bb fa ff ff       	jmp    80100452 <__alltraps>

80100997 <vector134>:
.globl vector134
vector134:
  pushl $0
80100997:	6a 00                	push   $0x0
  pushl $134
80100999:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
8010099e:	e9 af fa ff ff       	jmp    80100452 <__alltraps>

801009a3 <vector135>:
.globl vector135
vector135:
  pushl $0
801009a3:	6a 00                	push   $0x0
  pushl $135
801009a5:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
801009aa:	e9 a3 fa ff ff       	jmp    80100452 <__alltraps>

801009af <vector136>:
.globl vector136
vector136:
  pushl $0
801009af:	6a 00                	push   $0x0
  pushl $136
801009b1:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
801009b6:	e9 97 fa ff ff       	jmp    80100452 <__alltraps>

801009bb <vector137>:
.globl vector137
vector137:
  pushl $0
801009bb:	6a 00                	push   $0x0
  pushl $137
801009bd:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
801009c2:	e9 8b fa ff ff       	jmp    80100452 <__alltraps>

801009c7 <vector138>:
.globl vector138
vector138:
  pushl $0
801009c7:	6a 00                	push   $0x0
  pushl $138
801009c9:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
801009ce:	e9 7f fa ff ff       	jmp    80100452 <__alltraps>

801009d3 <vector139>:
.globl vector139
vector139:
  pushl $0
801009d3:	6a 00                	push   $0x0
  pushl $139
801009d5:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
801009da:	e9 73 fa ff ff       	jmp    80100452 <__alltraps>

801009df <vector140>:
.globl vector140
vector140:
  pushl $0
801009df:	6a 00                	push   $0x0
  pushl $140
801009e1:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
801009e6:	e9 67 fa ff ff       	jmp    80100452 <__alltraps>

801009eb <vector141>:
.globl vector141
vector141:
  pushl $0
801009eb:	6a 00                	push   $0x0
  pushl $141
801009ed:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
801009f2:	e9 5b fa ff ff       	jmp    80100452 <__alltraps>

801009f7 <vector142>:
.globl vector142
vector142:
  pushl $0
801009f7:	6a 00                	push   $0x0
  pushl $142
801009f9:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
801009fe:	e9 4f fa ff ff       	jmp    80100452 <__alltraps>

80100a03 <vector143>:
.globl vector143
vector143:
  pushl $0
80100a03:	6a 00                	push   $0x0
  pushl $143
80100a05:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
80100a0a:	e9 43 fa ff ff       	jmp    80100452 <__alltraps>

80100a0f <vector144>:
.globl vector144
vector144:
  pushl $0
80100a0f:	6a 00                	push   $0x0
  pushl $144
80100a11:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
80100a16:	e9 37 fa ff ff       	jmp    80100452 <__alltraps>

80100a1b <vector145>:
.globl vector145
vector145:
  pushl $0
80100a1b:	6a 00                	push   $0x0
  pushl $145
80100a1d:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
80100a22:	e9 2b fa ff ff       	jmp    80100452 <__alltraps>

80100a27 <vector146>:
.globl vector146
vector146:
  pushl $0
80100a27:	6a 00                	push   $0x0
  pushl $146
80100a29:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
80100a2e:	e9 1f fa ff ff       	jmp    80100452 <__alltraps>

80100a33 <vector147>:
.globl vector147
vector147:
  pushl $0
80100a33:	6a 00                	push   $0x0
  pushl $147
80100a35:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
80100a3a:	e9 13 fa ff ff       	jmp    80100452 <__alltraps>

80100a3f <vector148>:
.globl vector148
vector148:
  pushl $0
80100a3f:	6a 00                	push   $0x0
  pushl $148
80100a41:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
80100a46:	e9 07 fa ff ff       	jmp    80100452 <__alltraps>

80100a4b <vector149>:
.globl vector149
vector149:
  pushl $0
80100a4b:	6a 00                	push   $0x0
  pushl $149
80100a4d:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
80100a52:	e9 fb f9 ff ff       	jmp    80100452 <__alltraps>

80100a57 <vector150>:
.globl vector150
vector150:
  pushl $0
80100a57:	6a 00                	push   $0x0
  pushl $150
80100a59:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
80100a5e:	e9 ef f9 ff ff       	jmp    80100452 <__alltraps>

80100a63 <vector151>:
.globl vector151
vector151:
  pushl $0
80100a63:	6a 00                	push   $0x0
  pushl $151
80100a65:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
80100a6a:	e9 e3 f9 ff ff       	jmp    80100452 <__alltraps>

80100a6f <vector152>:
.globl vector152
vector152:
  pushl $0
80100a6f:	6a 00                	push   $0x0
  pushl $152
80100a71:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
80100a76:	e9 d7 f9 ff ff       	jmp    80100452 <__alltraps>

80100a7b <vector153>:
.globl vector153
vector153:
  pushl $0
80100a7b:	6a 00                	push   $0x0
  pushl $153
80100a7d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
80100a82:	e9 cb f9 ff ff       	jmp    80100452 <__alltraps>

80100a87 <vector154>:
.globl vector154
vector154:
  pushl $0
80100a87:	6a 00                	push   $0x0
  pushl $154
80100a89:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
80100a8e:	e9 bf f9 ff ff       	jmp    80100452 <__alltraps>

80100a93 <vector155>:
.globl vector155
vector155:
  pushl $0
80100a93:	6a 00                	push   $0x0
  pushl $155
80100a95:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
80100a9a:	e9 b3 f9 ff ff       	jmp    80100452 <__alltraps>

80100a9f <vector156>:
.globl vector156
vector156:
  pushl $0
80100a9f:	6a 00                	push   $0x0
  pushl $156
80100aa1:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
80100aa6:	e9 a7 f9 ff ff       	jmp    80100452 <__alltraps>

80100aab <vector157>:
.globl vector157
vector157:
  pushl $0
80100aab:	6a 00                	push   $0x0
  pushl $157
80100aad:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
80100ab2:	e9 9b f9 ff ff       	jmp    80100452 <__alltraps>

80100ab7 <vector158>:
.globl vector158
vector158:
  pushl $0
80100ab7:	6a 00                	push   $0x0
  pushl $158
80100ab9:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
80100abe:	e9 8f f9 ff ff       	jmp    80100452 <__alltraps>

80100ac3 <vector159>:
.globl vector159
vector159:
  pushl $0
80100ac3:	6a 00                	push   $0x0
  pushl $159
80100ac5:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
80100aca:	e9 83 f9 ff ff       	jmp    80100452 <__alltraps>

80100acf <vector160>:
.globl vector160
vector160:
  pushl $0
80100acf:	6a 00                	push   $0x0
  pushl $160
80100ad1:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
80100ad6:	e9 77 f9 ff ff       	jmp    80100452 <__alltraps>

80100adb <vector161>:
.globl vector161
vector161:
  pushl $0
80100adb:	6a 00                	push   $0x0
  pushl $161
80100add:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
80100ae2:	e9 6b f9 ff ff       	jmp    80100452 <__alltraps>

80100ae7 <vector162>:
.globl vector162
vector162:
  pushl $0
80100ae7:	6a 00                	push   $0x0
  pushl $162
80100ae9:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
80100aee:	e9 5f f9 ff ff       	jmp    80100452 <__alltraps>

80100af3 <vector163>:
.globl vector163
vector163:
  pushl $0
80100af3:	6a 00                	push   $0x0
  pushl $163
80100af5:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
80100afa:	e9 53 f9 ff ff       	jmp    80100452 <__alltraps>

80100aff <vector164>:
.globl vector164
vector164:
  pushl $0
80100aff:	6a 00                	push   $0x0
  pushl $164
80100b01:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
80100b06:	e9 47 f9 ff ff       	jmp    80100452 <__alltraps>

80100b0b <vector165>:
.globl vector165
vector165:
  pushl $0
80100b0b:	6a 00                	push   $0x0
  pushl $165
80100b0d:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
80100b12:	e9 3b f9 ff ff       	jmp    80100452 <__alltraps>

80100b17 <vector166>:
.globl vector166
vector166:
  pushl $0
80100b17:	6a 00                	push   $0x0
  pushl $166
80100b19:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
80100b1e:	e9 2f f9 ff ff       	jmp    80100452 <__alltraps>

80100b23 <vector167>:
.globl vector167
vector167:
  pushl $0
80100b23:	6a 00                	push   $0x0
  pushl $167
80100b25:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
80100b2a:	e9 23 f9 ff ff       	jmp    80100452 <__alltraps>

80100b2f <vector168>:
.globl vector168
vector168:
  pushl $0
80100b2f:	6a 00                	push   $0x0
  pushl $168
80100b31:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
80100b36:	e9 17 f9 ff ff       	jmp    80100452 <__alltraps>

80100b3b <vector169>:
.globl vector169
vector169:
  pushl $0
80100b3b:	6a 00                	push   $0x0
  pushl $169
80100b3d:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
80100b42:	e9 0b f9 ff ff       	jmp    80100452 <__alltraps>

80100b47 <vector170>:
.globl vector170
vector170:
  pushl $0
80100b47:	6a 00                	push   $0x0
  pushl $170
80100b49:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
80100b4e:	e9 ff f8 ff ff       	jmp    80100452 <__alltraps>

80100b53 <vector171>:
.globl vector171
vector171:
  pushl $0
80100b53:	6a 00                	push   $0x0
  pushl $171
80100b55:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
80100b5a:	e9 f3 f8 ff ff       	jmp    80100452 <__alltraps>

80100b5f <vector172>:
.globl vector172
vector172:
  pushl $0
80100b5f:	6a 00                	push   $0x0
  pushl $172
80100b61:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
80100b66:	e9 e7 f8 ff ff       	jmp    80100452 <__alltraps>

80100b6b <vector173>:
.globl vector173
vector173:
  pushl $0
80100b6b:	6a 00                	push   $0x0
  pushl $173
80100b6d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
80100b72:	e9 db f8 ff ff       	jmp    80100452 <__alltraps>

80100b77 <vector174>:
.globl vector174
vector174:
  pushl $0
80100b77:	6a 00                	push   $0x0
  pushl $174
80100b79:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
80100b7e:	e9 cf f8 ff ff       	jmp    80100452 <__alltraps>

80100b83 <vector175>:
.globl vector175
vector175:
  pushl $0
80100b83:	6a 00                	push   $0x0
  pushl $175
80100b85:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
80100b8a:	e9 c3 f8 ff ff       	jmp    80100452 <__alltraps>

80100b8f <vector176>:
.globl vector176
vector176:
  pushl $0
80100b8f:	6a 00                	push   $0x0
  pushl $176
80100b91:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
80100b96:	e9 b7 f8 ff ff       	jmp    80100452 <__alltraps>

80100b9b <vector177>:
.globl vector177
vector177:
  pushl $0
80100b9b:	6a 00                	push   $0x0
  pushl $177
80100b9d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
80100ba2:	e9 ab f8 ff ff       	jmp    80100452 <__alltraps>

80100ba7 <vector178>:
.globl vector178
vector178:
  pushl $0
80100ba7:	6a 00                	push   $0x0
  pushl $178
80100ba9:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
80100bae:	e9 9f f8 ff ff       	jmp    80100452 <__alltraps>

80100bb3 <vector179>:
.globl vector179
vector179:
  pushl $0
80100bb3:	6a 00                	push   $0x0
  pushl $179
80100bb5:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
80100bba:	e9 93 f8 ff ff       	jmp    80100452 <__alltraps>

80100bbf <vector180>:
.globl vector180
vector180:
  pushl $0
80100bbf:	6a 00                	push   $0x0
  pushl $180
80100bc1:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
80100bc6:	e9 87 f8 ff ff       	jmp    80100452 <__alltraps>

80100bcb <vector181>:
.globl vector181
vector181:
  pushl $0
80100bcb:	6a 00                	push   $0x0
  pushl $181
80100bcd:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
80100bd2:	e9 7b f8 ff ff       	jmp    80100452 <__alltraps>

80100bd7 <vector182>:
.globl vector182
vector182:
  pushl $0
80100bd7:	6a 00                	push   $0x0
  pushl $182
80100bd9:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
80100bde:	e9 6f f8 ff ff       	jmp    80100452 <__alltraps>

80100be3 <vector183>:
.globl vector183
vector183:
  pushl $0
80100be3:	6a 00                	push   $0x0
  pushl $183
80100be5:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
80100bea:	e9 63 f8 ff ff       	jmp    80100452 <__alltraps>

80100bef <vector184>:
.globl vector184
vector184:
  pushl $0
80100bef:	6a 00                	push   $0x0
  pushl $184
80100bf1:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
80100bf6:	e9 57 f8 ff ff       	jmp    80100452 <__alltraps>

80100bfb <vector185>:
.globl vector185
vector185:
  pushl $0
80100bfb:	6a 00                	push   $0x0
  pushl $185
80100bfd:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
80100c02:	e9 4b f8 ff ff       	jmp    80100452 <__alltraps>

80100c07 <vector186>:
.globl vector186
vector186:
  pushl $0
80100c07:	6a 00                	push   $0x0
  pushl $186
80100c09:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
80100c0e:	e9 3f f8 ff ff       	jmp    80100452 <__alltraps>

80100c13 <vector187>:
.globl vector187
vector187:
  pushl $0
80100c13:	6a 00                	push   $0x0
  pushl $187
80100c15:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
80100c1a:	e9 33 f8 ff ff       	jmp    80100452 <__alltraps>

80100c1f <vector188>:
.globl vector188
vector188:
  pushl $0
80100c1f:	6a 00                	push   $0x0
  pushl $188
80100c21:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
80100c26:	e9 27 f8 ff ff       	jmp    80100452 <__alltraps>

80100c2b <vector189>:
.globl vector189
vector189:
  pushl $0
80100c2b:	6a 00                	push   $0x0
  pushl $189
80100c2d:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
80100c32:	e9 1b f8 ff ff       	jmp    80100452 <__alltraps>

80100c37 <vector190>:
.globl vector190
vector190:
  pushl $0
80100c37:	6a 00                	push   $0x0
  pushl $190
80100c39:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
80100c3e:	e9 0f f8 ff ff       	jmp    80100452 <__alltraps>

80100c43 <vector191>:
.globl vector191
vector191:
  pushl $0
80100c43:	6a 00                	push   $0x0
  pushl $191
80100c45:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
80100c4a:	e9 03 f8 ff ff       	jmp    80100452 <__alltraps>

80100c4f <vector192>:
.globl vector192
vector192:
  pushl $0
80100c4f:	6a 00                	push   $0x0
  pushl $192
80100c51:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
80100c56:	e9 f7 f7 ff ff       	jmp    80100452 <__alltraps>

80100c5b <vector193>:
.globl vector193
vector193:
  pushl $0
80100c5b:	6a 00                	push   $0x0
  pushl $193
80100c5d:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
80100c62:	e9 eb f7 ff ff       	jmp    80100452 <__alltraps>

80100c67 <vector194>:
.globl vector194
vector194:
  pushl $0
80100c67:	6a 00                	push   $0x0
  pushl $194
80100c69:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
80100c6e:	e9 df f7 ff ff       	jmp    80100452 <__alltraps>

80100c73 <vector195>:
.globl vector195
vector195:
  pushl $0
80100c73:	6a 00                	push   $0x0
  pushl $195
80100c75:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
80100c7a:	e9 d3 f7 ff ff       	jmp    80100452 <__alltraps>

80100c7f <vector196>:
.globl vector196
vector196:
  pushl $0
80100c7f:	6a 00                	push   $0x0
  pushl $196
80100c81:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
80100c86:	e9 c7 f7 ff ff       	jmp    80100452 <__alltraps>

80100c8b <vector197>:
.globl vector197
vector197:
  pushl $0
80100c8b:	6a 00                	push   $0x0
  pushl $197
80100c8d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
80100c92:	e9 bb f7 ff ff       	jmp    80100452 <__alltraps>

80100c97 <vector198>:
.globl vector198
vector198:
  pushl $0
80100c97:	6a 00                	push   $0x0
  pushl $198
80100c99:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
80100c9e:	e9 af f7 ff ff       	jmp    80100452 <__alltraps>

80100ca3 <vector199>:
.globl vector199
vector199:
  pushl $0
80100ca3:	6a 00                	push   $0x0
  pushl $199
80100ca5:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
80100caa:	e9 a3 f7 ff ff       	jmp    80100452 <__alltraps>

80100caf <vector200>:
.globl vector200
vector200:
  pushl $0
80100caf:	6a 00                	push   $0x0
  pushl $200
80100cb1:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
80100cb6:	e9 97 f7 ff ff       	jmp    80100452 <__alltraps>

80100cbb <vector201>:
.globl vector201
vector201:
  pushl $0
80100cbb:	6a 00                	push   $0x0
  pushl $201
80100cbd:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
80100cc2:	e9 8b f7 ff ff       	jmp    80100452 <__alltraps>

80100cc7 <vector202>:
.globl vector202
vector202:
  pushl $0
80100cc7:	6a 00                	push   $0x0
  pushl $202
80100cc9:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
80100cce:	e9 7f f7 ff ff       	jmp    80100452 <__alltraps>

80100cd3 <vector203>:
.globl vector203
vector203:
  pushl $0
80100cd3:	6a 00                	push   $0x0
  pushl $203
80100cd5:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
80100cda:	e9 73 f7 ff ff       	jmp    80100452 <__alltraps>

80100cdf <vector204>:
.globl vector204
vector204:
  pushl $0
80100cdf:	6a 00                	push   $0x0
  pushl $204
80100ce1:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
80100ce6:	e9 67 f7 ff ff       	jmp    80100452 <__alltraps>

80100ceb <vector205>:
.globl vector205
vector205:
  pushl $0
80100ceb:	6a 00                	push   $0x0
  pushl $205
80100ced:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
80100cf2:	e9 5b f7 ff ff       	jmp    80100452 <__alltraps>

80100cf7 <vector206>:
.globl vector206
vector206:
  pushl $0
80100cf7:	6a 00                	push   $0x0
  pushl $206
80100cf9:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
80100cfe:	e9 4f f7 ff ff       	jmp    80100452 <__alltraps>

80100d03 <vector207>:
.globl vector207
vector207:
  pushl $0
80100d03:	6a 00                	push   $0x0
  pushl $207
80100d05:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
80100d0a:	e9 43 f7 ff ff       	jmp    80100452 <__alltraps>

80100d0f <vector208>:
.globl vector208
vector208:
  pushl $0
80100d0f:	6a 00                	push   $0x0
  pushl $208
80100d11:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
80100d16:	e9 37 f7 ff ff       	jmp    80100452 <__alltraps>

80100d1b <vector209>:
.globl vector209
vector209:
  pushl $0
80100d1b:	6a 00                	push   $0x0
  pushl $209
80100d1d:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
80100d22:	e9 2b f7 ff ff       	jmp    80100452 <__alltraps>

80100d27 <vector210>:
.globl vector210
vector210:
  pushl $0
80100d27:	6a 00                	push   $0x0
  pushl $210
80100d29:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
80100d2e:	e9 1f f7 ff ff       	jmp    80100452 <__alltraps>

80100d33 <vector211>:
.globl vector211
vector211:
  pushl $0
80100d33:	6a 00                	push   $0x0
  pushl $211
80100d35:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
80100d3a:	e9 13 f7 ff ff       	jmp    80100452 <__alltraps>

80100d3f <vector212>:
.globl vector212
vector212:
  pushl $0
80100d3f:	6a 00                	push   $0x0
  pushl $212
80100d41:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
80100d46:	e9 07 f7 ff ff       	jmp    80100452 <__alltraps>

80100d4b <vector213>:
.globl vector213
vector213:
  pushl $0
80100d4b:	6a 00                	push   $0x0
  pushl $213
80100d4d:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
80100d52:	e9 fb f6 ff ff       	jmp    80100452 <__alltraps>

80100d57 <vector214>:
.globl vector214
vector214:
  pushl $0
80100d57:	6a 00                	push   $0x0
  pushl $214
80100d59:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
80100d5e:	e9 ef f6 ff ff       	jmp    80100452 <__alltraps>

80100d63 <vector215>:
.globl vector215
vector215:
  pushl $0
80100d63:	6a 00                	push   $0x0
  pushl $215
80100d65:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
80100d6a:	e9 e3 f6 ff ff       	jmp    80100452 <__alltraps>

80100d6f <vector216>:
.globl vector216
vector216:
  pushl $0
80100d6f:	6a 00                	push   $0x0
  pushl $216
80100d71:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
80100d76:	e9 d7 f6 ff ff       	jmp    80100452 <__alltraps>

80100d7b <vector217>:
.globl vector217
vector217:
  pushl $0
80100d7b:	6a 00                	push   $0x0
  pushl $217
80100d7d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
80100d82:	e9 cb f6 ff ff       	jmp    80100452 <__alltraps>

80100d87 <vector218>:
.globl vector218
vector218:
  pushl $0
80100d87:	6a 00                	push   $0x0
  pushl $218
80100d89:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
80100d8e:	e9 bf f6 ff ff       	jmp    80100452 <__alltraps>

80100d93 <vector219>:
.globl vector219
vector219:
  pushl $0
80100d93:	6a 00                	push   $0x0
  pushl $219
80100d95:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
80100d9a:	e9 b3 f6 ff ff       	jmp    80100452 <__alltraps>

80100d9f <vector220>:
.globl vector220
vector220:
  pushl $0
80100d9f:	6a 00                	push   $0x0
  pushl $220
80100da1:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
80100da6:	e9 a7 f6 ff ff       	jmp    80100452 <__alltraps>

80100dab <vector221>:
.globl vector221
vector221:
  pushl $0
80100dab:	6a 00                	push   $0x0
  pushl $221
80100dad:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
80100db2:	e9 9b f6 ff ff       	jmp    80100452 <__alltraps>

80100db7 <vector222>:
.globl vector222
vector222:
  pushl $0
80100db7:	6a 00                	push   $0x0
  pushl $222
80100db9:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
80100dbe:	e9 8f f6 ff ff       	jmp    80100452 <__alltraps>

80100dc3 <vector223>:
.globl vector223
vector223:
  pushl $0
80100dc3:	6a 00                	push   $0x0
  pushl $223
80100dc5:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
80100dca:	e9 83 f6 ff ff       	jmp    80100452 <__alltraps>

80100dcf <vector224>:
.globl vector224
vector224:
  pushl $0
80100dcf:	6a 00                	push   $0x0
  pushl $224
80100dd1:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
80100dd6:	e9 77 f6 ff ff       	jmp    80100452 <__alltraps>

80100ddb <vector225>:
.globl vector225
vector225:
  pushl $0
80100ddb:	6a 00                	push   $0x0
  pushl $225
80100ddd:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
80100de2:	e9 6b f6 ff ff       	jmp    80100452 <__alltraps>

80100de7 <vector226>:
.globl vector226
vector226:
  pushl $0
80100de7:	6a 00                	push   $0x0
  pushl $226
80100de9:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
80100dee:	e9 5f f6 ff ff       	jmp    80100452 <__alltraps>

80100df3 <vector227>:
.globl vector227
vector227:
  pushl $0
80100df3:	6a 00                	push   $0x0
  pushl $227
80100df5:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
80100dfa:	e9 53 f6 ff ff       	jmp    80100452 <__alltraps>

80100dff <vector228>:
.globl vector228
vector228:
  pushl $0
80100dff:	6a 00                	push   $0x0
  pushl $228
80100e01:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
80100e06:	e9 47 f6 ff ff       	jmp    80100452 <__alltraps>

80100e0b <vector229>:
.globl vector229
vector229:
  pushl $0
80100e0b:	6a 00                	push   $0x0
  pushl $229
80100e0d:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
80100e12:	e9 3b f6 ff ff       	jmp    80100452 <__alltraps>

80100e17 <vector230>:
.globl vector230
vector230:
  pushl $0
80100e17:	6a 00                	push   $0x0
  pushl $230
80100e19:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
80100e1e:	e9 2f f6 ff ff       	jmp    80100452 <__alltraps>

80100e23 <vector231>:
.globl vector231
vector231:
  pushl $0
80100e23:	6a 00                	push   $0x0
  pushl $231
80100e25:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
80100e2a:	e9 23 f6 ff ff       	jmp    80100452 <__alltraps>

80100e2f <vector232>:
.globl vector232
vector232:
  pushl $0
80100e2f:	6a 00                	push   $0x0
  pushl $232
80100e31:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
80100e36:	e9 17 f6 ff ff       	jmp    80100452 <__alltraps>

80100e3b <vector233>:
.globl vector233
vector233:
  pushl $0
80100e3b:	6a 00                	push   $0x0
  pushl $233
80100e3d:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
80100e42:	e9 0b f6 ff ff       	jmp    80100452 <__alltraps>

80100e47 <vector234>:
.globl vector234
vector234:
  pushl $0
80100e47:	6a 00                	push   $0x0
  pushl $234
80100e49:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
80100e4e:	e9 ff f5 ff ff       	jmp    80100452 <__alltraps>

80100e53 <vector235>:
.globl vector235
vector235:
  pushl $0
80100e53:	6a 00                	push   $0x0
  pushl $235
80100e55:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
80100e5a:	e9 f3 f5 ff ff       	jmp    80100452 <__alltraps>

80100e5f <vector236>:
.globl vector236
vector236:
  pushl $0
80100e5f:	6a 00                	push   $0x0
  pushl $236
80100e61:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
80100e66:	e9 e7 f5 ff ff       	jmp    80100452 <__alltraps>

80100e6b <vector237>:
.globl vector237
vector237:
  pushl $0
80100e6b:	6a 00                	push   $0x0
  pushl $237
80100e6d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
80100e72:	e9 db f5 ff ff       	jmp    80100452 <__alltraps>

80100e77 <vector238>:
.globl vector238
vector238:
  pushl $0
80100e77:	6a 00                	push   $0x0
  pushl $238
80100e79:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
80100e7e:	e9 cf f5 ff ff       	jmp    80100452 <__alltraps>

80100e83 <vector239>:
.globl vector239
vector239:
  pushl $0
80100e83:	6a 00                	push   $0x0
  pushl $239
80100e85:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
80100e8a:	e9 c3 f5 ff ff       	jmp    80100452 <__alltraps>

80100e8f <vector240>:
.globl vector240
vector240:
  pushl $0
80100e8f:	6a 00                	push   $0x0
  pushl $240
80100e91:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
80100e96:	e9 b7 f5 ff ff       	jmp    80100452 <__alltraps>

80100e9b <vector241>:
.globl vector241
vector241:
  pushl $0
80100e9b:	6a 00                	push   $0x0
  pushl $241
80100e9d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
80100ea2:	e9 ab f5 ff ff       	jmp    80100452 <__alltraps>

80100ea7 <vector242>:
.globl vector242
vector242:
  pushl $0
80100ea7:	6a 00                	push   $0x0
  pushl $242
80100ea9:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
80100eae:	e9 9f f5 ff ff       	jmp    80100452 <__alltraps>

80100eb3 <vector243>:
.globl vector243
vector243:
  pushl $0
80100eb3:	6a 00                	push   $0x0
  pushl $243
80100eb5:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
80100eba:	e9 93 f5 ff ff       	jmp    80100452 <__alltraps>

80100ebf <vector244>:
.globl vector244
vector244:
  pushl $0
80100ebf:	6a 00                	push   $0x0
  pushl $244
80100ec1:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
80100ec6:	e9 87 f5 ff ff       	jmp    80100452 <__alltraps>

80100ecb <vector245>:
.globl vector245
vector245:
  pushl $0
80100ecb:	6a 00                	push   $0x0
  pushl $245
80100ecd:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
80100ed2:	e9 7b f5 ff ff       	jmp    80100452 <__alltraps>

80100ed7 <vector246>:
.globl vector246
vector246:
  pushl $0
80100ed7:	6a 00                	push   $0x0
  pushl $246
80100ed9:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
80100ede:	e9 6f f5 ff ff       	jmp    80100452 <__alltraps>

80100ee3 <vector247>:
.globl vector247
vector247:
  pushl $0
80100ee3:	6a 00                	push   $0x0
  pushl $247
80100ee5:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
80100eea:	e9 63 f5 ff ff       	jmp    80100452 <__alltraps>

80100eef <vector248>:
.globl vector248
vector248:
  pushl $0
80100eef:	6a 00                	push   $0x0
  pushl $248
80100ef1:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
80100ef6:	e9 57 f5 ff ff       	jmp    80100452 <__alltraps>

80100efb <vector249>:
.globl vector249
vector249:
  pushl $0
80100efb:	6a 00                	push   $0x0
  pushl $249
80100efd:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
80100f02:	e9 4b f5 ff ff       	jmp    80100452 <__alltraps>

80100f07 <vector250>:
.globl vector250
vector250:
  pushl $0
80100f07:	6a 00                	push   $0x0
  pushl $250
80100f09:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
80100f0e:	e9 3f f5 ff ff       	jmp    80100452 <__alltraps>

80100f13 <vector251>:
.globl vector251
vector251:
  pushl $0
80100f13:	6a 00                	push   $0x0
  pushl $251
80100f15:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
80100f1a:	e9 33 f5 ff ff       	jmp    80100452 <__alltraps>

80100f1f <vector252>:
.globl vector252
vector252:
  pushl $0
80100f1f:	6a 00                	push   $0x0
  pushl $252
80100f21:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
80100f26:	e9 27 f5 ff ff       	jmp    80100452 <__alltraps>

80100f2b <vector253>:
.globl vector253
vector253:
  pushl $0
80100f2b:	6a 00                	push   $0x0
  pushl $253
80100f2d:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
80100f32:	e9 1b f5 ff ff       	jmp    80100452 <__alltraps>

80100f37 <vector254>:
.globl vector254
vector254:
  pushl $0
80100f37:	6a 00                	push   $0x0
  pushl $254
80100f39:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
80100f3e:	e9 0f f5 ff ff       	jmp    80100452 <__alltraps>

80100f43 <vector255>:
.globl vector255
vector255:
  pushl $0
80100f43:	6a 00                	push   $0x0
  pushl $255
80100f45:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
80100f4a:	e9 03 f5 ff ff       	jmp    80100452 <__alltraps>
80100f4f:	90                   	nop

80100f50 <kbd_intr>:
    return c;
}

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
80100f50:	55                   	push   %ebp
80100f51:	89 e5                	mov    %esp,%ebp
80100f53:	57                   	push   %edi
80100f54:	56                   	push   %esi
80100f55:	53                   	push   %ebx
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
80100f56:	be 60 00 00 00       	mov    $0x60,%esi
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	8b 0d 40 4f 10 80    	mov    0x80104f40,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80100f64:	31 ff                	xor    %edi,%edi
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
80100f66:	bb 64 00 00 00       	mov    $0x64,%ebx
80100f6b:	90                   	nop
80100f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f70:	89 da                	mov    %ebx,%edx
80100f72:	ec                   	in     (%dx),%al
    if ((inb(KBSTATP) & KBS_DIB) == 0) {
80100f73:	a8 01                	test   $0x1,%al
80100f75:	0f 84 35 01 00 00    	je     801010b0 <kbd_intr+0x160>
80100f7b:	89 f2                	mov    %esi,%edx
80100f7d:	ec                   	in     (%dx),%al
    if (data == 0xE0) {
80100f7e:	3c e0                	cmp    $0xe0,%al
80100f80:	89 c2                	mov    %eax,%edx
80100f82:	74 64                	je     80100fe8 <kbd_intr+0x98>
80100f84:	89 cf                	mov    %ecx,%edi
80100f86:	83 e7 40             	and    $0x40,%edi
    } else if (data & 0x80) {
80100f89:	84 c0                	test   %al,%al
80100f8b:	0f 88 f7 00 00 00    	js     80101088 <kbd_intr+0x138>
    } else if (shift & E0ESC) {
80100f91:	85 ff                	test   %edi,%edi
80100f93:	74 06                	je     80100f9b <kbd_intr+0x4b>
        data |= 0x80;
80100f95:	83 ca 80             	or     $0xffffff80,%edx
        shift &= ~E0ESC;
80100f98:	83 e1 bf             	and    $0xffffffbf,%ecx
    shift |= shiftcode[data];
80100f9b:	0f b6 d2             	movzbl %dl,%edx
80100f9e:	0f b6 82 40 28 10 80 	movzbl -0x7fefd7c0(%edx),%eax
80100fa5:	09 c1                	or     %eax,%ecx
    shift ^= togglecode[data];
80100fa7:	0f b6 82 40 27 10 80 	movzbl -0x7fefd8c0(%edx),%eax
80100fae:	31 c1                	xor    %eax,%ecx
    c = charcode[shift & (CTL | SHIFT)][data];
80100fb0:	89 c8                	mov    %ecx,%eax
80100fb2:	83 e0 03             	and    $0x3,%eax
    if (shift & CAPSLOCK) {
80100fb5:	f6 c1 08             	test   $0x8,%cl
    c = charcode[shift & (CTL | SHIFT)][data];
80100fb8:	8b 04 85 20 27 10 80 	mov    -0x7fefd8e0(,%eax,4),%eax
80100fbf:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
    if (shift & CAPSLOCK) {
80100fc3:	74 33                	je     80100ff8 <kbd_intr+0xa8>
        if ('a' <= c && c <= 'z')
80100fc5:	8d 50 9f             	lea    -0x61(%eax),%edx
80100fc8:	83 fa 19             	cmp    $0x19,%edx
80100fcb:	77 43                	ja     80101010 <kbd_intr+0xc0>
            c += 'A' - 'a';
80100fcd:	83 e8 20             	sub    $0x20,%eax
    while ((c = (*proc)()) != -1) {
80100fd0:	83 f8 ff             	cmp    $0xffffffff,%eax
80100fd3:	75 2c                	jne    80101001 <kbd_intr+0xb1>
80100fd5:	89 0d 40 4f 10 80    	mov    %ecx,0x80104f40
    cons_intr(kbd_proc_data);
}
80100fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fde:	5b                   	pop    %ebx
80100fdf:	5e                   	pop    %esi
80100fe0:	5f                   	pop    %edi
80100fe1:	5d                   	pop    %ebp
80100fe2:	c3                   	ret    
80100fe3:	90                   	nop
80100fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        shift |= E0ESC;
80100fe8:	83 c9 40             	or     $0x40,%ecx
80100feb:	bf 01 00 00 00       	mov    $0x1,%edi
80100ff0:	e9 7b ff ff ff       	jmp    80100f70 <kbd_intr+0x20>
80100ff5:	8d 76 00             	lea    0x0(%esi),%esi
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
80100ff8:	89 ca                	mov    %ecx,%edx
80100ffa:	f7 d2                	not    %edx
80100ffc:	83 e2 06             	and    $0x6,%edx
80100fff:	74 23                	je     80101024 <kbd_intr+0xd4>
        if (c != 0) {
80101001:	85 c0                	test   %eax,%eax
80101003:	74 e6                	je     80100feb <kbd_intr+0x9b>
80101005:	8d 76 00             	lea    0x0(%esi),%esi
80101008:	89 0d 40 4f 10 80    	mov    %ecx,0x80104f40
8010100e:	eb 41                	jmp    80101051 <kbd_intr+0x101>
        else if ('A' <= c && c <= 'Z')
80101010:	8d 50 bf             	lea    -0x41(%eax),%edx
80101013:	83 fa 19             	cmp    $0x19,%edx
80101016:	77 e0                	ja     80100ff8 <kbd_intr+0xa8>
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
80101018:	89 ca                	mov    %ecx,%edx
            c += 'a' - 'A';
8010101a:	83 c0 20             	add    $0x20,%eax
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
8010101d:	f7 d2                	not    %edx
8010101f:	83 e2 06             	and    $0x6,%edx
80101022:	75 e4                	jne    80101008 <kbd_intr+0xb8>
80101024:	3d e9 00 00 00       	cmp    $0xe9,%eax
80101029:	75 d6                	jne    80101001 <kbd_intr+0xb1>
        cprintf("Rebooting!\n");
8010102b:	83 ec 0c             	sub    $0xc,%esp
8010102e:	89 0d 40 4f 10 80    	mov    %ecx,0x80104f40
80101034:	68 e0 26 10 80       	push   $0x801026e0
80101039:	e8 c2 0b 00 00       	call   80101c00 <cprintf>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
8010103e:	b8 03 00 00 00       	mov    $0x3,%eax
80101043:	ba 92 00 00 00       	mov    $0x92,%edx
80101048:	ee                   	out    %al,(%dx)
80101049:	b8 e9 ff ff ff       	mov    $0xffffffe9,%eax
8010104e:	83 c4 10             	add    $0x10,%esp
            cons.buf[cons.wpos ++] = c;
80101051:	8b 0d 64 51 10 80    	mov    0x80105164,%ecx
80101057:	8d 51 01             	lea    0x1(%ecx),%edx
8010105a:	88 81 60 4f 10 80    	mov    %al,-0x7fefb0a0(%ecx)
            if (cons.wpos == CONSBUFSIZE) {
80101060:	81 fa 00 02 00 00    	cmp    $0x200,%edx
            cons.buf[cons.wpos ++] = c;
80101066:	89 15 64 51 10 80    	mov    %edx,0x80105164
            if (cons.wpos == CONSBUFSIZE) {
8010106c:	0f 85 ec fe ff ff    	jne    80100f5e <kbd_intr+0xe>
                cons.wpos = 0;
80101072:	c7 05 64 51 10 80 00 	movl   $0x0,0x80105164
80101079:	00 00 00 
8010107c:	e9 dd fe ff ff       	jmp    80100f5e <kbd_intr+0xe>
80101081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        data = (shift & E0ESC ? data : data & 0x7F);
80101088:	83 e2 7f             	and    $0x7f,%edx
8010108b:	85 ff                	test   %edi,%edi
8010108d:	0f 45 d0             	cmovne %eax,%edx
        shift &= ~(shiftcode[data] | E0ESC);
80101090:	0f b6 d2             	movzbl %dl,%edx
80101093:	0f b6 82 40 28 10 80 	movzbl -0x7fefd7c0(%edx),%eax
8010109a:	83 c8 40             	or     $0x40,%eax
8010109d:	0f b6 c0             	movzbl %al,%eax
801010a0:	f7 d0                	not    %eax
801010a2:	21 c1                	and    %eax,%ecx
801010a4:	e9 42 ff ff ff       	jmp    80100feb <kbd_intr+0x9b>
801010a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010b0:	89 f8                	mov    %edi,%eax
801010b2:	84 c0                	test   %al,%al
801010b4:	0f 85 1b ff ff ff    	jne    80100fd5 <kbd_intr+0x85>
}
801010ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010bd:	5b                   	pop    %ebx
801010be:	5e                   	pop    %esi
801010bf:	5f                   	pop    %edi
801010c0:	5d                   	pop    %ebp
801010c1:	c3                   	ret    
801010c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801010d0 <serial_intr.part.0>:
serial_intr(void) {
801010d0:	55                   	push   %ebp
801010d1:	89 e5                	mov    %esp,%ebp
801010d3:	57                   	push   %edi
801010d4:	56                   	push   %esi
801010d5:	8b 35 64 51 10 80    	mov    0x80105164,%esi
801010db:	53                   	push   %ebx
    if (c == 127) {
801010dc:	31 ff                	xor    %edi,%edi
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
801010de:	bb f8 03 00 00       	mov    $0x3f8,%ebx
801010e3:	b9 fd 03 00 00       	mov    $0x3fd,%ecx
801010e8:	90                   	nop
801010e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010f0:	89 ca                	mov    %ecx,%edx
801010f2:	ec                   	in     (%dx),%al
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
801010f3:	a8 01                	test   $0x1,%al
801010f5:	74 41                	je     80101138 <serial_intr.part.0+0x68>
801010f7:	89 da                	mov    %ebx,%edx
801010f9:	ec                   	in     (%dx),%al
    int c = inb(COM1 + COM_RX);
801010fa:	0f b6 d0             	movzbl %al,%edx
    if (c == 127) {
801010fd:	83 fa 7f             	cmp    $0x7f,%edx
80101100:	74 0e                	je     80101110 <serial_intr.part.0+0x40>
        if (c != 0) {
80101102:	85 d2                	test   %edx,%edx
80101104:	74 ea                	je     801010f0 <serial_intr.part.0+0x20>
80101106:	eb 0d                	jmp    80101115 <serial_intr.part.0+0x45>
80101108:	90                   	nop
80101109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if (c == 127) {
80101110:	b8 08 00 00 00       	mov    $0x8,%eax
            cons.buf[cons.wpos ++] = c;
80101115:	88 86 60 4f 10 80    	mov    %al,-0x7fefb0a0(%esi)
8010111b:	83 c6 01             	add    $0x1,%esi
                cons.wpos = 0;
8010111e:	b8 00 00 00 00       	mov    $0x0,%eax
            if (cons.wpos == CONSBUFSIZE) {
80101123:	81 fe 00 02 00 00    	cmp    $0x200,%esi
80101129:	bf 01 00 00 00       	mov    $0x1,%edi
                cons.wpos = 0;
8010112e:	0f 44 f0             	cmove  %eax,%esi
80101131:	eb b0                	jmp    801010e3 <serial_intr.part.0+0x13>
80101133:	90                   	nop
80101134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101138:	89 f8                	mov    %edi,%eax
8010113a:	84 c0                	test   %al,%al
8010113c:	75 05                	jne    80101143 <serial_intr.part.0+0x73>
}
8010113e:	5b                   	pop    %ebx
8010113f:	5e                   	pop    %esi
80101140:	5f                   	pop    %edi
80101141:	5d                   	pop    %ebp
80101142:	c3                   	ret    
80101143:	89 35 64 51 10 80    	mov    %esi,0x80105164
80101149:	eb f3                	jmp    8010113e <serial_intr.part.0+0x6e>
8010114b:	90                   	nop
8010114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101150 <serial_intr>:
    if (serial_exists) {
80101150:	a1 68 51 10 80       	mov    0x80105168,%eax
serial_intr(void) {
80101155:	55                   	push   %ebp
80101156:	89 e5                	mov    %esp,%ebp
    if (serial_exists) {
80101158:	85 c0                	test   %eax,%eax
8010115a:	74 0c                	je     80101168 <serial_intr+0x18>
}
8010115c:	5d                   	pop    %ebp
8010115d:	e9 6e ff ff ff       	jmp    801010d0 <serial_intr.part.0>
80101162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101168:	5d                   	pop    %ebp
80101169:	c3                   	ret    
8010116a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101170 <cons_init>:
    pic_enable(IRQ_KBD);
}

/* cons_init - initializes the console devices */
void
cons_init(void) {
80101170:	55                   	push   %ebp
80101171:	89 e5                	mov    %esp,%ebp
80101173:	57                   	push   %edi
80101174:	56                   	push   %esi
80101175:	53                   	push   %ebx
    *cp = (uint16_t) 0xA55A;
80101176:	bb 5a a5 ff ff       	mov    $0xffffa55a,%ebx
cons_init(void) {
8010117b:	83 ec 0c             	sub    $0xc,%esp
    uint16_t was = *cp;
8010117e:	0f b7 15 00 80 0b 00 	movzwl 0xb8000,%edx
    *cp = (uint16_t) 0xA55A;
80101185:	66 89 1d 00 80 0b 00 	mov    %bx,0xb8000
    if (*cp != 0xA55A) {
8010118c:	0f b7 05 00 80 0b 00 	movzwl 0xb8000,%eax
80101193:	66 3d 5a a5          	cmp    $0xa55a,%ax
80101197:	0f 84 f3 00 00 00    	je     80101290 <cons_init+0x120>
        addr_6845 = MONO_BASE;
8010119d:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
801011a2:	bf b4 03 00 00       	mov    $0x3b4,%edi
        cp = (uint16_t*)MONO_BUF;
801011a7:	be 00 00 0b 00       	mov    $0xb0000,%esi
        addr_6845 = MONO_BASE;
801011ac:	66 89 0d 6c 51 10 80 	mov    %cx,0x8010516c
801011b3:	b9 b5 03 00 00       	mov    $0x3b5,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
801011b8:	b8 0e 00 00 00       	mov    $0xe,%eax
801011bd:	89 fa                	mov    %edi,%edx
801011bf:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
801011c0:	89 ca                	mov    %ecx,%edx
801011c2:	ec                   	in     (%dx),%al
    pos = inb(addr_6845 + 1) << 8;
801011c3:	0f b6 c0             	movzbl %al,%eax
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
801011c6:	89 fa                	mov    %edi,%edx
801011c8:	c1 e0 08             	shl    $0x8,%eax
801011cb:	89 c3                	mov    %eax,%ebx
801011cd:	b8 0f 00 00 00       	mov    $0xf,%eax
801011d2:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
801011d3:	89 ca                	mov    %ecx,%edx
801011d5:	ec                   	in     (%dx),%al
    pos |= inb(addr_6845 + 1);
801011d6:	0f b6 c0             	movzbl %al,%eax
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
801011d9:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
    crt_buf = (uint16_t*) cp;
801011de:	89 35 70 51 10 80    	mov    %esi,0x80105170
    pos |= inb(addr_6845 + 1);
801011e4:	09 d8                	or     %ebx,%eax
801011e6:	31 db                	xor    %ebx,%ebx
801011e8:	89 ca                	mov    %ecx,%edx
    crt_pos = pos;
801011ea:	66 a3 6e 51 10 80    	mov    %ax,0x8010516e
801011f0:	89 d8                	mov    %ebx,%eax
801011f2:	ee                   	out    %al,(%dx)
801011f3:	bf fb 03 00 00       	mov    $0x3fb,%edi
801011f8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801011fd:	89 fa                	mov    %edi,%edx
801011ff:	ee                   	out    %al,(%dx)
80101200:	b8 0c 00 00 00       	mov    $0xc,%eax
80101205:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010120a:	ee                   	out    %al,(%dx)
8010120b:	be f9 03 00 00       	mov    $0x3f9,%esi
80101210:	89 d8                	mov    %ebx,%eax
80101212:	89 f2                	mov    %esi,%edx
80101214:	ee                   	out    %al,(%dx)
80101215:	b8 03 00 00 00       	mov    $0x3,%eax
8010121a:	89 fa                	mov    %edi,%edx
8010121c:	ee                   	out    %al,(%dx)
8010121d:	ba fc 03 00 00       	mov    $0x3fc,%edx
80101222:	89 d8                	mov    %ebx,%eax
80101224:	ee                   	out    %al,(%dx)
80101225:	b8 01 00 00 00       	mov    $0x1,%eax
8010122a:	89 f2                	mov    %esi,%edx
8010122c:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
8010122d:	ba fd 03 00 00       	mov    $0x3fd,%edx
80101232:	ec                   	in     (%dx),%al
80101233:	89 c3                	mov    %eax,%ebx
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
80101235:	31 c0                	xor    %eax,%eax
80101237:	89 ca                	mov    %ecx,%edx
80101239:	80 fb ff             	cmp    $0xff,%bl
8010123c:	0f 95 c0             	setne  %al
8010123f:	a3 68 51 10 80       	mov    %eax,0x80105168
80101244:	ec                   	in     (%dx),%al
80101245:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010124a:	ec                   	in     (%dx),%al
    if (serial_exists) {
8010124b:	80 fb ff             	cmp    $0xff,%bl
8010124e:	74 0d                	je     8010125d <cons_init+0xed>
        pic_enable(IRQ_COM1);
80101250:	83 ec 0c             	sub    $0xc,%esp
80101253:	6a 04                	push   $0x4
80101255:	e8 b6 04 00 00       	call   80101710 <pic_enable>
8010125a:	83 c4 10             	add    $0x10,%esp
    kbd_intr();
8010125d:	e8 ee fc ff ff       	call   80100f50 <kbd_intr>
    pic_enable(IRQ_KBD);
80101262:	83 ec 0c             	sub    $0xc,%esp
80101265:	6a 01                	push   $0x1
80101267:	e8 a4 04 00 00       	call   80101710 <pic_enable>
    cga_init();
    serial_init();
    kbd_init();
    if (!serial_exists) {
8010126c:	a1 68 51 10 80       	mov    0x80105168,%eax
80101271:	83 c4 10             	add    $0x10,%esp
80101274:	85 c0                	test   %eax,%eax
80101276:	75 10                	jne    80101288 <cons_init+0x118>
        cprintf("serial port does not exist!!\n");
80101278:	83 ec 0c             	sub    $0xc,%esp
8010127b:	68 ec 26 10 80       	push   $0x801026ec
80101280:	e8 7b 09 00 00       	call   80101c00 <cprintf>
80101285:	83 c4 10             	add    $0x10,%esp
    }
}
80101288:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010128b:	5b                   	pop    %ebx
8010128c:	5e                   	pop    %esi
8010128d:	5f                   	pop    %edi
8010128e:	5d                   	pop    %ebp
8010128f:	c3                   	ret    
        *cp = was;
80101290:	66 89 15 00 80 0b 00 	mov    %dx,0xb8000
        addr_6845 = CGA_BASE;
80101297:	ba d4 03 00 00       	mov    $0x3d4,%edx
8010129c:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801012a1:	66 89 15 6c 51 10 80 	mov    %dx,0x8010516c
801012a8:	bf d4 03 00 00       	mov    $0x3d4,%edi
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;
801012ad:	be 00 80 0b 00       	mov    $0xb8000,%esi
801012b2:	e9 01 ff ff ff       	jmp    801011b8 <cons_init+0x48>
801012b7:	89 f6                	mov    %esi,%esi
801012b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801012c0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
801012c0:	55                   	push   %ebp
801012c1:	ba 79 03 00 00       	mov    $0x379,%edx
801012c6:	89 e5                	mov    %esp,%ebp
801012c8:	57                   	push   %edi
801012c9:	56                   	push   %esi
801012ca:	53                   	push   %ebx
801012cb:	83 ec 0c             	sub    $0xc,%esp
801012ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (c != '\b') {
801012d1:	83 fb 08             	cmp    $0x8,%ebx
801012d4:	0f 84 f6 00 00 00    	je     801013d0 <cons_putc+0x110>
801012da:	ec                   	in     (%dx),%al
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
801012db:	84 c0                	test   %al,%al
801012dd:	78 29                	js     80101308 <cons_putc+0x48>
801012df:	31 f6                	xor    %esi,%esi
801012e1:	b9 84 00 00 00       	mov    $0x84,%ecx
801012e6:	bf 79 03 00 00       	mov    $0x379,%edi
801012eb:	90                   	nop
801012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801012f0:	89 ca                	mov    %ecx,%edx
801012f2:	ec                   	in     (%dx),%al
801012f3:	ec                   	in     (%dx),%al
801012f4:	ec                   	in     (%dx),%al
801012f5:	ec                   	in     (%dx),%al
801012f6:	83 c6 01             	add    $0x1,%esi
801012f9:	89 fa                	mov    %edi,%edx
801012fb:	ec                   	in     (%dx),%al
801012fc:	81 fe 00 32 00 00    	cmp    $0x3200,%esi
80101302:	74 04                	je     80101308 <cons_putc+0x48>
80101304:	84 c0                	test   %al,%al
80101306:	79 e8                	jns    801012f0 <cons_putc+0x30>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80101308:	ba 78 03 00 00       	mov    $0x378,%edx
8010130d:	89 d8                	mov    %ebx,%eax
8010130f:	ee                   	out    %al,(%dx)
80101310:	ba 7a 03 00 00       	mov    $0x37a,%edx
80101315:	b8 0d 00 00 00       	mov    $0xd,%eax
8010131a:	ee                   	out    %al,(%dx)
8010131b:	b8 08 00 00 00       	mov    $0x8,%eax
80101320:	ee                   	out    %al,(%dx)
    if (!(c & ~0xFF)) {
80101321:	f7 c3 00 ff ff ff    	test   $0xffffff00,%ebx
80101327:	89 de                	mov    %ebx,%esi
80101329:	0f 84 8c 01 00 00    	je     801014bb <cons_putc+0x1fb>
    switch (c & 0xff) {
8010132f:	89 f1                	mov    %esi,%ecx
80101331:	0f b7 05 6e 51 10 80 	movzwl 0x8010516e,%eax
80101338:	0f b6 d1             	movzbl %cl,%edx
8010133b:	83 fa 0a             	cmp    $0xa,%edx
8010133e:	0f 84 84 01 00 00    	je     801014c8 <cons_putc+0x208>
80101344:	83 fa 0d             	cmp    $0xd,%edx
80101347:	0f 84 7e 01 00 00    	je     801014cb <cons_putc+0x20b>
8010134d:	83 fa 08             	cmp    $0x8,%edx
80101350:	0f 84 0a 02 00 00    	je     80101560 <cons_putc+0x2a0>
        crt_buf[crt_pos ++] = c;     // write the character
80101356:	8d 48 01             	lea    0x1(%eax),%ecx
80101359:	8b 15 70 51 10 80    	mov    0x80105170,%edx
    if (crt_pos >= CRT_SIZE) {
8010135f:	66 81 f9 cf 07       	cmp    $0x7cf,%cx
        crt_buf[crt_pos ++] = c;     // write the character
80101364:	66 89 0d 6e 51 10 80 	mov    %cx,0x8010516e
8010136b:	66 89 34 42          	mov    %si,(%edx,%eax,2)
    if (crt_pos >= CRT_SIZE) {
8010136f:	0f 86 7b 01 00 00    	jbe    801014f0 <cons_putc+0x230>
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
80101375:	a1 70 51 10 80       	mov    0x80105170,%eax
8010137a:	83 ec 04             	sub    $0x4,%esp
8010137d:	68 00 0f 00 00       	push   $0xf00
80101382:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80101388:	52                   	push   %edx
80101389:	50                   	push   %eax
8010138a:	e8 51 07 00 00       	call   80101ae0 <memmove>
            crt_buf[i] = 0x0700 | ' ';
8010138f:	8b 15 70 51 10 80    	mov    0x80105170,%edx
80101395:	83 c4 10             	add    $0x10,%esp
80101398:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
8010139e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
801013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801013a8:	b9 20 07 00 00       	mov    $0x720,%ecx
801013ad:	83 c0 02             	add    $0x2,%eax
801013b0:	66 89 48 fe          	mov    %cx,-0x2(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
801013b4:	39 c2                	cmp    %eax,%edx
801013b6:	75 f0                	jne    801013a8 <cons_putc+0xe8>
        crt_pos -= CRT_COLS;
801013b8:	0f b7 05 6e 51 10 80 	movzwl 0x8010516e,%eax
801013bf:	8d 48 b0             	lea    -0x50(%eax),%ecx
801013c2:	66 89 0d 6e 51 10 80 	mov    %cx,0x8010516e
801013c9:	e9 22 01 00 00       	jmp    801014f0 <cons_putc+0x230>
801013ce:	66 90                	xchg   %ax,%ax
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
801013d0:	ec                   	in     (%dx),%al
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
801013d1:	31 f6                	xor    %esi,%esi
801013d3:	84 c0                	test   %al,%al
801013d5:	b9 84 00 00 00       	mov    $0x84,%ecx
801013da:	bf 79 03 00 00       	mov    $0x379,%edi
801013df:	79 0b                	jns    801013ec <cons_putc+0x12c>
801013e1:	eb 1d                	jmp    80101400 <cons_putc+0x140>
801013e3:	90                   	nop
801013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801013e8:	84 c0                	test   %al,%al
801013ea:	78 14                	js     80101400 <cons_putc+0x140>
801013ec:	89 ca                	mov    %ecx,%edx
801013ee:	ec                   	in     (%dx),%al
801013ef:	ec                   	in     (%dx),%al
801013f0:	ec                   	in     (%dx),%al
801013f1:	ec                   	in     (%dx),%al
801013f2:	83 c6 01             	add    $0x1,%esi
801013f5:	89 fa                	mov    %edi,%edx
801013f7:	ec                   	in     (%dx),%al
801013f8:	81 fe 00 32 00 00    	cmp    $0x3200,%esi
801013fe:	75 e8                	jne    801013e8 <cons_putc+0x128>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80101400:	b9 08 00 00 00       	mov    $0x8,%ecx
80101405:	ba 78 03 00 00       	mov    $0x378,%edx
8010140a:	89 c8                	mov    %ecx,%eax
8010140c:	ee                   	out    %al,(%dx)
8010140d:	ba 7a 03 00 00       	mov    $0x37a,%edx
80101412:	b8 0d 00 00 00       	mov    $0xd,%eax
80101417:	ee                   	out    %al,(%dx)
80101418:	89 c8                	mov    %ecx,%eax
8010141a:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
8010141b:	ba 79 03 00 00       	mov    $0x379,%edx
80101420:	ec                   	in     (%dx),%al
80101421:	84 c0                	test   %al,%al
80101423:	78 2b                	js     80101450 <cons_putc+0x190>
80101425:	31 f6                	xor    %esi,%esi
80101427:	b9 84 00 00 00       	mov    $0x84,%ecx
8010142c:	bf 79 03 00 00       	mov    $0x379,%edi
80101431:	eb 0d                	jmp    80101440 <cons_putc+0x180>
80101433:	90                   	nop
80101434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101438:	81 fe 00 32 00 00    	cmp    $0x3200,%esi
8010143e:	74 10                	je     80101450 <cons_putc+0x190>
80101440:	89 ca                	mov    %ecx,%edx
80101442:	ec                   	in     (%dx),%al
80101443:	ec                   	in     (%dx),%al
80101444:	ec                   	in     (%dx),%al
80101445:	ec                   	in     (%dx),%al
80101446:	83 c6 01             	add    $0x1,%esi
80101449:	89 fa                	mov    %edi,%edx
8010144b:	ec                   	in     (%dx),%al
8010144c:	84 c0                	test   %al,%al
8010144e:	79 e8                	jns    80101438 <cons_putc+0x178>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80101450:	b8 20 00 00 00       	mov    $0x20,%eax
80101455:	ba 78 03 00 00       	mov    $0x378,%edx
8010145a:	ee                   	out    %al,(%dx)
8010145b:	ba 7a 03 00 00       	mov    $0x37a,%edx
80101460:	b8 0d 00 00 00       	mov    $0xd,%eax
80101465:	ee                   	out    %al,(%dx)
80101466:	b8 08 00 00 00       	mov    $0x8,%eax
8010146b:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
8010146c:	ba 79 03 00 00       	mov    $0x379,%edx
80101471:	ec                   	in     (%dx),%al
80101472:	84 c0                	test   %al,%al
80101474:	78 2a                	js     801014a0 <cons_putc+0x1e0>
80101476:	31 f6                	xor    %esi,%esi
80101478:	b9 84 00 00 00       	mov    $0x84,%ecx
8010147d:	bf 79 03 00 00       	mov    $0x379,%edi
80101482:	eb 0c                	jmp    80101490 <cons_putc+0x1d0>
80101484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101488:	81 fe 00 32 00 00    	cmp    $0x3200,%esi
8010148e:	74 10                	je     801014a0 <cons_putc+0x1e0>
80101490:	89 ca                	mov    %ecx,%edx
80101492:	ec                   	in     (%dx),%al
80101493:	ec                   	in     (%dx),%al
80101494:	ec                   	in     (%dx),%al
80101495:	ec                   	in     (%dx),%al
80101496:	83 c6 01             	add    $0x1,%esi
80101499:	89 fa                	mov    %edi,%edx
8010149b:	ec                   	in     (%dx),%al
8010149c:	84 c0                	test   %al,%al
8010149e:	79 e8                	jns    80101488 <cons_putc+0x1c8>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
801014a0:	b9 08 00 00 00       	mov    $0x8,%ecx
801014a5:	ba 78 03 00 00       	mov    $0x378,%edx
801014aa:	89 c8                	mov    %ecx,%eax
801014ac:	ee                   	out    %al,(%dx)
801014ad:	ba 7a 03 00 00       	mov    $0x37a,%edx
801014b2:	b8 0d 00 00 00       	mov    $0xd,%eax
801014b7:	ee                   	out    %al,(%dx)
801014b8:	89 c8                	mov    %ecx,%eax
801014ba:	ee                   	out    %al,(%dx)
        c |= 0x0700;
801014bb:	89 de                	mov    %ebx,%esi
801014bd:	81 ce 00 07 00 00    	or     $0x700,%esi
801014c3:	e9 67 fe ff ff       	jmp    8010132f <cons_putc+0x6f>
        crt_pos += CRT_COLS;
801014c8:	83 c0 50             	add    $0x50,%eax
        crt_pos -= (crt_pos % CRT_COLS);
801014cb:	0f b7 c0             	movzwl %ax,%eax
801014ce:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
801014d4:	c1 e8 16             	shr    $0x16,%eax
801014d7:	8d 04 80             	lea    (%eax,%eax,4),%eax
801014da:	c1 e0 04             	shl    $0x4,%eax
801014dd:	89 c1                	mov    %eax,%ecx
801014df:	66 a3 6e 51 10 80    	mov    %ax,0x8010516e
    if (crt_pos >= CRT_SIZE) {
801014e5:	66 81 f9 cf 07       	cmp    $0x7cf,%cx
801014ea:	0f 87 85 fe ff ff    	ja     80101375 <cons_putc+0xb5>
    outb(addr_6845, 14);
801014f0:	0f b7 35 6c 51 10 80 	movzwl 0x8010516c,%esi
801014f7:	b8 0e 00 00 00       	mov    $0xe,%eax
801014fc:	89 f2                	mov    %esi,%edx
801014fe:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
801014ff:	8d 7e 01             	lea    0x1(%esi),%edi
80101502:	89 c8                	mov    %ecx,%eax
80101504:	66 c1 e8 08          	shr    $0x8,%ax
80101508:	89 fa                	mov    %edi,%edx
8010150a:	ee                   	out    %al,(%dx)
8010150b:	b8 0f 00 00 00       	mov    $0xf,%eax
80101510:	89 f2                	mov    %esi,%edx
80101512:	ee                   	out    %al,(%dx)
80101513:	89 c8                	mov    %ecx,%eax
80101515:	89 fa                	mov    %edi,%edx
80101517:	ee                   	out    %al,(%dx)
    if (c != '\b') {
80101518:	83 fb 08             	cmp    $0x8,%ebx
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
8010151b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80101520:	74 6e                	je     80101590 <cons_putc+0x2d0>
80101522:	ec                   	in     (%dx),%al
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
80101523:	a8 20                	test   $0x20,%al
80101525:	75 29                	jne    80101550 <cons_putc+0x290>
80101527:	31 f6                	xor    %esi,%esi
80101529:	b9 84 00 00 00       	mov    $0x84,%ecx
8010152e:	bf fd 03 00 00       	mov    $0x3fd,%edi
80101533:	90                   	nop
80101534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101538:	89 ca                	mov    %ecx,%edx
8010153a:	ec                   	in     (%dx),%al
8010153b:	ec                   	in     (%dx),%al
8010153c:	ec                   	in     (%dx),%al
8010153d:	ec                   	in     (%dx),%al
8010153e:	83 c6 01             	add    $0x1,%esi
80101541:	89 fa                	mov    %edi,%edx
80101543:	ec                   	in     (%dx),%al
80101544:	a8 20                	test   $0x20,%al
80101546:	75 08                	jne    80101550 <cons_putc+0x290>
80101548:	81 fe 00 32 00 00    	cmp    $0x3200,%esi
8010154e:	75 e8                	jne    80101538 <cons_putc+0x278>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80101550:	ba f8 03 00 00       	mov    $0x3f8,%edx
80101555:	89 d8                	mov    %ebx,%eax
80101557:	ee                   	out    %al,(%dx)
    lpt_putc(c);
    // 输出vga
    cga_putc(c);
    // 输出到串口com1
    serial_putc(c);
}
80101558:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010155b:	5b                   	pop    %ebx
8010155c:	5e                   	pop    %esi
8010155d:	5f                   	pop    %edi
8010155e:	5d                   	pop    %ebp
8010155f:	c3                   	ret    
        if (crt_pos > 0) {
80101560:	31 c9                	xor    %ecx,%ecx
80101562:	66 85 c0             	test   %ax,%ax
80101565:	74 89                	je     801014f0 <cons_putc+0x230>
            crt_pos --;
80101567:	8d 48 ff             	lea    -0x1(%eax),%ecx
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
8010156a:	8b 15 70 51 10 80    	mov    0x80105170,%edx
80101570:	66 81 e6 00 ff       	and    $0xff00,%si
80101575:	83 ce 20             	or     $0x20,%esi
80101578:	0f b7 c1             	movzwl %cx,%eax
            crt_pos --;
8010157b:	66 89 0d 6e 51 10 80 	mov    %cx,0x8010516e
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
80101582:	66 89 34 42          	mov    %si,(%edx,%eax,2)
80101586:	e9 5a ff ff ff       	jmp    801014e5 <cons_putc+0x225>
8010158b:	90                   	nop
8010158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
80101590:	ec                   	in     (%dx),%al
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
80101591:	31 db                	xor    %ebx,%ebx
80101593:	a8 20                	test   $0x20,%al
80101595:	b9 84 00 00 00       	mov    $0x84,%ecx
8010159a:	be fd 03 00 00       	mov    $0x3fd,%esi
8010159f:	74 0f                	je     801015b0 <cons_putc+0x2f0>
801015a1:	eb 1d                	jmp    801015c0 <cons_putc+0x300>
801015a3:	90                   	nop
801015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801015a8:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
801015ae:	74 10                	je     801015c0 <cons_putc+0x300>
801015b0:	89 ca                	mov    %ecx,%edx
801015b2:	ec                   	in     (%dx),%al
801015b3:	ec                   	in     (%dx),%al
801015b4:	ec                   	in     (%dx),%al
801015b5:	ec                   	in     (%dx),%al
801015b6:	83 c3 01             	add    $0x1,%ebx
801015b9:	89 f2                	mov    %esi,%edx
801015bb:	ec                   	in     (%dx),%al
801015bc:	a8 20                	test   $0x20,%al
801015be:	74 e8                	je     801015a8 <cons_putc+0x2e8>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
801015c0:	b8 08 00 00 00       	mov    $0x8,%eax
801015c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801015ca:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
801015cb:	ba fd 03 00 00       	mov    $0x3fd,%edx
801015d0:	ec                   	in     (%dx),%al
801015d1:	a8 20                	test   $0x20,%al
801015d3:	75 2b                	jne    80101600 <cons_putc+0x340>
801015d5:	31 db                	xor    %ebx,%ebx
801015d7:	b9 84 00 00 00       	mov    $0x84,%ecx
801015dc:	be fd 03 00 00       	mov    $0x3fd,%esi
801015e1:	eb 0d                	jmp    801015f0 <cons_putc+0x330>
801015e3:	90                   	nop
801015e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801015e8:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
801015ee:	74 10                	je     80101600 <cons_putc+0x340>
801015f0:	89 ca                	mov    %ecx,%edx
801015f2:	ec                   	in     (%dx),%al
801015f3:	ec                   	in     (%dx),%al
801015f4:	ec                   	in     (%dx),%al
801015f5:	ec                   	in     (%dx),%al
801015f6:	83 c3 01             	add    $0x1,%ebx
801015f9:	89 f2                	mov    %esi,%edx
801015fb:	ec                   	in     (%dx),%al
801015fc:	a8 20                	test   $0x20,%al
801015fe:	74 e8                	je     801015e8 <cons_putc+0x328>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80101600:	b8 20 00 00 00       	mov    $0x20,%eax
80101605:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010160a:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
8010160b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80101610:	ec                   	in     (%dx),%al
80101611:	a8 20                	test   $0x20,%al
80101613:	75 2b                	jne    80101640 <cons_putc+0x380>
80101615:	31 db                	xor    %ebx,%ebx
80101617:	b9 84 00 00 00       	mov    $0x84,%ecx
8010161c:	be fd 03 00 00       	mov    $0x3fd,%esi
80101621:	eb 0d                	jmp    80101630 <cons_putc+0x370>
80101623:	90                   	nop
80101624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101628:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
8010162e:	74 10                	je     80101640 <cons_putc+0x380>
80101630:	89 ca                	mov    %ecx,%edx
80101632:	ec                   	in     (%dx),%al
80101633:	ec                   	in     (%dx),%al
80101634:	ec                   	in     (%dx),%al
80101635:	ec                   	in     (%dx),%al
80101636:	83 c3 01             	add    $0x1,%ebx
80101639:	89 f2                	mov    %esi,%edx
8010163b:	ec                   	in     (%dx),%al
8010163c:	a8 20                	test   $0x20,%al
8010163e:	74 e8                	je     80101628 <cons_putc+0x368>
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
80101640:	b8 08 00 00 00       	mov    $0x8,%eax
80101645:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010164a:	ee                   	out    %al,(%dx)
}
8010164b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010164e:	5b                   	pop    %ebx
8010164f:	5e                   	pop    %esi
80101650:	5f                   	pop    %edi
80101651:	5d                   	pop    %ebp
80101652:	c3                   	ret    
80101653:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101659:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101660 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
80101660:	55                   	push   %ebp
80101661:	89 e5                	mov    %esp,%ebp
80101663:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
80101666:	a1 68 51 10 80       	mov    0x80105168,%eax
8010166b:	85 c0                	test   %eax,%eax
8010166d:	75 41                	jne    801016b0 <cons_getc+0x50>

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
    kbd_intr();
8010166f:	e8 dc f8 ff ff       	call   80100f50 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
80101674:	8b 15 60 51 10 80    	mov    0x80105160,%edx
        if (cons.rpos == CONSBUFSIZE) {
            cons.rpos = 0;
        }
        return c;
    }
    return 0;
8010167a:	31 c0                	xor    %eax,%eax
    if (cons.rpos != cons.wpos) {
8010167c:	3b 15 64 51 10 80    	cmp    0x80105164,%edx
80101682:	74 18                	je     8010169c <cons_getc+0x3c>
        c = cons.buf[cons.rpos ++];
80101684:	8d 4a 01             	lea    0x1(%edx),%ecx
80101687:	0f b6 82 60 4f 10 80 	movzbl -0x7fefb0a0(%edx),%eax
        if (cons.rpos == CONSBUFSIZE) {
8010168e:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
        c = cons.buf[cons.rpos ++];
80101694:	89 0d 60 51 10 80    	mov    %ecx,0x80105160
        if (cons.rpos == CONSBUFSIZE) {
8010169a:	74 04                	je     801016a0 <cons_getc+0x40>
}
8010169c:	c9                   	leave  
8010169d:	c3                   	ret    
8010169e:	66 90                	xchg   %ax,%ax
            cons.rpos = 0;
801016a0:	c7 05 60 51 10 80 00 	movl   $0x0,0x80105160
801016a7:	00 00 00 
}
801016aa:	c9                   	leave  
801016ab:	c3                   	ret    
801016ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801016b0:	e8 1b fa ff ff       	call   801010d0 <serial_intr.part.0>
801016b5:	eb b8                	jmp    8010166f <cons_getc+0xf>
801016b7:	66 90                	xchg   %ax,%ax
801016b9:	66 90                	xchg   %ax,%ax
801016bb:	66 90                	xchg   %ax,%ax
801016bd:	66 90                	xchg   %ax,%ax
801016bf:	90                   	nop

801016c0 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
801016c0:	55                   	push   %ebp
801016c1:	b8 34 00 00 00       	mov    $0x34,%eax
801016c6:	ba 43 00 00 00       	mov    $0x43,%edx
801016cb:	89 e5                	mov    %esp,%ebp
801016cd:	83 ec 14             	sub    $0x14,%esp
801016d0:	ee                   	out    %al,(%dx)
801016d1:	ba 40 00 00 00       	mov    $0x40,%edx
801016d6:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
801016db:	ee                   	out    %al,(%dx)
801016dc:	b8 2e 00 00 00       	mov    $0x2e,%eax
801016e1:	ee                   	out    %al,(%dx)
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
801016e2:	68 40 29 10 80       	push   $0x80102940
    ticks = 0;
801016e7:	c7 05 d0 61 10 80 00 	movl   $0x0,0x801061d0
801016ee:	00 00 00 
    cprintf("++ setup timer interrupts\n");
801016f1:	e8 0a 05 00 00       	call   80101c00 <cprintf>
    pic_enable(IRQ_TIMER);
801016f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801016fd:	e8 0e 00 00 00       	call   80101710 <pic_enable>
}
80101702:	83 c4 10             	add    $0x10,%esp
80101705:	c9                   	leave  
80101706:	c3                   	ret    
80101707:	66 90                	xchg   %ax,%ax
80101709:	66 90                	xchg   %ax,%ax
8010170b:	66 90                	xchg   %ax,%ax
8010170d:	66 90                	xchg   %ax,%ax
8010170f:	90                   	nop

80101710 <pic_enable>:
        outb(IO_PIC2 + 1, mask >> 8);
    }
}

void
pic_enable(unsigned int irq) {
80101710:	55                   	push   %ebp
    pic_setmask(irq_mask & ~(1 << irq));
80101711:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
    if (did_init) {
80101716:	8b 15 74 51 10 80    	mov    0x80105174,%edx
pic_enable(unsigned int irq) {
8010171c:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
8010171e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80101721:	d3 c0                	rol    %cl,%eax
80101723:	66 23 05 20 47 10 80 	and    0x80104720,%ax
    if (did_init) {
8010172a:	85 d2                	test   %edx,%edx
    irq_mask = mask;
8010172c:	66 a3 20 47 10 80    	mov    %ax,0x80104720
    if (did_init) {
80101732:	74 10                	je     80101744 <pic_enable+0x34>
80101734:	ba 21 00 00 00       	mov    $0x21,%edx
80101739:	ee                   	out    %al,(%dx)
8010173a:	ba a1 00 00 00       	mov    $0xa1,%edx
        outb(IO_PIC2 + 1, mask >> 8);
8010173f:	66 c1 e8 08          	shr    $0x8,%ax
80101743:	ee                   	out    %al,(%dx)
}
80101744:	5d                   	pop    %ebp
80101745:	c3                   	ret    
80101746:	8d 76 00             	lea    0x0(%esi),%esi
80101749:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101750 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
80101750:	55                   	push   %ebp
    did_init = 1;
80101751:	c7 05 74 51 10 80 01 	movl   $0x1,0x80105174
80101758:	00 00 00 
8010175b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
pic_init(void) {
80101760:	89 e5                	mov    %esp,%ebp
80101762:	57                   	push   %edi
80101763:	56                   	push   %esi
80101764:	53                   	push   %ebx
80101765:	bb 21 00 00 00       	mov    $0x21,%ebx
8010176a:	89 da                	mov    %ebx,%edx
8010176c:	ee                   	out    %al,(%dx)
8010176d:	b9 a1 00 00 00       	mov    $0xa1,%ecx
80101772:	89 ca                	mov    %ecx,%edx
80101774:	ee                   	out    %al,(%dx)
80101775:	be 11 00 00 00       	mov    $0x11,%esi
8010177a:	ba 20 00 00 00       	mov    $0x20,%edx
8010177f:	89 f0                	mov    %esi,%eax
80101781:	ee                   	out    %al,(%dx)
80101782:	b8 20 00 00 00       	mov    $0x20,%eax
80101787:	89 da                	mov    %ebx,%edx
80101789:	ee                   	out    %al,(%dx)
8010178a:	b8 04 00 00 00       	mov    $0x4,%eax
8010178f:	ee                   	out    %al,(%dx)
80101790:	bf 03 00 00 00       	mov    $0x3,%edi
80101795:	89 f8                	mov    %edi,%eax
80101797:	ee                   	out    %al,(%dx)
80101798:	ba a0 00 00 00       	mov    $0xa0,%edx
8010179d:	89 f0                	mov    %esi,%eax
8010179f:	ee                   	out    %al,(%dx)
801017a0:	b8 28 00 00 00       	mov    $0x28,%eax
801017a5:	89 ca                	mov    %ecx,%edx
801017a7:	ee                   	out    %al,(%dx)
801017a8:	b8 02 00 00 00       	mov    $0x2,%eax
801017ad:	ee                   	out    %al,(%dx)
801017ae:	89 f8                	mov    %edi,%eax
801017b0:	ee                   	out    %al,(%dx)
801017b1:	bf 68 00 00 00       	mov    $0x68,%edi
801017b6:	ba 20 00 00 00       	mov    $0x20,%edx
801017bb:	89 f8                	mov    %edi,%eax
801017bd:	ee                   	out    %al,(%dx)
801017be:	be 0a 00 00 00       	mov    $0xa,%esi
801017c3:	89 f0                	mov    %esi,%eax
801017c5:	ee                   	out    %al,(%dx)
801017c6:	ba a0 00 00 00       	mov    $0xa0,%edx
801017cb:	89 f8                	mov    %edi,%eax
801017cd:	ee                   	out    %al,(%dx)
801017ce:	89 f0                	mov    %esi,%eax
801017d0:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
801017d1:	0f b7 05 20 47 10 80 	movzwl 0x80104720,%eax
801017d8:	66 83 f8 ff          	cmp    $0xffff,%ax
801017dc:	74 0a                	je     801017e8 <pic_init+0x98>
801017de:	89 da                	mov    %ebx,%edx
801017e0:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
801017e1:	66 c1 e8 08          	shr    $0x8,%ax
801017e5:	89 ca                	mov    %ecx,%edx
801017e7:	ee                   	out    %al,(%dx)
        pic_setmask(irq_mask);
    }
}
801017e8:	5b                   	pop    %ebx
801017e9:	5e                   	pop    %esi
801017ea:	5f                   	pop    %edi
801017eb:	5d                   	pop    %ebp
801017ec:	c3                   	ret    
801017ed:	66 90                	xchg   %ax,%ax
801017ef:	90                   	nop

801017f0 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
801017f0:	55                   	push   %ebp
    size_t cnt = 0;
801017f1:	31 c0                	xor    %eax,%eax
strlen(const char *s) {
801017f3:	89 e5                	mov    %esp,%ebp
801017f5:	8b 55 08             	mov    0x8(%ebp),%edx
    while (*s ++ != '\0') {
801017f8:	80 3a 00             	cmpb   $0x0,(%edx)
801017fb:	74 0c                	je     80101809 <strlen+0x19>
801017fd:	8d 76 00             	lea    0x0(%esi),%esi
        cnt ++;
80101800:	83 c0 01             	add    $0x1,%eax
    while (*s ++ != '\0') {
80101803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80101807:	75 f7                	jne    80101800 <strlen+0x10>
    }
    return cnt;
}
80101809:	5d                   	pop    %ebp
8010180a:	c3                   	ret    
8010180b:	90                   	nop
8010180c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101810 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
80101810:	55                   	push   %ebp
    size_t cnt = 0;
80101811:	31 c0                	xor    %eax,%eax
strnlen(const char *s, size_t len) {
80101813:	89 e5                	mov    %esp,%ebp
80101815:	8b 55 0c             	mov    0xc(%ebp),%edx
80101818:	8b 4d 08             	mov    0x8(%ebp),%ecx
    while (cnt < len && *s ++ != '\0') {
8010181b:	85 d2                	test   %edx,%edx
8010181d:	74 1e                	je     8010183d <strnlen+0x2d>
8010181f:	80 39 00             	cmpb   $0x0,(%ecx)
80101822:	75 12                	jne    80101836 <strnlen+0x26>
80101824:	eb 17                	jmp    8010183d <strnlen+0x2d>
80101826:	8d 76 00             	lea    0x0(%esi),%esi
80101829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80101830:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
80101834:	74 07                	je     8010183d <strnlen+0x2d>
        cnt ++;
80101836:	83 c0 01             	add    $0x1,%eax
    while (cnt < len && *s ++ != '\0') {
80101839:	39 c2                	cmp    %eax,%edx
8010183b:	75 f3                	jne    80101830 <strnlen+0x20>
    }
    return cnt;
}
8010183d:	5d                   	pop    %ebp
8010183e:	c3                   	ret    
8010183f:	90                   	nop

80101840 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
80101840:	55                   	push   %ebp
80101841:	89 e5                	mov    %esp,%ebp
80101843:	57                   	push   %edi
80101844:	56                   	push   %esi
80101845:	8b 55 08             	mov    0x8(%ebp),%edx
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
80101848:	8b 75 0c             	mov    0xc(%ebp),%esi
8010184b:	89 d7                	mov    %edx,%edi
8010184d:	ac                   	lods   %ds:(%esi),%al
8010184e:	aa                   	stos   %al,%es:(%edi)
8010184f:	84 c0                	test   %al,%al
80101851:	75 fa                	jne    8010184d <strcpy+0xd>
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
80101853:	5e                   	pop    %esi
80101854:	89 d0                	mov    %edx,%eax
80101856:	5f                   	pop    %edi
80101857:	5d                   	pop    %ebp
80101858:	c3                   	ret    
80101859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101860 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
80101860:	55                   	push   %ebp
80101861:	89 e5                	mov    %esp,%ebp
80101863:	56                   	push   %esi
80101864:	53                   	push   %ebx
80101865:	8b 75 10             	mov    0x10(%ebp),%esi
80101868:	8b 45 08             	mov    0x8(%ebp),%eax
8010186b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    char *p = dst;
    while (len > 0) {
8010186e:	85 f6                	test   %esi,%esi
80101870:	74 20                	je     80101892 <strncpy+0x32>
80101872:	01 c6                	add    %eax,%esi
    char *p = dst;
80101874:	89 c2                	mov    %eax,%edx
80101876:	8d 76 00             	lea    0x0(%esi),%esi
80101879:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
        if ((*p = *src) != '\0') {
80101880:	0f b6 19             	movzbl (%ecx),%ebx
            src ++;
80101883:	80 fb 01             	cmp    $0x1,%bl
        if ((*p = *src) != '\0') {
80101886:	88 1a                	mov    %bl,(%edx)
            src ++;
80101888:	83 d9 ff             	sbb    $0xffffffff,%ecx
        }
        p ++, len --;
8010188b:	83 c2 01             	add    $0x1,%edx
    while (len > 0) {
8010188e:	39 f2                	cmp    %esi,%edx
80101890:	75 ee                	jne    80101880 <strncpy+0x20>
    }
    return dst;
}
80101892:	5b                   	pop    %ebx
80101893:	5e                   	pop    %esi
80101894:	5d                   	pop    %ebp
80101895:	c3                   	ret    
80101896:	8d 76 00             	lea    0x0(%esi),%esi
80101899:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801018a0 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
801018a0:	55                   	push   %ebp
801018a1:	89 e5                	mov    %esp,%ebp
801018a3:	57                   	push   %edi
801018a4:	56                   	push   %esi
    asm volatile (
801018a5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801018a8:	8b 75 08             	mov    0x8(%ebp),%esi
801018ab:	ac                   	lods   %ds:(%esi),%al
801018ac:	ae                   	scas   %es:(%edi),%al
801018ad:	75 08                	jne    801018b7 <strcmp+0x17>
801018af:	84 c0                	test   %al,%al
801018b1:	75 f8                	jne    801018ab <strcmp+0xb>
801018b3:	31 c0                	xor    %eax,%eax
801018b5:	eb 04                	jmp    801018bb <strcmp+0x1b>
801018b7:	19 c0                	sbb    %eax,%eax
801018b9:	0c 01                	or     $0x1,%al
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
801018bb:	5e                   	pop    %esi
801018bc:	5f                   	pop    %edi
801018bd:	5d                   	pop    %ebp
801018be:	c3                   	ret    
801018bf:	90                   	nop

801018c0 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
801018c0:	55                   	push   %ebp
801018c1:	89 e5                	mov    %esp,%ebp
801018c3:	57                   	push   %edi
801018c4:	56                   	push   %esi
801018c5:	8b 7d 10             	mov    0x10(%ebp),%edi
801018c8:	53                   	push   %ebx
801018c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801018cc:	8b 75 0c             	mov    0xc(%ebp),%esi
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
801018cf:	85 ff                	test   %edi,%edi
801018d1:	74 2f                	je     80101902 <strncmp+0x42>
801018d3:	0f b6 01             	movzbl (%ecx),%eax
801018d6:	0f b6 1e             	movzbl (%esi),%ebx
801018d9:	84 c0                	test   %al,%al
801018db:	74 37                	je     80101914 <strncmp+0x54>
801018dd:	38 c3                	cmp    %al,%bl
801018df:	75 33                	jne    80101914 <strncmp+0x54>
801018e1:	01 f7                	add    %esi,%edi
801018e3:	eb 13                	jmp    801018f8 <strncmp+0x38>
801018e5:	8d 76 00             	lea    0x0(%esi),%esi
801018e8:	0f b6 01             	movzbl (%ecx),%eax
801018eb:	84 c0                	test   %al,%al
801018ed:	74 21                	je     80101910 <strncmp+0x50>
801018ef:	0f b6 1a             	movzbl (%edx),%ebx
801018f2:	89 d6                	mov    %edx,%esi
801018f4:	38 d8                	cmp    %bl,%al
801018f6:	75 1c                	jne    80101914 <strncmp+0x54>
        n --, s1 ++, s2 ++;
801018f8:	8d 56 01             	lea    0x1(%esi),%edx
801018fb:	83 c1 01             	add    $0x1,%ecx
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
801018fe:	39 fa                	cmp    %edi,%edx
80101900:	75 e6                	jne    801018e8 <strncmp+0x28>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
}
80101902:	5b                   	pop    %ebx
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
80101903:	31 c0                	xor    %eax,%eax
}
80101905:	5e                   	pop    %esi
80101906:	5f                   	pop    %edi
80101907:	5d                   	pop    %ebp
80101908:	c3                   	ret    
80101909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101910:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
80101914:	29 d8                	sub    %ebx,%eax
}
80101916:	5b                   	pop    %ebx
80101917:	5e                   	pop    %esi
80101918:	5f                   	pop    %edi
80101919:	5d                   	pop    %ebp
8010191a:	c3                   	ret    
8010191b:	90                   	nop
8010191c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101920 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
80101920:	55                   	push   %ebp
80101921:	89 e5                	mov    %esp,%ebp
80101923:	53                   	push   %ebx
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    while (*s != '\0') {
8010192a:	0f b6 10             	movzbl (%eax),%edx
8010192d:	84 d2                	test   %dl,%dl
8010192f:	74 1d                	je     8010194e <strchr+0x2e>
        if (*s == c) {
80101931:	38 d3                	cmp    %dl,%bl
80101933:	89 d9                	mov    %ebx,%ecx
80101935:	75 0d                	jne    80101944 <strchr+0x24>
80101937:	eb 17                	jmp    80101950 <strchr+0x30>
80101939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101940:	38 ca                	cmp    %cl,%dl
80101942:	74 0c                	je     80101950 <strchr+0x30>
            return (char *)s;
        }
        s ++;
80101944:	83 c0 01             	add    $0x1,%eax
    while (*s != '\0') {
80101947:	0f b6 10             	movzbl (%eax),%edx
8010194a:	84 d2                	test   %dl,%dl
8010194c:	75 f2                	jne    80101940 <strchr+0x20>
    }
    return NULL;
8010194e:	31 c0                	xor    %eax,%eax
}
80101950:	5b                   	pop    %ebx
80101951:	5d                   	pop    %ebp
80101952:	c3                   	ret    
80101953:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101959:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101960 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
80101960:	55                   	push   %ebp
80101961:	89 e5                	mov    %esp,%ebp
80101963:	53                   	push   %ebx
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	8b 55 0c             	mov    0xc(%ebp),%edx
    while (*s != '\0') {
8010196a:	0f b6 18             	movzbl (%eax),%ebx
        if (*s == c) {
8010196d:	38 d3                	cmp    %dl,%bl
8010196f:	74 1d                	je     8010198e <strfind+0x2e>
80101971:	84 db                	test   %bl,%bl
80101973:	89 d1                	mov    %edx,%ecx
80101975:	75 0d                	jne    80101984 <strfind+0x24>
80101977:	eb 15                	jmp    8010198e <strfind+0x2e>
80101979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101980:	84 d2                	test   %dl,%dl
80101982:	74 0a                	je     8010198e <strfind+0x2e>
            break;
        }
        s ++;
80101984:	83 c0 01             	add    $0x1,%eax
    while (*s != '\0') {
80101987:	0f b6 10             	movzbl (%eax),%edx
        if (*s == c) {
8010198a:	38 ca                	cmp    %cl,%dl
8010198c:	75 f2                	jne    80101980 <strfind+0x20>
    }
    return (char *)s;
}
8010198e:	5b                   	pop    %ebx
8010198f:	5d                   	pop    %ebp
80101990:	c3                   	ret    
80101991:	eb 0d                	jmp    801019a0 <strtol>
80101993:	90                   	nop
80101994:	90                   	nop
80101995:	90                   	nop
80101996:	90                   	nop
80101997:	90                   	nop
80101998:	90                   	nop
80101999:	90                   	nop
8010199a:	90                   	nop
8010199b:	90                   	nop
8010199c:	90                   	nop
8010199d:	90                   	nop
8010199e:	90                   	nop
8010199f:	90                   	nop

801019a0 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
801019a0:	55                   	push   %ebp
801019a1:	89 e5                	mov    %esp,%ebp
801019a3:	57                   	push   %edi
801019a4:	56                   	push   %esi
801019a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801019a8:	53                   	push   %ebx
801019a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
801019ac:	0f b6 01             	movzbl (%ecx),%eax
801019af:	3c 20                	cmp    $0x20,%al
801019b1:	75 0f                	jne    801019c2 <strtol+0x22>
801019b3:	90                   	nop
801019b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s ++;
801019b8:	83 c1 01             	add    $0x1,%ecx
    while (*s == ' ' || *s == '\t') {
801019bb:	0f b6 01             	movzbl (%ecx),%eax
801019be:	3c 20                	cmp    $0x20,%al
801019c0:	74 f6                	je     801019b8 <strtol+0x18>
801019c2:	3c 09                	cmp    $0x9,%al
801019c4:	74 f2                	je     801019b8 <strtol+0x18>
    }

    // plus/minus sign
    if (*s == '+') {
801019c6:	3c 2b                	cmp    $0x2b,%al
801019c8:	0f 84 a2 00 00 00    	je     80101a70 <strtol+0xd0>
    int neg = 0;
801019ce:	31 ff                	xor    %edi,%edi
        s ++;
    }
    else if (*s == '-') {
801019d0:	3c 2d                	cmp    $0x2d,%al
801019d2:	0f 84 88 00 00 00    	je     80101a60 <strtol+0xc0>
        s ++, neg = 1;
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
801019d8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
801019de:	0f be 11             	movsbl (%ecx),%edx
801019e1:	75 12                	jne    801019f5 <strtol+0x55>
801019e3:	80 fa 30             	cmp    $0x30,%dl
801019e6:	0f 84 94 00 00 00    	je     80101a80 <strtol+0xe0>
        s += 2, base = 16;
    }
    else if (base == 0 && s[0] == '0') {
801019ec:	85 db                	test   %ebx,%ebx
801019ee:	75 05                	jne    801019f5 <strtol+0x55>
        s ++, base = 8;
    }
    else if (base == 0) {
        base = 10;
801019f0:	bb 0a 00 00 00       	mov    $0xa,%ebx
801019f5:	31 c0                	xor    %eax,%eax
801019f7:	89 5d 10             	mov    %ebx,0x10(%ebp)
801019fa:	eb 18                	jmp    80101a14 <strtol+0x74>
801019fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
            dig = *s - '0';
80101a00:	83 ea 30             	sub    $0x30,%edx
            dig = *s - 'A' + 10;
        }
        else {
            break;
        }
        if (dig >= base) {
80101a03:	3b 55 10             	cmp    0x10(%ebp),%edx
80101a06:	7d 28                	jge    80101a30 <strtol+0x90>
            break;
        }
        s ++, val = (val * base) + dig;
80101a08:	0f af 45 10          	imul   0x10(%ebp),%eax
80101a0c:	83 c1 01             	add    $0x1,%ecx
80101a0f:	01 d0                	add    %edx,%eax
80101a11:	0f be 11             	movsbl (%ecx),%edx
        if (*s >= '0' && *s <= '9') {
80101a14:	8d 72 d0             	lea    -0x30(%edx),%esi
80101a17:	89 f3                	mov    %esi,%ebx
80101a19:	80 fb 09             	cmp    $0x9,%bl
80101a1c:	76 e2                	jbe    80101a00 <strtol+0x60>
        else if (*s >= 'a' && *s <= 'z') {
80101a1e:	8d 72 9f             	lea    -0x61(%edx),%esi
80101a21:	89 f3                	mov    %esi,%ebx
80101a23:	80 fb 19             	cmp    $0x19,%bl
80101a26:	77 28                	ja     80101a50 <strtol+0xb0>
            dig = *s - 'a' + 10;
80101a28:	83 ea 57             	sub    $0x57,%edx
        if (dig >= base) {
80101a2b:	3b 55 10             	cmp    0x10(%ebp),%edx
80101a2e:	7c d8                	jl     80101a08 <strtol+0x68>
        // we don't properly detect overflow!
    }

    if (endptr) {
80101a30:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a33:	85 d2                	test   %edx,%edx
80101a35:	74 05                	je     80101a3c <strtol+0x9c>
        *endptr = (char *) s;
80101a37:	8b 75 0c             	mov    0xc(%ebp),%esi
80101a3a:	89 0e                	mov    %ecx,(%esi)
    }
    return (neg ? -val : val);
80101a3c:	89 c2                	mov    %eax,%edx
80101a3e:	f7 da                	neg    %edx
80101a40:	85 ff                	test   %edi,%edi
}
80101a42:	5b                   	pop    %ebx
    return (neg ? -val : val);
80101a43:	0f 45 c2             	cmovne %edx,%eax
}
80101a46:	5e                   	pop    %esi
80101a47:	5f                   	pop    %edi
80101a48:	5d                   	pop    %ebp
80101a49:	c3                   	ret    
80101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        else if (*s >= 'A' && *s <= 'Z') {
80101a50:	8d 72 bf             	lea    -0x41(%edx),%esi
80101a53:	89 f3                	mov    %esi,%ebx
80101a55:	80 fb 19             	cmp    $0x19,%bl
80101a58:	77 d6                	ja     80101a30 <strtol+0x90>
            dig = *s - 'A' + 10;
80101a5a:	83 ea 37             	sub    $0x37,%edx
80101a5d:	eb a4                	jmp    80101a03 <strtol+0x63>
80101a5f:	90                   	nop
        s ++, neg = 1;
80101a60:	83 c1 01             	add    $0x1,%ecx
80101a63:	bf 01 00 00 00       	mov    $0x1,%edi
80101a68:	e9 6b ff ff ff       	jmp    801019d8 <strtol+0x38>
80101a6d:	8d 76 00             	lea    0x0(%esi),%esi
        s ++;
80101a70:	83 c1 01             	add    $0x1,%ecx
    int neg = 0;
80101a73:	31 ff                	xor    %edi,%edi
80101a75:	e9 5e ff ff ff       	jmp    801019d8 <strtol+0x38>
80101a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
80101a80:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
80101a84:	3c 78                	cmp    $0x78,%al
80101a86:	74 18                	je     80101aa0 <strtol+0x100>
    else if (base == 0 && s[0] == '0') {
80101a88:	85 db                	test   %ebx,%ebx
80101a8a:	0f 85 65 ff ff ff    	jne    801019f5 <strtol+0x55>
        s ++, base = 8;
80101a90:	83 c1 01             	add    $0x1,%ecx
80101a93:	0f be d0             	movsbl %al,%edx
80101a96:	bb 08 00 00 00       	mov    $0x8,%ebx
80101a9b:	e9 55 ff ff ff       	jmp    801019f5 <strtol+0x55>
80101aa0:	0f be 51 02          	movsbl 0x2(%ecx),%edx
        s += 2, base = 16;
80101aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
80101aa9:	83 c1 02             	add    $0x2,%ecx
80101aac:	e9 44 ff ff ff       	jmp    801019f5 <strtol+0x55>
80101ab1:	eb 0d                	jmp    80101ac0 <memset>
80101ab3:	90                   	nop
80101ab4:	90                   	nop
80101ab5:	90                   	nop
80101ab6:	90                   	nop
80101ab7:	90                   	nop
80101ab8:	90                   	nop
80101ab9:	90                   	nop
80101aba:	90                   	nop
80101abb:	90                   	nop
80101abc:	90                   	nop
80101abd:	90                   	nop
80101abe:	90                   	nop
80101abf:	90                   	nop

80101ac0 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
80101ac0:	55                   	push   %ebp
80101ac1:	89 e5                	mov    %esp,%ebp
80101ac3:	57                   	push   %edi
80101ac4:	8b 55 08             	mov    0x8(%ebp),%edx
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
80101ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80101acd:	89 d7                	mov    %edx,%edi
80101acf:	f3 aa                	rep stos %al,%es:(%edi)
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
80101ad1:	89 d0                	mov    %edx,%eax
80101ad3:	5f                   	pop    %edi
80101ad4:	5d                   	pop    %ebp
80101ad5:	c3                   	ret    
80101ad6:	8d 76 00             	lea    0x0(%esi),%esi
80101ad9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ae0 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
80101ae0:	55                   	push   %ebp
80101ae1:	89 e5                	mov    %esp,%ebp
80101ae3:	57                   	push   %edi
80101ae4:	56                   	push   %esi
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
80101aeb:	8b 55 10             	mov    0x10(%ebp),%edx

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
80101aee:	39 f0                	cmp    %esi,%eax
80101af0:	72 16                	jb     80101b08 <memmove+0x28>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
80101af2:	8d 7a ff             	lea    -0x1(%edx),%edi
    asm volatile (
80101af5:	89 d1                	mov    %edx,%ecx
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
80101af7:	01 fe                	add    %edi,%esi
80101af9:	01 c7                	add    %eax,%edi
    asm volatile (
80101afb:	fd                   	std    
80101afc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
80101afe:	fc                   	cld    
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
80101aff:	5e                   	pop    %esi
80101b00:	5f                   	pop    %edi
80101b01:	5d                   	pop    %ebp
80101b02:	c3                   	ret    
80101b03:	90                   	nop
80101b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
80101b08:	89 d1                	mov    %edx,%ecx
    asm volatile (
80101b0a:	89 c7                	mov    %eax,%edi
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
80101b0c:	c1 e9 02             	shr    $0x2,%ecx
    asm volatile (
80101b0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
80101b11:	89 d1                	mov    %edx,%ecx
80101b13:	83 e1 03             	and    $0x3,%ecx
80101b16:	74 02                	je     80101b1a <memmove+0x3a>
80101b18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
80101b1a:	5e                   	pop    %esi
80101b1b:	5f                   	pop    %edi
80101b1c:	5d                   	pop    %ebp
80101b1d:	c3                   	ret    
80101b1e:	66 90                	xchg   %ax,%ax

80101b20 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
80101b20:	55                   	push   %ebp
80101b21:	89 e5                	mov    %esp,%ebp
80101b23:	57                   	push   %edi
80101b24:	56                   	push   %esi
80101b25:	8b 55 10             	mov    0x10(%ebp),%edx
80101b28:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2b:	8b 75 0c             	mov    0xc(%ebp),%esi
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
80101b2e:	89 d1                	mov    %edx,%ecx
    asm volatile (
80101b30:	89 c7                	mov    %eax,%edi
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
80101b32:	c1 e9 02             	shr    $0x2,%ecx
    asm volatile (
80101b35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
80101b37:	89 d1                	mov    %edx,%ecx
80101b39:	83 e1 03             	and    $0x3,%ecx
80101b3c:	74 02                	je     80101b40 <memcpy+0x20>
80101b3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
80101b40:	5e                   	pop    %esi
80101b41:	5f                   	pop    %edi
80101b42:	5d                   	pop    %ebp
80101b43:	c3                   	ret    
80101b44:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101b4a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101b50 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
80101b50:	55                   	push   %ebp
80101b51:	89 e5                	mov    %esp,%ebp
80101b53:	57                   	push   %edi
80101b54:	56                   	push   %esi
80101b55:	53                   	push   %ebx
80101b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
80101b59:	8b 75 08             	mov    0x8(%ebp),%esi
80101b5c:	8b 7d 0c             	mov    0xc(%ebp),%edi
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
80101b5f:	85 db                	test   %ebx,%ebx
80101b61:	74 29                	je     80101b8c <memcmp+0x3c>
        if (*s1 != *s2) {
80101b63:	0f b6 16             	movzbl (%esi),%edx
80101b66:	0f b6 0f             	movzbl (%edi),%ecx
80101b69:	38 d1                	cmp    %dl,%cl
80101b6b:	75 2b                	jne    80101b98 <memcmp+0x48>
80101b6d:	b8 01 00 00 00       	mov    $0x1,%eax
80101b72:	eb 14                	jmp    80101b88 <memcmp+0x38>
80101b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101b78:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80101b7c:	83 c0 01             	add    $0x1,%eax
80101b7f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80101b84:	38 ca                	cmp    %cl,%dl
80101b86:	75 10                	jne    80101b98 <memcmp+0x48>
    while (n -- > 0) {
80101b88:	39 c3                	cmp    %eax,%ebx
80101b8a:	75 ec                	jne    80101b78 <memcmp+0x28>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
}
80101b8c:	5b                   	pop    %ebx
    return 0;
80101b8d:	31 c0                	xor    %eax,%eax
}
80101b8f:	5e                   	pop    %esi
80101b90:	5f                   	pop    %edi
80101b91:	5d                   	pop    %ebp
80101b92:	c3                   	ret    
80101b93:	90                   	nop
80101b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
80101b98:	0f b6 c2             	movzbl %dl,%eax
}
80101b9b:	5b                   	pop    %ebx
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
80101b9c:	29 c8                	sub    %ecx,%eax
}
80101b9e:	5e                   	pop    %esi
80101b9f:	5f                   	pop    %edi
80101ba0:	5d                   	pop    %ebp
80101ba1:	c3                   	ret    
80101ba2:	66 90                	xchg   %ax,%ax
80101ba4:	66 90                	xchg   %ax,%ax
80101ba6:	66 90                	xchg   %ax,%ax
80101ba8:	66 90                	xchg   %ax,%ax
80101baa:	66 90                	xchg   %ax,%ax
80101bac:	66 90                	xchg   %ax,%ax
80101bae:	66 90                	xchg   %ax,%ax

80101bb0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
80101bb0:	55                   	push   %ebp
80101bb1:	89 e5                	mov    %esp,%ebp
80101bb3:	53                   	push   %ebx
80101bb4:	83 ec 10             	sub    $0x10,%esp
80101bb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    cons_putc(c);
80101bba:	ff 75 08             	pushl  0x8(%ebp)
80101bbd:	e8 fe f6 ff ff       	call   801012c0 <cons_putc>
    (*cnt) ++;
80101bc2:	83 03 01             	addl   $0x1,(%ebx)
}
80101bc5:	83 c4 10             	add    $0x10,%esp
80101bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101bcb:	c9                   	leave  
80101bcc:	c3                   	ret    
80101bcd:	8d 76 00             	lea    0x0(%esi),%esi

80101bd0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
80101bd0:	55                   	push   %ebp
80101bd1:	89 e5                	mov    %esp,%ebp
80101bd3:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
80101bd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80101bd9:	ff 75 0c             	pushl  0xc(%ebp)
80101bdc:	ff 75 08             	pushl  0x8(%ebp)
    int cnt = 0;
80101bdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
80101be6:	50                   	push   %eax
80101be7:	68 b0 1b 10 80       	push   $0x80101bb0
80101bec:	e8 af 01 00 00       	call   80101da0 <vprintfmt>
    return cnt;
}
80101bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf4:	c9                   	leave  
80101bf5:	c3                   	ret    
80101bf6:	8d 76 00             	lea    0x0(%esi),%esi
80101bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101c00 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
80101c00:	55                   	push   %ebp
80101c01:	89 e5                	mov    %esp,%ebp
80101c03:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
80101c06:	8d 45 0c             	lea    0xc(%ebp),%eax
    int cnt = 0;
80101c09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
80101c10:	50                   	push   %eax
80101c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
80101c14:	ff 75 08             	pushl  0x8(%ebp)
80101c17:	50                   	push   %eax
80101c18:	68 b0 1b 10 80       	push   $0x80101bb0
80101c1d:	e8 7e 01 00 00       	call   80101da0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
80101c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c25:	c9                   	leave  
80101c26:	c3                   	ret    
80101c27:	89 f6                	mov    %esi,%esi
80101c29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101c30 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
80101c30:	55                   	push   %ebp
80101c31:	89 e5                	mov    %esp,%ebp
    cons_putc(c);
}
80101c33:	5d                   	pop    %ebp
    cons_putc(c);
80101c34:	e9 87 f6 ff ff       	jmp    801012c0 <cons_putc>
80101c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101c40 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	56                   	push   %esi
80101c44:	53                   	push   %ebx
80101c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
80101c48:	0f be 13             	movsbl (%ebx),%edx
80101c4b:	84 d2                	test   %dl,%dl
80101c4d:	74 41                	je     80101c90 <cputs+0x50>
    int cnt = 0;
80101c4f:	31 f6                	xor    %esi,%esi
80101c51:	eb 07                	jmp    80101c5a <cputs+0x1a>
80101c53:	90                   	nop
80101c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    (*cnt) ++;
80101c58:	89 c6                	mov    %eax,%esi
    cons_putc(c);
80101c5a:	83 ec 0c             	sub    $0xc,%esp
80101c5d:	52                   	push   %edx
80101c5e:	e8 5d f6 ff ff       	call   801012c0 <cons_putc>
    while ((c = *str ++) != '\0') {
80101c63:	0f be 54 33 01       	movsbl 0x1(%ebx,%esi,1),%edx
80101c68:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
80101c6b:	8d 46 01             	lea    0x1(%esi),%eax
    while ((c = *str ++) != '\0') {
80101c6e:	84 d2                	test   %dl,%dl
80101c70:	75 e6                	jne    80101c58 <cputs+0x18>
80101c72:	83 c6 02             	add    $0x2,%esi
    cons_putc(c);
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	6a 0a                	push   $0xa
80101c7a:	e8 41 f6 ff ff       	call   801012c0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
80101c7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101c82:	89 f0                	mov    %esi,%eax
80101c84:	5b                   	pop    %ebx
80101c85:	5e                   	pop    %esi
80101c86:	5d                   	pop    %ebp
80101c87:	c3                   	ret    
80101c88:	90                   	nop
80101c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    while ((c = *str ++) != '\0') {
80101c90:	be 01 00 00 00       	mov    $0x1,%esi
80101c95:	eb de                	jmp    80101c75 <cputs+0x35>
80101c97:	89 f6                	mov    %esi,%esi
80101c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ca0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
80101ca0:	55                   	push   %ebp
80101ca1:	89 e5                	mov    %esp,%ebp
80101ca3:	83 ec 08             	sub    $0x8,%esp
80101ca6:	8d 76 00             	lea    0x0(%esi),%esi
80101ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    int c;
    while ((c = cons_getc()) == 0)
80101cb0:	e8 ab f9 ff ff       	call   80101660 <cons_getc>
80101cb5:	85 c0                	test   %eax,%eax
80101cb7:	74 f7                	je     80101cb0 <getchar+0x10>
        /* do nothing */;
    return c;
}
80101cb9:	c9                   	leave  
80101cba:	c3                   	ret    
80101cbb:	66 90                	xchg   %ax,%ax
80101cbd:	66 90                	xchg   %ax,%ax
80101cbf:	90                   	nop

80101cc0 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
80101cc0:	55                   	push   %ebp
80101cc1:	89 e5                	mov    %esp,%ebp
80101cc3:	57                   	push   %edi
80101cc4:	56                   	push   %esi
80101cc5:	53                   	push   %ebx
80101cc6:	89 c6                	mov    %eax,%esi
80101cc8:	89 d7                	mov    %edx,%edi
80101cca:	83 ec 2c             	sub    $0x2c,%esp
80101ccd:	8b 5d 14             	mov    0x14(%ebp),%ebx
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101cd9:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101cdc:	8b 5d 18             	mov    0x18(%ebp),%ebx
80101cdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ce2:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ce5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101ce8:	31 db                	xor    %ebx,%ebx
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
80101cea:	85 d2                	test   %edx,%edx
80101cec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101cef:	74 08                	je     80101cf9 <printnum+0x39>
80101cf1:	89 d0                	mov    %edx,%eax
80101cf3:	31 d2                	xor    %edx,%edx
80101cf5:	f7 f1                	div    %ecx
80101cf7:	89 c3                	mov    %eax,%ebx
80101cf9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101cfc:	f7 f1                	div    %ecx
80101cfe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101d01:	89 da                	mov    %ebx,%edx
80101d03:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101d06:	89 55 cc             	mov    %edx,-0x34(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
80101d09:	31 d2                	xor    %edx,%edx
    unsigned mod = do_div(result, base);
80101d0b:	89 45 c8             	mov    %eax,-0x38(%ebp)
80101d0e:	83 eb 01             	sub    $0x1,%ebx
    if (num >= base) {
80101d11:	3b 55 dc             	cmp    -0x24(%ebp),%edx
80101d14:	73 3a                	jae    80101d50 <printnum+0x90>
        printnum(putch, putdat, result, base, width - 1, padc);
80101d16:	83 ec 0c             	sub    $0xc,%esp
80101d19:	ff 75 e4             	pushl  -0x1c(%ebp)
80101d1c:	89 fa                	mov    %edi,%edx
80101d1e:	53                   	push   %ebx
80101d1f:	51                   	push   %ecx
80101d20:	89 f0                	mov    %esi,%eax
80101d22:	ff 75 cc             	pushl  -0x34(%ebp)
80101d25:	ff 75 c8             	pushl  -0x38(%ebp)
80101d28:	e8 93 ff ff ff       	call   80101cc0 <printnum>
80101d2d:	83 c4 20             	add    $0x20,%esp
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
80101d30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101d33:	89 7d 0c             	mov    %edi,0xc(%ebp)
80101d36:	0f be 80 5b 29 10 80 	movsbl -0x7fefd6a5(%eax),%eax
80101d3d:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
    putch("0123456789abcdef"[mod], putdat);
80101d43:	89 f0                	mov    %esi,%eax
}
80101d45:	5b                   	pop    %ebx
80101d46:	5e                   	pop    %esi
80101d47:	5f                   	pop    %edi
80101d48:	5d                   	pop    %ebp
    putch("0123456789abcdef"[mod], putdat);
80101d49:	ff e0                	jmp    *%eax
80101d4b:	90                   	nop
80101d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if (num >= base) {
80101d50:	76 26                	jbe    80101d78 <printnum+0xb8>
        while (-- width > 0)
80101d52:	85 db                	test   %ebx,%ebx
80101d54:	7e da                	jle    80101d30 <printnum+0x70>
80101d56:	8d 76 00             	lea    0x0(%esi),%esi
80101d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
            putch(padc, putdat);
80101d60:	83 ec 08             	sub    $0x8,%esp
80101d63:	57                   	push   %edi
80101d64:	ff 75 e4             	pushl  -0x1c(%ebp)
80101d67:	ff d6                	call   *%esi
        while (-- width > 0)
80101d69:	83 c4 10             	add    $0x10,%esp
80101d6c:	83 eb 01             	sub    $0x1,%ebx
80101d6f:	75 ef                	jne    80101d60 <printnum+0xa0>
80101d71:	eb bd                	jmp    80101d30 <printnum+0x70>
80101d73:	90                   	nop
80101d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if (num >= base) {
80101d78:	3b 4d d8             	cmp    -0x28(%ebp),%ecx
80101d7b:	76 99                	jbe    80101d16 <printnum+0x56>
80101d7d:	eb d3                	jmp    80101d52 <printnum+0x92>
80101d7f:	90                   	nop

80101d80 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
80101d80:	55                   	push   %ebp
80101d81:	89 e5                	mov    %esp,%ebp
80101d83:	8b 45 0c             	mov    0xc(%ebp),%eax
    b->cnt ++;
80101d86:	83 40 08 01          	addl   $0x1,0x8(%eax)
    if (b->buf < b->ebuf) {
80101d8a:	8b 10                	mov    (%eax),%edx
80101d8c:	3b 50 04             	cmp    0x4(%eax),%edx
80101d8f:	73 0a                	jae    80101d9b <sprintputch+0x1b>
        *b->buf ++ = ch;
80101d91:	8d 4a 01             	lea    0x1(%edx),%ecx
80101d94:	89 08                	mov    %ecx,(%eax)
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	88 02                	mov    %al,(%edx)
    }
}
80101d9b:	5d                   	pop    %ebp
80101d9c:	c3                   	ret    
80101d9d:	8d 76 00             	lea    0x0(%esi),%esi

80101da0 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
80101da0:	55                   	push   %ebp
80101da1:	89 e5                	mov    %esp,%ebp
80101da3:	57                   	push   %edi
80101da4:	56                   	push   %esi
80101da5:	53                   	push   %ebx
80101da6:	83 ec 2c             	sub    $0x2c,%esp
80101da9:	8b 7d 08             	mov    0x8(%ebp),%edi
80101dac:	8b 75 0c             	mov    0xc(%ebp),%esi
        while ((ch = *(unsigned char *)fmt ++) != '%') {
80101daf:	8b 45 10             	mov    0x10(%ebp),%eax
80101db2:	8d 58 01             	lea    0x1(%eax),%ebx
80101db5:	0f b6 00             	movzbl (%eax),%eax
80101db8:	83 f8 25             	cmp    $0x25,%eax
80101dbb:	75 19                	jne    80101dd6 <vprintfmt+0x36>
80101dbd:	eb 29                	jmp    80101de8 <vprintfmt+0x48>
80101dbf:	90                   	nop
            putch(ch, putdat);
80101dc0:	83 ec 08             	sub    $0x8,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
80101dc3:	83 c3 01             	add    $0x1,%ebx
            putch(ch, putdat);
80101dc6:	56                   	push   %esi
80101dc7:	50                   	push   %eax
80101dc8:	ff d7                	call   *%edi
        while ((ch = *(unsigned char *)fmt ++) != '%') {
80101dca:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
80101dce:	83 c4 10             	add    $0x10,%esp
80101dd1:	83 f8 25             	cmp    $0x25,%eax
80101dd4:	74 12                	je     80101de8 <vprintfmt+0x48>
            if (ch == '\0') {
80101dd6:	85 c0                	test   %eax,%eax
80101dd8:	75 e6                	jne    80101dc0 <vprintfmt+0x20>
}
80101dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ddd:	5b                   	pop    %ebx
80101dde:	5e                   	pop    %esi
80101ddf:	5f                   	pop    %edi
80101de0:	5d                   	pop    %ebp
80101de1:	c3                   	ret    
80101de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        char padc = ' ';
80101de8:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
        lflag = altflag = 0;
80101dec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
        width = precision = -1;
80101df3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
        lflag = altflag = 0;
80101df8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
        width = precision = -1;
80101dff:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
        switch (ch = *(unsigned char *)fmt ++) {
80101e06:	0f b6 0b             	movzbl (%ebx),%ecx
80101e09:	8d 43 01             	lea    0x1(%ebx),%eax
80101e0c:	89 45 10             	mov    %eax,0x10(%ebp)
80101e0f:	8d 41 dd             	lea    -0x23(%ecx),%eax
80101e12:	3c 55                	cmp    $0x55,%al
80101e14:	0f 87 ab 02 00 00    	ja     801020c5 <vprintfmt+0x325>
80101e1a:	0f b6 c0             	movzbl %al,%eax
80101e1d:	ff 24 85 e4 29 10 80 	jmp    *-0x7fefd61c(,%eax,4)
80101e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
            padc = '0';
80101e27:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
80101e2b:	eb d9                	jmp    80101e06 <vprintfmt+0x66>
                ch = *fmt;
80101e2d:	0f be 43 01          	movsbl 0x1(%ebx),%eax
        switch (ch = *(unsigned char *)fmt ++) {
80101e31:	0f b6 d1             	movzbl %cl,%edx
80101e34:	8b 5d 10             	mov    0x10(%ebp),%ebx
                precision = precision * 10 + ch - '0';
80101e37:	83 ea 30             	sub    $0x30,%edx
                if (ch < '0' || ch > '9') {
80101e3a:	8d 48 d0             	lea    -0x30(%eax),%ecx
80101e3d:	83 f9 09             	cmp    $0x9,%ecx
80101e40:	0f 87 12 02 00 00    	ja     80102058 <vprintfmt+0x2b8>
80101e46:	8d 76 00             	lea    0x0(%esi),%esi
80101e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
                precision = precision * 10 + ch - '0';
80101e50:	8d 14 92             	lea    (%edx,%edx,4),%edx
            for (precision = 0; ; ++ fmt) {
80101e53:	83 c3 01             	add    $0x1,%ebx
                precision = precision * 10 + ch - '0';
80101e56:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
                ch = *fmt;
80101e5a:	0f be 03             	movsbl (%ebx),%eax
                if (ch < '0' || ch > '9') {
80101e5d:	8d 48 d0             	lea    -0x30(%eax),%ecx
80101e60:	83 f9 09             	cmp    $0x9,%ecx
80101e63:	76 eb                	jbe    80101e50 <vprintfmt+0xb0>
80101e65:	e9 ee 01 00 00       	jmp    80102058 <vprintfmt+0x2b8>
            putch(va_arg(ap, int), putdat);
80101e6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101e6d:	83 ec 08             	sub    $0x8,%esp
80101e70:	56                   	push   %esi
80101e71:	8d 58 04             	lea    0x4(%eax),%ebx
80101e74:	ff 30                	pushl  (%eax)
80101e76:	ff d7                	call   *%edi
            break;
80101e78:	83 c4 10             	add    $0x10,%esp
            putch(va_arg(ap, int), putdat);
80101e7b:	89 5d 14             	mov    %ebx,0x14(%ebp)
            break;
80101e7e:	e9 2c ff ff ff       	jmp    80101daf <vprintfmt+0xf>
    if (lflag >= 2) {
80101e83:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
        return va_arg(*ap, long long);
80101e87:	8b 45 14             	mov    0x14(%ebp),%eax
    if (lflag >= 2) {
80101e8a:	0f 8e 25 03 00 00    	jle    801021b5 <vprintfmt+0x415>
        return va_arg(*ap, long long);
80101e90:	8b 08                	mov    (%eax),%ecx
80101e92:	8b 58 04             	mov    0x4(%eax),%ebx
80101e95:	83 c0 08             	add    $0x8,%eax
80101e98:	89 45 14             	mov    %eax,0x14(%ebp)
            if ((long long)num < 0) {
80101e9b:	85 db                	test   %ebx,%ebx
80101e9d:	0f 89 6a 03 00 00    	jns    8010220d <vprintfmt+0x46d>
                putch('-', putdat);
80101ea3:	83 ec 08             	sub    $0x8,%esp
80101ea6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80101ea9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
80101eac:	56                   	push   %esi
80101ead:	6a 2d                	push   $0x2d
80101eaf:	ff d7                	call   *%edi
                num = -(long long)num;
80101eb1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80101eb4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80101eb7:	b8 0a 00 00 00       	mov    $0xa,%eax
80101ebc:	f7 d9                	neg    %ecx
80101ebe:	83 d3 00             	adc    $0x0,%ebx
80101ec1:	89 ca                	mov    %ecx,%edx
80101ec3:	83 c4 10             	add    $0x10,%esp
80101ec6:	f7 db                	neg    %ebx
80101ec8:	89 d9                	mov    %ebx,%ecx
80101eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            printnum(putch, putdat, num, base, width, padc);
80101ed0:	0f be 5d e0          	movsbl -0x20(%ebp),%ebx
80101ed4:	83 ec 0c             	sub    $0xc,%esp
80101ed7:	53                   	push   %ebx
80101ed8:	ff 75 e4             	pushl  -0x1c(%ebp)
80101edb:	50                   	push   %eax
80101edc:	51                   	push   %ecx
80101edd:	89 f8                	mov    %edi,%eax
80101edf:	52                   	push   %edx
80101ee0:	89 f2                	mov    %esi,%edx
80101ee2:	e8 d9 fd ff ff       	call   80101cc0 <printnum>
            break;
80101ee7:	83 c4 20             	add    $0x20,%esp
80101eea:	e9 c0 fe ff ff       	jmp    80101daf <vprintfmt+0xf>
            err = va_arg(ap, int);
80101eef:	8b 45 14             	mov    0x14(%ebp),%eax
80101ef2:	8d 58 04             	lea    0x4(%eax),%ebx
80101ef5:	8b 00                	mov    (%eax),%eax
80101ef7:	99                   	cltd   
80101ef8:	31 d0                	xor    %edx,%eax
80101efa:	29 d0                	sub    %edx,%eax
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
80101efc:	83 f8 06             	cmp    $0x6,%eax
80101eff:	0f 8f ec 01 00 00    	jg     801020f1 <vprintfmt+0x351>
80101f05:	8b 14 85 3c 2b 10 80 	mov    -0x7fefd4c4(,%eax,4),%edx
80101f0c:	85 d2                	test   %edx,%edx
80101f0e:	0f 84 dd 01 00 00    	je     801020f1 <vprintfmt+0x351>
                printfmt(putch, putdat, "%s", p);
80101f14:	52                   	push   %edx
80101f15:	68 7c 29 10 80       	push   $0x8010297c
80101f1a:	e9 d8 01 00 00       	jmp    801020f7 <vprintfmt+0x357>
            lflag ++;
80101f1f:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
        switch (ch = *(unsigned char *)fmt ++) {
80101f23:	8b 5d 10             	mov    0x10(%ebp),%ebx
            goto reswitch;
80101f26:	e9 db fe ff ff       	jmp    80101e06 <vprintfmt+0x66>
    if (lflag >= 2) {
80101f2b:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
        return va_arg(*ap, unsigned long long);
80101f2f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f32:	8b 10                	mov    (%eax),%edx
    if (lflag >= 2) {
80101f34:	0f 8e 6b 02 00 00    	jle    801021a5 <vprintfmt+0x405>
        return va_arg(*ap, unsigned long long);
80101f3a:	8b 48 04             	mov    0x4(%eax),%ecx
80101f3d:	83 c0 08             	add    $0x8,%eax
80101f40:	89 45 14             	mov    %eax,0x14(%ebp)
80101f43:	b8 08 00 00 00       	mov    $0x8,%eax
80101f48:	eb 86                	jmp    80101ed0 <vprintfmt+0x130>
            putch('0', putdat);
80101f4a:	83 ec 08             	sub    $0x8,%esp
80101f4d:	56                   	push   %esi
80101f4e:	6a 30                	push   $0x30
80101f50:	ff d7                	call   *%edi
            putch('x', putdat);
80101f52:	5a                   	pop    %edx
80101f53:	59                   	pop    %ecx
80101f54:	56                   	push   %esi
80101f55:	6a 78                	push   $0x78
80101f57:	ff d7                	call   *%edi
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
80101f59:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5c:	31 c9                	xor    %ecx,%ecx
            goto number;
80101f5e:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
80101f61:	8b 10                	mov    (%eax),%edx
80101f63:	83 c0 04             	add    $0x4,%eax
80101f66:	89 45 14             	mov    %eax,0x14(%ebp)
            goto number;
80101f69:	b8 10 00 00 00       	mov    $0x10,%eax
80101f6e:	e9 5d ff ff ff       	jmp    80101ed0 <vprintfmt+0x130>
            if ((p = va_arg(ap, char *)) == NULL) {
80101f73:	8b 45 14             	mov    0x14(%ebp),%eax
80101f76:	83 c0 04             	add    $0x4,%eax
80101f79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101f7c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f7f:	8b 18                	mov    (%eax),%ebx
80101f81:	85 db                	test   %ebx,%ebx
80101f83:	0f 84 63 02 00 00    	je     801021ec <vprintfmt+0x44c>
            if (width > 0 && padc != '-') {
80101f89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101f8c:	8d 4b 01             	lea    0x1(%ebx),%ecx
80101f8f:	85 c0                	test   %eax,%eax
80101f91:	0f 8e 72 01 00 00    	jle    80102109 <vprintfmt+0x369>
80101f97:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
80101f9b:	0f 84 68 01 00 00    	je     80102109 <vprintfmt+0x369>
                for (width -= strnlen(p, precision); width > 0; width --) {
80101fa1:	83 ec 08             	sub    $0x8,%esp
80101fa4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80101fa7:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101faa:	52                   	push   %edx
80101fab:	53                   	push   %ebx
80101fac:	e8 5f f8 ff ff       	call   80101810 <strnlen>
80101fb1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101fb4:	83 c4 10             	add    $0x10,%esp
80101fb7:	8b 55 d0             	mov    -0x30(%ebp),%edx
80101fba:	29 c1                	sub    %eax,%ecx
80101fbc:	85 c9                	test   %ecx,%ecx
80101fbe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101fc1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
80101fc4:	7e 3a                	jle    80102000 <vprintfmt+0x260>
80101fc6:	0f be 45 e0          	movsbl -0x20(%ebp),%eax
80101fca:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80101fcd:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101fd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101fd6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101fd9:	89 c3                	mov    %eax,%ebx
                    putch(padc, putdat);
80101fdb:	83 ec 08             	sub    $0x8,%esp
80101fde:	56                   	push   %esi
80101fdf:	ff 75 e0             	pushl  -0x20(%ebp)
80101fe2:	ff d7                	call   *%edi
                for (width -= strnlen(p, precision); width > 0; width --) {
80101fe4:	83 c4 10             	add    $0x10,%esp
80101fe7:	83 eb 01             	sub    $0x1,%ebx
80101fea:	75 ef                	jne    80101fdb <vprintfmt+0x23b>
80101fec:	b8 01 00 00 00       	mov    $0x1,%eax
80101ff1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80101ff4:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101ff7:	83 e8 01             	sub    $0x1,%eax
80101ffa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101ffd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
80102000:	0f be 03             	movsbl (%ebx),%eax
80102003:	85 c0                	test   %eax,%eax
80102005:	89 c3                	mov    %eax,%ebx
80102007:	0f 85 05 01 00 00    	jne    80102112 <vprintfmt+0x372>
            if ((p = va_arg(ap, char *)) == NULL) {
8010200d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102010:	89 45 14             	mov    %eax,0x14(%ebp)
80102013:	e9 97 fd ff ff       	jmp    80101daf <vprintfmt+0xf>
    if (lflag >= 2) {
80102018:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
        return va_arg(*ap, unsigned long long);
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
8010201f:	8b 10                	mov    (%eax),%edx
    if (lflag >= 2) {
80102021:	0f 8e b5 01 00 00    	jle    801021dc <vprintfmt+0x43c>
        return va_arg(*ap, unsigned long long);
80102027:	8b 48 04             	mov    0x4(%eax),%ecx
8010202a:	83 c0 08             	add    $0x8,%eax
8010202d:	89 45 14             	mov    %eax,0x14(%ebp)
80102030:	b8 0a 00 00 00       	mov    $0xa,%eax
80102035:	e9 96 fe ff ff       	jmp    80101ed0 <vprintfmt+0x130>
            putch(ch, putdat);
8010203a:	83 ec 08             	sub    $0x8,%esp
8010203d:	56                   	push   %esi
8010203e:	6a 25                	push   $0x25
80102040:	ff d7                	call   *%edi
            break;
80102042:	83 c4 10             	add    $0x10,%esp
80102045:	e9 65 fd ff ff       	jmp    80101daf <vprintfmt+0xf>
            precision = va_arg(ap, int);
8010204a:	8b 45 14             	mov    0x14(%ebp),%eax
        switch (ch = *(unsigned char *)fmt ++) {
8010204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
            precision = va_arg(ap, int);
80102050:	8b 10                	mov    (%eax),%edx
80102052:	83 c0 04             	add    $0x4,%eax
80102055:	89 45 14             	mov    %eax,0x14(%ebp)
            if (width < 0)
80102058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010205b:	85 c0                	test   %eax,%eax
8010205d:	0f 89 a3 fd ff ff    	jns    80101e06 <vprintfmt+0x66>
                width = precision, precision = -1;
80102063:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80102066:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010206b:	e9 96 fd ff ff       	jmp    80101e06 <vprintfmt+0x66>
        switch (ch = *(unsigned char *)fmt ++) {
80102070:	8b 5d 10             	mov    0x10(%ebp),%ebx
            padc = '-';
80102073:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
80102077:	e9 8a fd ff ff       	jmp    80101e06 <vprintfmt+0x66>
8010207c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010207f:	b9 00 00 00 00       	mov    $0x0,%ecx
        switch (ch = *(unsigned char *)fmt ++) {
80102084:	8b 5d 10             	mov    0x10(%ebp),%ebx
80102087:	85 c0                	test   %eax,%eax
80102089:	0f 49 c8             	cmovns %eax,%ecx
8010208c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010208f:	e9 72 fd ff ff       	jmp    80101e06 <vprintfmt+0x66>
    if (lflag >= 2) {
80102094:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
        return va_arg(*ap, unsigned long long);
80102098:	8b 45 14             	mov    0x14(%ebp),%eax
8010209b:	8b 10                	mov    (%eax),%edx
    if (lflag >= 2) {
8010209d:	0f 8e 29 01 00 00    	jle    801021cc <vprintfmt+0x42c>
        return va_arg(*ap, unsigned long long);
801020a3:	8b 48 04             	mov    0x4(%eax),%ecx
801020a6:	83 c0 08             	add    $0x8,%eax
801020a9:	89 45 14             	mov    %eax,0x14(%ebp)
801020ac:	b8 10 00 00 00       	mov    $0x10,%eax
801020b1:	e9 1a fe ff ff       	jmp    80101ed0 <vprintfmt+0x130>
        switch (ch = *(unsigned char *)fmt ++) {
801020b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
            altflag = 1;
801020b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
            goto reswitch;
801020c0:	e9 41 fd ff ff       	jmp    80101e06 <vprintfmt+0x66>
            putch('%', putdat);
801020c5:	83 ec 08             	sub    $0x8,%esp
801020c8:	56                   	push   %esi
801020c9:	6a 25                	push   $0x25
801020cb:	ff d7                	call   *%edi
            for (fmt --; fmt[-1] != '%'; fmt --)
801020cd:	83 c4 10             	add    $0x10,%esp
801020d0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
801020d4:	89 5d 10             	mov    %ebx,0x10(%ebp)
801020d7:	0f 84 d2 fc ff ff    	je     80101daf <vprintfmt+0xf>
801020dd:	89 d8                	mov    %ebx,%eax
801020df:	90                   	nop
801020e0:	83 e8 01             	sub    $0x1,%eax
801020e3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
801020e7:	75 f7                	jne    801020e0 <vprintfmt+0x340>
801020e9:	89 45 10             	mov    %eax,0x10(%ebp)
801020ec:	e9 be fc ff ff       	jmp    80101daf <vprintfmt+0xf>
                printfmt(putch, putdat, "error %d", err);
801020f1:	50                   	push   %eax
801020f2:	68 73 29 10 80       	push   $0x80102973
                printfmt(putch, putdat, "%s", p);
801020f7:	56                   	push   %esi
801020f8:	57                   	push   %edi
801020f9:	e8 32 01 00 00       	call   80102230 <printfmt>
801020fe:	83 c4 10             	add    $0x10,%esp
            err = va_arg(ap, int);
80102101:	89 5d 14             	mov    %ebx,0x14(%ebp)
80102104:	e9 a6 fc ff ff       	jmp    80101daf <vprintfmt+0xf>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
80102109:	0f be 03             	movsbl (%ebx),%eax
8010210c:	85 c0                	test   %eax,%eax
8010210e:	89 c3                	mov    %eax,%ebx
80102110:	74 70                	je     80102182 <vprintfmt+0x3e2>
80102112:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102115:	89 7d 08             	mov    %edi,0x8(%ebp)
80102118:	0f be d3             	movsbl %bl,%edx
8010211b:	89 75 0c             	mov    %esi,0xc(%ebp)
8010211e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80102121:	89 ce                	mov    %ecx,%esi
80102123:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80102126:	eb 26                	jmp    8010214e <vprintfmt+0x3ae>
80102128:	90                   	nop
80102129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
                    putch(ch, putdat);
80102130:	83 ec 08             	sub    $0x8,%esp
80102133:	ff 75 0c             	pushl  0xc(%ebp)
80102136:	50                   	push   %eax
80102137:	ff 55 08             	call   *0x8(%ebp)
8010213a:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
8010213d:	83 c6 01             	add    $0x1,%esi
80102140:	0f be 56 ff          	movsbl -0x1(%esi),%edx
80102144:	83 ef 01             	sub    $0x1,%edi
80102147:	0f be c2             	movsbl %dl,%eax
8010214a:	85 c0                	test   %eax,%eax
8010214c:	74 2b                	je     80102179 <vprintfmt+0x3d9>
8010214e:	85 db                	test   %ebx,%ebx
80102150:	78 08                	js     8010215a <vprintfmt+0x3ba>
80102152:	83 eb 01             	sub    $0x1,%ebx
80102155:	83 fb ff             	cmp    $0xffffffff,%ebx
80102158:	74 1f                	je     80102179 <vprintfmt+0x3d9>
                if (altflag && (ch < ' ' || ch > '~')) {
8010215a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
8010215d:	85 c9                	test   %ecx,%ecx
8010215f:	74 cf                	je     80102130 <vprintfmt+0x390>
80102161:	83 ea 20             	sub    $0x20,%edx
80102164:	83 fa 5e             	cmp    $0x5e,%edx
80102167:	76 c7                	jbe    80102130 <vprintfmt+0x390>
                    putch('?', putdat);
80102169:	83 ec 08             	sub    $0x8,%esp
8010216c:	ff 75 0c             	pushl  0xc(%ebp)
8010216f:	6a 3f                	push   $0x3f
80102171:	ff 55 08             	call   *0x8(%ebp)
80102174:	83 c4 10             	add    $0x10,%esp
80102177:	eb c4                	jmp    8010213d <vprintfmt+0x39d>
80102179:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010217c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010217f:	8b 7d 08             	mov    0x8(%ebp),%edi
            for (; width > 0; width --) {
80102182:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80102185:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80102188:	85 c9                	test   %ecx,%ecx
8010218a:	0f 8e 7d fe ff ff    	jle    8010200d <vprintfmt+0x26d>
                putch(' ', putdat);
80102190:	83 ec 08             	sub    $0x8,%esp
80102193:	56                   	push   %esi
80102194:	6a 20                	push   $0x20
80102196:	ff d7                	call   *%edi
            for (; width > 0; width --) {
80102198:	83 c4 10             	add    $0x10,%esp
8010219b:	83 eb 01             	sub    $0x1,%ebx
8010219e:	75 f0                	jne    80102190 <vprintfmt+0x3f0>
801021a0:	e9 68 fe ff ff       	jmp    8010200d <vprintfmt+0x26d>
801021a5:	31 c9                	xor    %ecx,%ecx
801021a7:	83 45 14 04          	addl   $0x4,0x14(%ebp)
    if (lflag >= 2) {
801021ab:	b8 08 00 00 00       	mov    $0x8,%eax
801021b0:	e9 1b fd ff ff       	jmp    80101ed0 <vprintfmt+0x130>
        return va_arg(*ap, long);
801021b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021b8:	83 c0 04             	add    $0x4,%eax
801021bb:	8b 11                	mov    (%ecx),%edx
801021bd:	89 45 14             	mov    %eax,0x14(%ebp)
801021c0:	89 d3                	mov    %edx,%ebx
801021c2:	89 d1                	mov    %edx,%ecx
801021c4:	c1 fb 1f             	sar    $0x1f,%ebx
801021c7:	e9 cf fc ff ff       	jmp    80101e9b <vprintfmt+0xfb>
801021cc:	31 c9                	xor    %ecx,%ecx
801021ce:	83 45 14 04          	addl   $0x4,0x14(%ebp)
    if (lflag >= 2) {
801021d2:	b8 10 00 00 00       	mov    $0x10,%eax
801021d7:	e9 f4 fc ff ff       	jmp    80101ed0 <vprintfmt+0x130>
801021dc:	31 c9                	xor    %ecx,%ecx
801021de:	83 45 14 04          	addl   $0x4,0x14(%ebp)
801021e2:	b8 0a 00 00 00       	mov    $0xa,%eax
801021e7:	e9 e4 fc ff ff       	jmp    80101ed0 <vprintfmt+0x130>
            if (width > 0 && padc != '-') {
801021ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801021ef:	b9 6d 29 10 80       	mov    $0x8010296d,%ecx
801021f4:	85 c0                	test   %eax,%eax
801021f6:	7e 06                	jle    801021fe <vprintfmt+0x45e>
801021f8:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
801021fc:	75 1d                	jne    8010221b <vprintfmt+0x47b>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
801021fe:	b8 28 00 00 00       	mov    $0x28,%eax
80102203:	bb 28 00 00 00       	mov    $0x28,%ebx
80102208:	e9 05 ff ff ff       	jmp    80102112 <vprintfmt+0x372>
            num = getint(&ap, lflag);
8010220d:	89 ca                	mov    %ecx,%edx
8010220f:	b8 0a 00 00 00       	mov    $0xa,%eax
80102214:	89 d9                	mov    %ebx,%ecx
80102216:	e9 b5 fc ff ff       	jmp    80101ed0 <vprintfmt+0x130>
                p = "(null)";
8010221b:	bb 6c 29 10 80       	mov    $0x8010296c,%ebx
80102220:	e9 7c fd ff ff       	jmp    80101fa1 <vprintfmt+0x201>
80102225:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102230 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
80102230:	55                   	push   %ebp
80102231:	89 e5                	mov    %esp,%ebp
80102233:	83 ec 08             	sub    $0x8,%esp
    va_start(ap, fmt);
80102236:	8d 45 14             	lea    0x14(%ebp),%eax
    vprintfmt(putch, putdat, fmt, ap);
80102239:	50                   	push   %eax
8010223a:	ff 75 10             	pushl  0x10(%ebp)
8010223d:	ff 75 0c             	pushl  0xc(%ebp)
80102240:	ff 75 08             	pushl  0x8(%ebp)
80102243:	e8 58 fb ff ff       	call   80101da0 <vprintfmt>
}
80102248:	83 c4 10             	add    $0x10,%esp
8010224b:	c9                   	leave  
8010224c:	c3                   	ret    
8010224d:	8d 76 00             	lea    0x0(%esi),%esi

80102250 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
80102250:	55                   	push   %ebp
80102251:	89 e5                	mov    %esp,%ebp
80102253:	83 ec 18             	sub    $0x18,%esp
80102256:	8b 45 08             	mov    0x8(%ebp),%eax
    struct sprintbuf b = {str, str + size - 1, 0};
80102259:	8b 55 0c             	mov    0xc(%ebp),%edx
8010225c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102263:	8d 54 10 ff          	lea    -0x1(%eax,%edx,1),%edx
80102267:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
8010226a:	39 c2                	cmp    %eax,%edx
    struct sprintbuf b = {str, str + size - 1, 0};
8010226c:	89 55 f0             	mov    %edx,-0x10(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
8010226f:	72 2f                	jb     801022a0 <vsnprintf+0x50>
80102271:	85 c0                	test   %eax,%eax
80102273:	74 2b                	je     801022a0 <vsnprintf+0x50>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
80102275:	8d 45 ec             	lea    -0x14(%ebp),%eax
80102278:	ff 75 14             	pushl  0x14(%ebp)
8010227b:	ff 75 10             	pushl  0x10(%ebp)
8010227e:	50                   	push   %eax
8010227f:	68 80 1d 10 80       	push   $0x80101d80
80102284:	e8 17 fb ff ff       	call   80101da0 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
80102289:	8b 45 ec             	mov    -0x14(%ebp),%eax
    return b.cnt;
8010228c:	83 c4 10             	add    $0x10,%esp
    *b.buf = '\0';
8010228f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
80102292:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102295:	c9                   	leave  
80102296:	c3                   	ret    
80102297:	89 f6                	mov    %esi,%esi
80102299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
        return -E_INVAL;
801022a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
801022a5:	c9                   	leave  
801022a6:	c3                   	ret    
801022a7:	89 f6                	mov    %esi,%esi
801022a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801022b0 <snprintf>:
snprintf(char *str, size_t size, const char *fmt, ...) {
801022b0:	55                   	push   %ebp
801022b1:	89 e5                	mov    %esp,%ebp
801022b3:	83 ec 08             	sub    $0x8,%esp
    va_start(ap, fmt);
801022b6:	8d 45 14             	lea    0x14(%ebp),%eax
    cnt = vsnprintf(str, size, fmt, ap);
801022b9:	50                   	push   %eax
801022ba:	ff 75 10             	pushl  0x10(%ebp)
801022bd:	ff 75 0c             	pushl  0xc(%ebp)
801022c0:	ff 75 08             	pushl  0x8(%ebp)
801022c3:	e8 88 ff ff ff       	call   80102250 <vsnprintf>
}
801022c8:	c9                   	leave  
801022c9:	c3                   	ret    
