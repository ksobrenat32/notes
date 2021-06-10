#!/usr/bin/python3

def counter(word,letter):
    count = 0
    for letra in word:
        if letra == (letter):
            count = count + 1
    print('The letter',letter,'appears',count,'times','in',word)
print('If you give a word and a letter I will tell you how many times the lettter appears in that word c:')
word = input('Write a word: ')
letter = input('Write a letter: ')

counter(word,letter)
