#include <000defs.h>
#include <002x86.h>

/**
 * $ dmesg
 * [    0.000000] e820: BIOS-provided physical RAM map:
 * #forum_pre 16g 
 * [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009dfff] usable
 * [    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reserved
 * [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved* 
 * [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000efffffff] usable
 * [    0.000000] BIOS-e820: [mem 0x00000000fc000000-0x00000000ffffffff] reserved
 * [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000040fffffff] usable
 *
 *  #cmx 2g 
 *  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 *  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 *  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 *  BIOS-e820: 0000000000100000 - 000000007ffe0000 (usable)
 *  BIOS-e820: 000000007ffe0000 - 0000000080000000 (reserved)
 *  BIOS-e820: 00000000feffc000 - 00000000ff000000 (reserved)
 *  BIOS-e820: 00000000fffc0000 - 0000000100000000 (reserved)
 */


/*
 * 撸一个链表
 */


//需要一个表示一块内存的东西，内存以页框为单位
struct Page {};

// 搞一个管理器对象
struct physical_mem_manager {

};

// 初始化无力内存管理
void init_physical_mem_manager(void);

// 探测物理地址大小 
void detect_physical_mem_size(void);
// 初始化页表
void init_page(void);
// 做映射
void __make_map(void);
// 将已分配内存做映射
void map_used_mem(void);
// 分配内存
void alloc_mem(void);
// 释放内存
void free_mem(void);
