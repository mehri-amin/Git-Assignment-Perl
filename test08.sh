#!/bin/sh

# Init, add multiple files, commit, log, show files from different commits

legit.pl init
touch a b c d e f g h
legit.pl add a b c d e f
legit.pl commit -m message1
echo hello >a
legit.pl add a
legit.pl commit -m message2
legit.pl log
legit.pl show 0:a
legit.pl show 1:a
legit.pl show 0:b
legit.pl show 1:b
legit.pl show 0:g
legit.pl show 1:g

