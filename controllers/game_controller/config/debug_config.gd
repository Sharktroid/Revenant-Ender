## A [Node] that stores debugging settings
extends Node

#gdlint: disable = class-variable-name
## Whether units are unable to move after movement.
var UNIT_WAIT := BooleanOption.new(&"unit_wait", &"debug", true)
## Whether map borders are displayed
var DISPLAY_MAP_BORDERS := BooleanOption.new(&"display_map_borders", &"debug", false)
## Whether a terrain overlay is rendered
var DISPLAY_MAP_TERRAIN := BooleanOption.new(&"display_map_terrain", &"debug", false)
## Whether a box representing the cursor's position is rendered
var DISPLAY_MAP_CURSOR := BooleanOption.new(&"display_map_cursor", &"debug", false)
## Whether the input receiver is printed in the standard output
var PRINT_INPUT_RECEIVER := BooleanOption.new(&"print_input_receiver", &"debug", false)
## Whether the frame rate is displayed
var SHOW_FPS := BooleanOption.new(&"show_fps", &"debug", false)
#gdlint: enable = class-variable-name
