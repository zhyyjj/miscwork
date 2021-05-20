####################################################################################
###### Flyline checking utilities to check the connnectivities in Innovus database
####################################################################################

namespace eval flyline {
    variable inst_name ""
    variable inst_names ""
    variable iopins_list ""
    variable iopin_index 0
    variable current_pins ""
    variable current_pins_bit_index -1
}

proc bit_blast_simple {name} {
    set expanded_names {}

    if [regexp {(\S+)([_\[])(\d+)\s*:\s*(\d+)\s*(.*)([_\]])} $name -> base pre start end rest post] {
        if [regexp {:\s*([-\d]+)} $rest -> step] {
            set step [expr ($start <= $end) ? abs($step) : -abs($step)]
        } else {
            set step [expr ($start <= $end) ? 1 : -1]
        }
        set i $start
        while {$step>0 && $i<=$end || $step<0 && $i>=$end} {
            lappend expanded_names $base$pre$i$post
            incr i $step
        }
    } else {
        set expanded_names $name
    }

    return [join $expanded_names]
}

proc read_pinspec {pinfile inst} {
    set flyline::inst_name $inst
    set flyline::inst_names [get_db insts .name $inst]
    set flyline::iopins_list ""
    set flyline::iopin_index 0

    # initialize iopins_list, iopin_index
    set fp [open $pinfile r]
    set start 0
    while {[gets $fp line] >=0} {
        if [regexp {^\s*//} $line] { continue }
        if [regexp {^\s*$}  $line] { continue }
        if [regexp {^\s*#}  $line] { continue }
        if [regexp {dummy}  $line] { continue }
        if [regexp {^module} $line] { continue }
        if [regexp {^endmodule} $line] { continue }
        if [regexp {^\s*(input|output|inout)} $line] {set start 1 }
        if {$start == 0} { continue }

        if {[regexp {^\s*(input|output|inout)\s+(\S+)\s+(\w+)\s*;} $line -> direction bus pin_name]} {
            lappend flyline::iopins_list $pin_name$bus
        } elseif {[regexp {^\s*(input|output|inout)\s+(.*)} $line -> direction pin_name]} {
            while { ![regexp {;\s*$} $line] } {
                gets $fp line
                append pin_name $line
            }
            set pin_names [join [split $pin_name ", ;"]]
            lappend flyline::iopins_list {*}$pin_names
        } else {
            puts "ERROR: wrong syntax: $line, in pinSpec file"
        }
    }

    # save iopins_list in sorted order, and printout the status/information
    set flyline::iopins_list [join [lsort -dictionary $flyline::iopins_list]]
    infopp
    highlight_current_pin [lindex $flyline::iopins_list 0]
}

# pin-by-pin traverse through the iopins_list, initialize current_pins and select/highlight it.
gui_bind_key n -cmd ppn
gui_bind_key p -cmd ppp
alias ppp {ppn -1}
proc ppn {{args ""} } {
    if {$args == ""} {
        # goto next pin of iopins_list
        incr flyline::iopin_index

    } elseif {$args == -1} {
        # goto prev pin of iopins_list
        incr flyline::iopin_index -1

    } elseif [regexp {^\d+$} $args] {
        # iopin_index = args
        set flyline::iopin_index $args

    } else {
        # treat args as a regexp pattern
        set found [lsearch -all $flyline::iopins_list $args]
        if {$found != ""} {
            puts "INFO: found following pins:"
            foreach i $found { puts "$i:  [lindex $flyline::iopins_list $i]" }
            set flyline::iopin_index [lindex $found 0]
        } else {
            puts "INFO: $args does not match any pins." 
        }
    }

    set current_pin [lindex $flyline::iopins_list $flyline::iopin_index]
    highlight_current_pin $current_pin
}

proc highlight_current_pin {current_pin} {
    set flyline::current_pins [bit_blast_simple $current_pin]
    set flyline::current_pins_bit_index -1

    set pins {}
    foreach inst $flyline::inst_names {
        foreach p $flyline::current_pins {
            lappend pins pin:$inst/$p
        }
    }

    set nets      [get_db $pins .net -u]
    set direction [get_db $pins .direction -u]

    puts "INFO: highlighting: $flyline::inst_name/$current_pin direction:($direction) net_name:([get_db $nets .name])"
    # gui_deselect -all
    # select_obj $pins
    gui_clear_highlight -all
    gui_highlight $nets -color red
}

# bit-by-bit traverse through the current_pins.
gui_bind_key Shift-F -cmd bbn
gui_bind_key b -cmd bbp
alias bbp {bbn -1}
proc bbn {{args ""} } {
    if {$args == ""} {
        incr flyline::current_pins_bit_index

    } elseif {$args == -1} {
        incr flyline::current_pins_bit_index -1

    } elseif [regexp {^\d+$} $args] {
        set flyline::current_pins_bit_index $args

    } else {
        puts "ERROR: $args needs to be an integer." 
    }

    set pins {}
    set current_pin_bit [lindex $flyline::current_pins $flyline::current_pins_bit_index]
    foreach inst $flyline::inst_names {
        if {$current_pin_bit == ""} { continue }
        lappend pins pin:$inst/$current_pin_bit
    }

    puts "INFO: net of pin: $flyline::inst_name/$current_pin_bit selected"
    gui_deselect -all
    select_obj [get_db $pins .net -u]
}

# printout current status/information
proc infopp {} {
    set i 0
    foreach pins $flyline::iopins_list {
        puts "$i:  $pins"
        incr i
    }
    puts "Current index is at: $flyline::iopin_index"
}
proc infobb {} {
    set i 0
    foreach pins $flyline::current_pins {
        puts "$i:  $pins"
        incr i
    }
    puts "Current bit index is at: $flyline::current_pins_bit_index"
}
