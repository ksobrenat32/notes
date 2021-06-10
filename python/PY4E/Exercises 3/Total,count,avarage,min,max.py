#!/usr/bin/python3

anterior = 0
promedio = 0
count = 0
minValue = None
maxValue = None

while True:
    line = input('Enter a number: ')

    if line == 'done':
        print('total:',anterior)
        print('count:',count)
        print('Minimum Value:',minValue)
        print('Maximum Value:',maxValue)
        break

    try:
        line = float(line)
        anterior = anterior + line
        count = count + 1

        if minValue is None or minValue < line:
            minValue = line

        if maxValue is None or maxValue > line:
            maxValue = line

    except:
        print('No mama, un numero porfavor')
