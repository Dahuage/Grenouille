#coding:utf8

import sys
import os 
from io import BytesIO

def main():
	boot_block_path = sys.argv[1]
	formatted_boot = sys.argv[2]
	stat = os.stat(boot_block_path)
	if stat.stat_size > 510:
		printf("boot block cat not greater than 510B")
		return -1
	buf = BytesIO()
	with open(boot_block_path, 'r+') as f:
		buf.write(f.read())
	buf.seek(510)
	buf.write(0x55)
	buf.seek(511)
	buf.write(0xAA)
	with open(formatted_boot, 'wb+') as f:
		f.write(buf.read())
	return 0

if __name__ == '__main__':
	main()




