###### create a simple layout and save to gds file
set L [layout create]
$L create cell TOP
$L create layer 1
$L create layer 2.7
$L create polygon TOP 1 0 0 100 100
$L create polygon TOP 1 0 0 0 40 30 40 30 80 45 80 45 25 15 25 15 0
$L gdsout temp.gds

###### rename the cells in a gds layout then write out a new gds file
set infile [lindex $argv 0]
set outfile [lindex $argv 1]
set pname [lindex $argv 2]
set cell_list_file [lindex $argv 3]
if { [info exists infile ] != 1 || [info exists outfile] != 1 || [info exists pname] !=1 } {
    puts stderr "Usage: calibredrv $argv0 infile outfile prefix [cell_list]"
    exit 1
}
if { $cell_list_file != "" } {
    if {[catch {set cellfile [open ${cell_list_file} r]}]} {
        puts stderr "Error: Cannot open exclude cell list file for reading"
        exit 1
    }
    set exclude_cells [read $cellfile]
    close $cellfile
} else {
    set exclude_cells ""
}
# open the library gds
set L [layout create $infile -dt_expand]
set C [$L cells]
# rename
# if { [lsearch -exact $eclist $scell] < 0 } {
set i 1
set eclist [join $exclude_cells " "]
foreach scell $C {
    set ex 0
    foreach ec $eclist {
        if { [regexp $ec $scell] } {
            set ex 1
            continue
        }
    }
    if { $ex == 0 } {
        $L cellname $scell ${pname}_${i}
        incr i
    } else {
        puts "Note: $scell not changed"
    }
}
$L gdsout $outfile

