#include <x86.h>
#include <defs.h>
#include <idt.h>
#include <memlayout.h>
#include <trap.h>


/*
 * 根据https://wiki.osdev.org/IDT
 * 实现一个idt描述符，64位-8bytes-long
 */ 
struct idt_entry {
	uint16_t offset_1;
	uint16_t selector;
	uint8_t  zero;
	uint8_t  type_attr;
	uint16_t offset_2;
};

/* 更加详细易操作的idt描述符，位域实现
 * 
 *  			IDT entry, Interrupt Gates
 * ------------------------------------------------------------------------------------------------
 * Name	 	Bit				FullName&&&&&&&&&&&&&Description
 * Offset	48..63		 Offset 16..31		Higher part of the offset.
 * P		47			 Present		    Set to 0 for unused interrupts.
 * DPL		45,46		 Descriptor Privilege Level	Gate call protection. Specifies which privilege Level the calling Descriptor minimum should have. So hardware and CPU interrupts can be protected from being called out of userspace.
 * S		44			 Storage Segment	Set to 0 for interrupt and trap gates (see below).
 * Type		40..43		 Gate Type 0..3	Possible IDT gate types :
 * 								0b0101	0x5	5	80386 32 bit task gate
 * 								0b0110	0x6	6	80286 16-bit interrupt gate
 * 								0b0111	0x7	7	80286 16-bit trap gate
 * 								0b1110	0xE	14	80386 32-bit interrupt gate
 * 								0b1111	0xF	15	80386 32-bit trap gate
 * 0		32..39		Unused 0..7	Have to be 0.
 * Selector	16..31		Selector 0..15	Selector of the interrupt function (to make sense - the kernel's selector). The selector's descriptor's DPL field has to be 0 so the iret instruction won't throw a #GP exeption when executed.
 * Offset	0..15		Offset 0..15	Lower part of the interrupt function's offset address (also known as pointer).
 *
 */
struct idt_entry_in_bits_field {
	unsigned idt_high_16_offset: 16;	//isr地址高16位 									48-63
	unsigned idt_present: 1;            //本条是否在用   									47
	unsigned idt_dpl: 2;                //段描述符的特权等级 								45-46
	unsigned idt_s: 1;                  //存储段 Set to 0 for interrupt and trap gates	44
	unsigned idt_type: 4;               //中断类型										40-43
	unsigned idt_unused: 8;             //unused，0										32-39
	unsigned idt_slector: 16;           //段描述符								16-31
	unsigned idt_lower_16_offset: 16;   //isr地址低16位									0-15
};

#define SET_IDTENTRY(gate,  isr_offset, idt_dpl, idt_is_trap, idt_slector){ \
		(gate).idt_high_16_offset = (isr_offset) >> 16;\
		(gate).idt_present = 1 ;\
		(gate).idt_dpl = (idt_dpl);\
		(gate).idt_s = 0;\
		(gate).idt_type = (idt_is_trap)?0xF : 0xE;\
		(gate).idt_unused = 0;\
		(gate).idt_slector = (idt_slector);\
		(gate).idt_lower_16_offset = (isr_offset) & 0xffff;\
}


struct gatedesc {
    unsigned gd_off_15_0 : 16;        // low 16 bits of offset in segment
    unsigned gd_ss : 16;            // segment selector
    unsigned gd_args : 5;            // # args, 0 for interrupt/trap gates
    unsigned gd_rsv1 : 3;            // reserved(should be zero I guess)
    unsigned gd_type : 4;            // type(STS_{TG,IG32,TG32})
    unsigned gd_s : 1;                // must be 0 (system)
    unsigned gd_dpl : 2;            // descriptor(meaning new) privilege level
    unsigned gd_p : 1;                // Present
    unsigned gd_off_31_16 : 16;        // high bits of offset in segment
 };


 #define SETGATE(gate, istrap, sel, off, dpl) {            \
    (gate).gd_off_15_0 = (uint32_t)(off) & 0xffff;        \
    (gate).gd_ss = (sel);                                \
    (gate).gd_args = 0;                                    \
    (gate).gd_rsv1 = 0;                                    \
    (gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;    \
    (gate).gd_s = 0;                                    \
    (gate).gd_dpl = (dpl);                                \
    (gate).gd_p = 1;                                    \
    (gate).gd_off_31_16 = (uint32_t)(off) >> 16;        \
}



static struct idt_entry_in_bits_field idt[256] = {{0}};
static struct pseudodesc d = {sizeof(idt)-1, idt};


void
init_idt(void){
	int i;
	extern uintptr_t __vectors[];
    
    for (i = 0; i < sizeof(idt) / sizeof(struct idt_entry_in_bits_field); i ++) {
        SET_IDTENTRY(idt[i], __vectors[i], DPL_KERNEL, 0, GD_KTEXT);
        // SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    // SETGATE(idt[T_SWITCH_TOK],  __vectors[T_SWITCH_TOK], GD_KTEXT, 0, DPL_USER);
	// load the IDT
    lidt(&d);
}