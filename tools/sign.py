#coding:utf8

import sys
import os 
from io import BytesIO

def main():
	boot_block_path = sys.argv[1]
	stat = os.stat(boot_block_path)
	print("boot_block_size:%d"%stat.st_size)
	if stat.st_size > 510:
		print("boot block cat not greater than 510B")
		return -1
	buf = BytesIO()
	with open(boot_block_path, 'rb') as f:
		buf.write(f.read())
	buf.seek(510)
	# buf.write((0x55).to_bytes(length=1, byteorder='big'))
	# buf.seek(511)
	# buf.write((0xAA).to_bytes(length=1, byteorder='big'))
	buf.write(bytes([0x55, 0xAA]))
	with open(boot_block_path, 'wb') as f:
		f.seek(0)
		f.write(buf.getvalue())
	return 0

if __name__ == '__main__':
	main()




