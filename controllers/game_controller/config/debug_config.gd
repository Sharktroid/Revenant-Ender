extends "res://controllers/game_controller/config/config.gd"

const UNIT_WAIT = &"unit_wait"
const DISPLAY_MAP_BORDERS = &"display_map_borders"
const DISPLAY_MAP_TERRAIN = &"display_map_terrain"
const DISPLAY_MAP_CURSOR = &"display_map_cursor"
const PRINT_INPUT_RECEIVER = &"print_input_receiver"
const SHOW_FPS = &"show_fps"


func _init() -> void:
	_config = {
		# Whether units are unable to move after movement.
		UNIT_WAIT: true,
		# Whether map borders are displayed
		DISPLAY_MAP_BORDERS: false,
		DISPLAY_MAP_TERRAIN: false,
		DISPLAY_MAP_CURSOR: false,
		PRINT_INPUT_RECEIVER: false,
		SHOW_FPS: false
	}
	super()
