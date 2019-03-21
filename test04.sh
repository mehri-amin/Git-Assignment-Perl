#!/bin/sh

legit.pl init
touch a
echo line 1 >>a
legit.pl add a
legit.pl commit -m message0
#file is same in index and snap
legit.pl commit -m message1
# file is different in index and snap
echo line 2 >>a
legit.pl add a
legit.pl commit -m message2
# file does not exist in snap but in index
touch b
legit.pl add a
legit.pl commit -m message3
legit.pl show 0:a
legit.pl show 1:a
legit.pl show 2:b
