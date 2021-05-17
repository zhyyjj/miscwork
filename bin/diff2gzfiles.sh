#!/bin/sh

exe=$3
if [ "$exe" = "" ]; then
    exe=tkdiff
fi

cp -f $1 /tmp/diff1.gz
cp -f $2 /tmp/diff2.gz
rm -f /tmp/diff1 /tmp/diff2

sort=$4
if [ "$sort" = "sort" ]; then
    gunzip -c /tmp/diff1.gz | sort > /tmp/diff1
    gunzip -c /tmp/diff2.gz | sort > /tmp/diff2
else
    gunzip /tmp/diff1.gz
    gunzip /tmp/diff2.gz
fi


$exe /tmp/diff1 /tmp/diff2

rm -f /tmp/diff1* /tmp/diff2*

