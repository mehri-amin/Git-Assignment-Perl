#!/bin/sh

# Test to see what happens if legit is not initialized
touch a
legit.pl add a
legit.pl commit -m message
legit.pl log
legit.pl show 0:a

