#!/usr/bin/python3

fname = input('Enter a file name:')

fhand = open(fname)

count = 0
numero = 0
numero = float(numero)

for line in fhand:
    if line.startswith('X-DSPAM-Confidence:'):
        count = count + 1
        lugar = line.find(':') + 1
        num = line[lugar:]
        num = float(num)
        numero = numero + num
result = numero / count
print('Average spam confidence:',result)
