#!/usr/bin/python3

fname = input('Enter a file name:')

fhand = open(fname)

for line in fhand:
    up = line.upper()
    print(up.rstrip())
