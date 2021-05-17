#!/bin/sh

exe=$3
if [ "$exe" = "" ]; then
    exe=tkdiff
fi

sort $1 > /tmp/diff1.sorted
sort $2 > /tmp/diff2.sorted

#filemerge -r -w /tmp/diff1.sorted /tmp/diff2.sorted
$exe /tmp/diff1.sorted /tmp/diff2.sorted

rm -f /tmp/diff1.sorted /tmp/diff2.sorted

