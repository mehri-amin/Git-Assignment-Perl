#!/bin/sh

# Testing Commit
# without -m message
# incorrect flag
# normal commit
# commit but with no files changed
legit.pl init
touch a
touch b
legit.pl add a b
legit.pl commit
legit.pl commit -m
legit.pl commit -l message
legit.pl commit -m message
legit.pl commit -m message2

