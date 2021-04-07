#!/usr/bin/python3

score = input("Enter Score: ")
pr = ''

score = float(score)

if score <= 1.0 and score >= 0.0:
    if score >= 0.9:
        pr = 'A'
    elif score >= 0.8:
        pr = 'B'
    elif score >= 0.7:
        pr = 'C'
    elif score >= 0.6:
        pr = 'D'
    elif score < 0.6:
        pr = 'F'
else:
    pr = 'Esto no es algo valido bb'

print(pr)
