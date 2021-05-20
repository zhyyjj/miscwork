#!/bin/sh
# usage: $0 <oas_file> [0|1]
# [0|1]: 0 generates simple report; 1 generates more detailed report with instance numbers

mode=0
if [ "$2" != "" ]; then
    mode=$2
fi

sedcmd="s?^foreach.*?set L [layout create $1]; dump_hier \$L \$fileID [\$L topcell] $mode \"\"?"
sed -e "$sedcmd" /import/pa-tools/FLOW/CDN/icf/latest/utilities/calibredrv.layout.hier.tcl > temp.tcl

calibredrv temp.tcl
