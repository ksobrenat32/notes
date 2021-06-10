#!/usr/bin/python3
word = input('Write a word: ')
largo = len(word)

while largo > 0:
    letter = word[largo-1]
    print(letter)
    largo = largo - 1
