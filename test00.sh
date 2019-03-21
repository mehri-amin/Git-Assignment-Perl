#!/bin/sh
# Check all error messages are correctly outputted.

legit.pl
legit.pl not_a_git_command
legit.pl init another_arguement
legit.pl init
legit.pl init
touch a
legit.pl add b
legit.pl add a
legit.pl log
legit.pl commit
legit.pl commit -m "message 1"
legit.pl log
legit.pl show
legit.pl show not_correct_
echo line1>>a
legit.pl add a
legit.pl commit -m "message 2"
legit.pl show a:1
legit.pl log
legit.pl show a:2
echo line2>>a
legit.pl add a
legit.pl show a:
