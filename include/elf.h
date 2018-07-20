#ifndef __LIBS_ELF_H__
#define __LIBS_ELF_H__

#include <defs.h>

/* 读apue的时候，一直困惑的魔数 */
#define ELF_MAGIC    0x464C457FU            // "\x7FELF" in little endian

/* file header */
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

/* program section header */
struct elf_pro_hdr {
    uint32_t p_type;   // loadable code or data, dynamic linking info,etc.
    uint32_t p_offset; // file offset of segment
    uint32_t p_va;     // virtual address to map segment
    uint32_t p_pa;     // physical address, not used
    uint32_t p_filesz; // size of segment in file
    uint32_t p_memsz;  // size of segment in memory (bigger if contains bss）
    uint32_t p_flags;  // read/write/execute bits
    uint32_t p_align;  // required alignment, invariably hardware page size
};


/* section header table */
// struct elf_seg_hdr{
//     uint32_t sh_name;
//     uint32_t sh_type;
//     uint32_t sh_flags;
//     uint32_t sh_addr;
//     uint32_t sh_offset;
//     uint32_t sh_size;
//     uint32_t sh_link;
//     uint32_t sh_info;
//     uint32_t sh_addralign;
//     uint32_t sh_entsize;
// };

#endif /* !__LIBS_ELF_H__ */

