#!/bin/sh

# Testing add, commit, and show 

legit.pl init
echo line 1a >a
echo line 1b >b
legit.pl add a b
legit.pl commit -m message1
echo line 2a >>a
legit.pl add a
legit.pl commit -m message2
echo line 3a >>a
legit.pl add a
echo line 4a >>a
legit.pl show 0:a
legit.pl show 1:a
legit.pl show 2:a
legit.pl show :a
cat a

