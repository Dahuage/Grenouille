#! coding:utf8

def main():
    print(".text\n")
    print(".globl __alltraps")
    for i in range(256):
        print(".globl vector%d"%i)
        print("vector%d:"%i)
        if i < 8 or (i > 14 and i != 17): 
            print("  pushl \\$0")
        print("  pushl $%d"%i)
        print("  jmp __alltraps")
    
    print("")
    print("# vector table")
    print(".data")
    print(".globl __vectors")
    print("__vectors:")
    for i in range(256):
        print("  .long vector%d"%i)
    return 0;

if __name__ == '__main__':
	main()

