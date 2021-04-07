#!/usr/bin/python3
str = 'X-DSPAM-Confidence:0.8475'

colon_num = str.find(':') + 1

prnt = str[colon_num:]
flt = float(prnt)

print(flt)
