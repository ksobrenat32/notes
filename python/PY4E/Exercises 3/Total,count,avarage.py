#!/usr/bin/python3
anterior = 0
promedio = 0
count = 0
while True:
    line = input('Enter a number: ')

    if line == 'done':
        print('total:',anterior)
        print('count:',count)
        print('avarage',promedio)
        break

    try:
        line = float(line)
        anterior = anterior + line
        count = count + 1
        promedio = anterior / count
    except:
        print('No mama, un numero porfavor')
