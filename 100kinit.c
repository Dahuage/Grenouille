#include <000defs.h>
#include <002x86.h>
#include <102mmu.h>
#include <101memlayout.h>
#include <203console.h>

#include <stdio.h>


void kernel_init(void) __attribute__((noreturn));

void
kernel_init(void){
	cons_init();
	char *message = "I worked my ass off to figure out this\n";
	cprintf(message);
	while(1);
}

__attribute__((__aligned__(PGSIZE)))
uintptr_t entrypgdir[NPDENTRIES] = {
  // Map VA's [0, 4MB) to PA's [0, 4MB)
  [0] = (0) | PTE_P | PTE_W | PTE_PS,
  // Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
  [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS,
};
// PTE_PS == 0x80 && CR4.PSE == 1
// entrypgdir直接映射到一个4m的地址空间而不是映射到一个页表
/*
						Table 4-4. 
Format of a 32-Bit Page-Directory Entry that Maps a 4-MByte Page
================================================================
PAGING
Bit Position(s)					Contents
--------------------------------------------------------------------
0 (P)				Present; must be 1 to map a 4-MByte page
--------------------------------------------------------------------
1 (R/W)				Read/write; if 0, writes may not be allowed
					to the 4-MByte page referenced by this entry
					(see Section 4.6)
--------------------------------------------------------------------
2 (U/S)				User/supervisor; if 0, user-mode accesses 
					are not allowed to the 4-MByte page referenced
					by this entry (see Section 4.6)
--------------------------------------------------------------------
3 (PWT)				Page-level write-through; indirectly determines
					the memory type used to access the 4-MByte page
					referenced by this entry (see Section 4.9
--------------------------------------------------------------------
4 (PCD)				Page-level cache disable; indirectly determines
					the memory type used to access the 4-MByte page
					referenced by this entry (see Section 4.9)
--------------------------------------------------------------------
5 (A)				Accessed; indicates whether software has accessed
					the 4-MByte page referenced by this entry (see Section 4.8)
--------------------------------------------------------------------
6 (D)				Dirty; indicates whether software has written
					to the 4-MByte page referenced by this entry 
					(see Section 4.8)
--------------------------------------------------------------------
7 (PS)				Page size; must be 1 (otherwise, this entry
					references a page table; see Table 4-5)
--------------------------------------------------------------------
8 (G)				Global; if CR4.PGE = 1, determines whether 
					the translation is global (see Section 4.10);
					ignored otherwise
--------------------------------------------------------------------
11:9				Ignored
--------------------------------------------------------------------
12 (PAT)			If the PAT is supported, indirectly determines
					the memory type used to access the 4-MByte page
					referenced by this entry (see Section 4.9.2);
					otherwise, reserved (must be 0)1
--------------------------------------------------------------------
(M–20):13			Bits (M–1):32 of physical address of the 4-MByte
					page referenced by this entry2
--------------------------------------------------------------------
21:(M–19)			Reserved (must be 0)
--------------------------------------------------------------------
31:22				Bits 31:22 of physical address of the 4-MByte 
					page referenced by this entry
--------------------------------------------------------------------
NOTES:
1. See Section 4.1.4 for how to determine whether the PAT is supported.
2. If the PSE-36 mechanism is not supported, M is 32, and this row does 
   not apply. If the PSE-36 mechanism is supported, M is the min-imum 
   of 40 and MAXPHYADDR (this row does not apply if MAXPHYADDR = 32).
   See Section 4.1.4 for how to determine MAXPHYA- DDR and whether the
   PSE-36 mechanism is supported.
--------------------------------------------------------------------


								Table 4-5. 
Format of a 32-Bit Page-Directory Entry that References a Page Table
====================================================================
Bit Position(s)       					Contents
0 (P)                 Present; must be 1 to reference a page table
--------------------------------------------------------------------
1 (R/W)				  Read/write; if 0, writes may not be allowed 
					  to the 4-MByte region controlled by this entry
					  (see Section 4.6)
--------------------------------------------------------------------				  
2 (U/S)				  User/supervisor; if 0, user-mode accesses are 
					  not allowed to the 4-MByte region controlled by
					  this entry (see Section 4.6)
--------------------------------------------------------------------					  
3 (PWT)				  Page-level write-through; indirectly determines
					  the memory type used to access the page table 
					  referenced by this entry (see Section 4.9)
--------------------------------------------------------------------
4 (PCD)				  Page-level cache disable; indirectly determines
					  the memory type used to access the page table 
					  referenced by this entry (see Section 4.9)
--------------------------------------------------------------------
5 (A)				  Accessed; indicates whether this entry has been 
					  used for linear-address translation (see Section 4.8)
--------------------------------------------------------------------
6					  Ignored
--------------------------------------------------------------------
7 (PS)				  If CR4.PSE = 1, must be 0 (otherwise, this entry 
					  maps a 4-MByte page; see Table 4-4); otherwise, ignored
--------------------------------------------------------------------
11:8				  Ignored
--------------------------------------------------------------------
31:12				  Physical address of 4-KByte aligned page table 
					 referenced by this entry
--------------------------------------------------------------------

*/