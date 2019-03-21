#!/bin/sh

legit.pl init
legit.pl log
legit.pl show 0:a
echo line 1 >>a
legit.pl add a
legit.pl commit -m message0
legit.pl log
legit.pl show 0:a
legit.pl init
legit.pl add b
touch b
legit.pl add b
legit.pl commit -m message1
echo line 2 >>b
echo line 2 >>a
legit.pl add a b
legit.pl commit -m message2
legit.pl show 2:a

