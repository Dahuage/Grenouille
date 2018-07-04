/*
 *
 * 现在我门开始从磁盘上读os到内存。先考虑以下几个问题
 * 1. 现在我们什么都没有，如何进行磁盘IO？
 * 2. 从磁盘上的什么位置开始读，写入内存的什么位置？
 * 3. os是以什么样的形式存在？
 * 4. 当完成以上步骤，如何打包bootloader为标准格式？
 */


#include <defs.h> //类型宏
#include <elf.h>  //elf结构声明
#include <x86.h>  //x86底层io

#define SECTSIZE    512
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

/* 忙等硬盘可读 */
static void
waitdisk(void) {
    //从端口0x1F7读入一个字节
    //并测试其就绪位
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}

/* 
 * 试着搞一个硬盘读写函数，参照ucore 
 * @para:addr内存地址
 * @para:secno扇区号
 */
static void
readsect(void *dst, uint32_t secno) {
    //等待磁盘就绪
    waitdisk();

    //要读写的扇区数量，1，交给0x1F2
    outb(0x1F2, 1);

    /*
     * 采用LBA28逻辑扇区编址方法。一个扇区地址由28位组成。
     * 扇区寻址范围为2^28扇区。硬盘大小=2^28*单扇区字节数
     * 以下4行，设置起始扇区号。扇区号28位，分4次进行。以
     * 8-8-8-4进行。
     */
    outb(0x1F3, secno & 0xFF);                
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    //高四位设置LBA模式,主硬盘,以及LBA地址 27～24
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);

    //请求读命令0x20发送给0x1F7
    outb(0x1F7, 0x20);                      

    //等待磁盘就绪
    waitdisk();

    /*
     * 0x1F0为磁盘的数据端口
     * 
     */
    insl(0x1F0, dst, SECTSIZE / 4);
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

/* 
 * 现在，我们开始试着写一个读内核文件指定位置，指定大小的函数
 * para@addr: 读到该内存位置
 * para@count:读的字节数
 * para@offset:从该位置开始读
 * 注意：读硬盘必须以扇区为单位
  */
static void
read_elf_header(uint32_t addr, uint32_t count, uint32_t offset){
    // 根据要读的长度count，确定内存区域的结束为止
    uint32_t addr_end = addr + count;
    // 如何offset不是整数个扇区，预留出多读部分的空间
    addr -= offset % SECTSIZE;
    // 将忽略字节转化为扇区，offset一定为正数，
    sector_no = (offset / SECTSIZE) + 1;
    while(addr < addr_end){
        readsect((uint8_t*)addr, sector_no);
        pa += SECTSIZE;
        offset++;
    }
}

/*
 * 问题3，os以什么格式存在---->elf,可执行&可链接文件
 * 该文件结构对可执行文件的结构有细致的描述，由elf文件
 * 我们可以得知该文件的大小，起始位置，数据段，代码段等
 * 基本的信息.
 * 更多关于elf文件的信息参见https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
 * 我们将以下两个结构整理到elf.h
 */



/* 现在可以从磁盘上讲elf header 读入内存 */
#define ELFHDR      ((struct elf_hdr *) 0x10000) // 就写在这里，爱谁谁。
void
main(void){
    struct elf_pro_hdr *ph, eph;
    //读系统镜像的elf头到0x10000／64kb处
    read_elf_header(ELFHDR, 512*8, 0);

    // 检查elf文件是否合法
    if (ELFHDR->e_magic != ELF_MAGIC)
        goto bad;

    // 将程序各个段读到指定位置
    // 第一个程序头段表指针
    ph = (struct elf_pro_hdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);

    // 最后一个程序头段表指针
    eph = ph + ELFHDR->e_phnum;

    while(ph<eph){
        read_elf_header(ph->p_pa, ph->p_memsz, ph->p_offset);
        ph++;
    }
    // 调起os的入口，永不返回
    ((void (*)(void)) (ELFHDR->e_entry))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);
    while (1)
}


