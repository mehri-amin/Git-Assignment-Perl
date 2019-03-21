#!/bin/sh

# Test initialize 

legit.pl init l
legit.pl init 
legit.pl init

# Test add of files that dont exist in cd
legit.pl add a
touch a
touch b
touch c
# can add multiple files
legit.pl add a b c
# files that contain '-'
touch c-
legit.pl add c-
#files that start with with non-alphanumeric character
touch _file
legit.pl add _file
