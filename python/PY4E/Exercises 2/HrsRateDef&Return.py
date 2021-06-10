#!/usr/bin/python3

hrs = input("Enter Hours:")
rate = input("Enter Rate:")

def computepay(h,r):
    pay = (40 * rate)
    extra = h - 40
    extra = extra * (r * 1.5)
    pay = pay + extra
    return pay

hrs = float(hrs)
rate = float(rate)

if hrs > 40 :
    print('Pay',computepay(hrs,rate))
else:
    pay = hrs * rate
    print('Pay',pay)
