## A [Config] that stores debugging settings
extends Config

## Whether units are unable to move after movement.
const UNIT_WAIT: StringName = &"unit_wait"
## Whether map borders are displayed
const DISPLAY_MAP_BORDERS: StringName = &"display_map_borders"
## Whether a terrain overlay is rendered
const DISPLAY_MAP_TERRAIN: StringName = &"display_map_terrain"
## Whether a box representing the cursor's position is rendered
const DISPLAY_MAP_CURSOR: StringName = &"display_map_cursor"
## Whether the input receiver is printed in the standard output
const PRINT_INPUT_RECEIVER: StringName = &"print_input_receiver"
## Whether the frame rate is displayed
const SHOW_FPS: StringName = &"show_fps"


func _init() -> void:
	_config = {
		UNIT_WAIT: true,
		DISPLAY_MAP_BORDERS: false,
		DISPLAY_MAP_TERRAIN: false,
		DISPLAY_MAP_CURSOR: false,
		PRINT_INPUT_RECEIVER: false,
		SHOW_FPS: false
	}
	_category = "Debug"
	super()
