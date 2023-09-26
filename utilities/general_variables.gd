@tool
extends Node

const adjacent_tiles: Array[Vector2i] = [Vector2i(16, 0), Vector2i(-16, 0),
	Vector2i(0, 16), Vector2i(0, -16)]
var theme: Theme = load("uid://5iql263qnldx")
@onready var font_yellow: String = theme.get_color("font_color", "YellowLabel").to_html()
@onready var font_blue: String = theme.get_color("font_color", "BlueLabel").to_html()

var _frame_delta: float
var _debug_constants: Dictionary = { # Constants used in the debug menu.
	unit_wait = true, # Whether units are unable to move after movement.
	display_map_borders = false, # Whether map borders are displayed
	display_map_terrain = false,
	display_map_cursor = false,
}
var _config_file := ConfigFile.new() # File used for saving and loading of configuration settings.
var _default_screen_size: Vector2i


func _ready() -> void:
	_load_config()
	var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	_default_screen_size = Vector2i(width, height)


func _exit_tree() -> void:
	save_config()


func _process(delta: float) -> void:
	_frame_delta = delta


func get_screen_size() -> Vector2i:
	return _default_screen_size


func save_config() -> void:
	# Saves configuration.
	for constant in _debug_constants:
		_config_file.set_value("Debug", constant, get_debug_constant(constant))
	# warning-ignore:return_value_discarded
	_config_file.save("user://config.ini")


func get_debug_constant(constant: String):
	return _debug_constants[constant]


func set_debug_constant(constant: String, value) -> void:
	_debug_constants[constant] = value
	save_config()


## Gets the amount of time that has elapsed since the previous frame.
func get_frame_delta() -> float:
	return _frame_delta


func invert_debug_constant(constant: String) -> void:
	set_debug_constant(constant, not(get_debug_constant(constant)))


func _load_config() -> void:
	# Loads configuration
	_config_file.load("user://config.ini")
	for constant in _debug_constants:
		var new_constant = get_debug_constant(constant)
		_debug_constants[constant] = _config_file.get_value("Debug", constant, new_constant)
