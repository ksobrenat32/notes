#!/usr/bin/python3
paro = input('¿En que número paramos?')

try:
    paro = float(paro)
except:
    print('Introduce un número')
    exit()

func0 = 0
func1 = 1
func2 = 0

while func0 < paro:
    print(func0)
    if func1 > paro:
        break
    func2 = func0 + func1
    print(func1)
    if func2 > paro:
        break
    func0 = func1 + func2
    print(func2)
    func1 = func0 + func2
