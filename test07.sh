#!/bin/sh
# Test show command argumenets
legit.pl init
echo line 1 >>a
legit.pl add a
legit.pl show 0:a
legit.pl commit -m message1
legit.pl show 0:abc
legit.pl show :abc
legit.pl show 0:a
echo line 2 >>a
legit.pl add a
legit.pl show :a
