#!/bin/sh

echo "milestone-notes - (c) 2020 Unforgiven.pl - written by Miki Olsz - Apache 2.0 License"
set -x
ls -l /
ruby /milestone-notes.rb "$0" "$1" "$2" "$3" "$4"
