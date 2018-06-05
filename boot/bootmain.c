/*
 *
 * 现在我门开始从磁盘上读os到内存。先考虑以下几个问题
 * 1. 现在我们什么都没有，如何进行磁盘IO？
 * 2. 从磁盘上的什么位置开始读，写入内存的什么位置？
 * 3. os是以什么样的形式存在？
 * 4. 当完成以上步骤，如何封装bootloader为标准格式？
 */


/*
 * 先解决问题1，如何进行io
 * 汇编指令in port data/out data port指令进行io操作
 * 参考bsd，ucore及Linux的实现方法，我们将这些底层的io
 * 实现以内联汇编的形式，实现为c函数。关于内联汇编的详细
 * 信息，参见https://www.ibm.com/developerworks/cn/linux/sdk/assemble/inline/index.html
 * 在相当的时候，c并不能做到我们想要的一切。我们可以把像
 * 下面这些与硬件底层相关的代码统一放在一个头文件中。如下
 * 类型的底层代码我们将统一整理到i386.h.
 * 
 */

/* 从指定端口读取一个字节 */ 
static inline u_char
inb(u_int port)
{
	u_char	data;
	asm volatile("inb %w1, %0" : "=a" (data) : "Nd" (port));
	return (data);
}


/* 从指定端口中读取半字到指定内存位置 */
static inline void
insl(u_int port, void *addr, size_t count)
{
	asm volatile(
			 "cld; rep; insl"
			 : "+D" (addr), "+c" (count)
			 : "d" (port)
			 : "memory");
}

/* 硬盘可读？ */
static void
waitdisk(void) {
    //从端口0x1F7读入一个字节
    //并测试其就绪位
    //参见
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}


/* 
 * 试着搞一个硬盘读写函数，参照ucore 
 * @para:addr内存地址
 * @para:secno扇区号
 */
 static void
 read_sector(u_int *addr, u_int secno){
    /* 确保硬盘可读 */
    waitdisk();

    
 }



/*
 * 问题2从读什么？从哪儿读，读多少，读到内存中的什么位置。
 * 读内核的meta data即elf文件的header及elf的program header
 * 从磁盘的第2个扇区1号扇区开始读，第一个扇区0号扇区存储本文件
 * 读一个扇区
 * 读入到0x10000，64kB处
 * 
 * 硬盘的分布
 * 0号山区：按特殊格式封装的512字节的bootloader
 * 1号扇区：os img的开始。os img以 elf header 开始
 * ***************************************************
 * 注意：
 * 实际上，我们忽略了mbr---硬盘主引导记录及其他一些可能的启动过程
 * 如下在free bsd 中。mbr启动经过了以下过程。
 * bios-->load mbr[0扇区]
 * mbr -->load bootloader_1[1扇区]
 * .......
 * bootloader_n --> load os img[n扇区]
 * mbr被加载到0x7c00后，重新定位自己。将bootloader加载到0x7c00
 * bootloader可能再重新定位自己，把其他程序加载到0x7c00，也可能
 * 直接加载内核镜像
 * 硬盘分布
 * 0号扇区：mbr
 * 1号扇区：bootloader
 * 2号扇区：bootloader2   #in free bsd
 * 3号扇区：Boot Extender #in free bsd
 * 4号扇区：os img
 */

/* 现在，我们开始试着写一个读内核镜像elf header的函数 */
static void
read_elf_header(u_int addr, u_int count, u_int offset){
    u_int addr_end = addr + count;

} 

/*
 * 问题3，os以什么格式存在---->elf,可执行&可链接文件
 * 该文件结构对可执行文件的结构有细致的描述，由elf文件
 * 我们可以得知该文件的大小，起始位置，数据段，代码段等
 * 基本的信息.
 * 更多关于elf文件的信息参见https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
 */

/* 正如apue所述，可执行文件有个魔数 */
#define		ELF_MAGIC	0x464C457FU // "\x7FELF" in little endian
struct elf_hdr {
	uint32_t e_magic;     // must equal ELF_MAGIC
    uint8_t e_elf[12];
    uint16_t e_type;      // 1=relocatable, 2=executable, 3=shared object, 4=core image
    uint16_t e_machine;   // 3=x86, 4=68K, etc.
    uint32_t e_version;   // file version, always 1
    uint32_t e_entry;     // entry point if executable
    uint32_t e_phoff;     // file position of program header or 0
    uint32_t e_shoff;     // file position of section header or 0
    uint32_t e_flags;     // architecture-specific flags, usually 0
    uint16_t e_ehsize;    // size of this elf header
    uint16_t e_phentsize; // size of an entry in program header
    uint16_t e_phnum;     // number of entries in program header or 0
    uint16_t e_shentsize; // size of an entry in section header
    uint16_t e_shnum;     // number of entries in section header or 0
    uint16_t e_shstrndx;  // section number that contains section name strings
};

struct elf_pro_hdr {
	uint32_t p_type;   // loadable code or data, dynamic linking info,etc.
    uint32_t p_offset; // file offset of segment
    uint32_t p_va;     // virtual address to map segment
    uint32_t p_pa;     // physical address, not used
    uint32_t p_filesz; // size of segment in file
    uint32_t p_memsz;  // size of segment in memory (bigger if contains bss）
    uint32_t p_flags;  // read/write/execute bits
    uint32_t p_align;  // required alignment, invariably hardware page size
}

struct elf_seg_hdr{

}
/* 现在可以从磁盘上讲elf header 读入内存 */



