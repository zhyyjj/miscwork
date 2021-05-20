#
# goto/zmto

proc goto {x y {unit ""} } {
  if {[regexp {^nm$} $unit] } {
    set unit 1000.0
  } elseif {[regexp {^um$} $unit] } {
    set unit 1.0
  } elseif { [regexp {\.} $x] || [regexp {\.} $y] } {
    set unit 1.0
  } else {
    set unit 1000.0
  }

  set x [ expr { $x / $unit } ]
  set y [ expr { $y / $unit } ]
  set x1 [ expr { $x-0.5 } ]
  set x2 [ expr { $x+0.5 } ]
  set y1 [ expr { $y-0.5 } ]
  set y2 [ expr { $y+0.5 } ]

## draw rulers
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start RulerTool
   gui_set_mouse_tool_option -tool RulerTool -option {Mode} -value {Two point}
   gui_set_mouse_tool_option -tool RulerTool -option {Snapping} -value {Min Grid}
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$x1 $y"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$x2 $y"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$x $y1"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$x $y2"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
## zoom to it
   gui_zoom -window [gui_get_current_window -view] -rect "{$x1 $y1} {$x2 $y2}" -fit
}

proc zmto {llx lly urx ury {unit ""} } {
  if {[regexp {^nm$} $unit] } {
    set unit 1000.0
  } elseif {[regexp {^um$} $unit] } {
    set unit 1.0
  } elseif { [regexp {\.} $llx] || [regexp {\.} $lly] || [regexp {\.} $urx] || [regexp {\.} $ury] } {
    set unit 1.0
  } else {
    set unit 1000.0
  }

   set llx [ expr { $llx / $unit } ]
   set lly [ expr { $lly / $unit } ]
   set urx [ expr { $urx / $unit } ]
   set ury [ expr { $ury / $unit } ]

#    puts "$llx\n$lly\n $urx\n $ury\n"
## draw rulers
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start RulerTool
   gui_set_mouse_tool_option -tool RulerTool -option {Mode} -value {Multi point}
   gui_set_mouse_tool_option -tool RulerTool -option {TickLabel} -value {Segment Distance}
   gui_set_mouse_tool_option -tool RulerTool -option {Snapping} -value {Min Grid}
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$llx $lly"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$urx $lly"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$urx $ury"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$llx $ury"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -add_point "$llx $lly"
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -apply
   gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
## zoom to it
   gui_zoom -window [gui_get_current_window -view] -rect "{$llx $lly} {$urx $ury}" -fit
}
