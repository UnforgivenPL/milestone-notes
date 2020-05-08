#!/bin/sh

echo "milestone-notes - (c) 2020 Unforgiven.pl - written by Miki Olsz - Apache 2.0 License"
set -o xtrace
pwd
dir
dir /

ruby milestone-notes.rb $*

set +o xtrace