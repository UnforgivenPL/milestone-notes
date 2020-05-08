#!/bin/sh

echo "milestone-notes - (c) 2020 Unforgiven.pl - written by Miki Olsz - Apache 2.0 License"
set +o xtrace
ls -l
ruby ./milestone-notes.rb "$0" "$1" "$2" "$3" "$4"
