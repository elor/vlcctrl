#!/usr/bin/env python

import os
import argparse
import subprocess
from time import sleep

def handleInput(line, control):
	control.write(line)

def daemon(pipe):
	DEVNULL=open(os.devnull, 'wb')
	vlc = subprocess.Popen(['vlc', '-I', 'rc', '--extraintf', 'http'], stdin=subprocess.PIPE, stdout=DEVNULL, stderr=DEVNULL)

	pipe = open(pipe, 'r')

	while vlc.poll() == None:
		handleInput(pipe.readline(), vlc.stdin)

def main():
	parser = argparse.ArgumentParser(description="tool for background vlc player control in an embedded invironment")
	parser.add_argument('--pipe', '-p', help='communicate through this file', default='pipe.fifo')

	args=parser.parse_args()

	daemon(args.pipe)


if __name__ == "__main__":
	main()
