#!/usr/bin/python3

hrs = input("Enter Hours:")
rate = input("Enter Rate:")

hrs = float(hrs)
rate = float(rate)

if hrs > 40 :
    pay = (40 * rate)
    extra = hrs - 40
    extra = extra * (rate * 1.5)
    pay = pay + extra
else:
    pay = hrs * rate


print(pay)
