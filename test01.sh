#!/bin/sh

# Tests what shows does when a non-existing commit is input
# Tests to see if show and log work accordingly
# Tests to see if commit omitted prints file from index

legit.pl init
touch a
touch b
legit.pl add a b
legit.pl commit -m message1
echo line 1 >>a
echo line 2 >>a
echo line 1 >b
legit.pl add a b
legit.pl commit -m message2
echo line 1 >a
echo line 3 >>a
echo line 2 >>b
legit.pl add a b
legit.pl commit -m message3
echo line 4 >>a
echo line 5 >>a
echo line 3 >b
legit.pl add a b
legit.pl commit -m message4
echo line 6 >>a
echo line 7 >>a
echo line 4 >>b
legit.pl add a b
legit.pl commit -m message5
legit.pl log
legit.pl show 6:b
legit.pl show 4:b
legit.pl show :b
